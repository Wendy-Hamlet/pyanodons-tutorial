// Reads the plan's 5-hour rate limit that statusline.js saved and says whether to keep playing.
//
//   node quota.js                 status line + verdict; exit 0 = ok, 2 = low, 3 = no data
//   node quota.js --json          the same as JSON
//   node quota.js wait [minutes]  blocks until the 5-hour window resets or `minutes` (default 40)
//                                 pass; run it as a background task while the game is paused
//   node quota.js guard           like the default, but when low it also pauses the game
//                                 (node a.js pause) and says what to do next
//
// "low" means five_hour.used_percentage >= PT_QUOTA_LOW (default 90) and the window has not
// reset yet. Claude Code refreshes the numbers after each API response, so they are as fresh as
// the last turn.
const fs = require('fs');

const FILE = process.env.PT_QUOTA_FILE || 'C:\\tmp\\cf-agent\\quota.json';
const LOW = Number(process.env.PT_QUOTA_LOW || 90);

function read() {
  try { return JSON.parse(fs.readFileSync(FILE, 'utf8')); } catch { return null; }
}

function verdict(now = Date.now() / 1000) {
  const q = read();
  const five = q && q.rate_limits && q.rate_limits.five_hour;
  if (!five) return { state: 'unknown', reason: `no rate limit data in ${FILE}` };
  const reset = five.resets_at;
  const used = reset <= now ? 0 : five.used_percentage;
  return {
    state: used >= LOW ? 'low' : 'ok',
    used,
    low_at: LOW,
    resets_at: reset,
    resets_in_min: Math.max(0, Math.round((reset - now) / 60)),
    seen_min_ago: Math.round((now - (q.rate_limits_seen || q.written)) / 60),
    seven_day: q.rate_limits.seven_day && q.rate_limits.seven_day.used_percentage,
    cache_expires_in_min: q.prompt_cache && q.prompt_cache.expires_at
      ? Math.round((q.prompt_cache.expires_at - now) / 60) : null,
  };
}

const clock = (s) => new Date(s * 1000).toLocaleString('zh-CN', { hour12: false });
const [cmd, arg] = process.argv.slice(2);

if (cmd === 'wait') {
  const until = Date.now() + Number(arg || 40) * 60000;
  const tick = () => {
    const v = verdict();
    if (v.state !== 'low') { console.log(`quota ${v.state}: ${JSON.stringify(v)}`); process.exit(0); }
    if (Date.now() >= until) { console.log(`still low after ${arg || 40} min: ${JSON.stringify(v)}`); process.exit(2); }
    setTimeout(tick, Math.min(30000, Math.max(1000, v.resets_at * 1000 - Date.now() + 5000)));
  };
  tick();
} else if (cmd === 'guard') {
  const v = verdict();
  console.log(`5h used ${v.used}%, resets in ${v.resets_in_min} min -> ${v.state}`);
  if (v.state !== 'low') process.exit(v.state === 'ok' ? 0 : 3);
  require('./rcon').send(['/agent pause {"value":true}']).then((a) => {
    console.log(`game paused: ${a[0]}`);
    console.log('next: run `node quota.js wait 40` as a background task and end the turn; '
      + 'when it reports ok, `node a.js pause value=false`');
    process.exit(2);
  }, (e) => { console.log(`could not pause the game: ${e.message}`); process.exit(2); });
} else {
  const v = verdict();
  if (cmd === '--json') console.log(JSON.stringify(v));
  else if (v.state === 'unknown') console.log(v.reason);
  else {
    console.log(`5h used ${v.used}% (low at ${v.low_at}%), resets ${clock(v.resets_at)} (in ${v.resets_in_min} min); `
      + `7d ${v.seven_day}%; data from ${v.seen_min_ago} min ago; cache expires in ${v.cache_expires_in_min} min -> ${v.state}`);
  }
  process.exit({ ok: 0, low: 2, unknown: 3 }[v.state]);
}
