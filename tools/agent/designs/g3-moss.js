// Game 3: the service belt and the moss block east of the battery line.
// Service belt: the battery line's paddock belt (y -416.5, east; north lane Moss, south lane Native
// flora) ends at x -17.5; it is extended east to x 75.5 under the Glass/Melamine belt at x -1.5.
// Moss block south of it: 4 Moss farms facing south (Moss-1: Muddy sludge + CO2, no Stone), their
// fluid ports on the bottom edge (y -409.5), fed by two interleaved lines as in the author's moss
// farms (chapter 17): sludge on y -408.5 (pipes at the left ports, undergrounds between), CO2 on
// y -407.5 (risers at the right ports). A Washer (soil from a Soil extractor that drops into it)
// makes the sludge, a Moondrop greenhouse (moondrop-co2, the T.U.R.D. hidden module runs it empty)
// the CO2. Each farm's Moss goes onto the belt's north lane by an inserter above it.
const { Layout } = require('../layout');
const g = new Layout();
const yA = -408.5, yB = -407.5;
// Service belt: x -16.5 .. 75.5 along y -416.5.
g.path(-16.5, -416.5, 'E14');
g.underground(-2.5, -416.5, 'E', 2);
g.path(0.5, -416.5, 'E76');
const farms = [17, 23, 29, 35];
farms.forEach((x, i) => {
  g.add('moss-farm-mk01', x, -412, 'S', 'Moss-1');
  g.add('burner-inserter', x + 0.5, -415.5, 'S'); // picks Moss from the farm, drops on the belt
  if (i > 0) g.add('pipe-to-ground', x - 2.5, yA, 'E');
  g.add('pipe', x - 1.5, yA);
  g.add('pipe-to-ground', x - 0.5, yA, 'W');
  g.add('pipe', x + 1.5, yA);
  if (i > 0) g.add('pipe-to-ground', x + 0.5, yB, 'E');
  g.add('pipe', x + 1.5, yB);
  g.add('pipe-to-ground', x + 2.5, yB, 'W');
});
// Sludge: Washer (output at its bottom-left, 41.5,-409.5) -> pipes -> underground to the farms.
g.add('pipe-to-ground', 38.5, yA, 'E');
for (const x of [39.5, 40.5, 41.5]) g.add('pipe', x, yA);
g.add('washer', 42, -412, 'S', 'muddy-sludge');
g.add('soil-extractor-mk01', 48.5, -411.5, 'E', 'soil'); // drops Soil 3.8 tiles west: into the Washer
// CO2: greenhouse below, its north port at 43.5,-406.5 meets the CO2 line.
g.add('pipe-to-ground', 41.5, yB, 'E');
g.add('pipe', 42.5, yB);
g.add('pipe', 43.5, yB);
g.add('moondrop-greenhouse-mk01', 43.5, -402.5, 'N', 'moondrop-co2');
// Water for the Washer (top port 41.5,-414.5) and the Soil extractor (top port 48.5,-414.5).
for (let x = 41.5; x <= 48.5; x++) g.add('pipe', x, -415.5);
// Power: from the grid pole at -0.5,-431.5.
for (const [x, y] of [[2.5, -425.5], [6.5, -420.5], [12.5, -417.5], [14.5, -415.5], [20.5, -415.5], [26.5, -415.5],
  [32.5, -415.5], [38.5, -415.5], [45.5, -417.5], [52.5, -415.5], [52.5, -409.5], [49.5, -404.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-moss.json')));
