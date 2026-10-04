#!/usr/bin/env node
// The agent's hands and eyes: sends /agent commands to the Factorio server over RCON.
//
//   node a.js <op> [key=value ...] [+ <op> key=value ...]   several ops in one connection
//   node a.js <op> '{"json": "arguments"}'
//   node a.js <op> @file.json [key=value ...]               arguments from a file (merged)
//   node a.js raw server-save                                any console command (slash optional)
//
// Values: numbers and true/false are converted, [..] and {..} are JSON, `names`, `types`, `add`
// and `set` split on commas. Long arguments are uploaded in parts (the `_buf` op).
// Ops: status inv look scan entities factory prod recipe tech proto | place ghost blueprint
// build_ghosts clear cancel_clear remove rotate set_recipe insert take collect fuel feed craft
// craft_cancel walk mine stop research speed pause note eval respawn
const fs = require('fs');
const { send } = require('./rcon');

const LISTS = new Set(['names', 'types', 'add', 'set']);

function parseValue(key, v) {
  if (/^-?\d+(\.\d+)?$/.test(v)) return Number(v);
  if (v === 'true') return true;
  if (v === 'false') return false;
  if (/^[[{]/.test(v)) return JSON.parse(v);
  if (LISTS.has(key)) return v.split(',');
  return v;
}

function parseOp(words) {
  const [op, ...rest] = words;
  let args = {};
  for (const w of rest) {
    if (w.startsWith('{')) Object.assign(args, JSON.parse(w));
    else if (w.startsWith('@')) Object.assign(args, JSON.parse(fs.readFileSync(w.slice(1), 'utf8')));
    else {
      const i = w.indexOf('=');
      if (i < 0) throw new Error(`argument "${w}" is not key=value`);
      args[w.slice(0, i)] = parseValue(w.slice(0, i), w.slice(i + 1));
    }
  }
  return { op, args };
}

// Commands for one op; long JSON goes through the buffer.
function commandsFor({ op, args }) {
  // Git Bash rewrites a leading slash into a path, so raw commands may leave it out.
  if (op === 'raw') return [(args._ || '').replace(/^(?!\/)/, '/')];
  const json = Object.keys(args).length ? JSON.stringify(args) : '';
  if (json.length < 3000) return [`/agent ${op} ${json}`];
  const parts = [];
  for (let i = 0; i < json.length; i += 3000) parts.push(`/agent _buf ${json.slice(i, i + 3000)}`);
  return [...parts, `/agent ${op} @buf`];
}

function fmt(v, indent = '') {
  if (v === null || typeof v !== 'object') return JSON.stringify(v);
  const one = JSON.stringify(v);
  if (one.length <= 110) return one;
  const inner = indent + '  ';
  if (Array.isArray(v)) return '[\n' + v.map((x) => inner + fmt(x, inner)).join(',\n') + '\n' + indent + ']';
  return '{\n' + Object.entries(v).map(([k, x]) => `${inner}${k}: ${fmt(x, inner)}`).join(',\n') + '\n' + indent + '}';
}

// Client-side op: wait until the game has advanced `seconds` (game time), the job queue is
// empty (jobs=true) and/or the crafting queue is empty (crafting=true); at most `max` real
// seconds (default 120).
async function wait(args) {
  const status = async () => JSON.parse((await send(['/agent status {"events":false}']))[0]);
  const start = await status();
  const until = start.tick + Math.round((args.seconds || 0) * 60);
  const deadline = Date.now() + (args.max || 120) * 1000;
  for (;;) {
    const s = await status();
    const done = s.tick >= until && (!args.jobs || !(s.jobs || []).length)
      && (!args.crafting || !(s.crafting || []).length);
    if (done || Date.now() > deadline || (s.paused && s.tick < until)) {
      return { waited_game_s: Math.round((s.tick - start.tick) / 60), done, paused: s.paused, jobs: s.jobs, crafting: s.crafting };
    }
    await new Promise((r) => setTimeout(r, 1000));
  }
}

async function main() {
  const argv = process.argv.slice(2);
  if (!argv.length) { console.log('usage: node a.js <op> [key=value ...] [+ <op> ...]'); process.exit(1); }
  const groups = [[]];
  for (const w of argv) { if (w === '+') groups.push([]); else groups[groups.length - 1].push(w); }
  const ops = groups.filter((g) => g.length).map((g) => (g[0] === 'raw' ? { op: 'raw', args: { _: g.slice(1).join(' ') } } : parseOp(g)));
  let failed = false;
  // Ops run in order; a client-side `wait` splits them into batches.
  for (let i = 0; i < ops.length;) {
    if (ops[i].op === 'wait') {
      if (ops.length > 1) console.log('== wait');
      console.log(fmt(await wait(ops[i].args)));
      i += 1;
      continue;
    }
    let j = i;
    while (j < ops.length && ops[j].op !== 'wait') j += 1;
    failed = (await runBatch(ops.slice(i, j), ops.length > 1)) || failed;
    i = j;
  }
  process.exit(failed ? 1 : 0);
}

async function runBatch(ops, label) {
  const plan = ops.map((o) => ({ o, cmds: commandsFor(o) }));
  const answers = await send(plan.flatMap((p) => p.cmds));
  let k = 0;
  let failed = false;
  for (const p of plan) {
    k += p.cmds.length;
    const text = answers[k - 1];
    if (label) console.log(`== ${p.o.op}`);
    let res;
    try { res = JSON.parse(text); } catch { console.log(text); continue; }
    if (res && res.error) failed = true;
    if (res && typeof res.text === 'string') console.log(res.text);
    else console.log(fmt(res));
  }
  return failed;
}

main().catch((e) => { console.error(String(e.message || e)); process.exit(2); });
