// Prints a Chinese summary of the snapshot written by tools/inspect-save.ps1, using the zh-CN
// locale dump (run factorio --dump-prototype-locale with locale=zh-CN in the dump config).
// Usage: node tools/summarize-save.js [snapshot dir]

const paths = require('./paths');
const dir = process.argv[2] || paths.save;
const report = require(`${dir}/save-report.json`);
const entities = Object.values(require(`${dir}/entities.json`)); // an empty list is written as {}
const load = (kind) => { try { return require(`${paths.dump}/${kind}-locale.json`).names; } catch { return {}; } };
const L = { item: load('item'), entity: load('entity'), recipe: load('recipe'), technology: load('technology'), fluid: load('fluid') };
const zh = (kind, name) => (L[kind] && L[kind][name]) || L.item[name] || L.entity[name] || L.fluid[name] || name;
const top = (obj, n) => Object.entries(obj || {}).sort((a, b) => b[1] - a[1]).slice(0, n);
const fmt = (v) => (v >= 1e6 ? (v / 1e6).toFixed(1) + 'M' : v >= 1e3 ? (v / 1e3).toFixed(1) + 'k' : String(Math.round(v)));
const h = (title) => console.log(`\n## ${title}`);

// game.tick stands still while the game is tick-paused (Factory Planner's pause option, for one);
// ticks_played keeps counting, so the difference is the time spent paused.
const hours = report.tick / 60 / 3600;
const paused = (report.ticks_played - report.tick) / 60 / 3600;
console.log(`游戏时长 ${hours.toFixed(1)} 小时（tick ${report.tick}）${paused >= 0.05 ? `，另有 ${paused.toFixed(1)} 小时游戏停住（如 Factory Planner 的暂停）` : ''}`);
const changed = Object.entries((report.config && report.config.mod_changes) || {});
if (changed.length || (report.config && report.config.startup_settings_changed)) {
  console.log(`注意：读档环境与存档不一致（${changed.map(([n, c]) => `${n} ${c.old || '无'}→${c.new || '无'}`).join('，')}${report.config.startup_settings_changed ? ' 启动设置不同' : ''}）`);
}

h('地图设置');
const map = report.map || {};
console.log(`种子 ${map.seed}，起始区域 ${map.starting_area}，无敌人模式 ${map.no_enemies}，和平模式 ${map.peaceful}，虫巢扩张 ${report.enemy_expansion}，科技价格倍率 ${report.technology_price_multiplier}`);
const controls = map.autoplace_controls || {};
const unusual = Object.entries(controls).filter(([, c]) => c.frequency !== 1 || c.size !== 1 || c.richness !== 1);
const r3 = (x) => Math.round(x * 1000) / 1000;
console.log(unusual.length ? '非默认资源设置：' + unusual.map(([n, c]) => `${n}(频率${r3(c.frequency)} 大小${r3(c.size)} 丰度${r3(c.richness)})`).join('，') : '资源生成全部为默认值');
const expressions = Object.entries((report.map_gen_settings || {}).property_expression_names || {});
if (expressions.length) console.log('地形表达式：' + expressions.map(([k, v]) => `${k} = ${v}`).join('，'));
const adv = report.advanced_settings; // inspectors from 2026-10-08 on
if (adv && !adv.error) {
  const ex = adv.enemy_expansion;
  console.log(`污染 ${adv.pollution.enabled ? '开' : '关'}；进化系数 时间 ${adv.enemy_evolution.time_factor}、摧毁 ${adv.enemy_evolution.destroy_factor}、污染 ${adv.enemy_evolution.pollution_factor}；` +
    `扩张 ${ex.enabled ? `开（最远 ${ex.max_expansion_distance} 区块，冷却 ${ex.min_expansion_cooldown / 3600}–${ex.max_expansion_cooldown / 3600} 分钟）` : '关'}；` +
    `腐坏时间倍率 ${adv.difficulty_settings.spoil_time_modifier}`);
}

h('研究');
const r = report.research;
console.log(`已研究 ${r.researched.length} 项；当前研究：${r.current ? zh('technology', r.current) + `（${(r.progress * 100).toFixed(0)}%）` : '无'}`);
if (r.queue.length) console.log('研究队列：' + r.queue.map((t) => zh('technology', t)).join(' → '));
console.log('已研究：' + r.researched.map((t) => zh('technology', t)).join('、'));
console.log('现在可研究：' + r.available.map((t) => zh('technology', t)).join('、'));

h('玩家');
for (const p of Object.values(report.players || {})) { // {} when the save has no players
  console.log(`${p.name} @ (${Math.round(p.position.x)}, ${Math.round(p.position.y)}) ${p.surface}，控制方式 ${p.controller}`);
  console.log('背包：' + p.inventory.sort((a, b) => b.count - a.count).map((i) => `${zh('item', i.name)}×${i.count}`).join('、'));
  if (p.crafting_queue.length) console.log('手搓队列：' + p.crafting_queue.map((c) => `${zh('recipe', c.recipe)}×${c.count}`).join('、'));
}

h('已建造（按数量）');
const byName = {};
for (const e of entities) byName[e.ghost ? `${e.ghost}（虚影）` : e.name] = (byName[e.ghost ? `${e.ghost}（虚影）` : e.name] || 0) + 1;
console.log(top(byName, 50).map(([n, c]) => `${n.endsWith('（虚影）') ? zh('entity', n.slice(0, -4)) + '（虚影）' : zh('entity', n)}×${c}`).join('、'));
const box = report.base_box;
if (box) console.log(`基地范围：x ${Math.round(box.x1)}..${Math.round(box.x2)}，y ${Math.round(box.y1)}..${Math.round(box.y2)}（${Math.round(box.x2 - box.x1)}×${Math.round(box.y2 - box.y1)} 格）`);

h('机器在做什么');
const byRecipe = {};
for (const e of entities) if (e.recipe) {
  const key = `${e.recipe}|${e.name}`;
  byRecipe[key] = (byRecipe[key] || 0) + 1;
}
console.log(top(byRecipe, 60).map(([k, c]) => { const [rec, m] = k.split('|'); return `${zh('recipe', rec)}（${zh('entity', m)}×${c}）`; }).join('\n'));
const idle = entities.filter((e) => (e.type === 'assembling-machine') && !e.recipe).length;
if (idle) console.log(`未设置配方的组装类机器：${idle} 台`);

// Ore left under each drill (save inspector): drills over a mined-out spot have stopped for
// good, and rows are often built longer than needed on purpose, so downstream drills take over
// when upstream ones run dry.
h('采矿机下方剩余矿量');
const drills = entities.filter((e) => e.type === 'mining-drill');
const byResource = {};
for (const d of drills) {
  const left = Object.values(d.ore || {}).reduce((a, b) => a + b, 0);
  const key = d.target || Object.keys(d.ore || {})[0] || '无矿';
  const r = byResource[key] || (byResource[key] = { drills: 0, empty: 0, low: 0, total: 0, status: {} });
  r.drills += 1;
  r.total += left;
  if (left === 0) r.empty += 1;
  else if (left < 1000) r.low += 1;
  r.status[d.status] = (r.status[d.status] || 0) + 1;
}
for (const [name, r] of Object.entries(byResource)) {
  const status = Object.entries(r.status).map(([s, c]) => `${s} ${c}`).join('，');
  console.log(`${zh('entity', name)}：${r.drills} 台，下方共剩 ${fmt(r.total)}；已采空 ${r.empty} 台，少于 1000 的 ${r.low} 台（状态：${status}）`);
}

h('累计产量（前 30）');
const items = report.items || {};
console.log(top(items.produced, 30).map(([n, c]) => `${zh('item', n)} ${fmt(c)}`).join('、'));
h('累计流体产量（前 15）');
console.log(top((report.fluids || {}).produced, 15).map(([n, c]) => `${zh('fluid', n)} ${fmt(c)}`).join('、'));

h('全地图资源（已生成区域内的矿格数）');
const tiles = Object.entries(report.resource_tiles || {}).sort((a, b) => b[1] - a[1]);
console.log(tiles.length ? tiles.map(([n, c]) => `${zh('entity', n)} ${c}`).join('、') : '（报告里没有这项）');

h('基地附近资源（按区块聚合的矿区）');
const patches = {};
for (const b of report.resources || []) {
  const list = (patches[b.name] = patches[b.name] || []);
  let patch = list.find((p) => p.chunks.some(([x, y]) => Math.abs(x - b.cx) <= 1 && Math.abs(y - b.cy) <= 1));
  if (!patch) { patch = { chunks: [], amount: 0, tiles: 0 }; list.push(patch); }
  patch.chunks.push([b.cx, b.cy]);
  patch.amount += b.amount;
  patch.tiles += b.tiles;
}
const cx = box ? (box.x1 + box.x2) / 2 : 0, cy = box ? (box.y1 + box.y2) / 2 : 0;
for (const [name, list] of Object.entries(patches)) {
  const desc = list.sort((a, b) => b.amount - a.amount).map((p) => {
    const px = p.chunks.reduce((s, c) => s + c[0], 0) / p.chunks.length * 32 + 16;
    const py = p.chunks.reduce((s, c) => s + c[1], 0) / p.chunks.length * 32 + 16;
    return `(${Math.round(px)}, ${Math.round(py)}) 距基地中心 ${Math.round(Math.hypot(px - cx, py - cy))} 格，储量 ${fmt(p.amount)}`;
  });
  console.log(`${zh('entity', name)}：${desc.join('；')}`);
}
console.log(`扫描范围内敌方实体：${report.enemies_near}`);
