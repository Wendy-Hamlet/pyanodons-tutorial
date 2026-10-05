// Vrauk area east of the battery cell (x 100..140, y -75..-45): rc-mk01 (22x22) breeds Cocoons
// (4 Water barrels + 5 Native flora + 3 Saps + 10 Moss -> 4-6 Cocoons + 4 Barrels, 80 s), an
// inserter / chest / inserter link hands them to the Vrauks paddock (13x13; 3 Water barrels +
// 15 Native flora + 10 Cocoons + 5 Moss -> 2 Vrauks + 3 Barrels in 160 s at speed 0.05 per
// Vrauks module + 1). A Barrel machine fills Barrels with Water. Inputs come from chests.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('rc-mk01', 113, -62, 'N', 'vrauks-cocoon-1');
g.add(ins, 113.5, -73.5, 'N'); g.add('wooden-chest', 113.5, -74.5);       // rc inputs
g.add(ins, 124.5, -62.5, 'W', null, { filters: ['cocoon'] });                // only Cocoons leave the rc here
g.add('wooden-chest', 125.5, -62.5); g.add(ins, 126.5, -62.5, 'W');
g.add('vrauks-paddock-mk01', 133.5, -62.5, 'N', 'vrauks-1');
g.add(ins, 133.5, -69.5, 'N'); g.add('wooden-chest', 133.5, -70.5);      // paddock inputs
g.add(ins, 133.5, -55.5, 'N'); g.add('wooden-chest', 133.5, -54.5);      // Vrauks + Barrels out
g.add('barrel-machine-mk01', 106.5, -47.5, 'N', 'water-barrel');
g.add('offshore-pump', 105.5, -49.5, 'N');                               // Water into its north-west input
g.add(ins, 106.5, -45.5, 'S'); g.add('wooden-chest', 106.5, -44.5);      // empty Barrels in
g.add(ins, 108.5, -47.5, 'W'); g.add('wooden-chest', 109.5, -47.5);      // Water barrels out
for (const [x, y] of [[92.5, -58.5], [98.5, -56.5], [101.5, -50.5], [104.5, -48.5], [108.5, -50.5], [115.5, -50.5], [122.5, -50.5], [126.5, -56.5]]) {
  g.add('small-electric-pole', x, y);
}
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/vrauks.json')));
