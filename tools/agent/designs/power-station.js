// Power station on the Raw coal patch: the author's Raw coal module (15 Raw coal/s) feeds a belt
// west past four south-facing Boilers (two inserters each); a Steam engine below each Boiler; one
// Offshore pump (Pump Anywhere) at the west end supplies all four through their side
// connections. Ash stays in the Boilers' burnt-result slots (1000 each) for the round to collect.
const fs = require('fs');
const { Layout } = require('../layout');
const g = new Layout();
g.blueprint(fs.readFileSync(__dirname + '/../../../blueprints/raw-coal-module.txt', 'utf8'), -36, -38);
g.path(-36.5, -33.5, 'W13');
for (const bx of [-46.5, -43.5, -40.5, -37.5]) {
  g.add('burner-inserter', bx - 1, -32.5, 'N');
  g.add('burner-inserter', bx, -32.5, 'N');
  g.add('boiler', bx, -31, 'S');
  g.add('steam-engine', bx, -27.5, 'N');
}
g.add('offshore-pump', -48.5, -31.5, 'W');
for (const [x, y] of [[-47.5, -24.5], [-41.5, -24.5], [-36.5, -24.5], [-36.5, -17.5], [-31.5, -15.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/power-station.json')));
