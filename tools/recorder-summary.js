// Prints a Chinese summary of a game recorded by the companion mod (tools/companion/recorder.lua):
// log sizes and growth, mod changes, research timeline, chat, the last N minutes of activity and
// the latest production. Names come from the zh-CN locale dump in C:\tmp\cf-dump (if present).
// Usage: node tools/recorder-summary.js [--minutes 30] [--run <id>] [recorder dir]
//   default dir: %APPDATA%\Factorio\script-output\py-tutorial-companion\recorder; the run whose
//   files changed last is used unless --run is given.

const { defaultRoot, option, loadRun, tech, clock, list, productionMinutes } = require('./recorder-log');

const args = process.argv.slice(2);
const minutes = Number(option(args, '--minutes', 30));
const runId = option(args, '--run');
const { run, timeline, segments, live, activity, firstTick, lastTick } = loadRun(args[0] || defaultRoot, runId);

const size = (b) => (b >= 1048576 ? `${(b / 1048576).toFixed(2)} MB` : `${(b / 1024).toFixed(1)} KB`);
const h = (title) => console.log(`\n## ${title}`);

h('记录');
const total = run.files.reduce((sum, f) => sum + f.size, 0);
const timelineSize = (run.files.find((f) => f.name === 'timeline.jsonl') || { size: 0 }).size;
const liveSize = live.reduce((sum, f) => sum + f.size, 0);
const hours = (lastTick - firstTick) / 216000;
console.log(`运行 ${run.name}：游戏时间 ${clock(firstTick)} 到 ${clock(lastTick)}（记录了 ${hours.toFixed(2)} 小时）`);
console.log(`文件 ${run.files.length} 个，共 ${size(total)}；时间线 ${size(timelineSize)}，活动日志 ${segments.length} 段（有效 ${live.length} 段，${size(liveSize)}）`);
// Rotation may have deleted the oldest segments, so the activity rate uses the span still on disk.
const activityHours = activity.length ? (lastTick - activity[0].t) / 216000 : 0;
if (hours >= 1 && activityHours >= 1) { // shorter spans are dominated by the start lines
  console.log(`增长：每游戏小时约 ${size(timelineSize / hours + liveSize / activityHours)}`);
}

h('模组');
for (const line of timeline.filter((l) => l.k === 'start' || l.k === 'config')) {
  if (line.k === 'start') console.log(`${clock(line.t)} 开始记录：种子 ${line.seed}，模组 ${Object.keys(line.mods).length} 个`);
  else {
    const changes = Object.entries(line.mods_changed || {}).map(([n, [a, b]]) => `${n} ${a || '无'}→${b || '无'}`);
    console.log(`${clock(line.t)} 配置变化：${changes.join('，') || '无模组变化'}${line.startup_settings_changed ? '；启动设置有变' : ''}`);
  }
}

h('研究');
const finished = timeline.filter((l) => l.k === 'research_finished');
console.log(`已完成 ${finished.length} 项`);
for (const l of finished) console.log(`  ${clock(l.t)} ${tech(l.name)}${l.level > 1 ? ` ${l.level}` : ''}${l.by_script ? '（脚本）' : ''}`);
const started = timeline.filter((l) => l.k === 'research_started');
const current = started.length && started[started.length - 1];
if (current && !finished.some((f) => f.t >= current.t && f.name === current.name)) {
  console.log(`  当前：${tech(current.name)}（${clock(current.t)} 开始）`);
}

h('聊天与命令');
const talk = timeline.filter((l) => l.k === 'chat' || l.k === 'command').slice(-20);
if (!talk.length) console.log('无');
for (const l of talk) {
  console.log(l.k === 'chat' ? `  ${clock(l.t)} ${l.player || '服务器'}：${l.message}`
    : `  ${clock(l.t)} /${l.command}${l.parameters ? ` ${l.parameters}` : ''}`);
}

h(`最近 ${minutes} 分钟`);
const recent = activity.filter((l) => l.k === 'minute' && l.t > lastTick - minutes * 3600);
const sums = {};
const crafted = {};
let lastPlayers;
for (const l of recent) {
  if (l.players) lastPlayers = l.players;
  for (const [n, c] of Object.entries(l.crafted || {})) crafted[n] = (crafted[n] || 0) + c;
  for (const [surface, b] of Object.entries(l.surfaces || {})) {
    for (const [group, value] of Object.entries(b)) {
      const key = `${surface}|${group}`;
      if (group === 'area') {
        const a = sums[key] || [Infinity, Infinity, -Infinity, -Infinity];
        sums[key] = [Math.min(a[0], value[0]), Math.min(a[1], value[1]), Math.max(a[2], value[2]), Math.max(a[3], value[3])];
      } else if (group === 'machines') {
        const counts = sums[key] || {};
        for (const [name] of value) counts[name] = (counts[name] || 0) + 1;
        sums[key] = counts;
      } else {
        const counts = sums[key] || {};
        for (const [n, c] of Object.entries(value)) counts[n] = (counts[n] || 0) + c;
        sums[key] = counts;
      }
    }
  }
}
const GROUPS = { built: '手动建造', robot_built: '机器人建造', ghosts: '放置虚影', machines: '其中机器', mined: '手动拆除/采集', robot_mined: '机器人拆除', ghosts_removed: '移除虚影', died: '被摧毁', tiles: '铺地砖', tiles_mined: '拆地砖' };
if (lastPlayers) console.log(`玩家位置：${Object.entries(lastPlayers).map(([n, [x, y, s]]) => `${n} (${x}, ${y}) @${s}`).join('，')}`);
for (const [key, value] of Object.entries(sums)) {
  const [surface, group] = key.split('|');
  if (group === 'area') console.log(`${surface} 建造范围：(${value[0]}, ${value[1]}) 到 (${value[2]}, ${value[3]})`);
  else console.log(`${surface} ${GROUPS[group] || group}：${list(value)}`);
}
if (Object.keys(crafted).length) console.log(`手搓：${list(crafted)}`);
if (!Object.keys(sums).length && !Object.keys(crafted).length) console.log('无建造、拆除或手搓');

const production = [...activity].reverse().find((l) => l.k === 'production');
const span = production ? productionMinutes(production, firstTick) : 10;
h(`最近一次产量（${Number(span.toFixed(1))} 分钟内，每分钟）`);
if (!production) console.log('还没有');
else {
  for (const [surface, entry] of Object.entries(production.surfaces)) {
    for (const [key, label] of [['items_produced', '物品产出'], ['items_consumed', '物品消耗'], ['fluids_produced', '流体产出'], ['fluids_consumed', '流体消耗']]) {
      if (!entry[key]) continue;
      const perMinute = Object.fromEntries(Object.entries(entry[key]).map(([n, v]) => [n, Math.round(v / span * 10) / 10]));
      console.log(`${surface} ${label}（${clock(production.t)}，共 ${Object.keys(entry[key]).length} 种）：${list(perMinute)}`);
    }
  }
}
