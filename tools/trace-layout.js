// Traces the logistics of one area of a save snapshot (entities.json from tools/inspect-save.ps1):
// belt lines (start, end, length, what they carry, who loads and unloads them), fluid networks
// (connected segments: fluid, pipes, machines) and machines with their inputs and outputs. Used to
// read the author's layouts as design input. Prints Chinese names (zh-CN locale dump).
// Usage: node tools/trace-layout.js x1 y1 x2 y2

const paths = require('./paths');
const [x1, y1, x2, y2] = process.argv.slice(2).map(Number);
const all = Object.values(require(`${paths.save}/entities.json`));
const load = (kind) => { try { return require(`${paths.dump}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), fluid: load('fluid'), recipe: load('recipe') };
const zh = (n) => L.entity[n] || L.item[n] || L.fluid[n] || L.recipe[n] || n;

const inside = (e) => e.x >= x1 && e.x < x2 + 1 && e.y >= y1 && e.y < y2 + 1;
const list = all.filter((e) => inside(e) && e.type !== 'entity-ghost');
const key = (x, y) => `${Math.floor(x)},${Math.floor(y)}`;
const at = new Map();
for (const e of list) {
  for (let x = Math.floor(e.x1 + 0.01); x < Math.ceil(e.x2 - 0.01); x++) {
    for (let y = Math.floor(e.y1 + 0.01); y < Math.ceil(e.y2 - 0.01); y++) at.set(`${x},${y}`, e);
  }
}
const VEC = { north: [0, -1], east: [1, 0], south: [0, 1], west: [-1, 0] };
const pos = (e) => `(${Math.floor(e.x)},${Math.floor(e.y)})`;
const name = (e) => (e ? zh(e.name) : '空地');

// ---- belts --------------------------------------------------------------------------------------
const belts = list.filter((e) => e.type === 'transport-belt' || e.type === 'underground-belt');
const next = new Map();
for (const b of belts) {
  const v = VEC[b.dir] || [0, 0];
  if (b.type === 'underground-belt' && b.ug === 'input') {
    for (let d = 1; d <= 10; d++) {
      const o = at.get(key(b.x + v[0] * d, b.y + v[1] * d));
      if (o && o.type === 'underground-belt' && o.ug === 'output' && o.dir === b.dir) { next.set(b, o); break; }
    }
  } else {
    const o = at.get(key(b.x + v[0], b.y + v[1]));
    const ov = o && VEC[o.dir];
    if (o && (o.type === 'transport-belt' || o.type === 'underground-belt') && !(ov[0] === -v[0] && ov[1] === -v[1])) next.set(b, o);
  }
}
const incoming = new Map();
for (const [a, b] of next) {
  // A straight feed (same direction) continues a line; a perpendicular one side-loads into it.
  if (a.dir === b.dir || b.type === 'underground-belt') incoming.set(b, a);
}
const lineOf = new Map();
const lines = [];
const starts = belts.filter((b) => !incoming.has(b));
const rest = belts.filter((b) => incoming.has(b));
for (const s of [...starts, ...rest]) {
  if (lineOf.has(s)) continue;
  const line = { id: lines.length + 1, tiles: [], items: {}, joins: null };
  let b = s;
  while (b && !lineOf.has(b)) {
    lineOf.set(b, line);
    line.tiles.push(b);
    for (const [n, c] of Object.entries(b.items || {})) line.items[n] = (line.items[n] || 0) + c;
    const n = next.get(b);
    if (n && n.dir !== b.dir && n.type === 'transport-belt' && incoming.get(n) !== b) { line.sideloads = n; break; }
    b = n;
  }
  if (b && lineOf.has(b) && lineOf.get(b) !== line) line.joins = b;
  lines.push(line);
}
const tileLine = new Map();
for (const l of lines) for (const t of l.tiles) tileLine.set(key(t.x, t.y), l);

// ---- inserters and drills -----------------------------------------------------------------------
const loads = new Map();
const unloads = new Map();
const add = (map, k, v) => { if (!map.has(k)) map.set(k, []); map.get(k).push(v); };
for (const i of list.filter((e) => e.type === 'inserter' && e.pickup && e.drop)) {
  const from = at.get(key(i.pickup.x, i.pickup.y));
  const to = at.get(key(i.drop.x, i.drop.y));
  const f = i.filter ? `${i.filter_mode === 'blacklist' ? '除' : ''}${zh(i.filter)}${i.filter_mode === 'blacklist' ? '外' : ''}` : '';
  add(loads, to, { via: i, from, filter: f });
  add(unloads, from, { via: i, to, filter: f });
}
for (const d of list.filter((e) => e.type === 'mining-drill' && e.drop)) add(loads, at.get(key(d.drop.x, d.drop.y)), { via: d, from: d, filter: '' });

const sum = (arr) => {
  const out = {};
  for (const s of arr) { const k = `${name(s.from || s.to)}${s.filter ? `[${s.filter}]` : ''}`; out[k] = (out[k] || 0) + 1; }
  return Object.entries(out).map(([k, c]) => `${k}×${c}`).join('、');
};

console.log(`区域 (${x1},${y1})-(${x2},${y2})：${list.length} 个实体，${belts.length} 格传送带，${lines.length} 条带线`);
console.log('\n## 带线（长度 ≥ 3）');
for (const l of lines.filter((l) => l.tiles.length >= 3).sort((a, b) => b.tiles.length - a.tiles.length)) {
  const first = l.tiles[0];
  const last = l.tiles[l.tiles.length - 1];
  const inn = l.tiles.flatMap((t) => loads.get(t) || []);
  const out = l.tiles.flatMap((t) => unloads.get(t) || []);
  const items = Object.entries(l.items).sort((a, b) => b[1] - a[1]).map(([n, c]) => `${zh(n)}${c}`).join('、') || '空';
  const end = l.joins ? `并入带线 ${lineOf.get(l.joins).id}` : l.sideloads ? `侧入带线 ${lineOf.get(l.sideloads) ? lineOf.get(l.sideloads).id : '?'}` : `止于 ${name(at.get(key(last.x + (VEC[last.dir] || [0, 0])[0], last.y + (VEC[last.dir] || [0, 0])[1])))}`;
  console.log(`线 ${l.id}：${pos(first)} → ${pos(last)}，${l.tiles.length} 格，${end}；带上：${items}`);
  if (inn.length) console.log(`  放上：${sum(inn)}`);
  if (out.length) console.log(`  取走：${sum(out.map((o) => ({ to: o.to, filter: o.filter })))}`);
}

// ---- fluids -------------------------------------------------------------------------------------
console.log('\n## 流体网络');
const segs = new Map();
for (const e of list) {
  for (const fb of e.fluid_boxes || []) {
    if (fb.segment == null) continue;
    if (!segs.has(fb.segment)) segs.set(fb.segment, { fluids: {}, members: [] });
    const s = segs.get(fb.segment);
    if (fb.fluid) s.fluids[fb.fluid] = (s.fluids[fb.fluid] || 0) + (fb.amount || 0);
    s.members.push(e);
  }
}
for (const [id, s] of segs) {
  const pipes = s.members.filter((e) => e.type === 'pipe' || e.type === 'pipe-to-ground');
  const machines = s.members.filter((e) => !(e.type === 'pipe' || e.type === 'pipe-to-ground'));
  const xs = s.members.map((e) => e.x);
  const ys = s.members.map((e) => e.y);
  const fl = Object.keys(s.fluids).map(zh).join('、') || '空';
  console.log(`段 ${id}：${fl}；管道 ${pipes.filter((p) => p.type === 'pipe').length}、地下管道 ${pipes.filter((p) => p.type === 'pipe-to-ground').length}；连接 ${machines.map((m) => `${name(m)}${pos(m)}`).join('、') || '无'}；范围 x ${Math.min(...xs)}..${Math.max(...xs)}，y ${Math.min(...ys)}..${Math.max(...ys)}`);
}

// ---- machines -----------------------------------------------------------------------------------
console.log('\n## 机器');
for (const m of list.filter((e) => ['assembling-machine', 'furnace', 'storage-tank', 'boiler', 'generator', 'offshore-pump'].includes(e.type) && e.name !== 'stone-furnace')) {
  const inn = loads.get(m) || [];
  const out = unloads.get(m) || [];
  const fl = (m.fluid_boxes || []).map((f) => `${f.fluid ? zh(f.fluid) : '空'}@段${f.segment}`).join('、');
  console.log(`${name(m)} ${pos(m)}${m.recipe ? ` 配方 ${zh(m.recipe)}` : ''} 状态 ${m.status || '?'}`);
  const src = (s) => { const l = tileLine.get(key(s.via.pickup.x, s.via.pickup.y)); return l ? `带线${l.id}` : name(s.from); };
  const dst = (s) => { const l = tileLine.get(key(s.via.drop.x, s.via.drop.y)); return l ? `带线${l.id}` : name(s.to); };
  if (inn.length) console.log(`  进：${inn.map((s) => `${src(s)}${s.filter ? `[${s.filter}]` : ''}`).join('、')}`);
  if (out.length) console.log(`  出：${out.map((s) => `${dst(s)}${s.filter ? `[${s.filter}]` : ''}`).join('、')}`);
  if (fl) console.log(`  流体：${fl}`);
}
const poles = list.filter((e) => e.type === 'electric-pole');
console.log(`\n电线杆 ${poles.length} 根`);
