// Prints a recorded game (tools/companion/recorder.lua) as a Chinese timeline in fixed slices of
// game time: research, chat, what was built, removed and handcrafted, where machines went, where
// the player was, and production when a production line falls in the slice. Used to write
// chapters from the author's actual play.
// Usage: node tools/recorder-phases.js [--slice 5] [--run <id>] [recorder dir]

const { defaultRoot, option, loadRun, tech, clock, list, zh } = require('./recorder-log');

const args = process.argv.slice(2);
const slice = Number(option(args, '--slice', 5)) * 3600;
const runId = option(args, '--run');
const { run, timeline, activity, lastTick } = loadRun(args[0] || defaultRoot, runId);

const GROUPS = [['built', '手动建造'], ['robot_built', '机器人建造'], ['ghosts', '放置虚影'],
  ['mined', '手动拆除/采集'], ['robot_mined', '机器人拆除'], ['ghosts_removed', '移除虚影'],
  ['died', '被摧毁'], ['tiles', '铺地砖'], ['tiles_mined', '拆地砖']];

// Machines of one name placed within 12 tiles of each other count as one spot.
function spots(machines) {
  const byName = {};
  for (const [name, x, y] of machines) {
    const list = byName[name] || (byName[name] = []);
    const near = list.find((s) => Math.abs(s.x - x) <= 12 && Math.abs(s.y - y) <= 12);
    if (near) {
      near.n += 1;
      near.x = (near.x * (near.n - 1) + x) / near.n;
      near.y = (near.y * (near.n - 1) + y) / near.n;
    } else list.push({ x, y, n: 1 });
  }
  return Object.entries(byName).map(([name, list]) => `${zh(name)} ${list
    .map((s) => `×${s.n} (${Math.round(s.x)}, ${Math.round(s.y)})`).join('、')}`).join('；');
}

console.log(`运行 ${run.name}，按每 ${slice / 3600} 分钟游戏时间分段`);
for (let start = 0; start <= lastTick; start += slice) {
  const end = start + slice;
  const inSlice = (l) => l.t >= start && l.t < end;
  const events = timeline.filter(inSlice);
  const minutes = activity.filter((l) => l.k === 'minute' && inSlice(l));
  const production = activity.filter((l) => l.k === 'production' && inSlice(l));
  console.log(`\n## ${clock(start)}–${clock(end)}`);

  for (const e of events) {
    if (e.k === 'research_finished') console.log(`研究完成 ${clock(e.t)}：${tech(e.name)}${e.by_script ? '（脚本）' : ''}`);
    else if (e.k === 'research_started') console.log(`开始研究 ${clock(e.t)}：${tech(e.name)}`);
    else if (e.k === 'chat') console.log(`留言 ${clock(e.t)}：${e.message}`);
    else if (e.k === 'config') console.log(`配置变化 ${clock(e.t)}`);
  }

  const sums = {};
  const crafted = {};
  const machines = [];
  const positions = [];
  for (const l of minutes) {
    if (l.players) for (const [, p] of Object.entries(l.players)) positions.push(p);
    for (const [n, c] of Object.entries(l.crafted || {})) crafted[n] = (crafted[n] || 0) + c;
    for (const [surface, b] of Object.entries(l.surfaces || {})) {
      for (const [group] of GROUPS) {
        for (const [n, c] of Object.entries(b[group] || {})) {
          const key = surface === 'nauvis' ? group : `${group}@${surface}`;
          sums[key] = sums[key] || {};
          sums[key][n] = (sums[key][n] || 0) + c;
        }
      }
      for (const m of b.machines || []) machines.push(m);
    }
  }
  for (const [key, counts] of Object.entries(sums)) {
    const [group, surface] = key.split('@');
    const label = (GROUPS.find(([g]) => g === group) || [group, group])[1];
    console.log(`${label}${surface ? `（${surface}）` : ''}：${list(counts, 12)}`);
  }
  if (machines.length) console.log(`机器位置：${spots(machines)}`);
  if (Object.keys(crafted).length) console.log(`手搓：${list(crafted, 12)}`);
  if (positions.length) {
    const xs = positions.map((p) => p[0]);
    const ys = positions.map((p) => p[1]);
    console.log(`玩家活动范围：x ${Math.min(...xs)}..${Math.max(...xs)}，y ${Math.min(...ys)}..${Math.max(...ys)}`);
  }
  for (const p of production) {
    for (const [surface, entry] of Object.entries(p.surfaces)) {
      const perMinute = (counts) => Object.fromEntries(Object.entries(counts || {}).map(([n, v]) => [n, Math.round(v)]));
      console.log(`产量 ${clock(p.t)} ${surface}（前 10 分钟合计）：产出 ${list(perMinute(entry.items_produced), 10)}`);
      if (entry.items_consumed) console.log(`  消耗 ${list(perMinute(entry.items_consumed), 10)}`);
    }
  }
}
