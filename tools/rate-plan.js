// Solves a production plan from the prototype data dump: per-minute targets plus ONE chosen recipe
// for every item the plan makes itself. All recipe rates are solved together, so byproducts and
// returned items (cages, barrels) are netted out. Prints, per minute:
//   - every recipe's crafts and machines (machine speed with the plan's modules),
//   - every item: produced, consumed, by which recipes, and which targets (product lines) use it,
//   - raw inputs (with drill counts for mined resources) and surplus byproducts,
//   - power, and with plan.fuel the fuel burnt (boilers and steam engines included) and its Ash,
//   - with plan.blocks: each block's products, machines, inputs and byproducts to buffer, and
//     the flows between blocks (bus or direct link). plan.local = 'free' makes every item that
//     needs nothing or only Water in the blocks that use it; plan.carry moves an item between
//     blocks in a packed form (Stone as Stone bricks), packing and unpacking included,
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
// The recipes of machines a script runs (the Digosaurus dig site) come with the machine.
const sources = require('./sources')(raw);
const unlocked = (r) => raw.recipe[r].enabled !== false || scripted.has(r) || (unlockedBy[r] || []).some((t) => techs.has(t));
const viaMachine = new Set(sources.machineRecipes(unlocked));
const usable = (r) => unlocked(r) || viaMachine.has(r);

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
    for (const [i, a] of Object.entries(out)) { get(i).made += a * n; get(i).makers[r] = (get(i).makers[r] || 0) + a * n; }
    for (const [i, a] of Object.entries(inn)) { get(i).used += a * n; get(i).by[r] = (get(i).by[r] || 0) + a * n; }
  }
  return items;
};
let all = flows(rates);
const perTarget = Object.fromEntries(Object.keys(targets).map((t) => [t, flows(run({ [t]: targets[t] }))]));
const isFluid = (i) => !!raw.fluid[i];
const pm = (v) => v * 60;
const sum = (o) => Object.values(o).reduce((a, v) => a + v, 0);

// ---- blocks: which block runs how many crafts of each recipe -------------------------------------
const madeBy = Object.fromEntries(Object.entries(active).map(([i, r]) => [r, i]));
const blockOf = {};
for (const [b, items] of Object.entries(plan.blocks || {})) for (const i of items) blockOf[i] = b;
const homeOf = (r) => blockOf[madeBy[r]] || (plan.blocks ? '?' : '全部');

// Items made from nothing or from free inputs only (Water by default), directly or through other
// such items, found as the largest set closed under the chosen recipes (so self-feeding loops like
// Moondrop <-> Moondrop seeds count). With plan.local = 'free' every block that uses one makes its
// own share: no item of that kind travels between blocks.
const freeInputs = new Set(plan.freeInputs || ['water']);
const local = new Set(plan.local === 'free' ? Object.keys(active) : []);
for (let changed = true; changed;) {
  changed = false;
  for (const i of [...local]) {
    if (targets[i] || Object.keys(io(active[i]).inn).some((j) => !local.has(j) && !freeInputs.has(j))) { local.delete(i); changed = true; }
  }
}
// Shares: the fraction of a recipe's crafts each block runs. A local item's recipe is shared out
// like its consumption; loops between local items settle by iteration.
const share = {};
for (const r of Object.keys(rates)) share[r] = local.has(madeBy[r]) ? {} : { [homeOf(r)]: 1 };
for (let k = 0; k < 300; k++) {
  for (const i of local) {
    const by = (all[i] || { by: {} }).by;
    const total = sum(by);
    const s = {};
    for (const [c, v] of Object.entries(by)) for (const [b, w] of Object.entries(share[c] || {})) s[b] = (s[b] || 0) + (v / total) * w;
    share[active[i]] = s;
  }
}
const own = {}; // recipe -> { block: crafts per second }
for (const [r, x] of Object.entries(rates)) own[r] = Object.fromEntries(Object.entries(share[r]).map(([b, w]) => [b, w * x]));
const netByBlock = (i) => {
  const net = {};
  for (const [r, perBlock] of Object.entries(own)) {
    const { out, inn } = io(r);
    if (!out[i] && !inn[i]) continue;
    for (const [b, c] of Object.entries(perBlock)) net[b] = (net[b] || 0) + ((out[i] || 0) - (inn[i] || 0)) * c;
  }
  return net;
};

// Carried forms (plan.carry): an item travels between blocks packed as another, e.g. Stone as
// Stone bricks. Blocks with Stone to spare pack it, blocks short of Stone unpack bricks; Stone from
// outside is packed in the block `packIn`. The extra crafts count everywhere (machines, power).
const carried = {};
for (const [x, spec] of Object.entries(plan.carry || {})) {
  const perPack = io(spec.pack).inn[x];
  const perUnpack = io(spec.unpack).out[x];
  const net = netByBlock(x);
  const add = (r, b, c) => {
    own[r] = own[r] || {};
    own[r][b] = (own[r][b] || 0) + c;
    rates[r] = (rates[r] || 0) + c;
  };
  // The packing block takes outside Stone as it comes; only the other blocks pack and unpack.
  let spare = 0;
  let short = 0;
  for (const [b, v] of Object.entries(net)) {
    if (b === spec.packIn) continue;
    if (v > 1e-9) { add(spec.pack, b, v / perPack); spare += v; }
    if (v < -1e-9) { add(spec.unpack, b, -v / perUnpack); short -= v; }
  }
  if (short > spare + 1e-9) add(spec.pack, spec.packIn, (short - spare) / perPack);
  carried[x] = spec;
}
if (Object.keys(carried).length) all = flows(rates);
const label = (r) => {
  for (const [x, spec] of Object.entries(carried)) {
    if (r === spec.unpack) return `解包：${nm(spec.as)} → ${nm(x)}`;
  }
  return nm(madeBy[r] || r);
};
const crafts = (r, c) => (c * (raw.recipe[r].energy_required ?? 0.5)) / speedOf(machineOf(r));

console.log(`# ${plan.title || path.basename(args[0])}`);
console.log(`\n目标（每分钟）：${Object.entries(plan.targets).map(([k, v]) => `${nm(k)} ${v}`).join('、')}`);
if (plan.techs) console.log(`可用配方：开局 + ${techs.size} 项科技（${plan.techs.join('、')} 及其前置）`);

// Recipes and machines.
console.log('\n## 配方与机器\n');
console.log('| 配方 | 产物 | 每分钟次数 | 机器 | 速度 | 台数 |');
console.log('|---|---|---|---|---|---|');
for (const [item, r] of Object.entries(chosen)) if (!active[item]) console.log(`| ${rn(r)} | ${nm(item)} | 0（副产物已够） | | | |`);
for (const [r, x] of Object.entries(rates)) {
  const m = machineOf(r);
  console.log(`| ${rn(r)} | ${label(r)} | ${fmt(pm(x))} | ${nm(m)} | ${fmt(speedOf(m), 3)} | ${fmt(crafts(r, x))} |`);
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
  const map = sources.mapSources[i] ? `⚠ 只有地图上有限的${[...new Set(sources.mapSources[i].map((s) => nm(s.entity)))].slice(0, 3).join('/')}，采完不再生` : '';
  const src = (plan.sources || {})[i] || (mine ? `开采：${fmt(need / mine.perDrill)} 台${nm(mine.drill)}（每台每秒 ${fmt(mine.perDrill, 3)}）` : map);
  console.log(`| ${nm(i)}${isFluid(i) ? '（流体）' : ''} | ${fmt(pm(need))} | ${split} | ${src} |`);
}
console.log('\n## 多余的副产物（每分钟）\n');
const surplus = Object.entries(all).filter(([i, f]) => f.made - f.used > 1e-9 && !targets[i]).sort((a, b) => (b[1].made - b[1].used) - (a[1].made - a[1].used));
console.log(surplus.map(([i, f]) => `${nm(i)} ${fmt(pm(f.made - f.used))}`).join('、') || '无');

// Energy at full load, by what the machines run on (fractional machine counts), plus the drills
// mining the raw inputs.
const energy = { ...drillPower };
for (const [r, x] of Object.entries(rates)) {
  const m = machineOf(r);
  const kind = entity(m).energy_source.type;
  energy[kind] = (energy[kind] || 0) + crafts(r, x) * watts(entity(m).energy_usage);
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

// Machines per block (fractional), from the shares.
const blocks = [...new Set([...Object.keys(plan.blocks || {}), ...Object.values(own).flatMap((o) => Object.keys(o))])];
const machinesIn = (b) => {
  const m = {};
  for (const [r, perBlock] of Object.entries(own)) {
    if (!perBlock[b]) continue;
    const name = machineOf(r);
    m[name] = (m[name] || 0) + crafts(r, perBlock[b]);
  }
  return m;
};

if (plan.blocks) {
  // Links: per item and block, made minus used. Blocks short of an item import it from blocks with
  // some to spare (byproducts included, e.g. cages coming back) and from raw supply.
  const links = {};
  for (const i of Object.keys(all)) {
    const net = netByBlock(i);
    const to = Object.fromEntries(Object.entries(net).filter(([, v]) => v < -1e-9).map(([b, v]) => [b, -v]));
    if (!Object.keys(to).length) continue;
    const from = Object.fromEntries(Object.entries(net).filter(([, v]) => v > 1e-9));
    const short = sum(to) - sum(from);
    if (short > 1e-9) from['原料'] = short;
    links[i] = { from, to };
  }

  if (local.size) {
    console.log('\n## 现用现制：只靠水（或凭空）就能做的物品，在用它的区块里就地生产\n');
    for (const i of local) {
      const r = active[i];
      const per = Object.entries(own[r] || {}).filter(([, c]) => c > 1e-12).sort((a, b) => b[1] - a[1]);
      console.log(`- ${nm(i)}（${rn(r)}，${nm(machineOf(r))}）：${per.map(([b, c]) => `${b} ${fmt(crafts(r, c))} 台`).join('、')}`);
    }
  }

  console.log('\n## 区块\n');
  console.log('| 区块 | 产物（每分钟） | 机器 | 从外面进来（每分钟） | 副产物：要缓存（每分钟） |');
  console.log('|---|---|---|---|---|');
  for (const b of blocks) {
    // Products: the items the block's recipes are run for, counted over all its recipes;
    // everything else they give is a byproduct.
    const mains = new Set();
    const outputs = {};
    for (const [r, perBlock] of Object.entries(own)) {
      const c = perBlock[b];
      if (!c || c < 1e-12) continue;
      mains.add(madeBy[r] || Object.keys(carried).find((x) => carried[x].unpack === r));
      for (const [i, a] of Object.entries(io(r).out)) outputs[i] = (outputs[i] || 0) + a * c;
    }
    const made = [...mains].filter((i) => outputs[i]).map((i) => `${nm(i)}${local.has(i) ? '（现制）' : ''} ${fmt(pm(outputs[i]))}`);
    const byproducts = Object.fromEntries(Object.entries(outputs).filter(([i]) => !mains.has(i)));
    // A byproduct needs a buffer when it leaves the block or is left over.
    const leaving = Object.entries(byproducts).map(([i]) => [i, netByBlock(i)[b] || 0]).filter(([, v]) => v > 1e-9);
    // A byproduct packed for the bus (Stone as bricks) still needs its buffer, now as the pack.
    for (const [x, spec] of Object.entries(carried)) {
      const c = (own[spec.pack] || {})[b];
      if (b !== spec.packIn && c > 1e-12) leaving.push([spec.as, io(spec.pack).out[spec.as] * c, x]);
    }
    const inputs = Object.entries(links).filter(([, l]) => l.to[b]).map(([i, l]) => `${nm(i)} ${fmt(pm(l.to[b]))}（${Object.keys(l.from).join('+')}）`).join('、');
    console.log(`| ${b} | ${made.join('、')} | ${Object.entries(machinesIn(b)).map(([m, n]) => `${nm(m)} ${fmt(n)}`).join('、')} | ${inputs} | ${leaving.map(([i, v, x]) => `${nm(i)} ${fmt(pm(v))}${x ? `（由${nm(x)}打包）` : ''}`).join('、')} |`);
  }

  console.log('\n## 区块之间的物流（每分钟）\n');
  console.log('| 物品 | 来自 | 去向 | 合计 | 方式 |');
  console.log('|---|---|---|---|---|');
  const rows = Object.entries(links).map(([i, l]) => [i, l, sum(l.to)]);
  rows.sort((a, b) => Object.keys(b[1].to).length - Object.keys(a[1].to).length || b[2] - a[2]);
  for (const [i, l, total] of rows) {
    const to = Object.entries(l.to).sort((a, b) => b[1] - a[1]).map(([b, v]) => `${b} ${fmt(pm(v))}`).join('；');
    const how = isFluid(i) ? '管道' : Object.keys(l.to).length > 1 ? '总线' : '直连';
    const from = Object.entries(l.from).map(([b, v]) => (Object.keys(l.from).length > 1 ? `${b} ${fmt(pm(v))}` : b)).join('；');
    console.log(`| ${nm(i)}${isFluid(i) ? '（流体）' : ''} | ${from} | ${to} | ${fmt(pm(total))} | ${how} |`);
  }
}

// What every machine of the plan costs to build, once (whole machines per block).
if (args.includes('--build')) {
  const machineCount = {};
  for (const b of blocks) for (const [m, n] of Object.entries(machinesIn(b))) machineCount[m] = (machineCount[m] || 0) + Math.ceil(n - 1e-9);
  const makes = {};
  for (const [r, rec] of Object.entries(raw.recipe)) {
    if (rec.hidden) continue;
    for (const p of arr(rec.results)) if (!makes[p.name] || r === p.name) makes[p.name] = r;
  }
  const cost = {};
  console.log(`\n## 建造这些机器（各一次${plan.blocks ? '，每个区块各自向上取整' : ''}）\n`);
  for (const [m, n] of Object.entries(machineCount).sort((a, b) => b[1] - a[1])) {
    const r = makes[m];
    const ins = r ? arr(raw.recipe[r].ingredients) : [];
    for (const i of ins) cost[i.name] = (cost[i.name] || 0) + i.amount * n;
    const mods = Object.entries((plan.modules || {})[m] || {}).map(([mod, c]) => `${nm(mod)}×${c * n}`).join('、');
    console.log(`- ${nm(m)} ×${n}：${ins.map((i) => `${nm(i.name)}×${i.amount}`).join('、')}${mods ? `；模块 ${mods}` : ''}`);
  }
  console.log(`\n合计：${Object.entries(cost).sort((a, b) => b[1] - a[1]).map(([i, c]) => `${nm(i)} ${c}`).join('、')}`);
}
