// Duralumin smelter (smelter-mk01, 13x13; Aluminium 4 + Copper 2 -> 1 in 4 s) east of the
// electronics block. It burns fluid fuel at 10 MW (40 MJ per Duralumin) through one box in the
// middle of its north side, so it is turned south and fed Syngas from a plant below it:
//   Gasifier (turned east: Coal gas and Water in on the south side, Syngas and Tar out on the
//   north side) -> Syngas straight up into the smelter, Tar into a sinkhole;
//   D7 (distilled-raw-coal, turned east) west of it: Coal gas from its east side by pipe, Tar
//   from its south side into the tar distiller D8 of designs/plastic.js, Raw coal by three inserters, Coal + Iron oxide out north.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('smelter-mk01', 90.5, -14.5, 'S', 'duralumin-1');
g.add(ins, 90.5, -21.5, 'N'); g.add('wooden-chest', 90.5, -22.5);   // Aluminium, Copper
g.add(ins, 89.5, -7.5, 'N'); g.add('wooden-chest', 89.5, -6.5);     // Duralumin out
g.path(90.5, -7.5, 'S4', 'pipe');                                    // Syngas up into the smelter
g.add('gasifier', 90, 0, 'E', 'syngas');
g.add('py-sinkhole', 87.5, -5.5, 'E');                               // gasifier Tar (faces south)
g.add('offshore-pump', 87.5, 4.5, 'S');                              // Water into the gasifier
g.add('distilator', 80, 8, 'E', 'distilled-raw-coal');               // D7
g.path(84.5, 9.5, 'E6 N6', 'pipe');                                  // Coal gas D7 -> gasifier
// D7's Tar goes south into D8 (designs/plastic.js), no longer into a sinkhole.
for (const y of [5.5, 7.5, 8.5]) { g.add(ins, 75.5, y, 'W'); g.add('wooden-chest', 74.5, y); }
for (const x of [79.5, 80.5]) { g.add(ins, x, 3.5, 'S'); g.add('wooden-chest', x, 2.5); }
for (const [x, y] of [[76.5, -11.5], [83.5, -11.5], [83.5, -4.5], [85.5, -1.5], [83.5, 2.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/duralumin.json')));
