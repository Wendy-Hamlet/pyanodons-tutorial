// Zinc outpost v2: Aromatics made on the spot. The 723-tile pipe from pond 2 (designs/zinc.js)
// did not work: a pipe segment shares its fluid evenly over every box on it, so 5 100 Aromatics
// filled the 72 700-unit pipe to 7 %, the drills got 7 % of their 200 too, and a pump in front
// of them barely moves anything (pumps slow down with the fullness of their input segment).
// Here every segment is a few tiles long:
//   R  Distillation column, distilled-raw-coal: Raw coal (3 inserters, 5/s at full speed) ->
//      Tar (box 8, east) by pipe into T; Coal gas (box 2, north) into a vent; Coal and Iron
//      oxide out by inserter.
//   T  Distillation column, tar-distilation: Tar (box 1, north) -> Aromatics (box 9, south-east
//      corner) straight into the west drill; Flue gas (box 4, south) and CO2 (box 6, west) into
//      vents; Rich clay out by inserter.
// Power: one Boiler + Steam engine (2 x 500 kW).
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('distilator', 331, 408, 'N', 'distilled-raw-coal');            // R
for (const y of [405.5, 407.5, 409.5]) { g.add(ins, 326.5, y, 'W'); g.add('wooden-chest', 325.5, y); }
g.add('py-gas-vent', 332.5, 403.5, 'E');                             // coal gas (connection faces south)
g.add(ins, 331.5, 412.5, 'N'); g.add('wooden-chest', 331.5, 413.5);  // coal, iron oxide out
g.path(335.5, 409.5, 'E3 S3', 'pipe');                               // tar R -> T
g.add('distilator', 340, 416, 'N', 'tar-distilation');               // T
g.add('py-gas-vent', 341.5, 420.5, 'W');                             // flue gas (connection faces north)
g.add('py-gas-vent', 335.5, 417.5, 'N');                             // CO2 (connection faces east)
g.add(ins, 338.5, 420.5, 'N'); g.add('wooden-chest', 338.5, 421.5);  // rich clay out
g.add('boiler', 321.5, 412, 'N'); g.add('steam-engine', 321.5, 408.5, 'N');
g.add('pipe', 319.5, 412.5); g.add('offshore-pump', 319.5, 413.5, 'S');
g.add(ins, 321.5, 413.5, 'S'); g.add('wooden-chest', 321.5, 414.5);  // Boiler fuel
for (const [x, y] of [[323.5, 410.5], [326.5, 411.5], [331.5, 414.5], [335.5, 412.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/zinc-local.json')));
