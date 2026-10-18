// Expands the production tree of an item using only recipes available at a given point of the
// tech tree (enabled at start + unlocked by the listed technologies, plus the recipes of
// script-run machines that are buildable by then; see sources.js). Names are shown in Chinese
// with internal names in brackets. Items taken from map entities (fish, trees, rocks) are marked
// finite, and an item with no usable recipe lists the technologies that would give it one.
// Usage: node --max-old-space-size=4096 tools/recipe-tree.js <item> [--techs a,b,c] [--depth N]
//        --techs save,a,b: "save" stands for everything researched in the latest save snapshot
//        (tools/inspect-save.ps1).

const paths = require('./paths');
const dir = paths.dump;
const { expected, label } = require('./products');
const raw = require(`${dir}/data-raw-dump.json`);
const src = require('./sources')(raw);
const load = (kind) => { try { return require(`${dir}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), recipe: load('recipe'), fluid: load('fluid') };
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));

const args = process.argv.slice(2);
const target = args[0];
const opt = (flag) => { const i = args.indexOf(flag); return i >= 0 ? args[i + 1] : undefined; };
const techs = (opt('--techs') || '').split(',').filter(Boolean)
  .flatMap((t) => (t === 'save' ? require(`${paths.save}/save-report.json`).research.researched : [t]));
const maxDepth = Number(opt('--depth') || 12);

const hidden = (p) => p && ((p.flags || []).includes('hidden') || p.hidden);
const name = (type, n) => `${(type === 'fluid' ? L.fluid[n] : L.item[n]) || L.entity[n] || n}`;

// Recipes available: enabled at start plus unlocked by the given technologies.
const available = new Set(Object.entries(raw.recipe).filter(([, r]) => r.enabled !== false && !hidden(r)).map(([n]) => n));
for (const t of techs) {
  if (!raw.technology[t]) { console.error(`unknown technology ${t}`); process.exit(1); }
  for (const e of arr(raw.technology[t].effects)) if (e.type === 'unlock-recipe' && !hidden(raw.recipe[e.recipe])) available.add(e.recipe);
}
const viaMachine = new Set(src.machineRecipes((r) => available.has(r)));
for (const r of viaMachine) available.add(r);
const madeNow = new Set([...available].flatMap((r) => arr(raw.recipe[r].results).map((p) => p.name)));

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
  // Only a drill buildable at this point of the tech tree makes the resource a raw input.
  const all = drillsFor[category] || [];
  const now = all.filter((d) => madeNow.has(d));
  const drills = now.length ? now.map((d) => L.entity[d] || d).join('/')
    : `暂无可建造的采矿机${all.length ? '：' + all.map((d) => L.entity[d] || d).join('/') : ''}`;
  for (const p of results) {
    (rawSources[p.name] = rawSources[p.name] || []).push(`开采 ${L.entity[n] || n}（${drills}${fluid}）`);
    if (now.length) rawKind[p.name] = 'mined';
  }
}
for (const [n, it] of Object.entries(raw.item)) {
  if (it.burnt_result && arr(it.fuel_categories).length) {
    const list = (rawSources[it.burnt_result] = rawSources[it.burnt_result] || []);
    if (list.length < 3) list.push(`燃烧 ${L.item[n] || n} 的废料`);
    rawKind[it.burnt_result] = rawKind[it.burnt_result] || 'burnt';
  }
}
// Fish, trees and rocks placed by map generation: finite.
const finiteOnly = {};
for (const [item, list] of Object.entries(src.mapSources)) {
  if (!rawSources[item]) finiteOnly[item] = true;
  const what = [...new Set(list.map((s) => `${s.verb}${L.entity[s.entity] || s.entity}`))];
  (rawSources[item] = rawSources[item] || []).push(`${what.slice(0, 3).join('/')}${what.length > 3 ? ' 等' : ''}（地图上有限，采完不再生）`);
}
for (const [, p] of Object.entries(raw['offshore-pump'] || {})) {
  if (p.fluid) { (rawSources[p.fluid] = rawSources[p.fluid] || []).push('抽取泵'); rawKind[p.fluid] = 'pumped'; }
}
if (!rawSources.water) { rawSources.water = ['抽取泵']; rawKind.water = 'pumped'; }

const machinesFor = {};
for (const type of ['assembling-machine', 'furnace']) {
  for (const [n, e] of Object.entries(raw[type] || {})) {
    if (hidden(e)) continue;
    for (const c of arr(e.crafting_categories)) (machinesFor[c] = machinesFor[c] || []).push(n);
  }
}
const handCats = new Set(arr(raw.character.character.crafting_categories));
const buildable = (entity) => madeNow.has(entity);

const producers = {};
for (const n of available) {
  const r = raw.recipe[n];
  for (const p of arr(r.results)) (producers[p.name] = producers[p.name] || []).push(n);
}
// The first recipe is the one followed: filling or emptying barrels and canisters, and recipes
// that recycle those containers (Steel from barrels), go last, so the tree follows a real
// production line instead of a loop through a barrel.
const barreling = (rn) => arr(raw.recipe[rn].categories).some((c) => /barreling/.test(c));
const containers = new Set();
for (const rn of Object.keys(raw.recipe)) {
  if (barreling(rn)) for (const p of arr(raw.recipe[rn].results)) if (p.type !== 'fluid' && raw.item[p.name]) containers.add(p.name);
}
const rank = (rn) => (barreling(rn) ? 2 : arr(raw.recipe[rn].ingredients).some((i) => containers.has(i.name)) ? 1 : 0);
for (const list of Object.values(producers)) list.sort((a, b) => rank(a) - rank(b));

const amount = (i) => i.amount ?? (i.amount_min !== undefined ? `${i.amount_min}-${i.amount_max}` : 1);
const describeRecipe = (rn) => {
  const r = raw.recipe[rn];
  const cats = arr(r.categories).length ? arr(r.categories) : ['crafting'];
  const hand = cats.some((c) => handCats.has(c));
  const machines = [...new Set(cats.flatMap((c) => machinesFor[c] || []))].filter((m) => !/-mk0[2-4]$/.test(m));
  const usable = machines.filter(buildable).map((m) => L.entity[m] || m);
  const out = arr(r.results).map((p) => `${name(p.type, p.name)}${label(p)}`).join('+');
  const script = viaMachine.has(rn) ? '；⚠ 由脚本运行的机器：这是给计算器看的配方，实际速率要实测' : '';
  return `【${L.recipe[rn] || rn}】${r.energy_required ?? 0.5}s → ${out}；${hand ? '可手搓；' : ''}机器：${usable.join('/') || '（暂无可建造的机器）'}${script}`;
};
// Recipes for an item that a technology outside the list would unlock: named when the item has
// no recipe yet and nothing but finite map entities (or nothing at all) to come from.
const locked = (item) => Object.keys(raw.recipe)
  .filter((n) => !available.has(n) && !hidden(raw.recipe[n]) && src.unlockedBy[n] && arr(raw.recipe[n].results).some((p) => p.name === item))
  .map((n) => `【${L.recipe[n] || n}】[${n}] 需科技 ${src.unlockedBy[n].map((t) => tech(t)).join('/')}`);
const tech = (t) => techName[t] || t;
const techName = load('technology');
const scriptNote = (item, prefix) => {
  const other = src.otherScripted(item);
  if (other.length) {
    console.log(`${prefix}   另有 ${other.length} 个配方不由科技解锁（由脚本启用，如 T.U.R.D. 升级）：${other.slice(0, 4).map((n) => `【${L.recipe[n] || n}】[${n}]`).join('、')}${other.length > 4 ? ' 等' : ''}`);
  }
};

const seen = new Set();
const walk = (type, item, count, depth, path, prefix) => {
  const label = `${name(type, item)} [${item}]${count !== undefined ? ` ×${count}` : ''}`;
  const options = (producers[item] || []).filter((r) => !path.has(r));
  // Mined, pumped and burnt-result items are raw inputs: their recipes are only named.
  if (!options.length || rawKind[item]) {
    console.log(`${prefix}${label} ← ${rawSources[item] ? rawSources[item].join(' / ') : '⚠ 此时没有可用配方'}`);
    if (options.length) console.log(`${prefix}   也有配方：${options.slice(0, 3).map((r) => `【${L.recipe[r] || r}】[${r}]`).join('、')}${options.length > 3 ? ` 等 ${options.length} 个` : ''}`);
    if (!rawSources[item] || finiteOnly[item]) {
      const l = locked(item);
      if (l.length) console.log(`${prefix}   要持续供应，可用的配方还没解锁：${l.slice(0, 4).join('；')}${l.length > 4 ? ' 等' : ''}`);
    }
    scriptNote(item, prefix);
    return;
  }
  if (seen.has(item)) { console.log(`${prefix}${label} ← （见上）`); return; }
  seen.add(item);
  const [main, ...alts] = options;
  console.log(`${prefix}${label} ← ${describeRecipe(main)}${rawSources[item] ? '；也可' + rawSources[item].join('/') : ''}`);
  for (const a of alts) console.log(`${prefix}   或 ${describeRecipe(a)}`);
  scriptNote(item, prefix);
  if (depth >= maxDepth) return;
  const next = new Set(path).add(main);
  for (const i of arr(raw.recipe[main].ingredients)) walk(i.type, i.name, i.amount, depth + 1, next, prefix + '   ');
};
walk(raw.fluid[target] ? 'fluid' : 'item', target, undefined, 0, new Set(), '');

// Raw totals per unit of the target, following the first recipe at every step.
// Each item's totals are worked out once (a big tree reaches the same intermediates many times),
// unless a loop cut them short: those depend on the path and are not kept.
const memo = {};
const per = (type, item, path) => {
  if (memo[item]) return memo[item];
  const all = producers[item] || [];
  const options = all.filter((r) => !path.has(r));
  if (!options.length || (rawSources[item] && rawKind[item])) {
    return { sum: { [`${type}:${item}`]: 1 }, cut: options.length < all.length };
  }
  const r = raw.recipe[options[0]];
  const perCraft = expected(arr(r.results).find((p) => p.name === item));
  const next = new Set(path).add(options[0]);
  const sum = {};
  let cut = false;
  for (const i of arr(r.ingredients)) {
    const sub = per(i.type, i.name, next);
    cut = cut || sub.cut;
    for (const [k, v] of Object.entries(sub.sum)) sum[k] = (sum[k] || 0) + (v * i.amount) / perCraft;
  }
  if (!cut) memo[item] = { sum, cut };
  return { sum, cut };
};
const totals = per(raw.fluid[target] ? 'fluid' : 'item', target, new Set()).sum;
console.log(`\n每 1 个 ${name('item', target)} 的基础原料（每一步都沿上面列出的第一个配方）：` + Object.entries(totals)
  .map(([k, v]) => { const [t, n] = k.split(':'); return `${name(t, n)} ${Number(v.toFixed(3))}`; }).join('、'));
