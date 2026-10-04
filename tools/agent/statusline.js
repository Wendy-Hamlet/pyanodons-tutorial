// Claude Code status line command: keeps the plan's rate limits where tools can read them.
// Claude Code pipes session data (JSON) to this script after each update; the script saves
// rate_limits, prompt_cache and context_window to quota.json and prints a short status line.
// Configured in D:\factorio-explore\.claude\settings.local.json ("statusLine").
const fs = require('fs');
const path = require('path');

const OUT = process.env.PT_QUOTA_FILE || 'C:\\tmp\\cf-agent\\quota.json';

let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', (c) => { input += c; });
process.stdin.on('end', () => {
  let data = {};
  try { data = JSON.parse(input); } catch { /* print what we can */ }
  const limits = data.rate_limits || {};
  // A refresh between API responses carries no rate_limits: keep the last ones we saw.
  let previous = {};
  try { previous = JSON.parse(fs.readFileSync(OUT, 'utf8')); } catch { /* first run */ }
  const record = {
    written: Math.floor(Date.now() / 1000),
    session_id: data.session_id,
    rate_limits: Object.keys(limits).length ? limits : previous.rate_limits,
    rate_limits_seen: Object.keys(limits).length ? Math.floor(Date.now() / 1000) : previous.rate_limits_seen,
    prompt_cache: data.prompt_cache,
    context_window: data.context_window && {
      used_percentage: data.context_window.used_percentage,
      context_window_size: data.context_window.context_window_size,
    },
  };
  try {
    fs.mkdirSync(path.dirname(OUT), { recursive: true });
    fs.writeFileSync(OUT, JSON.stringify(record, null, 1));
  } catch { /* the status line must still print */ }

  const clock = (s) => new Date(s * 1000).toTimeString().slice(0, 5);
  const parts = [];
  const five = record.rate_limits && record.rate_limits.five_hour;
  const week = record.rate_limits && record.rate_limits.seven_day;
  if (five) parts.push(`5h ${Math.round(five.used_percentage)}% (resets ${clock(five.resets_at)})`);
  if (week) parts.push(`7d ${Math.round(week.used_percentage)}%`);
  const ctx = record.context_window && record.context_window.used_percentage;
  if (ctx != null) parts.push(`ctx ${Math.round(ctx)}%`);
  process.stdout.write(parts.join(' | ') || 'no rate limit data yet');
});
