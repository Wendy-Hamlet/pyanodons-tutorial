// Close-up of one area of a save snapshot (entities.json from tools/inspect-save.ps1):
// a PNG at `scale` px per tile and a character grid on stdout.
// Usage: node tools/render-area.js x1 y1 x2 y2 out.png [scale]
//
// Grid legend: belts ^ > v <; underground entrance U, exit u; inserter: drop direction as
// n e s w (uppercase = filtered, filters listed below; "all but X" = blacklist); M mining drill on Raw coal, m mining drill
// on any other resource (listed below), drop tiles marked * when empty; C chest, F furnace,
// B boiler, p electric pole, # anything else.

const fs = require('fs');
const zlib = require('zlib');

const [x1, y1, x2, y2] = process.argv.slice(2, 6).map(Number);
const out = process.argv[6] || 'C:/tmp/cf-dump/area.png';
const scale = Number(process.argv[7] || 8);
const all = require(`${require('./paths').save}/entities.json`);
const inside = (e) => e.x2 > x1 && e.x1 < x2 && e.y2 > y1 && e.y1 < y2;
const list = all.filter(inside);

const W = x2 - x1, H = y2 - y1;
const COLORS = {
  'transport-belt': [200, 160, 0], 'underground-belt': [150, 100, 0], splitter: [255, 120, 0],
  inserter: [110, 150, 190], 'mining-drill': [140, 90, 45], container: [190, 160, 110],
  furnace: [210, 90, 30], boiler: [220, 40, 40], 'electric-pole': [90, 90, 90],
  pipe: [50, 110, 210], 'pipe-to-ground': [40, 80, 170],
};
const px = Buffer.alloc(W * scale * H * scale * 3, 30);
const set = (x, y, c) => {
  if (x < 0 || y < 0 || x >= W * scale || y >= H * scale) return;
  const i = (y * W * scale + x) * 3;
  px[i] = c[0]; px[i + 1] = c[1]; px[i + 2] = c[2];
};
const rect = (ax, ay, bx, by, c) => { for (let y = ay; y < by; y++) for (let x = ax; x < bx; x++) set(x, y, c); };
const tx = (x) => Math.round((x - x1) * scale), ty = (y) => Math.round((y - y1) * scale);
const dark = (c) => c.map((v) => Math.floor(v * 0.45));
const mark = (p, c, r = Math.max(1, scale / 4)) => rect(tx(p.x) - r, ty(p.y) - r, tx(p.x) + r, ty(p.y) + r, c);
const VEC = { north: [0, -1], east: [1, 0], south: [0, 1], west: [-1, 0] };

const grid = Array.from({ length: H }, () => Array(W).fill('.'));
const put = (x, y, ch) => { const gx = Math.floor(x) - x1, gy = Math.floor(y) - y1; if (gy >= 0 && gy < H && gx >= 0 && gx < W) grid[gy][gx] = ch; };
const filters = {};
const targets = {};

const sorted = [...list].sort((a, b) => (b.x2 - b.x1) * (b.y2 - b.y1) - (a.x2 - a.x1) * (a.y2 - a.y1));
for (const e of sorted) {
  const c = COLORS[e.type] || [235, 235, 235];
  const ax = tx(Math.floor(e.x1 + 0.01)), ay = ty(Math.floor(e.y1 + 0.01));
  const bx = tx(Math.ceil(e.x2 - 0.01)), by = ty(Math.ceil(e.y2 - 0.01));
  rect(ax, ay, bx, by, dark(c));
  rect(ax + 1, ay + 1, bx - 1, by - 1, c);
  const v = VEC[e.dir] || [0, 0];
  if (e.type === 'transport-belt' || e.type === 'underground-belt') {
    mark({ x: e.x + v[0] * 0.3, y: e.y + v[1] * 0.3 }, [40, 20, 0]);
    put(e.x, e.y, e.type === 'underground-belt' ? (e.ug === 'input' ? 'U' : 'u') : { north: '^', east: '>', south: 'v', west: '<' }[e.dir]);
  } else if (e.type === 'inserter') {
    mark({ x: e.x + (e.drop.x - e.x) * 0.35, y: e.y + (e.drop.y - e.y) * 0.35 }, e.filter ? [255, 255, 255] : [20, 30, 60]);
    const dx = e.drop.x - e.x, dy = e.drop.y - e.y;
    let ch = Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? 'e' : 'w') : (dy > 0 ? 's' : 'n');
    if (e.filter) {
      ch = ch.toUpperCase();
      const key = (e.filter_mode === 'blacklist' ? 'all but ' : '') + e.filter;
      filters[key] = (filters[key] || 0) + 1;
    }
    put(e.x, e.y, ch);
  } else if (e.type === 'mining-drill') {
    const coal = e.target === 'raw-coal';
    if (!coal) { rect(ax + 1, ay + 1, bx - 1, by - 1, [90, 120, 90]); targets[e.target] = (targets[e.target] || 0) + 1; }
    for (let gy = Math.floor(e.y1 + 0.01); gy < Math.ceil(e.y2 - 0.01); gy++)
      for (let gx = Math.floor(e.x1 + 0.01); gx < Math.ceil(e.x2 - 0.01); gx++) put(gx, gy, coal ? 'M' : 'm');
    if (e.drop) { mark(e.drop, [255, 230, 0]); }
  } else {
    const ch = { container: 'C', furnace: 'F', boiler: 'B', 'electric-pole': 'p' }[e.type] || '#';
    for (let gy = Math.floor(e.y1 + 0.01); gy < Math.ceil(e.y2 - 0.01); gy++)
      for (let gx = Math.floor(e.x1 + 0.01); gx < Math.ceil(e.x2 - 0.01); gx++) put(gx, gy, ch);
  }
}
// Drill drop tiles on top of the grid.
for (const e of list) if (e.type === 'mining-drill' && e.drop) {
  const gx = Math.floor(e.drop.x) - x1, gy = Math.floor(e.drop.y) - y1;
  if (gy >= 0 && gy < H && gx >= 0 && gx < W && grid[gy][gx] === '.') grid[gy][gx] = '*';
}

console.log(`area (${x1},${y1})-(${x2},${y2}); x increases to the right, y downwards`);
grid.forEach((row, i) => console.log(String(y1 + i).padStart(5) + ' ' + row.join('')));
console.log('filtered inserters: ' + JSON.stringify(filters) + '; drills on other resources (m): ' + JSON.stringify(targets));
const counts = {};
for (const e of list) counts[e.name] = (counts[e.name] || 0) + 1;
console.log('entities: ' + Object.entries(counts).map(([n, c]) => `${n}×${c}`).join(', '));

const w = W * scale, h = H * scale;
const raw = Buffer.alloc((w * 3 + 1) * h);
for (let y = 0; y < h; y++) px.copy(raw, y * (w * 3 + 1) + 1, y * w * 3, (y + 1) * w * 3);
const chunk = (type, data) => {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length);
  const body = Buffer.concat([Buffer.from(type), data]);
  const crc = Buffer.alloc(4); crc.writeUInt32BE(zlib.crc32(body));
  return Buffer.concat([len, body, crc]);
};
const ihdr = Buffer.alloc(13);
ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = 8; ihdr[9] = 2;
fs.writeFileSync(out, Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0))]));
console.log(`wrote ${out} (${w}x${h})`);
