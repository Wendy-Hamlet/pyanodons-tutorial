// Claude Code status line command: keeps the plan's rate limits where tools can read them.
// Claude Code pipes session data (JSON) to this script after each update; the script saves
// rate_limits, prompt_cache and context_window to quota.json and prints a short status line:
//   <model> | 5h N% (time to reset) | 7d N% (time to reset) | ctx N%
// Percentages are coloured by band: green < 60, yellow 60-84, red >= 85.
// Installed for every Claude Code session: a copy at C:\tools\claude-statusline\statusline.js is
// the "statusLine" of %USERPROFILE%\.claude\settings.json. After editing this file, copy it there.
// A session started with CLAUDE_CONFIG_DIR (the `claude2` second account) gets its own quota file
// (quota-<dir name>.json) and an account tag, so the two accounts' limits never mix.
const fs = require('fs');
const path = require('path');

const cfgDir = process.env.CLAUDE_CONFIG_DIR;
const tag = cfgDir ? path.basename(cfgDir).replace(/^\.?claude-?/, '') || 'alt' : '';
const OUT = process.env.PT_QUOTA_FILE
  || (tag ? `C:\\tmp\\cf-agent\\quota-${tag}.json` : 'C:\\tmp\\cf-agent\\quota.json');

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

  const paint = (pct, text) => {
    const code = pct >= 85 ? 31 : pct >= 60 ? 33 : 32;
    return `\x1b[${code}m${text}\x1b[0m`;
  };
  // Time left until a reset: 42m / 2h13m / 3d4h.
  const left = (at) => {
    const mins = Math.max(0, Math.floor((at * 1000 - Date.now()) / 60000));
    if (mins < 60) return `${mins}m`;
    if (mins < 1440) return `${Math.floor(mins / 60)}h${String(mins % 60).padStart(2, '0')}m`;
    return `${Math.floor(mins / 1440)}d${Math.floor((mins % 1440) / 60)}h`;
  };
  const limitPart = (label, lim) => {
    const pct = Math.round(lim.used_percentage);
    const eta = lim.resets_at ? ` (${left(lim.resets_at)})` : '';
    return paint(pct, `${label} ${pct}%${eta}`);
  };

  const parts = [];
  const model = data.model && (data.model.display_name || data.model.id);
  if (model) parts.push(`\x1b[36m${tag ? `${tag}:` : ''}${model}\x1b[0m`);
  const five = record.rate_limits && record.rate_limits.five_hour;
  const week = record.rate_limits && record.rate_limits.seven_day;
  if (five) parts.push(limitPart('5h', five));
  if (week) parts.push(limitPart('7d', week));
  const ctx = record.context_window && record.context_window.used_percentage;
  if (ctx != null) parts.push(paint(Math.round(ctx), `ctx ${Math.round(ctx)}%`));
  process.stdout.write(parts.join(' | ') || 'no rate limit data yet');
});
