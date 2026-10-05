// Power station 2 on the eastern Raw coal patch (box 222..259 x -9..31): the first station's
// layout (designs/power-station.js) moved by (+276, +33), plus a pole line west along y 21.5 to
// the creature block's grid at (109.5, 8.5). The base outgrew four Boilers (8 MW, 16 machines on
// low power) once the data array, chamber, incubator, distillers and biofactory came in.
const fs = require('fs');
const { Layout } = require('../layout');
const g = new Layout();
const DX = 276, DY = 33;
g.blueprint(fs.readFileSync(__dirname + '/../../../blueprints/raw-coal-module.txt', 'utf8'), -36 + DX, -38 + DY);
g.path(-36.5 + DX, -33.5 + DY, 'W13');
for (const bx of [-46.5, -43.5, -40.5, -37.5]) {
  g.add('burner-inserter', bx - 1 + DX, -32.5 + DY, 'N');
  g.add('burner-inserter', bx + DX, -32.5 + DY, 'N');
  g.add('boiler', bx + DX, -31 + DY, 'S');
  g.add('steam-engine', bx + DX, -27.5 + DY, 'N');
}
g.add('offshore-pump', -48.5 + DX, -31.5 + DY, 'W');
for (const [x, y] of [[-47.5, -24.5], [-41.5, -24.5], [-36.5, -24.5], [-36.5, -17.5], [-31.5, -15.5]]) g.add('small-electric-pole', x + DX, y + DY);
// Line to the base: (109.5,8.5) -> (109.5,15.5) -> (109.5,21.5) -> east every 7 tiles to the station.
g.add('small-electric-pole', 109.5, 15.5); g.add('small-electric-pole', 109.5, 21.5);
for (let x = 116.5; x <= 235.5; x += 7) g.add('small-electric-pole', x, 21.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/power-station-2.json')));
