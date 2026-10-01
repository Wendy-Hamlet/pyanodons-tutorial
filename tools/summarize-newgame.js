// Chinese summary of the new-game snapshot (tools/newgame-observer), joined with the data.raw
// dump and the zh-CN locale dump. Usage: node --max-old-space-size=4096 tools/summarize-newgame.js

const dir = 'C:/tmp/cf-dump/data/script-output';
const report = require(`${dir}/cellforge/newgame-report.json`);
const raw = require(`${dir}/data-raw-dump.json`);
const load = (kind) => { try { return require(`${dir}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), recipe: load('recipe'), technology: load('technology'), fluid: load('fluid') };
const zh = (kind, name) => (L[kind] && L[kind][name]) || L.item[name] || L.fluid[name] || L.entity[name] || name;
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));
const { label } = require('./products');
const fmt = (v) => (v >= 1e6 ? (v / 1e6).toFixed(1) + 'M' : v >= 1e3 ? (v / 1e3).toFixed(1) + 'k' : String(Math.round(v)));
const h = (title) => console.log(`\n## ${title}`);
const items = (list) => arr(list).map((i) => `${zh(i.type === 'fluid' ? 'fluid' : 'item', i.name)}${label(i)}`).join(' + ');

// crafting category -> visible machines able to craft it
const machinesFor = {};
for (const type of ['assembling-machine', 'furnace', 'rocket-silo']) {
  for (const [n, e] of Object.entries(raw[type] || {})) {
    if ((e.flags || []).includes('hidden') || e.hidden) continue;
    for (const c of arr(e.crafting_categories)) (machinesFor[c] = machinesFor[c] || []).push(n);
  }
}
const enabled = new Set(report.recipes);
const handCats = new Set(Object.keys(report.character_crafting_categories));

h('开局物品（原版自由模式脚本）');
for (const [fn, list] of Object.entries(report.freeplay)) {
  const entries = Object.entries(list || {});
  console.log(`${fn}：${entries.length ? entries.map(([n, c]) => `${zh('item', n)}×${c}`).join('、') : '无'}`);
}
console.log('（另外 py_quick_start 在开场动画结束后给：pY建设机器人 MK4×100 + 能量装甲 MK2 及全套模块）');

h(`开局已解锁的配方（不含蓝图参数占位配方）`);
for (const name of report.recipes.filter((n) => !n.startsWith("parameter-"))) {
  const r = raw.recipe[name];
  // 2.1 recipes list several `categories` (default {"crafting"}) instead of one `category`.
  const cats = arr(r.categories).length ? arr(r.categories) : ['crafting'];
  const hand = cats.some((c) => handCats.has(c)) ? '可手搓' : '不可手搓';
  const machines = [...new Set(cats.flatMap((c) => machinesFor[c] || []))]
    .filter((m) => !/-mk0[2-4]$/.test(m)).map((m) => zh('entity', m));
  console.log(`- ${zh('recipe', name)}：${items(r.ingredients)} → ${items(r.results)}（${r.energy_required ?? 0.5}秒，${hand}；机器：${machines.join('/') || '—'}）`);
}

h('开局已研究 / 可研究');
console.log('已研究：' + report.researched.map((t) => zh('technology', t)).join('、'));
const describe = (name) => {
  const t = raw.technology[name];
  const cost = t.research_trigger
    ? `触发条件：${t.research_trigger.type} ${zh('item', t.research_trigger.item?.name || t.research_trigger.item || t.research_trigger.entity || '')} ${t.research_trigger.count ?? ''}`
    : `${t.unit.count ?? t.unit.count_formula}×(${arr(t.unit.ingredients).map((i) => zh('item', i.name || i[0])).join('+')})`;
  const unlocks = arr(t.effects).filter((e) => e.type === 'unlock-recipe').map((e) => zh('recipe', e.recipe));
  return `${zh('technology', name)}【${cost}】→ 解锁：${unlocks.join('、') || '（无配方）'}`;
};

h('开局科技的前几层（按前置关系展开）');
const done = new Set(report.researched);
let frontier = report.available;
for (let level = 1; level <= 4 && frontier.length; level++) {
  console.log(`第 ${level} 层：`);
  frontier.forEach((n) => console.log('  ' + describe(n)));
  frontier.forEach((n) => done.add(n));
  frontier = Object.entries(raw.technology)
    .filter(([n, t]) => !done.has(n) && !t.hidden && t.enabled !== false && arr(t.prerequisites).length && arr(t.prerequisites).every((p) => done.has(p)))
    .map(([n]) => n);
}

h(`出生点 ${report.radius} 格内的资源`);
const patches = {};
for (const b of report.resources) {
  const list = (patches[b.name] = patches[b.name] || []);
  let patch = list.find((p) => p.chunks.some(([x, y]) => Math.abs(x - b.cx) <= 1 && Math.abs(y - b.cy) <= 1));
  if (!patch) { patch = { chunks: [], amount: 0 }; list.push(patch); }
  patch.chunks.push([b.cx, b.cy]);
  patch.amount += b.amount;
}
const rows = [];
for (const [name, list] of Object.entries(patches)) for (const p of list) {
  const px = p.chunks.reduce((s, c) => s + c[0], 0) / p.chunks.length * 32 + 16 - report.spawn.x;
  const py = p.chunks.reduce((s, c) => s + c[1], 0) / p.chunks.length * 32 + 16 - report.spawn.y;
  rows.push({ name, d: Math.hypot(px, py), px, py, amount: p.amount });
}
rows.sort((a, b) => a.d - b.d).forEach((r) => console.log(`${zh('entity', r.name)}：距出生点 ${Math.round(r.d)} 格（${Math.round(r.px)}, ${Math.round(r.py)}），储量 ${fmt(r.amount)}`));

h('出生点附近的特殊实体（坠毁飞船等）');
const site = {};
for (const e of arr(report.crash_site)) site[e.name] = (site[e.name] || 0) + 1;
console.log(Object.entries(site).map(([n, c]) => `${zh('entity', n)}×${c}`).join('、') || '无');
