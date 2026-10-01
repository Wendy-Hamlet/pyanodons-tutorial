// Which items the buildings of a stage are made of: for every building recipe available with the
// given technologies (and their prerequisites), counts how many building recipes use each item
// and how many one of each building needs, and shows what the item itself is made of. Ranks the
// key intermediates of a stage (what a mall has to make). Prints Chinese names.
// Usage: node --max-old-space-size=4096 tools/building-inputs.js <tech,tech,...> [--top 40] [--show item,item]

const paths = require('./paths');
const raw = require(`${paths.dump}/data-raw-dump.json`);
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));
const load = (kind) => { try { return require(`${paths.dump}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), fluid: load('fluid'), entity: load('entity'), technology: load('technology') };
const nm = (n) => L.item[n] || L.fluid[n] || L.entity[n] || n;

const args = process.argv.slice(2);
const opt = (flag, d) => { const i = args.indexOf(flag); return i >= 0 ? args[i + 1] : d; };
const techs = new Set();
const add = (t) => {
  if (techs.has(t)) return;
  if (!raw.technology[t]) throw new Error(`unknown technology ${t}`);
  techs.add(t);
  for (const p of arr(raw.technology[t].prerequisites)) add(p);
};
for (const t of (args[0] || '').split(',').filter(Boolean)) add(t);

const available = new Set(Object.entries(raw.recipe).filter(([, r]) => r.enabled !== false && !r.hidden).map(([n]) => n));
for (const t of techs) for (const e of arr(raw.technology[t].effects)) if (e.type === 'unlock-recipe') available.add(e.recipe);
const building = (n) => raw.item[n] && raw.item[n].place_result;

const uses = {};
let count = 0;
for (const r of available) {
  const rec = raw.recipe[r];
  const b = arr(rec.results).find((p) => p.type === 'item' && building(p.name));
  if (!b) continue;
  count++;
  for (const i of arr(rec.ingredients)) {
    const u = (uses[i.name] = uses[i.name] || { recipes: [], total: 0 });
    u.recipes.push(`${nm(b.name)}×${i.amount}`);
    u.total += i.amount;
  }
}
const makers = {};
for (const r of available) for (const p of arr(raw.recipe[r].results)) (makers[p.name] = makers[p.name] || []).push(r);
const madeOf = (n) => {
  // Skip recipes that make some other building as their main point (they list byproducts too).
  const list = (makers[n] || []).filter((r) => !arr(raw.recipe[r].results).some((p) => building(p.name) && p.name !== n));
  if (!list.length) return n in raw.resource || !makers[n] ? '原料' : '?';
  const r = raw.recipe[list[0]];
  return arr(r.ingredients).map((i) => `${nm(i.name)}×${i.amount}`).join(' + ') + (list.length > 1 ? `（另有 ${list.length - 1} 个配方）` : '');
};

console.log(`科技：${[...args[0].split(',')].map((t) => L.technology[t] || t).join('、')} 及其前置，共 ${techs.size} 项；建筑配方 ${count} 个\n`);
console.log('| 物品 | 用到它的建筑配方数 | 每种建筑各造一台的总需求 | 它由什么做成（第一个配方） |');
console.log('|---|---|---|---|');
const rows = Object.entries(uses).sort((a, b) => b[1].recipes.length - a[1].recipes.length || b[1].total - a[1].total);
for (const [n, u] of rows.slice(0, Number(opt('--top', 40)))) {
  console.log(`| ${nm(n)}${building(n) ? '（本身也是建筑）' : ''} | ${u.recipes.length} | ${u.total} | ${madeOf(n)} |`);
}
for (const n of (opt('--show', '') || '').split(',').filter(Boolean)) {
  console.log(`\n${nm(n)} 用在：${(uses[n] || { recipes: [] }).recipes.join('、')}`);
}
