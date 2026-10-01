// What a save still moves by hand: for every crafting machine, where each solid ingredient comes
// from and where each product goes, read from the snapshot of tools/inspect-save.ps1.
//   from: belt / machine (direct insertion) / drill / chest an inserter fills / chest nobody fills
//         (filled by hand) / nothing (put into the machine by hand, or missing)
//   to:   belt / machine / chest an inserter empties / chest nobody empties (taken by hand) /
//         nothing (taken out of the machine by hand)
// Items that leave one machine by hand and enter another by hand are the manual links a bus (or
// trains) should replace. Building items collected in chests are a mall and listed apart.
// Usage: node --max-old-space-size=4096 tools/manual-links.js [x1 y1 x2 y2] [--all]

const paths = require('./paths');
const { analyse } = require('./logistics');
const raw = require(`${paths.dump}/data-raw-dump.json`);
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));
const load = (kind) => { try { return require(`${paths.dump}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), fluid: load('fluid'), recipe: load('recipe') };
const nm = (n) => L.item[n] || L.fluid[n] || L.entity[n] || n;
const rn = (n) => L.recipe[n] || n;

const args = process.argv.slice(2);
const box = args.filter((a) => !a.startsWith('--')).map(Number);
let entries = Object.values(require(`${paths.save}/entities.json`));
if (box.length === 4) entries = entries.filter((e) => e.x >= box[0] && e.x < box[2] + 1 && e.y >= box[1] && e.y < box[3] + 1);
const { list, loads, unloads, tileLine, carries, key } = analyse(entries);

const solid = (ps) => arr(ps).filter((p) => p.type !== 'fluid').map((p) => p.name);
const recipeIO = (r) => (raw.recipe[r] ? { inn: solid(raw.recipe[r].ingredients), out: solid(raw.recipe[r].results) } : { inn: [], out: [] });
const building = (n) => raw.item[n] && raw.item[n].place_result;
const minedBy = (resource) => {
  const m = (raw.resource[resource] || {}).minable || {};
  return m.results ? arr(m.results).map((p) => p.name) : m.result ? [m.result] : [];
};
const isMachine = (e) => e && (e.type === 'assembling-machine' || e.type === 'furnace');
const isChest = (e) => e && (e.type === 'container' || e.type === 'logistic-container');
const pos = (e) => `(${Math.floor(e.x)},${Math.floor(e.y)})`;

// The items a source can hand over, and how that link works.
const source = (s) => {
  const f = s.from;
  if (!f) return { kind: 'none', items: null };
  if (s.port || f.type === 'mining-drill') return { kind: f.type === 'mining-drill' ? 'drill' : 'machine', items: f.type === 'mining-drill' ? minedBy(f.target) : recipeIO(f.recipe).out };
  if (f.type === 'transport-belt' || f.type === 'underground-belt') {
    const l = tileLine.get(key(s.via.pickup.x, s.via.pickup.y));
    const items = l ? [...carries(l)] : [];
    return { kind: items.length ? 'belt' : 'belt?', items: items.length ? items : null };
  }
  if (isMachine(f)) return { kind: 'machine', items: recipeIO(f.recipe).out };
  if (isChest(f)) return { kind: loads.has(f) ? 'chest-auto' : 'chest-manual', items: Object.keys(f.items || {}), chest: f };
  return { kind: 'other', items: null };
};
const passes = (s, item) => !s.filter || (s.mode === 'blacklist' ? s.filter !== item : s.filter === item);
const target = (s) => {
  const t = s.to;
  if (!t) return 'none';
  if (t.type === 'transport-belt' || t.type === 'underground-belt' || t.type === 'splitter') return 'belt';
  if (isMachine(t)) return 'machine';
  if (isChest(t)) return unloads.has(t) ? 'chest-auto' : 'chest-manual';
  return 'other';
};

const usage = {}; // item -> { in: {route: [..]}, out: {route: [..]} }
const note = (item, side, route, m) => {
  const u = (usage[item] = usage[item] || { in: {}, out: {} });
  (u[side][route] = u[side][route] || []).push(m);
};
const machines = list.filter((e) => isMachine(e) && e.recipe);
for (const m of machines) {
  const { inn, out } = recipeIO(m.recipe);
  const srcs = (loads.get(m) || []).map((s) => ({ s, ...source(s) }));
  for (const i of inn) {
    const routes = new Set(srcs.filter((x) => passes(x.s, i) && (x.items === null ? x.kind === 'belt?' : x.items.includes(i))).map((x) => x.kind));
    const auto = ['belt', 'machine', 'drill', 'chest-auto', 'belt?'].find((k) => routes.has(k));
    note(i, 'in', auto || (routes.has('chest-manual') ? 'chest-manual' : (m.input || {})[i] ? 'hand' : 'none'), m);
  }
  const outs = unloads.get(m) || [];
  for (const o of out) {
    const routes = new Set(outs.filter((s) => passes(s, o)).map(target));
    const auto = ['belt', 'machine', 'chest-auto'].find((k) => routes.has(k));
    note(o, 'out', auto || (routes.has('chest-manual') ? 'chest-manual' : 'none'), m);
  }
}

const NAMES = {
  belt: '传送带', 'belt?': '传送带（快照里是空的）', machine: '机器直送', drill: '采矿机', 'chest-auto': '有机械臂补货的箱子',
  'chest-manual': '无人补货/取货的箱子', hand: '手放（机器里有货）', none: '没有来源', other: '其他',
};
const where = (ms) => {
  const byRecipe = {};
  for (const m of ms) (byRecipe[m.recipe] = byRecipe[m.recipe] || []).push(m);
  return Object.entries(byRecipe).map(([r, l]) => `${rn(r)}×${l.length} ${l.slice(0, 3).map(pos).join(' ')}${l.length > 3 ? ' …' : ''}`).join('；');
};
const MANUAL_IN = ['chest-manual', 'hand', 'none'];
const MANUAL_OUT = ['chest-manual', 'none'];
const count = (o, ks) => ks.reduce((a, k) => a + (o[k] || []).length, 0);

// ---- chests: collection (filled, never emptied) and supply (emptied, never filled) ----
const chests = list.filter(isChest);
const fillers = (c) => (loads.get(c) || []).map((x) => {
  const f = x.from;
  if (!f) return '?';
  if (x.port || f.type === 'mining-drill') return f.type === 'mining-drill' ? `采矿机（${nm(f.target)}）` : `${rn(f.recipe)}（出货口）`;
  if (isMachine(f)) return f.recipe ? rn(f.recipe) : nm(f.name);
  if (f.type === 'transport-belt' || f.type === 'underground-belt') return '传送带';
  return nm(f.name); // boilers, furnaces without recipe, other chests ...
});
const takers = (c) => (unloads.get(c) || []).map((x) => {
  const t = x.to;
  if (!t) return '?';
  if (isMachine(t)) return t.recipe ? rn(t.recipe) : nm(t.name);
  if (t.type === 'transport-belt' || t.type === 'underground-belt' || t.type === 'splitter') return '传送带';
  return nm(t.name);
});
const links = {}; // item -> { collect: {n, stock, from:Set}, supply: {n, stock, to:Set}, hand: [machines] }
const link = (i) => (links[i] = links[i] || { collect: { n: 0, stock: 0, from: new Set(), at: [] }, supply: { n: 0, stock: 0, to: new Set(), at: [] }, hand: [] });
for (const c of chests) {
  const filled = loads.has(c);
  const emptied = unloads.has(c);
  if (filled === emptied) continue; // buffers between inserters, or plain storage
  const side = filled ? 'collect' : 'supply';
  const items = Object.keys(c.items || {});
  for (const i of items.length ? items : ['(空)']) {
    const l = link(i)[side];
    l.n++;
    l.stock += (c.items || {})[i] || 0;
    for (const w of filled ? fillers(c) : takers(c)) (filled ? l.from : l.to).add(w);
    l.at.push(c);
  }
}
for (const [i, u] of Object.entries(usage)) for (const k of ['hand', 'none']) for (const m of u.in[k] || []) link(i).hand.push(m);

const at = (es) => {
  // Where: the 64-tile squares holding them, busiest first.
  const sq = {};
  for (const e of es) { const k = `(${Math.floor(e.x / 64) * 64},${Math.floor(e.y / 64) * 64})`; sq[k] = (sq[k] || 0) + 1; }
  return Object.entries(sq).sort((a, b) => b[1] - a[1]).slice(0, 4).map(([k, n]) => `${k}×${n}`).join(' ');
};

console.log(`机器 ${machines.length} 台（有配方的），箱子 ${chests.length} 个：收集箱（只进不出，要手取）${chests.filter((c) => loads.has(c) && !unloads.has(c)).length}，供货箱（只出不进，要手补）${chests.filter((c) => !loads.has(c) && unloads.has(c)).length}`);
console.log('\n## 手工搬运的物品：既有收集箱又有供货箱（或手放的机器）\n');
console.log('| 物品 | 收集箱（个，库存） | 由谁装进去 | 供货箱（个，库存） | 供给谁 | 手放的机器 |');
console.log('|---|---|---|---|---|---|');
const both = Object.entries(links).filter(([i, l]) => !building(i) && l.collect.n && (l.supply.n || l.hand.length))
  .sort((a, b) => b[1].collect.stock + b[1].supply.stock - a[1].collect.stock - a[1].supply.stock);
for (const [i, l] of both) {
  console.log(`| ${nm(i)} | ${l.collect.n}，${l.collect.stock} | ${[...l.collect.from].join('、')} | ${l.supply.n}，${l.supply.stock} | ${[...l.supply.to].join('、') || '—'} | ${l.hand.length ? where(l.hand) : '—'} |`);
}
console.log('\n## 只有供货端：手补的箱子或手放的机器，本地没有收集箱（来自别处、背包或手搓）\n');
for (const [i, l] of Object.entries(links).filter(([i, l]) => !building(i) && !l.collect.n && (l.supply.n || l.hand.length))) {
  console.log(`- ${nm(i)}：供货箱 ${l.supply.n} 个（库存 ${l.supply.stock}，供 ${[...l.supply.to].join('、') || '—'}；${at(l.supply.at)}）${l.hand.length ? `；手放的机器 ${where(l.hand)}` : ''}`);
}
console.log('\n## 只有收集端：装满等手取的箱子（不含建筑）\n');
for (const [i, l] of Object.entries(links).filter(([i, l]) => !building(i) && l.collect.n && !l.supply.n && !l.hand.length).sort((a, b) => b[1].collect.stock - a[1].collect.stock)) {
  console.log(`- ${nm(i)}：${l.collect.n} 个，库存 ${l.collect.stock}，由 ${[...l.collect.from].join('、')} 装入；${at(l.collect.at)}`);
}
console.log('\n## 产物没有出口的机器（留在机器里等手取，不含建筑）\n');
for (const [i, u] of Object.entries(usage).filter(([i, u]) => !building(i) && (u.out.none || []).length)) {
  console.log(`- ${nm(i)}：${where(u.out.none)}`);
}
console.log('\n## 超市：建筑类产物\n');
console.log(Object.entries(usage).filter(([i, u]) => building(i) && Object.keys(u.out).length).map(([i, u]) => `${nm(i)}（${Object.entries(u.out).map(([k, v]) => `${NAMES[k]} ${v.length}`).join('、')}）`).join('；') || '无');

if (args.includes('--all')) {
  console.log('\n## 每种物品的全部来源与去向（机器台数）\n');
  for (const [i, u] of Object.entries(usage).sort()) {
    const fmt = (o) => Object.entries(o).map(([k, v]) => `${NAMES[k]} ${v.length}`).join('、') || '—';
    console.log(`- ${nm(i)}：进 ${fmt(u.in)}；出 ${fmt(u.out)}`);
  }
}

// Burner machines nothing refuels: no inserter or drop brings them anything that burns.
const fuels = new Set(Object.entries(raw.item).filter(([, it]) => it.fuel_value && arr(it.fuel_categories || ['chemical']).length).map(([n]) => n));
const burners = list.filter((e) => e.fuel !== undefined && e.type !== 'inserter');
const unfed = burners.filter((e) => !(loads.get(e) || []).some((s) => {
  const src = source(s);
  return src.kind === 'belt?' || (src.items || []).some((i) => fuels.has(i) && passes(s, i));
}));
console.log('\n## 燃料靠手放的热能设备\n');
const fuelGroups = {};
for (const e of unfed) {
  const k = `${nm(e.name)}${e.recipe ? `（${rn(e.recipe)}）` : ''}`;
  (fuelGroups[k] = fuelGroups[k] || []).push(e);
}
for (const [k, es] of Object.entries(fuelGroups).sort((a, b) => b[1].length - a[1].length)) {
  const empty = es.filter((e) => e.status === 'no_fuel').length;
  console.log(`- ${k}：${es.length} 台${empty ? `，其中 ${empty} 台已断燃料` : ''}；${es.slice(0, 3).map(pos).join(' ')}${es.length > 3 ? ' …' : ''}`);
}
