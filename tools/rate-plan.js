// Solves a production plan from the prototype data dump: per-minute targets plus ONE chosen recipe
// for every item the plan makes itself. All recipe rates are solved together, so byproducts and
// returned items (cages, barrels) are netted out. Prints, per minute:
//   - every recipe's crafts and machines (machine speed with the plan's modules),
//   - every item: produced, consumed, by which recipes, and which targets (product lines) use it,
//   - raw inputs (with drill counts for mined resources) and surplus byproducts,
//   - with --build: what building every machine of the plan once costs.
// Plans are JS modules (research/plans/*.js) whose comments say why each recipe was chosen.
// Usage: node --max-old-space-size=4096 tools/rate-plan.js <plan.js> [--lang en|zh] [--build]

const path = require('path');
const paths = require('./paths');
const { expected } = require('./products');
const raw = require(`${paths.dump}/data-raw-dump.json`);
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));

const args = process.argv.slice(2);
const plan = require(path.resolve(args[0]));
const lang = args.includes('--lang') ? args[args.indexOf('--lang') + 1] : 'zh';
const localeDir = lang === 'en' ? paths.dump.replace('/data/', '/data-en/') : paths.dump;
const load = (kind) => { try { return require(`${localeDir}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), fluid: load('fluid'), entity: load('entity'), recipe: load('recipe') };
const nm = (n) => L.item[n] || L.fluid[n] || L.entity[n] || n;
const rn = (n) => L.recipe[n] || n;
const fmt = (v, d = 2) => (Math.abs(v) < 1e-9 ? '0' : Number(v.toFixed(d)).toString());

// ---- recipes the plan may use: enabled at start + unlocked by the plan's technologies -----------
const techs = new Set();
const addTech = (t) => {
  if (techs.has(t)) return;
  if (!raw.technology[t]) throw new Error(`unknown technology ${t}`);
  techs.add(t);
  for (const p of arr(raw.technology[t].prerequisites)) addTech(p);
};
for (const t of plan.techs || []) addTech(t);
const unlockedBy = {};
for (const [tn, t] of Object.entries(raw.technology)) for (const e of arr(t.effects)) if (e.type === 'unlock-recipe') (unlockedBy[e.recipe] = unlockedBy[e.recipe] || []).push(tn);
// Recipes a mod script enables (Py's T.U.R.D. upgrades) appear in no technology; plans list them.
const scripted = new Set(plan.scriptRecipes || []);
const usable = (r) => raw.recipe[r].enabled !== false || scripted.has(r) || (unlockedBy[r] || []).some((t) => techs.has(t));

// ---- machines ------------------------------------------------------------------------------------
const machinesFor = {};
for (const type of ['assembling-machine', 'furnace']) {
  for (const [n, e] of Object.entries(raw[type] || {})) {
    if (e.hidden || /-mk0[2-4]|-turd$|^assembling-machine-[23]$/.test(n)) continue;
    for (const c of arr(e.crafting_categories)) (machinesFor[c] = machinesFor[c] || []).push(n);
  }
}
const entity = (n) => raw['assembling-machine'][n] || raw.furnace[n];
const categories = (r) => (arr(raw.recipe[r].categories).length ? arr(raw.recipe[r].categories) : ['crafting']);
const machineOf = (r) => {
  // The plan may name a machine per recipe or per crafting category; else the first one listed.
  const named = plan.machines || {};
  const chosen = named[r] || categories(r).map((c) => named[c]).find(Boolean) || categories(r).flatMap((c) => machinesFor[c] || [])[0];
  if (!chosen || !entity(chosen)) throw new Error(`no machine for recipe ${r}`);
  return chosen;
};
// Speed with modules: crafting speed x (1 + sum of the modules' speed effects).
const speedOf = (m) => {
  let bonus = 0;
  for (const [mod, count] of Object.entries((plan.modules || {})[m] || {})) bonus += raw.module[mod].effect.speed * count;
  return entity(m).crafting_speed * (1 + bonus);
};

// ---- the linear system -------------------------------------------------------------------------
const amountOf = expected;
const io = (r) => {
  const out = {};
  for (const p of arr(raw.recipe[r].results)) out[p.name] = (out[p.name] || 0) + amountOf(p);
  const inn = {};
  for (const i of arr(raw.recipe[r].ingredients)) inn[i.name] = (inn[i.name] || 0) + i.amount;
  return { out, inn };
};
const targets = Object.fromEntries(Object.entries(plan.targets).map(([k, v]) => [k, v / 60])); // per second
const chosen = { ...plan.recipes };
for (const [item, r] of Object.entries(chosen)) {
  if (!raw.recipe[r]) throw new Error(`unknown recipe ${r} for ${item}`);
  if (!(item in io(r).out)) throw new Error(`recipe ${r} does not make ${item}`);
  if (!usable(r)) console.warn(`warning: recipe ${r} (${item}) is not unlocked by the plan's technologies (${(unlockedBy[r] || []).join(', ')})`);
}
const seen = new Set();
for (const r of Object.values(chosen)) { if (seen.has(r)) throw new Error(`recipe ${r} chosen for two items`); seen.add(r); }
for (const t of Object.keys(targets)) if (!chosen[t]) throw new Error(`no recipe chosen for target ${t}`);

// Gaussian elimination with partial pivoting: A x = b.
const solve = (A, b) => {
  const n = b.length;
  const M = A.map((row, i) => [...row, b[i]]);
  for (let c = 0; c < n; c++) {
    let p = c;
    for (let r = c + 1; r < n; r++) if (Math.abs(M[r][c]) > Math.abs(M[p][c])) p = r;
    if (Math.abs(M[p][c]) < 1e-12) throw new Error('the plan has no unique solution (an item is only consumed by its own recipe?)');
    [M[c], M[p]] = [M[p], M[c]];
    for (let r = 0; r < n; r++) {
      if (r === c) continue;
      const f = M[r][c] / M[c][c];
      if (f) for (let k = c; k <= n; k++) M[r][k] -= f * M[c][k];
    }
  }
  return M.map((row, i) => row[n] / row[i]);
};

// Items whose byproduct supply alone covers the need drop their recipe (it would run backwards).
const active = { ...chosen };
const run = (demand) => {
  const items = Object.keys(active);
  const recipes = items.map((i) => active[i]);
  const A = items.map((i) => recipes.map((r) => { const { out, inn } = io(r); return (out[i] || 0) - (inn[i] || 0); }));
  const x = solve(A, items.map((i) => demand[i] || 0));
  return Object.fromEntries(recipes.map((r, k) => [r, x[k]]));
};
let rates;
for (;;) {
  rates = run(targets);
  const negative = Object.entries(active).filter(([, r]) => rates[r] < -1e-9);
  if (!negative.length) break;
  for (const [item] of negative) delete active[item];
}

// ---- totals per item ----------------------------------------------------------------------------
const flows = (x) => {
  const items = {};
  const get = (i) => (items[i] = items[i] || { made: 0, used: 0, by: {}, makers: {} });
  for (const [r, n] of Object.entries(x)) {
    const { out, inn } = io(r);
    for (const [i, a] of Object.entries(out)) { get(i).made += a * n; get(i).makers[r] = a * n; }
    for (const [i, a] of Object.entries(inn)) { get(i).used += a * n; get(i).by[r] = a * n; }
  }
  return items;
};
const all = flows(rates);
const perTarget = Object.fromEntries(Object.keys(targets).map((t) => [t, flows(run({ [t]: targets[t] }))]));

const isFluid = (i) => !!raw.fluid[i];
const pm = (v) => v * 60;

console.log(`# ${plan.title || path.basename(args[0])}`);
console.log(`\n目标（每分钟）：${Object.entries(plan.targets).map(([k, v]) => `${nm(k)} ${v}`).join('、')}`);
if (plan.techs) console.log(`可用配方：开局 + ${techs.size} 项科技（${plan.techs.join('、')} 及其前置）`);

// Recipes and machines.
console.log('\n## 配方与机器\n');
console.log('| 配方 | 产物 | 每分钟次数 | 机器 | 速度 | 台数 |');
console.log('|---|---|---|---|---|---|');
const machineCount = {};
for (const [item, r] of Object.entries(chosen)) {
  if (!active[item]) { console.log(`| ${rn(r)} | ${nm(item)} | 0（副产物已够） | | | |`); continue; }
  const m = machineOf(r);
  const n = (rates[r] * (raw.recipe[r].energy_required ?? 0.5)) / speedOf(m);
  machineCount[m] = (machineCount[m] || 0) + Math.ceil(n - 1e-9);
  console.log(`| ${rn(r)} | ${nm(item)} | ${fmt(pm(rates[r]))} | ${nm(m)} | ${fmt(speedOf(m), 3)} | ${fmt(n)} |`);
}

// Items.
const lines = Object.keys(targets);
console.log('\n## 物品（每分钟；流体按单位）\n');
console.log(`| 物品 | 产出 | 消耗 | 消耗它的配方 | 用到它的目标 |`);
console.log('|---|---|---|---|---|');
const order = Object.entries(all).sort((a, b) => b[1].used - a[1].used);
for (const [i, f] of order) {
  if (f.used < 1e-9) continue;
  const by = Object.entries(f.by).sort((a, b) => b[1] - a[1]).map(([r, v]) => `${rn(r)} ${fmt(pm(v))}`).join('；');
  const users = lines.filter((t) => (perTarget[t][i] || { used: 0 }).used > 1e-9);
  console.log(`| ${nm(i)}${isFluid(i) ? '（流体）' : ''} | ${fmt(pm(f.made))} | ${fmt(pm(f.used))} | ${by} | ${users.map(nm).join('、')} |`);
}

// Raw inputs and surplus.
const drillsFor = {};
for (const [n, d] of Object.entries(raw['mining-drill'] || {})) {
  if (d.hidden || /-mk0[2-4]$/.test(n)) continue;
  for (const c of arr(d.resource_categories)) (drillsFor[c] = drillsFor[c] || []).push(d);
}
// "3MJ", "450kW" -> J or W.
const watts = (s) => { const m = /^([\d.]+)\s*([kMG]?)[WJ]$/.exec(s || ''); return m ? Number(m[1]) * { '': 1, k: 1e3, M: 1e6, G: 1e9 }[m[2]] : 0; };
const mining = {};
for (const [n, res] of Object.entries(raw.resource)) {
  const m = res.minable || {};
  for (const p of m.results ? arr(m.results) : m.result ? [{ name: m.result, amount: 1 }] : []) {
    const d = raw['mining-drill'][(plan.drills || {})[p.name]] || (drillsFor[res.category || 'basic-solid'] || [])[0];
    if (d && !mining[p.name]) mining[p.name] = { drill: d.name, perDrill: (d.mining_speed / m.mining_time) * amountOf(p), resource: n };
  }
}
console.log('\n## 原料（计划外供应，每分钟）\n');
console.log('| 原料 | 每分钟 | 各目标 | 来源 |');
console.log('|---|---|---|---|');
const drillPower = {}; // energy source type -> W of the drills mining the raw inputs
for (const [i, f] of order) {
  const need = f.used - f.made;
  if (active[i] || need < 1e-9) continue;
  const split = lines.map((t) => { const g = perTarget[t][i]; return g ? `${nm(t)} ${fmt(pm(g.used - g.made))}` : null; }).filter(Boolean).join('；');
  const mine = mining[i];
  if (mine && !(plan.sources || {})[i]) {
    const d = raw['mining-drill'][mine.drill];
    drillPower[d.energy_source.type] = (drillPower[d.energy_source.type] || 0) + (need / mine.perDrill) * watts(d.energy_usage);
  }
  const src = (plan.sources || {})[i] || (mine ? `开采：${fmt(need / mine.perDrill)} 台${nm(mine.drill)}（每台每秒 ${fmt(mine.perDrill, 3)}）` : '');
  console.log(`| ${nm(i)}${isFluid(i) ? '（流体）' : ''} | ${fmt(pm(need))} | ${split} | ${src} |`);
}
console.log('\n## 多余的副产物（每分钟）\n');
const surplus = order.concat(Object.entries(all).filter(([, f]) => f.used < 1e-9))
  .filter(([i, f], k, a) => a.findIndex(([j]) => j === i) === k && f.made - f.used > 1e-9 && !targets[i]);
console.log(surplus.map(([i, f]) => `${nm(i)} ${fmt(pm(f.made - f.used))}`).join('、') || '无');

// Energy at full load, by what the machines run on (fractional machine counts), plus the drills
// mining the raw inputs.
const energy = { ...drillPower };
for (const [item, r] of Object.entries(active)) {
  const m = machineOf(r);
  const n = (rates[r] * (raw.recipe[r].energy_required ?? 0.5)) / speedOf(m);
  const kind = entity(m).energy_source.type;
  energy[kind] = (energy[kind] || 0) + n * watts(entity(m).energy_usage);
}
console.log(`\n## 能耗（满负荷，含开采原料的采矿机）\n\n${Object.entries(energy).map(([k, w]) => `${{ electric: '电', burner: '燃料（热能）', fluid: '燃烧流体', heat: '热', void: '无' }[k] || k} ${fmt(w / 1e6, 1)} MW`).join('、')}`);

// Fuel and its burnt result (Ash): with plan.fuel set, everything that burns uses that item:
// burner machines and drills, boilers for the process steam, and with plan.electricity = 'steam'
// the boilers behind the steam engines too.
if (plan.fuel) {
  const fuel = raw.item[plan.fuel];
  const J = watts(fuel.fuel_value);
  const boiler = raw.boiler.boiler;
  const steamHC = watts(raw.fluid.steam.heat_capacity);
  const waterT = raw.fluid.water.default_temperature;
  const boilerW = watts(boiler.energy_consumption);
  const steamPerBoiler = boilerW / (steamHC * (boiler.target_temperature - waterT));
  const engine = raw.generator['steam-engine'];
  const engineSteam = engine.fluid_usage_per_tick * 60;
  const engineW = engineSteam * steamHC * (Math.min(engine.maximum_temperature, boiler.target_temperature) - waterT) * engine.effectivity;
  const steamNeed = all.steam ? Math.max(0, all.steam.used - all.steam.made) : 0;
  const processBoilers = steamNeed / steamPerBoiler;
  const uses = [
    ['热能机器和采矿机', (energy.burner || 0) / J, `${fmt((energy.burner || 0) / 1e6, 1)} MW`],
    ['工艺蒸汽锅炉', (processBoilers * boilerW) / J, `${fmt(processBoilers, 1)} 台锅炉（每台每秒 ${fmt(steamPerBoiler, 2)} 蒸汽）`],
  ];
  if (plan.electricity === 'steam') {
    const engines = (energy.electric || 0) / engineW;
    const boilers = (engines * engineSteam) / steamPerBoiler;
    uses.push(['发电', (boilers * boilerW) / J, `${fmt(engines, 1)} 台蒸汽机（每台 ${fmt(engineW / 1e6, 2)} MW）、${fmt(boilers, 1)} 台锅炉`]);
  }
  const burnt = fuel.burnt_result;
  console.log(`\n## 燃料与${burnt ? nm(burnt) : '废料'}（燃料：${nm(plan.fuel)}，每个 ${fmt(J / 1e6, 2)} MJ）\n`);
  console.log('| 用途 | 每秒燃料 | 说明 |');
  console.log('|---|---|---|');
  for (const [k, perS, text] of uses) console.log(`| ${k} | ${fmt(perS)} | ${text} |`);
  const total = uses.reduce((a, u) => a + u[1], 0);
  console.log(`| 合计 | ${fmt(total)} | 每分钟 ${fmt(pm(total))} |`);
  if (burnt) {
    const used = all[burnt] ? Math.max(0, all[burnt].used - all[burnt].made) : 0;
    console.log(`\n每烧 1 个留下 1 个${nm(burnt)}：每分钟烧出 ${fmt(pm(total))}，计划消耗 ${fmt(pm(used))}，多出 ${fmt(pm(total - used))}。`);
  }
}

// Blocks: the plan's groups of items made together. An item that leaves its block (or a raw
// input) going to ONE other block is a direct link; going to several, it belongs on the bus.
if (plan.blocks) {
  const blockOf = {};
  for (const [b, items] of Object.entries(plan.blocks)) for (const i of items) blockOf[i] = b;
  const madeBy = Object.fromEntries(Object.entries(active).map(([i, r]) => [r, i]));
  const blockOfRecipe = (r) => blockOf[madeBy[r]] || '?';
  // Per item and block: made minus used. Blocks short of an item import it from blocks with a
  // surplus (byproducts included, e.g. cages coming back) and from raw supply.
  const links = {};
  for (const [i, f] of Object.entries(all)) {
    const net = {};
    for (const [r, v] of Object.entries(f.makers)) net[blockOfRecipe(r)] = (net[blockOfRecipe(r)] || 0) + v;
    for (const [r, v] of Object.entries(f.by)) net[blockOfRecipe(r)] = (net[blockOfRecipe(r)] || 0) - v;
    const to = Object.fromEntries(Object.entries(net).filter(([, v]) => v < -1e-9).map(([b, v]) => [b, -v]));
    if (!Object.keys(to).length) continue;
    const from = Object.fromEntries(Object.entries(net).filter(([, v]) => v > 1e-9));
    const short = Object.values(to).reduce((a, v) => a + v, 0) - Object.values(from).reduce((a, v) => a + v, 0);
    if (short > 1e-9) from['原料'] = short;
    links[i] = { from, to };
  }
  console.log('\n## 区块\n');
  console.log('| 区块 | 产物（每分钟） | 机器 | 从外面进来（每分钟） |');
  console.log('|---|---|---|---|');
  for (const [b, items] of Object.entries(plan.blocks)) {
    const made = items.filter((i) => active[i]).map((i) => `${nm(i)} ${fmt(pm(all[i].made))}`).join('、');
    const machines = {};
    for (const i of items.filter((x) => active[x])) {
      const r = active[i];
      const m = machineOf(r);
      machines[m] = (machines[m] || 0) + (rates[r] * (raw.recipe[r].energy_required ?? 0.5)) / speedOf(m);
    }
    const inputs = Object.entries(links).filter(([, l]) => l.to[b]).map(([i, l]) => `${nm(i)} ${fmt(pm(l.to[b]))}（${Object.keys(l.from).join('+')}）`).join('、');
    console.log(`| ${b} | ${made} | ${Object.entries(machines).map(([m, n]) => `${nm(m)} ${fmt(n)}`).join('、')} | ${inputs} |`);
  }
  console.log('\n## 区块之间的物流（每分钟）\n');
  console.log('| 物品 | 来自 | 去向 | 合计 | 方式 |');
  console.log('|---|---|---|---|---|');
  const rows = Object.entries(links).map(([i, l]) => [i, l, Object.values(l.to).reduce((a, v) => a + v, 0)]);
  rows.sort((a, b) => Object.keys(b[1].to).length - Object.keys(a[1].to).length || b[2] - a[2]);
  for (const [i, l, total] of rows) {
    const to = Object.entries(l.to).sort((a, b) => b[1] - a[1]).map(([b, v]) => `${b} ${fmt(pm(v))}`).join('；');
    const how = isFluid(i) ? '管道' : Object.keys(l.to).length > 1 ? '总线' : '直连';
    const from = Object.entries(l.from).map(([b, v]) => (Object.keys(l.from).length > 1 ? `${b} ${fmt(pm(v))}` : b)).join('；');
    console.log(`| ${nm(i)}${isFluid(i) ? '（流体）' : ''} | ${from} | ${to} | ${fmt(pm(total))} | ${how} |`);
  }
}

// What every machine of the plan costs to build, once.
if (args.includes('--build')) {
  const makes = {};
  for (const [r, rec] of Object.entries(raw.recipe)) {
    if (rec.hidden) continue;
    for (const p of arr(rec.results)) if (!makes[p.name] || r === p.name) makes[p.name] = r;
  }
  const cost = {};
  console.log('\n## 建造这些机器（各一次）\n');
  for (const [m, n] of Object.entries(machineCount).sort((a, b) => b[1] - a[1])) {
    const r = makes[m];
    const ins = r ? arr(raw.recipe[r].ingredients) : [];
    for (const i of ins) cost[i.name] = (cost[i.name] || 0) + i.amount * n;
    const mods = Object.entries((plan.modules || {})[m] || {}).map(([mod, c]) => `${nm(mod)}×${c * n}`).join('、');
    console.log(`- ${nm(m)} ×${n}：${ins.map((i) => `${nm(i.name)}×${i.amount}`).join('、')}${mods ? `；模块 ${mods}` : ''}`);
  }
  console.log(`\n合计：${Object.entries(cost).sort((a, b) => b[1] - a[1]).map(([i, c]) => `${nm(i)} ${c}`).join('、')}`);
}
