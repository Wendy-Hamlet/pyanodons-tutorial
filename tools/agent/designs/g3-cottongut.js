// Game 3: the Cottongut cell (steady state) under the two Prandium labs.
//   PL1 (94,-460), PL2 (106,-460): caged Cottongut (7 pups, 4 Moondrop, 4 Wood seeds, 2 Water barrels,
//   3 Ralesia seeds -> 6 Cottongut + 2 Empty barrels), Cottongut MK 01 as modules.
//   RC (105,-439): Reproductive complex, cottongut-cub-1 (4 Cottongut, 2 Moondrop, 15 Ralesia seeds,
//   3 Water barrels -> 10 pups + 3 Empty barrels), 2 Cottongut MK 01 as modules.
// A closed sushi loop (racetrack) between them: y -452.5 east, y -451.5 west, x 86.5..115.5. Every
// machine has one inserter in from the loop (it takes only its ingredients) and one out onto it.
// The loop is read whole by one belt (entire belt hold) and the feeding inserters run only below a
// level: pups (RC out) < 21, Cottongut (PL outs) < 24, Moondrop (greenhouse feeder) < 16, Ralesia
// seeds (from the seed nursery N2) < 30. Empty barrels go round to a Barreling machine at the east
// end and come back full (the barrels in the loop are a fixed stock). Cottongut leaves at the west
// corner (filter inserter, only while the loop holds more than 12) for the Sarcorus incubator.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('rc-mk01', 105, -439, 'N', 'cottongut-cub-1');
g.path(86.5, -452.5, 'E29 S1 W29 N1');                          // the loop
g.add(ins, 89.5, -453.5, 'S'); g.add(ins, 91.5, -453.5, 'N');   // PL1 in, out
g.add(ins, 104.5, -453.5, 'S'); g.add(ins, 106.5, -453.5, 'N'); // PL2 in, out
g.add(ins, 110.5, -450.5, 'N'); g.add(ins, 97.5, -450.5, 'S');  // RC in, out
g.add(ins, 85.5, -451.5, 'W');                                  // Ralesia seeds N2 -> loop
g.add(ins, 86.5, -450.5, 'N', null, { filters: ['cottongut'] }); // Cottongut export
// Barreling machine at the east end, its own Offshore pump (port at the NE corner when facing E)
g.add('barrel-machine-mk01', 118.5, -451.5, 'E', 'water-barrel');
g.add('pipe', 120.5, -452.5); g.add('offshore-pump', 121.5, -452.5, 'E');
g.add(ins, 116.5, -452.5, 'E'); g.add(ins, 116.5, -451.5, 'W', null, { filters: ['barrel'] });
// Moondrop from the greenhouse (114..122 x -467..-458), side-loaded onto the loop's north lane
g.add(ins, 115.5, -457.5, 'N', null, { filters: ['moondrop'] });
g.path(115.5, -456.5, 'W2 S4');
for (const [x, y] of [[93.5, -453.5], [99.5, -453.5], [93.5, -450.5], [108.5, -453.5], [114.5, -453.5], [119.5, -454.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-cottongut.json')));
