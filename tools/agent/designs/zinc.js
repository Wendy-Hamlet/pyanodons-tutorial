// Zinc: Zinc ore needs Aromatics (4 per ore). A Distillation column at tailings pond 2
// (-49,82, tar-distilation: 350 Tar -> 100 Aromatics, 500 Flue gas and 100 CO2, both vented,
// plus Rich clay) sends Aromatics through a 723-tile pipe to the zinc patch at (369,417):
// two Fluid drills side by side, each dropping into a Stone furnace (40 ore -> 4 Zinc plates).
// Writes the outpost and the pipe as chunks of at most 100 entities, ordered along the route,
// for `zinc-build.sh` to place one chunk at a time.
const fs = require('fs');
const { Layout } = require('../layout');
const g = new Layout();
g.path(-44.5, 85.5, 'S15 E388 S320', 'pipe');          // ends at (343.5,419.5)
const ins = 'burner-inserter';
for (const x of [346.5, 351.5]) {
  g.add('fluid-drill-mk01', x, 419.5, 'N');
  g.add('stone-furnace', x + 0.5, 416);
  g.add(ins, x - 1, 422.5, 'S'); g.add('wooden-chest', x - 1, 423.5);  // drill fuel
}
// A pump in front of the drills: a pipe segment shares its fluid evenly over all its boxes, so
// the drills only fill to the long pipe's level (7 % after 5 100 Aromatics) and stop. The pump
// (29 kW, one Boiler + Steam engine) pulls from the pipe at any level.
g.list = g.list.filter((e) => !(e.name === 'pipe' && e.x === 343.5 && (e.y === 417.5 || e.y === 418.5)));
g.add('pump', 343.5, 418, 'S');
g.add('boiler', 338.5, 412, 'N'); g.add('steam-engine', 338.5, 408.5, 'N');
g.add('pipe', 336.5, 412.5); g.add('offshore-pump', 336.5, 413.5, 'S');
g.add(ins, 338.5, 413.5, 'S'); g.add('wooden-chest', 338.5, 414.5);       // Boiler fuel
g.add('small-electric-pole', 340.5, 410.5); g.add('small-electric-pole', 342.5, 416.5);
const out = process.argv[2] || 'C:/tmp/cf-agent/zinc';
const chunks = [];
for (let i = 0; i < g.list.length; i += 100) chunks.push({ list: g.list.slice(i, i + 100) });
chunks.forEach((c, i) => fs.writeFileSync(`${out}-${i}.json`, JSON.stringify(c)));
console.log(chunks.map((c, i) => `${i}:${c.list[0].x},${c.list[0].y}->${c.list[c.list.length - 1].x},${c.list[c.list.length - 1].y}`).join(' '));
