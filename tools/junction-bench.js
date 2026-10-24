// Helper of the junction bench (tools/junction-bench.ps1, tools/junction-bench/control.lua).
//   node tools/junction-bench.js entities <blueprint.txt>   rails and signals of a blueprint as JSON
//   node tools/junction-bench.js render <name> [out.svg [x1 y1 x2 y2]] [--mark x,y;x,y]   the bench's
//       map as an SVG: rails coloured by rail block, rail signals green, chain signals blue (a tick
//       points the way they face), track ends numbered, marked places ringed in red; with an area,
//       a close-up with signal numbers
//   node tools/junction-bench.js paths <name>               every path between open ends: length and
//       the signals met on the way
//   node tools/junction-bench.js symmetry <name>            rails and signals that differ between the
//       four sides of a junction meant to be the same from every side
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const outDir = process.env.JB_OUT || "C:/tmp/cf-save/data/script-output/junction-bench";
const decode = (s) => JSON.parse(zlib.inflateSync(Buffer.from(s.trim().slice(1), 'base64')).toString('utf8'));
const unit = (d) => [Math.sin(d * Math.PI / 8), -Math.cos(d * Math.PI / 8)];
const RAILS = /rail$|rail-a$|rail-b$/;
const SIGNALS = new Set(['rail-signal', 'rail-chain-signal']);

function entities(file) {
  const bp = decode(fs.readFileSync(file, 'utf8')).blueprint;
  const list = (bp.entities || []).filter((e) => RAILS.test(e.name) || SIGNALS.has(e.name))
    .map((e) => ({ name: e.name, position: e.position, direction: e.direction || 0 }));
  process.stdout.write(JSON.stringify(list));
}

const readMap = (name) => JSON.parse(fs.readFileSync(`${outDir}/${name}-map.json`, 'utf8'));

// A rail as a cubic curve from end to end; each end's direction points away from the rail.
function railCurve(r) {
  const [a, b] = r.ends;
  const chord = Math.hypot(b.x - a.x, b.y - a.y);
  const ua = unit(a.d), ub = unit(b.d);
  // Make each tangent point out of the rail (away from the other end).
  const out = (e, u, o) => ((e.x - o.x) * u[0] + (e.y - o.y) * u[1] >= 0 ? u : [-u[0], -u[1]]);
  const ta = out(a, ua, b), tb = out(b, ub, a);
  const k = chord / 3;
  return [[a.x, a.y], [a.x - ta[0] * k, a.y - ta[1] * k], [b.x - tb[0] * k, b.y - tb[1] * k], [b.x, b.y]];
}

function render(name, file, view, marks = []) {
  const m = readMap(name);
  const pts = m.rails.flatMap((r) => r.ends.map((e) => [e.x, e.y])).concat(m.signals.map((s) => [s.x, s.y]));
  let x1 = Math.min(...pts.map((p) => p[0])) - 6, x2 = Math.max(...pts.map((p) => p[0])) + 6;
  let y1 = Math.min(...pts.map((p) => p[1])) - 6, y2 = Math.max(...pts.map((p) => p[1])) + 6;
  // A close-up (x1 y1 x2 y2) at 30 px a tile, with signal numbers.
  if (view) [x1, y1, x2, y2] = view;
  const S = view ? 30 : 10;
  const blocks = Math.max(...m.rails.map((r) => r.block));
  const color = (b) => `hsl(${(b * 137.5) % 360},70%,${b % 2 ? 45 : 60}%)`;
  const X = (x) => ((x - x1) * S).toFixed(1), Y = (y) => ((y - y1) * S).toFixed(1);
  const parts = [`<svg xmlns="http://www.w3.org/2000/svg" width="${(x2 - x1) * S}" height="${(y2 - y1) * S}">`,
    `<rect width="100%" height="100%" fill="#1e1e1e"/>`];
  // Grid every 10 tiles.
  for (let x = Math.ceil(x1 / 10) * 10; x <= x2; x += 10) parts.push(`<line x1="${X(x)}" y1="0" x2="${X(x)}" y2="${(y2 - y1) * S}" stroke="#2c2c2c"/>`);
  for (let y = Math.ceil(y1 / 10) * 10; y <= y2; y += 10) parts.push(`<line x1="0" y1="${Y(y)}" x2="${(x2 - x1) * S}" y2="${Y(y)}" stroke="#2c2c2c"/>`);
  for (const r of m.rails) {
    const c = railCurve(r);
    parts.push(`<path d="M${X(c[0][0])},${Y(c[0][1])} C${X(c[1][0])},${Y(c[1][1])} ${X(c[2][0])},${Y(c[2][1])} ${X(c[3][0])},${Y(c[3][1])}" stroke="${color(r.block)}" stroke-width="${S * 0.7}" fill="none" stroke-linecap="butt"/>`);
  }
  for (const s of m.signals) {
    const [ux, uy] = unit(s.d);
    const fill = s.name === 'rail-signal' ? '#3ddc5a' : '#3d9bff';
    parts.push(`<line x1="${X(s.x)}" y1="${Y(s.y)}" x2="${X(s.x + ux * 1.4)}" y2="${Y(s.y + uy * 1.4)}" stroke="${fill}" stroke-width="3"/>`);
    parts.push(`<circle cx="${X(s.x)}" cy="${Y(s.y)}" r="${S * 0.45}" fill="${fill}" stroke="#000"/>`);
    if (view) parts.push(`<text x="${X(s.x - ux * 1.2)}" y="${Y(s.y - uy * 1.2)}" fill="#fff" font-size="${S * 0.6}" font-family="Arial" text-anchor="middle" dominant-baseline="middle">${m.signals.indexOf(s) + 1}</text>`);
  }
  // Marked places (x,y in bench coordinates): a red ring each.
  for (const [mx, my] of marks) parts.push(`<circle cx="${X(mx)}" cy="${Y(my)}" r="${S * 1.3}" fill="none" stroke="#ff3030" stroke-width="${Math.max(2, S * 0.25)}"/>`);
  m.ends.forEach((e, i) => {
    const [ux, uy] = unit(e.d);
    parts.push(`<text x="${X(e.x + ux * 3)}" y="${Y(e.y + uy * 3)}" fill="#fff" font-size="${S * 2}" font-family="Arial" text-anchor="middle" dominant-baseline="middle">${i + 1}</text>`);
  });
  parts.push(`<text x="8" y="${S * 2}" fill="#ccc" font-size="${S * 1.6}" font-family="Arial">${name}: ${m.rails.length} rails, ${m.signals.length} signals, ${blocks} blocks; grid 10 tiles</text>`);
  parts.push('</svg>');
  fs.writeFileSync(file, parts.join('\n'));
  console.log(`render: ${file} (${(x2 - x1) * S} x ${(y2 - y1) * S})`);
}

function paths(name) {
  const m = readMap(name);
  const kind = (i) => (i ? `${m.signals[i - 1].name === 'rail-signal' ? 'R' : 'C'}(${m.signals[i - 1].x},${m.signals[i - 1].y})` : '-');
  for (const p of m.paths) {
    // An empty Lua table comes out of table_to_json as {}.
    const steps = (Array.isArray(p.steps) ? p.steps : []).map((s) => kind(s.sig)).join(' ');
    console.log(`${p.from} -> ${p.to}: ${p.length} tiles, blocks ${[...new Set(p.rails.map((r) => m.rails[r - 1].block))].join(',')}; signals ${steps}`);
  }
}

// A junction meant to look the same from all four sides: every rail and signal turned by 90, 180
// and 270 degrees about the centre of its rails should meet one of the same name and direction.
// Lists those that do not.
function symmetry(name) {
  const m = readMap(name);
  // The centre of the track ends (a leg cut short at the edge does not move it).
  const xs = m.ends.map((e) => e.x), ys = m.ends.map((e) => e.y);
  const cx = (Math.min(...xs) + Math.max(...xs)) / 2, cy = (Math.min(...ys) + Math.max(...ys)) / 2;
  const key = (e, x, y, d) => `${e.name}@${x.toFixed(1)},${y.toFixed(1)}/${d}`;
  // Straight and diagonal rails look the same turned half way round.
  const dirKey = (e, d) => (/^straight-rail|half-diagonal/.test(e.name) ? d % 8 : d);
  for (const [label, list] of [['rail', m.rails], ['signal', m.signals]]) {
    const have = new Set(list.map((e) => key(e, e.x, e.y, dirKey(e, e.d))));
    const odd = [];
    for (const e of list) {
      const miss = [];
      for (const k of [1, 2, 3]) {
        let x = e.x - cx, y = e.y - cy;
        for (let i = 0; i < k; i++) [x, y] = [-y, x];
        if (!have.has(key(e, x + cx, y + cy, dirKey(e, (e.d + 4 * k) % 16)))) miss.push(k * 90);
      }
      if (miss.length) odd.push(`${e.name} ${e.x},${e.y} dir ${e.d}: no match turned ${miss.join('/')}`);
    }
    console.log(`${name}: ${list.length} ${label}s, ${odd.length} without a match on every side`);
    odd.forEach((o) => console.log(`  ${o}`));
  }
}

const [cmd, ...args] = process.argv.slice(2);
if (cmd === 'entities') entities(args[0]);
else if (cmd === 'render') {
  // --mark x,y;x,y draws a red ring around each place.
  const at = args.indexOf('--mark');
  const marks = at >= 0 ? args.splice(at, 2)[1].split(';').map((p) => p.split(',').map(Number)) : [];
  render(args[0], args[1] || `${outDir}/${args[0]}.svg`, args[5] !== undefined ? args.slice(2, 6).map(Number) : null, marks);
}
else if (cmd === 'paths') paths(args[0]);
else if (cmd === 'symmetry') symmetry(args[0]);
else {
  console.error('usage: entities <file> | render <name> [out.svg [x1 y1 x2 y2]] [--mark x,y;x,y] | paths <name> | symmetry <name>');
  process.exit(1);
}
