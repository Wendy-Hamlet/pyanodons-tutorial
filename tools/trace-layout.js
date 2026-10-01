// Traces the logistics of one area of a save snapshot (entities.json from tools/inspect-save.ps1):
// belt lines (start, end, length, what they carry, who loads and unloads them), fluid networks
// (connected segments: fluid, pipes, machines) and machines with their inputs and outputs. Used to
// read the author's layouts as design input. Prints Chinese names (zh-CN locale dump).
// Usage: node tools/trace-layout.js x1 y1 x2 y2

const paths = require('./paths');
const { analyse } = require('./logistics');
const [x1, y1, x2, y2] = process.argv.slice(2).map(Number);
const all = Object.values(require(`${paths.save}/entities.json`));
const load = (kind) => { try { return require(`${paths.dump}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), fluid: load('fluid'), recipe: load('recipe') };
const zh = (n) => L.entity[n] || L.item[n] || L.fluid[n] || L.recipe[n] || n;

const inside = (e) => e.x >= x1 && e.x < x2 + 1 && e.y >= y1 && e.y < y2 + 1;
const { list, at, lines, lineOf, tileLine, loads: rawLoads, unloads: rawUnloads, key, VEC } = analyse(all.filter(inside));
const pos = (e) => `(${Math.floor(e.x)},${Math.floor(e.y)})`;
const name = (e) => (e ? zh(e.name) : '空地');
const belts = list.filter((e) => e.type === 'transport-belt' || e.type === 'underground-belt');

// ---- inserters, drills and output ports ---------------------------------------------------------
// Filters shown as text; a blacklist filter reads "all but X".
const label = (s) => (s.port ? (s.via.type === 'mining-drill' ? '' : '出货口') : s.filter ? `${s.mode === 'blacklist' ? '除' : ''}${zh(s.filter)}${s.mode === 'blacklist' ? '外' : ''}` : '');
const relabel = (map) => new Map([...map].map(([k, v]) => [k, v.map((s) => ({ ...s, filter: label(s) }))]));
const loads = relabel(rawLoads);
const unloads = relabel(rawUnloads);

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
  const src = (s) => {
    if (!s.via.pickup) return `${name(s.from)}${pos(s.from)}出货口`;
    const l = tileLine.get(key(s.via.pickup.x, s.via.pickup.y));
    return l ? `带线${l.id}` : name(s.from);
  };
  const dst = (s) => { const l = tileLine.get(key(s.via.drop.x, s.via.drop.y)); return l ? `带线${l.id}` : name(s.to); };
  if (inn.length) console.log(`  进：${inn.map((s) => `${src(s)}${s.filter ? `[${s.filter}]` : ''}`).join('、')}`);
  if (out.length) console.log(`  出：${out.map((s) => `${dst(s)}${s.filter ? `[${s.filter}]` : ''}`).join('、')}`);
  if (fl) console.log(`  流体：${fl}`);
}
const poles = list.filter((e) => e.type === 'electric-pole');
console.log(`\n电线杆 ${poles.length} 根`);
