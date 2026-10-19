// One-call lookup of everything known about a name: the prototype data (item, fluid, building,
// recipe, technology, resource) in compact lines, the latest save snapshot (researched, built,
// in the inventory, ore patches) and every paragraph of the notes that mentions it.
// Names may be internal, English or Chinese, whole or part ("金属间化合物", "intermetallics",
// "locomotive"); several matches are listed, the exact one is shown in full.
// Usage: node tools/q.js <term> [--data | --notes] [--all] [--zh]
//   --data / --notes  only that part     --all  every note hit (default: the best 12)
//   --zh              also search the Chinese translations of the notes
// The data part reads a compact index built from the dump on first use (tools/dump-data.ps1
// output; rebuilt when the dump changes), so a query takes well under a second.

const fs = require('fs');
const path = require('path');
const os = require('os');
const paths = require('./paths');
const { expected } = require('./products');

const args = process.argv.slice(2);
const flag = (f) => args.includes(f);
const term = args.filter((a) => !a.startsWith('--')).join(' ').trim();
if (!term && !flag('--build')) {
  console.error('usage: node tools/q.js <term> [--data|--notes] [--all] [--zh]');
  process.exit(1);
}

// ---------------------------------------------------------------- data index
const dumpFile = `${paths.dump}/data-raw-dump.json`;
const indexFile = `${paths.dump}/q-index.json`;
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));
const hidden = (p) => p && (arr(p.flags).includes('hidden') || p.hidden);

function buildIndex() {
  const raw = JSON.parse(fs.readFileSync(dumpFile, 'utf8'));
  const loc = (dir, kind) => { try { return JSON.parse(fs.readFileSync(`${dir}/${kind}-locale.json`, 'utf8')).names; } catch { return {}; } };
  const enDir = paths.dump.replace(/data\/script-output$/, 'data-en/script-output');
  const names = {};
  for (const kind of ['item', 'fluid', 'entity', 'recipe', 'technology']) names[kind] = { zh: loc(paths.dump, kind), en: loc(enDir, kind) };

  const idx = { items: {}, recipes: {}, techs: {}, entities: {}, resources: {}, names, madeIn: {} };
  for (const [type, list] of Object.entries(raw)) {
    if (type === 'fluid' || type === 'recipe' || type === 'technology' || type === 'resource') continue;
    for (const [n, p] of Object.entries(list)) {
      if (p.stack_size === undefined) continue; // items of every item type
      idx.items[n] = {
        type, stack: p.stack_size, place: p.place_result, fuel: p.fuel_value, fuelcat: p.fuel_category,
        burnt: p.burnt_result, hidden: hidden(p) || undefined, module: p.effect ? p.effect : undefined,
      };
    }
  }
  for (const [n, p] of Object.entries(raw.fluid || {})) idx.items[n] = { type: 'fluid', fuel: p.fuel_value, hidden: hidden(p) || undefined };
  for (const [n, r] of Object.entries(raw.recipe || {})) {
    idx.recipes[n] = {
      cat: arr(r.categories).length ? arr(r.categories) : [r.category || 'crafting'], t: r.energy_required ?? 0.5,
      in: arr(r.ingredients).map((i) => [i.name, i.amount, i.type === 'fluid' ? 1 : 0]),
      out: arr(r.results).map((p) => [p.name, +expected(p).toFixed(4), p.type === 'fluid' ? 1 : 0, (p.probability ?? 1) < 1 ? p.probability : undefined]),
      start: r.enabled !== false || undefined, hidden: hidden(r) || undefined,
    };
  }
  for (const [n, t] of Object.entries(raw.technology || {})) {
    const u = t.unit || {};
    idx.techs[n] = {
      count: u.count ?? u.count_formula, time: u.time,
      packs: arr(u.ingredients).map((i) => (Array.isArray(i) ? i : [i.name, i.amount])),
      pre: arr(t.prerequisites), unlock: arr(t.effects).filter((e) => e.type === 'unlock-recipe').map((e) => e.recipe),
      trigger: t.research_trigger ? t.research_trigger.type : undefined, hidden: hidden(t) || undefined,
    };
  }
  const keep = ['crafting_speed', 'crafting_categories', 'energy_usage', 'max_power_output', 'mining_speed',
    'resource_categories', 'module_slots', 'researching_speed', 'inputs', 'speed', 'rotation_speed', 'max_speed',
    'max_power', 'inventory_size', 'consumption', 'pumping_speed', 'fluid_capacity', 'maximum_wire_distance',
    'supply_area_distance', 'target_temperature', 'max_health', 'weight', 'braking_force', 'friction_force',
    'air_resistance', 'max_distance', 'fluid', 'distribution_effectivity', 'charging_energy', 'robot_slots_count',
    'logistics_radius', 'construction_radius', 'max_energy', 'speed_multiplier', 'effectivity', 'fluid_usage_per_tick',
    'maximum_temperature', 'neighbour_bonus', 'max_underground_distance', 'production', 'energy_production'];
  for (const [type, list] of Object.entries(raw)) {
    for (const [n, p] of Object.entries(list)) {
      if (!p || !p.collision_box || !p.minable || type === 'resource' || type === 'tree' || type === 'simple-entity') continue;
      const e = { type };
      for (const k of keep) if (p[k] !== undefined) e[k] = p[k];
      const cb = p.collision_box;
      e.size = `${Math.round(cb[1][0] - cb[0][0])}x${Math.round(cb[1][1] - cb[0][1])}`;
      const es = p.energy_source || p.burner;
      if (es) e.energy = es.type + (es.fuel_categories ? `(${arr(es.fuel_categories).join('/')})` : '');
      if (p.fluid_boxes) e.fluid_boxes = arr(p.fluid_boxes).length;
      const m = p.minable;
      e.item = m.result || (arr(m.results)[0] || {}).name;
      if (hidden(p)) e.hidden = true;
      idx.entities[n] = e;
      for (const c of arr(p.crafting_categories)) (idx.madeIn[c] = idx.madeIn[c] || []).push(n);
    }
  }
  for (const [n, r] of Object.entries(raw.resource || {})) {
    const m = r.minable || {};
    idx.resources[n] = {
      cat: r.category || 'basic-solid', time: m.mining_time, fluid: m.required_fluid, fluidAmt: m.fluid_amount,
      out: (m.results ? arr(m.results) : m.result ? [{ name: m.result, amount: 1 }] : []).map((p) => [p.name, +expected(p).toFixed(3)]),
      infinite: r.infinite || undefined,
    };
  }
  idx.drillsFor = {};
  for (const [n, d] of Object.entries(raw['mining-drill'] || {})) {
    if (hidden(d)) continue;
    for (const c of arr(d.resource_categories)) (idx.drillsFor[c] = idx.drillsFor[c] || []).push(n);
  }
  idx.built = fs.statSync(dumpFile).mtimeMs;
  fs.writeFileSync(indexFile, JSON.stringify(idx));
  return idx;
}

function loadIndex() {
  let idx;
  try { idx = JSON.parse(fs.readFileSync(indexFile, 'utf8')); } catch { idx = null; }
  if (idx && idx.built === fs.statSync(dumpFile).mtimeMs) return idx;
  // The full dump needs a bigger heap than node's default: rebuild in a child process.
  const { execFileSync } = require('child_process');
  execFileSync(process.execPath, ['--max-old-space-size=4096', __filename, '--build'], { stdio: 'inherit' });
  return JSON.parse(fs.readFileSync(indexFile, 'utf8'));
}

if (flag('--build')) { buildIndex(); process.exit(0); }

// ---------------------------------------------------------------- the save snapshot
function loadSave() {
  const s = {};
  try { s.report = JSON.parse(fs.readFileSync(`${paths.save}/save-report.json`, 'utf8')); } catch { return null; }
  try {
    const ents = JSON.parse(fs.readFileSync(`${paths.save}/entities.json`, 'utf8'));
    const list = Array.isArray(ents) ? ents : ents.entities || Object.values(ents).flat();
    s.count = {};
    for (const e of list) if (e && e.name) s.count[e.name] = (s.count[e.name] || 0) + 1;
  } catch { s.count = null; }
  return s;
}

// ---------------------------------------------------------------- printing data facts
function main() {
  const wantData = !flag('--notes');
  const wantNotes = !flag('--data');
  const terms = new Set([term]);
  if (wantData) {
    const idx = loadIndex();
    const save = loadSave();
    for (const t of dataPart(idx, save)) terms.add(t);
  }
  if (wantNotes) notesPart([...terms].filter((t) => t && t.length >= 2));
}

function dataPart(idx, save) {
  const N = idx.names;
  const zh = (kind, n) => (N[kind] && N[kind].zh[n]) || '';
  const en = (kind, n) => (N[kind] && N[kind].en[n]) || '';
  const iname = (n) => {
    const it = idx.items[n];
    const k = it && it.type === 'fluid' ? 'fluid' : 'item';
    return zh(k, n) || zh('entity', n) || n;
  };
  const tag = (n) => `${iname(n)}[${n}]`;
  const q = term.toLowerCase();

  // Candidates: every kind whose internal, English or Chinese name matches.
  const cands = [];
  const consider = (kind, n, ...labels) => {
    const all = [n, ...labels].filter(Boolean).map((x) => String(x).toLowerCase());
    const score = all.some((x) => x === q) ? 3 : all.some((x) => x.startsWith(q)) ? 2 : all.some((x) => x.includes(q)) ? 1 : 0;
    // Ties go to the shortest matching name: "镍" finds 镍板 before 镍铬合金.
    if (score) cands.push({ kind, n, score, len: Math.min(...all.filter((x) => x.includes(q)).map((x) => x.length)) });
  };
  for (const [n, it] of Object.entries(idx.items)) {
    const k = it.type === 'fluid' ? 'fluid' : 'item';
    consider(k, n, zh(k, n), en(k, n));
  }
  for (const n of Object.keys(idx.techs)) consider('technology', n, zh('technology', n), en('technology', n));
  for (const n of Object.keys(idx.recipes)) if (!idx.items[n]) consider('recipe', n, zh('recipe', n), en('recipe', n));
  for (const n of Object.keys(idx.entities)) if (!idx.items[n] && !idx.items[idx.entities[n].item]) consider('entity', n, zh('entity', n), en('entity', n));
  for (const n of Object.keys(idx.resources)) if (!idx.items[n]) consider('resource', n, zh('entity', n), en('entity', n));
  const rank = { item: 0, fluid: 0, technology: 1, recipe: 2, entity: 3, resource: 4 };
  cands.sort((a, b) => b.score - a.score || a.len - b.len || rank[a.kind] - rank[b.kind] || a.n.length - b.n.length);
  if (!cands.length) { console.log(`data: nothing named like "${term}"`); return []; }

  const top = cands[0];
  const shown = cands.filter((c) => c.score === top.score).slice(0, top.score === 3 ? 3 : 1);
  const others = cands.filter((c) => !shown.includes(c)).slice(0, 15);
  const aliases = [];
  const researched = save ? new Set(save.report.research.researched) : null;
  const techOf = {};
  for (const [t, d] of Object.entries(idx.techs)) for (const r of d.unlock) (techOf[r] = techOf[r] || []).push(t);
  const techTag = (t) => {
    const d = idx.techs[t];
    const packs = d.packs.map(([p, a]) => `${a}${(zh('item', p) || p).replace(/科技包.*$/, '').slice(0, 6)}`).join('+');
    const st = researched ? (researched.has(t) ? ' ✓' : '') : '';
    return `${zh('technology', t) || t}[${t}] ${d.count}×(${packs})${st}`;
  };
  const recipeLine = (r) => {
    const d = idx.recipes[r];
    const io = (l) => l.map(([n, a, , p]) => `${a}${p ? `(${Math.round(p * 100)}%)` : ''} ${iname(n)}`).join(' + ');
    const machines = d.cat.flatMap((c) => idx.madeIn[c] || []).filter((m) => !idx.entities[m].hidden);
    const mk = [...new Set(machines.map((m) => zh('entity', m) || m))].slice(0, 3).join('/') || d.cat.join('/');
    const how = d.start ? '开局' : (techOf[r] || []).map(techTag).join(' | ') || '无科技解锁(脚本/隐藏)';
    return `${zh('recipe', r) || r}[${r}] ${d.t}s @${mk}: ${io(d.in)} -> ${io(d.out)} | ${how}`;
  };

  for (const c of shown) {
    aliases.push(c.n);
    const label = c.kind === 'fluid' ? zh('fluid', c.n) : c.kind === 'item' ? zh('item', c.n) : zh(c.kind === 'resource' ? 'entity' : c.kind, c.n);
    const enl = en(c.kind === 'resource' ? 'entity' : c.kind, c.n);
    if (label) aliases.push(label);
    if (enl) aliases.push(enl);
    console.log(`== ${label || c.n} [${c.n}] ${c.kind}${enl ? ` (${enl})` : ''}`);
    if (c.kind === 'item' || c.kind === 'fluid') {
      const it = idx.items[c.n];
      const facts = [];
      if (it.stack) facts.push(`stack ${it.stack}`);
      if (it.fuel) facts.push(`fuel ${it.fuel}${it.fuelcat ? ` (${it.fuelcat})` : ''}`);
      if (it.burnt) facts.push(`burnt -> ${tag(it.burnt)}`);
      if (it.module) facts.push(`module ${JSON.stringify(it.module)}`);
      if (it.hidden) facts.push('hidden');
      if (facts.length) console.log(`  ${facts.join(', ')}`);
      const made = Object.keys(idx.recipes).filter((r) => !idx.recipes[r].hidden && idx.recipes[r].out.some(([n]) => n === c.n));
      const used = Object.keys(idx.recipes).filter((r) => !idx.recipes[r].hidden && idx.recipes[r].in.some(([n]) => n === c.n));
      const main = (r) => (idx.recipes[r].out[0] || [])[0] === c.n;
      made.sort((a, b) => main(b) - main(a));
      console.log(`  made by ${made.length}:`);
      for (const r of made.slice(0, flag('--all') ? 999 : 8)) console.log(`   ${recipeLine(r)}`);
      if (made.length > 8 && !flag('--all')) console.log(`   … ${made.length - 8} more (--all)`);
      for (const [rn, res] of Object.entries(idx.resources)) {
        if (!res.out.some(([n]) => n === c.n)) continue;
        const drills = (idx.drillsFor[res.cat] || []).map((d) => zh('entity', d) || d).slice(0, 3).join('/');
        console.log(`   mined: ${zh('entity', rn) || rn}[${rn}] ${res.time}s${res.fluid ? ` + ${res.fluidAmt} ${iname(res.fluid)}` : ''} by ${drills || 'no drill'}${res.infinite ? ' (infinite)' : ''}`);
        if (save) {
          const patches = save.report.resources.filter((p) => p.name === rn).sort((a, b) => b.amount - a.amount);
          if (patches.length) console.log(`     patches in save (chunk centres): ${patches.slice(0, 5).map((p) => `(${p.cx * 32 + 16},${p.cy * 32 + 16}) ${(p.amount / 1e6).toFixed(1)}M`).join(', ')}${patches.length > 5 ? ` … ${patches.length} in all` : ''}`);
        }
      }
      console.log(`  used by ${used.length}: ${used.slice(0, flag('--all') ? 999 : 25).map((r) => `${zh('recipe', r) || r}[${r}]`).join(', ')}${used.length > 25 && !flag('--all') ? ' …' : ''}`);
      if (it.place && idx.entities[it.place]) entityLines(it.place);
      if (save) {
        const inv = (save.report.players[0] || {}).inventory || [];
        const have = inv.filter((s) => s.name === c.n).reduce((a, s) => a + s.count, 0);
        const p = save.report.items && save.report.items.produced ? save.report.items.produced[c.n] : undefined;
        const bits = [];
        if (have) bits.push(`${have} in inventory`);
        if (p !== undefined) bits.push(`${p} produced`);
        if (it.place && save.count && save.count[it.place]) bits.push(`${save.count[it.place]} built`);
        if (bits.length) console.log(`  save: ${bits.join(', ')}`);
      }
    } else if (c.kind === 'technology') {
      const d = idx.techs[c.n];
      console.log(`  ${techTag(c.n)}, ${d.time}s each${d.trigger ? `, trigger ${d.trigger}` : ''}`);
      console.log(`  needs: ${d.pre.map((p) => `${zh('technology', p) || p}[${p}]${researched && researched.has(p) ? ' ✓' : ''}`).join(', ') || '-'}`);
      const missing = researched ? missingPrereqs(idx, c.n, researched) : [];
      if (missing.length) console.log(`  still to research first (${missing.length}): ${missing.map((p) => `${zh('technology', p) || p}[${p}]`).join(', ')}`);
      console.log('  unlocks:');
      for (const r of d.unlock) if (idx.recipes[r]) console.log(`   ${recipeLine(r)}`);
    } else if (c.kind === 'recipe') {
      console.log(`  ${recipeLine(c.n)}`);
    } else if (c.kind === 'entity') {
      entityLines(c.n);
    } else if (c.kind === 'resource') {
      const res = idx.resources[c.n];
      console.log(`  ${res.time}s -> ${res.out.map(([n, a]) => `${a} ${tag(n)}`).join(' + ')}${res.fluid ? `, needs ${res.fluidAmt} ${tag(res.fluid)}` : ''}; drills: ${(idx.drillsFor[res.cat] || []).map((d) => zh('entity', d) || d).join('/')}`);
    }
  }
  if (others.length) console.log(`  also: ${others.map((c) => `${c.kind[0]}:${c.n}`).join(' ')}`);
  return aliases;

  function entityLines(n) {
    const e = idx.entities[n];
    const skip = new Set(['type', 'item', 'size', 'energy', 'crafting_categories', 'resource_categories', 'inputs']);
    const stats = Object.entries(e).filter(([k]) => !skip.has(k)).map(([k, v]) => `${k} ${typeof v === 'object' ? JSON.stringify(v) : v}`);
    console.log(`  building ${zh('entity', n) || n}[${n}] ${e.type} ${e.size}${e.energy ? `, ${e.energy}` : ''}: ${stats.join(', ')}`);
    if (e.crafting_categories) {
      const rs = Object.keys(idx.recipes).filter((r) => !idx.recipes[r].hidden && idx.recipes[r].cat.some((c) => e.crafting_categories.includes(c)));
      console.log(`   categories ${e.crafting_categories.join('/')}: ${rs.length} recipes`);
    }
    if (e.resource_categories) console.log(`   mines ${e.resource_categories.join('/')}`);
    if (e.inputs) console.log(`   packs ${e.inputs.map((p) => zh('item', p) || p).join(', ')}`);
    if (save && save.count && save.count[n]) console.log(`   save: ${save.count[n]} built`);
  }
}

function missingPrereqs(idx, t, done) {
  const out = new Set();
  const walk = (x) => { for (const p of idx.techs[x].pre) if (!done.has(p) && !out.has(p)) { out.add(p); walk(p); } };
  walk(t);
  return [...out];
}

// ---------------------------------------------------------------- notes
function notesPart(terms) {
  const repo = path.resolve(__dirname, '..');
  const ws = path.resolve(repo, '..');
  const slug = ws.replace(/[^A-Za-z0-9]/g, '-');
  const mem = path.join(os.homedir(), '.claude', 'projects', slug, 'memory');
  const zhToo = flag('--zh');
  const files = [];
  const add = (dir, re, prio) => {
    try {
      for (const f of fs.readdirSync(dir)) {
        if (!re.test(f) || (!zhToo && /\.zh-CN\.md$/.test(f))) continue;
        files.push({ file: path.join(dir, f), prio });
      }
    } catch { /* absent on other machines */ }
  };
  add(path.join(repo, 'research'), /\.md$/, 0);
  add(mem, /\.md$/, 1);
  add(ws, /^CLAUDE\.md$/, 1);
  add(path.join(ws, 'notes'), /\.md$/, 2);
  add(path.join(repo, 'research', 'agent-play'), /\.md$/, 2);
  add(path.join(repo, 'chapters'), /\.md$/, 3);
  add(path.join(repo, 'tools', 'agent'), /\.md$/, 3);
  add(path.join(ws, 'cellforge', 'docs'), /\.md$/, 4);
  add(repo, /^README\.md$/, 4);

  const lows = terms.map((t) => t.toLowerCase());
  const hits = [];
  for (const { file, prio } of files) {
    const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
    let heading = '';
    let unit = null;
    const flush = () => {
      if (!unit) return;
      const text = unit.lines.join(' ').replace(/\s+/g, ' ').trim();
      const low = text.toLowerCase();
      const matched = lows.filter((t) => low.includes(t));
      if (matched.length) hits.push({ file, prio, line: unit.start, heading: unit.heading, text, matched, first: Math.min(...matched.map((t) => low.indexOf(t))) });
      unit = null;
    };
    lines.forEach((l, i) => {
      if (/^#{1,6} /.test(l)) { flush(); heading = l.replace(/^#+ /, ''); return; }
      if (!l.trim()) { flush(); return; }
      const starts = /^\s{0,1}([-*] |\d+\. |\| )/.test(l) || !unit;
      if (starts) { flush(); unit = { start: i + 1, heading, lines: [l] }; } else unit.lines.push(l);
    });
    flush();
  }
  hits.sort((a, b) => b.matched.length - a.matched.length || a.prio - b.prio);
  const limit = flag('--all') ? hits.length : 12;
  const rel = (f) => (f.startsWith(mem) ? `memory/${path.basename(f)}` : path.relative(ws, f).replace(/\\/g, '/'));
  console.log(`== notes: ${hits.length} paragraphs mention ${terms.map((t) => `"${t}"`).join(' / ')}${hits.length > limit ? ` (best ${limit}; --all)` : ''}`);
  for (const h of hits.slice(0, limit)) {
    const from = Math.max(0, h.first - 120);
    let text = h.text.slice(from, from + 360);
    if (from > 0) text = `…${text}`;
    if (from + 360 < h.text.length) text += '…';
    console.log(`- ${rel(h.file)}:${h.line}${h.heading ? ` [${h.heading.slice(0, 50)}]` : ''} ${text}`);
  }
}

main();
