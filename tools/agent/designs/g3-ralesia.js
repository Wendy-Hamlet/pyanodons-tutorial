// Game 3: Ralesia block (3 Ralesia plantations, 12 Ralesia as modules each) north-east of the workshop.
// B_in (y -442.5, west-going): north lane Ralesia seeds, south lane Soil; inserters at y -443.5 feed the
// plantations (bottom edge). Plantation water port is bottom-centre, hydrogen top-centre: both rows
// share their tiles with inserters, so each port has a pipe with pipe-to-ground neighbours (6 apart).
// Plantation outputs at y -451.5 drop Ralesia on B_out (y -452.5, east), which climbs to y -457.5 and
// feeds the seed nursery N2 from above; N2 drops seeds from its west side onto the B_in riser
// (x 76.5, south) on its west lane -> the north lane after the turn. A Soil extractor east of the riser
// drops on its east lane -> south lane. Seeds leave at the west end of B_in for the consumers.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
const P = [44.5, 52.5, 60.5];
P.forEach((x, i) => {
  if (i > 0) g.add('ralesia-plantation-mk01', x, -447.5, 'N', 'ralesia-1');
  // water row y -443.5
  if (i > 0) g.add('pipe-to-ground', x - 1, -443.5, 'E');
  g.add('pipe', x, -443.5);
  g.add('pipe-to-ground', x + 1, -443.5, 'W');
  g.add(ins, x - 2, -443.5, 'S'); g.add(ins, x + 2, -443.5, 'S');
  // hydrogen row y -451.5
  g.add('pipe-to-ground', x - 1, -451.5, 'E');
  g.add('pipe', x, -451.5);
  if (i < 2) g.add('pipe-to-ground', x + 1, -451.5, 'W');
  g.add(ins, x - 2, -451.5, 'S'); g.add(ins, x + 2, -451.5, 'S'); // output: picks from the plantation
});
// water in from the east: last ptg (61.5) pairs with 67.5
g.add('pipe-to-ground', 67.5, -443.5, 'E'); g.add('pipe', 68.5, -443.5); g.add('offshore-pump', 69.5, -443.5, 'E');
// hydrogen in from the west: first ptg (43.5) pairs with 38.5
g.add('pipe-to-ground', 38.5, -451.5, 'W'); g.add('pipe', 37.5, -451.5);
// B_in: riser x 76.5 from -452.5 south to -443.5, then west along -442.5 to x 38.5
g.path(76.5, -452.5, 'S10 W38');                                   // riser, then B_in west to x 39.5
// B_out: y -452.5 east from 41.5 to 66.5, north to -457.5, east to 80.5, inserter down into N2
g.path(41.5, -452.5, 'E25 N5 E15');
g.add('botanical-nursery', 81.5, -452.5, 'N', 'ralesia-seeds');  // spans 78..85 x -456..-449
g.add(ins, 80.5, -456.5, 'N');                                      // B_out end (80.5,-457.5) -> N2
g.add(ins, 77.5, -452.5, 'E');                                      // seeds N2 -> riser
g.add('soil-extractor-mk01', 80.5, -445.5, 'W', 'soil');            // drops on the riser (east lane)
g.add('offshore-pump', 80.5, -441.5, 'S');                          // water into the extractor's bottom port
// power
for (const [x, y] of [[26.5, -439.5], [33.5, -441.5], [39.5, -445.5], [40.5, -448.5], [41.5, -443.5], [47.5, -443.5], [49.5, -443.5], [55.5, -443.5], [57.5, -443.5], [63.5, -443.5], [66.5, -448.5], [71.5, -448.5], [75.5, -451.5], [75.5, -446.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-ralesia.json')));
