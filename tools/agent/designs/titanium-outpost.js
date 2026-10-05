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
fs.writeFileSync(process.argv[2] || 'C:/tmp/cf-agent/titanium-outpost.json', JSON.stringify({ list }));
const count = {}; for (const e of list) count[e.name] = (count[e.name] || 0) + 1;
console.log(JSON.stringify(count));
