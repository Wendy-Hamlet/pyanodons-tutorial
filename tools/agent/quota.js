// Reads the plan's rate limits that statusline.js saved and says when to stop working.
//
//   node quota.js                  status line + stop threshold; exit 0 = ok, 2 = stop now, 3 = no data
//   node quota.js --json           the same as JSON
//   node quota.js watch [--pause]  blocks until the stop threshold is reached, then prints STOP and
//                                  exits 0; run it as a background task while working, its exit is the
//                                  event that says "wrap up now". --pause also pauses the agent game.
//   node quota.js wait-reset [min] blocks until the 5-hour window resets (exit 0) or `min` minutes pass
//                                  (default: the reminder interval; exit 2): the wake-up loop after a stop
//   node quota.js wait [min]       older form: blocks while the 5-hour use is at the stop threshold
//   node quota.js guard            older form: like the default, but pauses the agent game when it says stop
//
// Stop threshold (the user's rule, 2026-11-06): after a stop the session waits for the reset and is
// woken every reminder interval to keep the prompt cache alive; each wake-up costs about 1 %, wrapping
// up costs about 1 %, and within the last cache TTL before the reset no wake-up is needed (the system
// wakes the session after the reset). So stop at
//   max - wrap - wake * max(0, minutes to reset - ttl) / interval
// with max 99, wrap 1, wake 1, ttl 60, interval 30 (env PT_QUOTA_MAX, _WRAP, _WAKE, _TTL, _INTERVAL).
// The 7-day window counts too: stop when it reaches max - wrap (waiting for the 5-hour reset is then no
// use). Numbers are as fresh as the last API response (the status line saves them after each one).
// Account: PT_QUOTA_FILE, else quota-acc2.json when CLAUDE_CONFIG_DIR names the second account
// (D:\claude-acc2), else quota.json.
const fs = require('fs');

const DIR = 'C:\\tmp\\cf-agent';
const FILE = process.env.PT_QUOTA_FILE
  || `${DIR}\\${/acc2/i.test(process.env.CLAUDE_CONFIG_DIR || '') ? 'quota-acc2.json' : 'quota.json'}`;
const num = (k, d) => Number(process.env[k] || d);
const P = {
  max: num('PT_QUOTA_MAX', 99), wrap: num('PT_QUOTA_WRAP', 1), wake: num('PT_QUOTA_WAKE', 1),
  ttl: num('PT_QUOTA_TTL', 60), interval: num('PT_QUOTA_INTERVAL', 30),
};

function read() {
  try { return JSON.parse(fs.readFileSync(FILE, 'utf8')); } catch { return null; }
}

function verdict(now = Date.now() / 1000) {
  const q = read();
  if (!q || !q.rate_limits) return { state: 'unknown', reason: `no rate limit data in ${FILE}` };
  // Right after a reset the status line reports seven_day only: no five-hour window has started.
  const five = q.rate_limits.five_hour || { used_percentage: 0, resets_at: now + 5 * 3600 };
  const reset = five.resets_at;
  const used = reset <= now ? 0 : five.used_percentage;
  const resetsIn = Math.max(0, (reset - now) / 60);
  const wakes = Math.max(0, resetsIn - P.ttl) / P.interval;
  const threshold = Math.round((P.max - P.wrap - P.wake * wakes) * 10) / 10;
  const week = q.rate_limits.seven_day && q.rate_limits.seven_day.used_percentage;
  let state = 'ok', why = '';
  if (week != null && week >= P.max - P.wrap) { state = 'stop'; why = `7-day use ${week}% >= ${P.max - P.wrap}%`; }
  else if (used >= threshold) { state = 'stop'; why = `5h use ${used}% >= threshold ${threshold}%`; }
  return {
    state, why, used, threshold, resets_at: reset, resets_in_min: Math.round(resetsIn),
    wakeups_left: Math.ceil(wakes), seven_day: week, file: FILE,
    seen_min_ago: Math.round((now - (q.rate_limits_seen || q.written)) / 60),
    cache_expires_in_min: q.prompt_cache && q.prompt_cache.expires_at
      ? Math.round((q.prompt_cache.expires_at - now) / 60) : null,
  };
}

const clock = (s) => new Date(s * 1000).toLocaleString('zh-CN', { hour12: false });
const line = (v) => `5h used ${v.used}% (stop at ${v.threshold}%: ${P.max} - ${P.wrap} wrap - ${P.wake} x `
  + `${v.wakeups_left} wake-ups), resets ${clock(v.resets_at)} (in ${v.resets_in_min} min); 7d ${v.seven_day}%; `
  + `data from ${v.seen_min_ago} min ago; cache expires in ${v.cache_expires_in_min} min -> ${v.state}${v.why ? ` (${v.why})` : ''}`;
const pauseGame = () => { let r; try { r = require('./rcon'); } catch { return Promise.resolve(console.log('no rcon.js here: pause the game yourself')); } return r.send(['/agent pause {"value":true}'])
  .then((a) => console.log(`game paused: ${a[0]}`), (e) => console.log(`could not pause the game: ${e.message}`)); };
const args = process.argv.slice(2);
const cmd = args[0];

if (cmd === 'watch') {
  const poll = 20000;
  const first = verdict();
  console.log(`watching ${FILE}: ${first.state === 'unknown' ? first.reason : line(first)}`);
  const tick = () => {
    const v = verdict();
    if (v.state === 'stop') {
      console.log(`STOP ${new Date().toLocaleTimeString('zh-CN', { hour12: false })}: ${line(v)}`);
      if (args.includes('--pause')) pauseGame().then(() => process.exit(0)); else process.exit(0);
      return;
    }
    setTimeout(tick, poll);
  };
  tick();
} else if (cmd === 'wait-reset') {
  const minutes = Number(args[1] || P.interval);
  const start = verdict();
  const until = Date.now() + minutes * 60000;
  const tick = () => {
    const now = Date.now();
    if (start.resets_at && now / 1000 >= start.resets_at + 5) { console.log(`window reset: ${line(verdict())}`); process.exit(0); }
    if (now >= until) { console.log(`no reset yet after ${minutes} min: ${line(verdict())}`); process.exit(2); }
    setTimeout(tick, Math.min(30000, Math.max(1000, Math.min(until - now, (start.resets_at + 5) * 1000 - now))));
  };
  tick();
} else if (cmd === 'wait') {
  const until = Date.now() + Number(args[1] || P.interval) * 60000;
  const tick = () => {
    const v = verdict();
    if (v.state !== 'stop') { console.log(`quota ${v.state}: ${line(v)}`); process.exit(0); }
    if (Date.now() >= until) { console.log(`still at the stop threshold: ${line(v)}`); process.exit(2); }
    setTimeout(tick, Math.min(30000, Math.max(1000, v.resets_at * 1000 - Date.now() + 5000)));
  };
  tick();
} else {
  const v = verdict();
  if (cmd === '--json') console.log(JSON.stringify(v));
  else console.log(v.state === 'unknown' ? v.reason : line(v));
  if (cmd === 'guard' && v.state === 'stop') pauseGame().then(() => process.exit(2));
  else process.exit({ ok: 0, stop: 2, unknown: 3 }[v.state]);
}
