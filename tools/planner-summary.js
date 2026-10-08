// Prints the Factory Planner factories written by the companion mod (tools/companion/planner.lua)
// in Chinese: targets, the factory's inputs, byproducts and power, and every line with its machine
// count and rates per minute (subfloors indented). Names come from the zh-CN locale dump.
// Usage: node tools/planner-summary.js [--factory <part of the name>] [planner dir]
//   default dir: %APPDATA%\Factorio\script-output\py-tutorial-companion\planner; all factories,
//   most recently written first.

const fs = require('fs');
const path = require('path');
const { option, zh, clock } = require('./recorder-log');

const args = process.argv.slice(2);
const filter = option(args, '--factory');
const root = args[0] || path.join(process.env.APPDATA || '', 'Factorio', 'script-output',
  'py-tutorial-companion', 'planner');

const load = (kind) => { try { return require(`${require('./paths').dump}/${kind}-locale.json`).names; } catch { return {}; } };
const recipeNames = load('recipe');
// FP's own recipes for offshore pumps and the like are named "impostor-…".
const recipe = (name) => recipeNames[name] || zh(name.replace(/^impostor-/, ''));
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));
const num = (v) => (Math.abs(v) >= 100 ? Math.round(v) : Math.round(v * 100) / 100);
// FP gives item amounts per second; fluids are named "<fluid>|<temperature>"; electric power comes
// as the item "custom-electric-power" in W, and tiles under pumps as other "custom-…" items.
const POWER = 'custom-electric-power';
const label = (name) => {
  const [base, temperature] = name.split('|');
  return temperature !== undefined ? `${zh(base)}（${temperature}°）` : zh(base);
};
const rates = (items) => arr(items).filter((i) => !i.proto.name.startsWith('custom-') && Math.abs(i.amount * 60) >= 0.005)
  .map((i) => `${label(i.proto.name)}×${num(i.amount * 60)}`).join(' + ') || '—';
const power = (items) => arr(items).filter((i) => i.proto.name === POWER).reduce((s, i) => s + i.amount, 0);
const mw = (w) => `${num(w / 1e6)} MW`;

function printLines(floor, depth) {
  for (const line of arr(floor.lines)) {
    const pad = '  '.repeat(depth);
    if (line.class === 'Floor') {
      const top = arr(line.lines)[0];
      console.log(`${pad}- 子楼层（${top ? recipe(top.recipe.proto.name) : '?'}）：原料 ${rates(line.ingredients)} → 产物 ${rates(line.products)}`);
      printLines(line, depth + 1);
      continue;
    }
    const m = line.machine;
    const fuel = m.fuel ? `，燃料 ${zh(m.fuel.proto.name)}×${num((m.fuel.amount || 0) * 60)}` : '';
    const modules = arr(m.module_set && m.module_set.modules).map((x) => `${zh(x.proto.name)}×${x.amount}`).join('、');
    const watts = power(line.ingredients);
    console.log(`${pad}- ${recipe(line.recipe.proto.name)}${line.active === false ? '（停用）' : ''}：${zh(m.proto.name)}×${num(m.amount || 0)}` +
      `${fuel}${modules ? `，插件 ${modules}` : ''}${watts ? `，${mw(watts)}` : ''}${line.done ? '，已完成' : ''}`);
    console.log(`${pad}  ${rates(line.ingredients)} → ${rates(line.products)}${arr(line.byproducts).length ? `；副产物 ${rates(line.byproducts)}` : ''}`);
    if (line.comment) console.log(`${pad}  备注：${line.comment}`);
  }
}

const files = fs.existsSync(root) ? fs.readdirSync(root).filter((f) => f.endsWith('.json'))
  .map((f) => ({ f, ...fs.statSync(path.join(root, f)) })).sort((a, b) => b.mtimeMs - a.mtimeMs) : [];
if (!files.length) console.log(`还没有导出的工厂（${root}）`);
for (const { f, mtimeMs } of files) {
  const data = JSON.parse(fs.readFileSync(path.join(root, f), 'utf8'));
  const factory = data.factory;
  if (filter && !factory.name.includes(filter)) continue;
  const top = factory.top_floor;
  console.log(`\n## ${factory.name}`);
  console.log(`写出于游戏时间 ${clock(data.tick)}（${data.run || '?'}，${new Date(mtimeMs).toLocaleString('zh-CN')}），求解器 ${top.solver}，文件 ${f}`);
  console.log(`目标（每分钟）：${arr(factory.products).map((p) => {
    const d = p.definition || {};
    const want = d.type === 'amount' ? num(d.amount * 60) : d.type === 'belts' ? `${d.belt_count} 条带` : `${d.machine_count} 台机器`;
    return `${zh(p.proto.name)} 要 ${want}，满足 ${num(p.amount * 60)}`;
  }).join('；')}`);
  console.log(`工厂输入（每分钟）：${rates(top.ingredients)}`);
  if (arr(top.byproducts).length) console.log(`副产物（每分钟）：${rates(top.byproducts)}`);
  if (arr(top.products).length) console.log(`多出的产物（每分钟）：${rates(top.products)}`);
  const watts = power(top.ingredients);
  if (watts) console.log(`耗电：${mw(watts)}`);
  if (factory.notes) console.log(`工厂备注：${factory.notes}`);
  console.log('产线：');
  printLines(top, 0);
}
