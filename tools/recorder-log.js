// Shared loading for the recorder readers (recorder-summary.js, recorder-phases.js): picks a run,
// reads its timeline and activity segments, drops what an earlier loaded save abandoned, and
// provides Chinese names from the zh-CN locale dump in C:\tmp\cf-dump (if present).

const fs = require('fs');
const path = require('path');

const defaultRoot = path.join(process.env.APPDATA || '', 'Factorio', 'script-output',
  'py-tutorial-companion', 'recorder');

/** Removes `--name value` from args and returns value (or fallback). */
function option(args, name, fallback) {
  const i = args.indexOf(name);
  if (i < 0) return fallback;
  const [value] = args.splice(i, 2).slice(1);
  return value;
}

// Lines in write order; a tick that goes backwards means an earlier save was loaded, so the
// lines of the abandoned branch (t >= that tick) are dropped.
function addLines(list, text) {
  for (const raw of text.split('\n')) {
    if (!raw) continue;
    const line = JSON.parse(raw);
    if (list.length && line.t < list[list.length - 1].t) {
      while (list.length && list[list.length - 1].t >= line.t) list.pop();
    }
    list.push(line);
  }
  return list;
}

/** The run `runId`, or the one whose files changed last. */
function loadRun(root = defaultRoot, runId = undefined) {
  const runs = fs.readdirSync(root).map((name) => {
    const dir = path.join(root, name);
    const files = fs.readdirSync(dir).map((f) => ({ name: f, ...fs.statSync(path.join(dir, f)) }));
    return { name, dir, files, changed: Math.max(0, ...files.map((f) => f.mtimeMs)) };
  }).sort((a, b) => b.changed - a.changed);
  const run = runId ? runs.find((r) => r.name === runId) : runs[0];
  if (!run) throw new Error(`no recorded run in ${root}`);

  const timeline = addLines([], fs.readFileSync(path.join(run.dir, 'timeline.jsonl'), 'utf8'));
  // Segments in number order; one written before its predecessor is left over from an abandoned
  // branch, and so is everything after it.
  const segments = run.files.filter((f) => /^activity-\d+\.jsonl$/.test(f.name))
    .sort((a, b) => a.name.localeCompare(b.name));
  const live = [];
  for (const s of segments) {
    if (live.length && s.mtimeMs < live[live.length - 1].mtimeMs) break;
    live.push(s);
  }
  const activity = [];
  for (const s of live) addLines(activity, fs.readFileSync(path.join(run.dir, s.name), 'utf8'));

  const lastTick = Math.max(timeline.length ? timeline[timeline.length - 1].t : 0,
    activity.length ? activity[activity.length - 1].t : 0);
  const firstTick = timeline.length ? timeline[0].t : 0;
  return { run, timeline, segments, live, activity, firstTick, lastTick };
}

const localeDir = require('./paths').dump;
const load = (kind) => { try { return require(`${localeDir}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), technology: load('technology'), fluid: load('fluid'), tile: load('tile') };
// The recorder counts every tree type as "tree".
const zh = (name) => (name === 'tree' ? '树木' : L.item[name] || L.entity[name] || L.fluid[name] || L.tile[name] || name);
const tech = (name) => L.technology[name] || name;
const clock = (t) => {
  const m = Math.floor(t / 3600);
  return `${Math.floor(m / 60)}:${String(m % 60).padStart(2, '0')}`;
};

// Counts merged by display name: several prototypes can share one Chinese name (wreck variants).
function list(counts, n = 15) {
  const named = {};
  for (const [k, v] of Object.entries(counts)) {
    const name = zh(k.replace(/^tile\//, ''));
    named[name] = Math.round(((named[name] || 0) + v) * 10) / 10;
  }
  return Object.entries(named).sort((a, b) => b[1] - a[1]).slice(0, n).map(([k, v]) => `${k}×${v}`).join('，');
}

module.exports = { defaultRoot, option, loadRun, zh, tech, clock, list };
