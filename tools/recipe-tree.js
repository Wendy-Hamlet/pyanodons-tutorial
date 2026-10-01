// Expands the production tree of an item using only recipes available at a given point of the
// tech tree (enabled at start + unlocked by the listed technologies). Names are shown in Chinese
// with internal names in brackets.
// Usage: node --max-old-space-size=4096 tools/recipe-tree.js <item> [--techs a,b,c] [--depth N]

const dir = 'C:/tmp/cf-dump/data/script-output';
const raw = require(`${dir}/data-raw-dump.json`);
const load = (kind) => { try { return require(`${dir}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), recipe: load('recipe'), fluid: load('fluid') };
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));

const args = process.argv.slice(2);
const target = args[0];
const opt = (flag) => { const i = args.indexOf(flag); return i >= 0 ? args[i + 1] : undefined; };
const techs = (opt('--techs') || '').split(',').filter(Boolean);
const maxDepth = Number(opt('--depth') || 12);

const hidden = (p) => p && ((p.flags || []).includes('hidden') || p.hidden);
const name = (type, n) => `${(type === 'fluid' ? L.fluid[n] : L.item[n]) || L.entity[n] || n}`;

// Recipes available: enabled at start plus unlocked by the given technologies.
const available = new Set(Object.entries(raw.recipe).filter(([, r]) => r.enabled !== false && !hidden(r)).map(([n]) => n));
for (const t of techs) {
  if (!raw.technology[t]) { console.error(`unknown technology ${t}`); process.exit(1); }
  for (const e of arr(raw.technology[t].effects)) if (e.type === 'unlock-recipe') available.add(e.recipe);
}

// Raw sources: what mining resources, trees, offshore pumps and burnt fuel give.
const drillsFor = {};
for (const [n, d] of Object.entries(raw['mining-drill'] || {})) {
  if (hidden(d) || /-mk0[2-4]$/.test(n)) continue;
  for (const c of arr(d.resource_categories)) (drillsFor[c] = drillsFor[c] || []).push(n);
}
const rawSources = {};
const rawKind = {};
for (const [n, res] of Object.entries(raw.resource)) {
  const m = res.minable || {};
  const results = m.results ? arr(m.results) : m.result ? [{ name: m.result }] : [];
  const category = res.category || 'basic-solid';
  const fluid = m.required_fluid ? `，需要流体 ${name('fluid', m.required_fluid)}` : '';
  const drills = (drillsFor[category] || []).map((d) => L.entity[d] || d).join('/');
  for (const p of results) {
    (rawSources[p.name] = rawSources[p.name] || []).push(`开采 ${L.entity[n] || n}（${drills || category}${fluid}）`);
    rawKind[p.name] = 'mined';
  }
}
for (const [n, it] of Object.entries(raw.item)) {
  if (it.burnt_result && arr(it.fuel_categories).length) {
    const list = (rawSources[it.burnt_result] = rawSources[it.burnt_result] || []);
    if (list.length < 3) list.push(`燃烧 ${L.item[n] || n} 的废料`);
    rawKind[it.burnt_result] = rawKind[it.burnt_result] || 'burnt';
  }
}
for (const [n, t] of Object.entries(raw.tree || {})) {
  const m = t.minable || {};
  for (const p of m.results ? arr(m.results) : m.result ? [{ name: m.result }] : []) {
    if (!rawSources[p.name]) rawSources[p.name] = ['砍树'];
  }
}
for (const [, p] of Object.entries(raw['offshore-pump'] || {})) {
  if (p.fluid) (rawSources[p.fluid] = rawSources[p.fluid] || []).push('抽取泵');
}
if (!rawSources.water) rawSources.water = ['抽取泵'];

const machinesFor = {};
for (const type of ['assembling-machine', 'furnace']) {
  for (const [n, e] of Object.entries(raw[type] || {})) {
    if (hidden(e)) continue;
    for (const c of arr(e.crafting_categories)) (machinesFor[c] = machinesFor[c] || []).push(n);
  }
}
const handCats = new Set(arr(raw.character.character.crafting_categories));
const buildable = (entity) => [...available].some((r) => arr(raw.recipe[r].results).some((p) => p.name === entity));

const producers = {};
for (const n of available) {
  const r = raw.recipe[n];
  for (const p of arr(r.results)) (producers[p.name] = producers[p.name] || []).push(n);
}

const amount = (i) => i.amount ?? (i.amount_min !== undefined ? `${i.amount_min}-${i.amount_max}` : 1);
const describeRecipe = (rn) => {
  const r = raw.recipe[rn];
  const cats = arr(r.categories).length ? arr(r.categories) : ['crafting'];
  const hand = cats.some((c) => handCats.has(c));
  const machines = [...new Set(cats.flatMap((c) => machinesFor[c] || []))].filter((m) => !/-mk0[2-4]$/.test(m));
  const usable = machines.filter(buildable).map((m) => L.entity[m] || m);
  const out = arr(r.results).map((p) => `${name(p.type, p.name)}×${amount(p)}${p.probability && p.probability < 1 ? `(${p.probability * 100}%)` : ''}`).join('+');
  return `【${L.recipe[rn] || rn}】${r.energy_required ?? 0.5}s → ${out}；${hand ? '可手搓；' : ''}机器：${usable.join('/') || '（暂无可建造的机器）'}`;
};

const seen = new Set();
const walk = (type, item, count, depth, path, prefix) => {
  const label = `${name(type, item)} [${item}]${count !== undefined ? ` ×${count}` : ''}`;
  const options = (producers[item] || []).filter((r) => !path.has(r));
  if (rawSources[item] && !options.length) { console.log(`${prefix}${label} ← ${rawSources[item].join(' / ')}`); return; }
  if (!options.length) { console.log(`${prefix}${label} ← ⚠ 此时没有可用配方`); return; }
  if (seen.has(item)) { console.log(`${prefix}${label} ← （见上）`); return; }
  seen.add(item);
  const [main, ...alts] = options;
  console.log(`${prefix}${label} ← ${describeRecipe(main)}${rawSources[item] ? '；也可' + rawSources[item].join('/') : ''}`);
  for (const a of alts) console.log(`${prefix}   或 ${describeRecipe(a)}`);
  if (depth >= maxDepth) return;
  const next = new Set(path).add(main);
  for (const i of arr(raw.recipe[main].ingredients)) walk(i.type, i.name, i.amount, depth + 1, next, prefix + '   ');
};
walk(raw.fluid[target] ? 'fluid' : 'item', target, undefined, 0, new Set(), '');

// Raw totals per unit of the target, following the first recipe at every step.
const totals = {};
const expand = (type, item, need, path) => {
  const options = (producers[item] || []).filter((r) => !path.has(r));
  if (!options.length || (rawSources[item] && rawKind[item])) {
    const key = `${type}:${item}`;
    totals[key] = (totals[key] || 0) + need;
    return;
  }
  const r = raw.recipe[options[0]];
  const product = arr(r.results).find((p) => p.name === item);
  const perCraft = (product.amount ?? (product.amount_min + product.amount_max) / 2) * (product.probability ?? 1);
  const crafts = need / perCraft;
  const next = new Set(path).add(options[0]);
  for (const i of arr(r.ingredients)) expand(i.type, i.name, i.amount * crafts, next);
};
expand(raw.fluid[target] ? 'fluid' : 'item', target, 1, new Set());
console.log(`\n每 1 个 ${name('item', target)} 的基础原料：` + Object.entries(totals)
  .map(([k, v]) => { const [t, n] = k.split(':'); return `${name(t, n)} ${Number(v.toFixed(3))}`; }).join('、'));
