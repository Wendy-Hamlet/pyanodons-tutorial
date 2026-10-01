// Renders entities.json (from tools/inspect-save.ps1) to a PNG, one pixel per tile, coloured by
// entity type. Usage: node tools/render-save-map.js [out.png] [scale]

const fs = require('fs');
const zlib = require('zlib');

const dir = 'C:/tmp/cf-dump/data/script-output';
const out = process.argv[2] || 'C:/tmp/cf-dump/base-map.png';
const scale = Number(process.argv[3] || 1);
const entities = require(`${dir}/cellforge/entities.json`);

const COLORS = {
  'transport-belt': [200, 160, 0], 'underground-belt': [150, 110, 0], splitter: [255, 120, 0],
  inserter: [110, 130, 150], pipe: [50, 110, 210], 'pipe-to-ground': [40, 80, 170], pump: [80, 160, 255],
  'storage-tank': [30, 50, 140], 'electric-pole': [90, 90, 90], 'mining-drill': [140, 90, 45],
  furnace: [210, 90, 30], 'assembling-machine': [70, 150, 200], lab: [230, 120, 200],
  boiler: [220, 40, 40], generator: [255, 80, 80], container: [190, 160, 110], beacon: [150, 80, 200],
  'offshore-pump': [0, 200, 200], wall: [200, 200, 200],
};
const DEFAULT = [235, 235, 235];

let x1 = Infinity, y1 = Infinity, x2 = -Infinity, y2 = -Infinity;
for (const e of entities) {
  x1 = Math.min(x1, Math.floor(e.x1)); y1 = Math.min(y1, Math.floor(e.y1));
  x2 = Math.max(x2, Math.ceil(e.x2)); y2 = Math.max(y2, Math.ceil(e.y2));
}
const w = (x2 - x1) * scale, h = (y2 - y1) * scale;
const px = Buffer.alloc(w * h * 3, 24);

// Big entities first so belts and pipes stay visible on top.
const sorted = [...entities].sort((a, b) => (b.x2 - b.x1) * (b.y2 - b.y1) - (a.x2 - a.x1) * (a.y2 - a.y1));
for (const e of sorted) {
  const c = COLORS[e.type] || DEFAULT;
  const ex1 = (Math.floor(e.x1 + 0.01) - x1) * scale, ey1 = (Math.floor(e.y1 + 0.01) - y1) * scale;
  const ex2 = (Math.ceil(e.x2 - 0.01) - x1) * scale, ey2 = (Math.ceil(e.y2 - 0.01) - y1) * scale;
  for (let y = ey1; y < ey2; y++) for (let x = ex1; x < ex2; x++) {
    const i = (y * w + x) * 3;
    px[i] = c[0]; px[i + 1] = c[1]; px[i + 2] = c[2];
  }
}
// Grid line every 100 tiles for orientation.
for (let t = Math.ceil(x1 / 100) * 100; t < x2; t += 100) for (let y = 0; y < h; y += 2) px.fill(60, (y * w + (t - x1) * scale) * 3, (y * w + (t - x1) * scale) * 3 + 3);
for (let t = Math.ceil(y1 / 100) * 100; t < y2; t += 100) for (let x = 0; x < w; x += 2) px.fill(60, (((t - y1) * scale) * w + x) * 3, (((t - y1) * scale) * w + x) * 3 + 3);

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
fs.writeFileSync(out, Buffer.concat([
  Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
  chunk('IHDR', ihdr), chunk('IDAT', zlib.deflateSync(raw)), chunk('IEND', Buffer.alloc(0)),
]));
console.log(`${out}: ${w}x${h}, origin (${x1}, ${y1}), grid lines every 100 tiles`);
