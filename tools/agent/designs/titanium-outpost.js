// Titanium outpost: the lead outpost's layout (designs/lead-outpost.js) moved onto the east edge
// of the titanium patch at (-290,60). Titanium ore also needs Acetylene (4 per ore). The lead
// design's Slacked lime chest is left out (Slacked lime is a liquid and goes to the sinkhole).
const { execFileSync } = require('child_process');
const fs = require('fs');
const lead = 'C:/tmp/cf-agent/lead-outpost.json';
execFileSync('node', [__dirname + '/lead-outpost.js', lead]);
const DX = 183, DY = 471;
const list = JSON.parse(fs.readFileSync(lead, 'utf8')).list
  .filter((e) => !(e.x === -453.5 && (e.y === -423.5 || e.y === -424.5)))
  .map((e) => ({ ...e, x: e.x + DX, y: e.y + DY }));
// Two more drills to the west (Acetylene passes through the drills from the east): titanium is
// the slowest input of the vrauk chain.
for (const x of [-288.5, -293.5]) {
  list.push({ name: 'fluid-drill-mk01', x, y: 51.5, dir: 'N' }, { name: 'stone-furnace', x: x + 0.5, y: 48 },
    { name: 'burner-inserter', x: x - 1, y: 54.5, dir: 'S' }, { name: 'wooden-chest', x: x - 1, y: 55.5 });
}
fs.writeFileSync(process.argv[2] || 'C:/tmp/cf-agent/titanium-outpost.json', JSON.stringify({ list }));
const count = {}; for (const e of list) count[e.name] = (count[e.name] || 0) + 1;
console.log(JSON.stringify(count));
