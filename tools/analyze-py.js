// Summarises the prototype facts that drive block (city block) sizing, from the dump written by
// tools/dump-data.ps1. Usage: node --max-old-space-size=4096 tools/analyze-py.js [dump.json]

const dumpPath = process.argv[2] || 'C:/tmp/cf-dump/data/script-output/data-raw-dump.json';
const raw = require(dumpPath);

const hidden = (e) => (e.flags || []).includes('hidden') || e.hidden;
const visible = (type) => Object.entries(raw[type] || {}).filter(([, e]) => !hidden(e));
const tiles = (e) => {
  if (e.tile_width) return `${e.tile_width}x${e.tile_height}`;
  const b = e.collision_box;
  return b ? `${Math.ceil(b[1][0] - b[0][0])}x${Math.ceil(b[1][1] - b[0][1])}` : '?';
};
const section = (title) => console.log(`\n== ${title}`);

section('roboports (logistic / construction radius)');
for (const [n, e] of visible('roboport')) {
  console.log(`${n.padEnd(26)} ${tiles(e).padEnd(5)} logistic ${e.logistics_radius} construction ${e.construction_radius}`);
}

section('electric poles (supply area distance / wire reach)');
for (const [n, e] of visible('electric-pole')) {
  console.log(`${n.padEnd(26)} ${tiles(e).padEnd(5)} supply ${e.supply_area_distance} wire ${e.maximum_wire_distance}`);
}

section('rolling stock (tiles per car = joint + connection distance)');
for (const type of ['locomotive', 'cargo-wagon', 'fluid-wagon']) {
  for (const [n, e] of visible(type)) {
    console.log(`${type.padEnd(12)} ${n.padEnd(24)} ${e.joint_distance + e.connection_distance} tiles`);
  }
}

section('crafting machines');
const machines = [];
for (const type of ['assembling-machine', 'furnace']) {
  for (const [n, e] of visible(type)) {
    machines.push({ n, size: tiles(e), speed: e.crafting_speed, slots: e.module_slots ?? 0, next: e.next_upgrade });
  }
}
const histogram = {};
for (const m of machines) histogram[m.size] = (histogram[m.size] || 0) + 1;
console.log(`${machines.length} machines; footprints: ` +
  Object.entries(histogram).sort((a, b) => b[1] - a[1]).map(([k, v]) => `${k}:${v}`).join(' '));
const area = (size) => size.split('x').map(Number).reduce((a, b) => a * b);
const largest = machines.filter((m) => !/-mk0[2-4]$/.test(m.n))
  .sort((a, b) => area(b.size) - area(a.size)).slice(0, 10);
console.log('largest: ' + largest.map((m) => `${m.n} ${m.size}`).join(', '));

const families = {};
for (const m of machines) {
  const match = m.n.match(/^(.*)-mk0?(\d)$/);
  if (match) (families[match[1]] = families[match[1]] || []).push({ tier: +match[2], ...m });
}
const tiered = Object.entries(families).filter(([, list]) => list.length > 1);
const resized = tiered.filter(([, list]) => new Set(list.map((m) => m.size)).size > 1);
console.log(`${tiered.length} tiered families; footprint changes across tiers: ` +
  (resized.map(([f, list]) => `${f} ${list.sort((a, b) => a.tier - b.tier).map((m) => m.size).join('/')}`).join(', ') || 'none'));
const ratios = {};
for (const [, list] of tiered) {
  list.sort((a, b) => a.tier - b.tier);
  const key = list.map((m) => (m.speed / list[0].speed).toFixed(1)).join('/') + ' speed, slots ' +
    list.map((m) => m.slots).join('/');
  ratios[key] = (ratios[key] || 0) + 1;
}
console.log('tier patterns: ' + Object.entries(ratios).sort((a, b) => b[1] - a[1]).slice(0, 6)
  .map(([k, v]) => `${k} (x${v})`).join('; '));
