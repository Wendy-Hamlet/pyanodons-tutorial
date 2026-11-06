// Game 3: the Auog block, south of the service belt's east end (green science, steady state).
// 1.67 Auogs a minute are slaughtered: Brain-bound for 0.5 Animal samples a minute (3 Brains each,
// 1 an Auog), and their Bones are exactly the 5 a minute for the samples and the Bonemeal.
//   RC   Reproductive complex, 2 Auogs as modules: pups (20 Native flora, 10 Moss, 5 Water barrels)
//   P    Auog paddock, 4 Auogs: 4 pups -> 2-4 Auogs (same inputs); pups come straight from RC
//   BM1, BM2  Barreling machines beside P and RC: Water barrels in, Empty barrels back (filtered)
//   AM   Assembling machine 1 (burner, a stack of fuel lasts days): Auog + Cage -> Caged Auog
//   SH   Slaughterhouse: Caged Auog -> parts + Cage (back to AM) + Blood
//   GA   Gene lab (Animal samples), east-facing: parts by two inserters, Blood by a 3-pipe link
//   FBR  Bonemeal (Bones + Steam); a Boiler burning spare Meat gives its Steam
//   Void Py burner fed by one inserter whose filter a decider combinator sets: any item SH holds
//        more than 30 of (spare Meat, Guts, Fat, Skin); spare Blood over an Overflow valve into a Sinkhole
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.path(76.5, -416.5, 'E21');                                         // service belt to x 96.5
g.add('rc-mk01', 70, -404, 'N', 'auog-pup-breeding-1');
g.add(ins, 61.5, -415.5, 'N'); g.add(ins, 62.5, -415.5, 'N');       // flora + moss
g.add('auog-paddock-mk01', 90, -408, 'N', 'auog-maturing-1');
g.add(ins, 84.5, -415.5, 'N'); g.add(ins, 85.5, -415.5, 'N');
g.add(ins, 82.5, -410.5, 'W', null, { filters: ['auog-pup'] });     // RC -> P
// Water barrels for P
g.add('barrel-machine-mk01', 88.5, -398.5, 'W', 'water-barrel');
g.add('pipe', 86.5, -397.5); g.add('offshore-pump', 85.5, -397.5, 'W');
g.add(ins, 88.5, -400.5, 'S');                                        // Water barrels -> P
g.add(ins, 87.5, -400.5, 'N', null, { filters: ['barrel'] });       // Empty barrels -> BM1
// Water barrels for RC
g.add('barrel-machine-mk01', 64.5, -390.5, 'W', 'water-barrel');
g.add('pipe', 62.5, -389.5); g.add('offshore-pump', 61.5, -389.5, 'W');
g.add(ins, 64.5, -392.5, 'S');
g.add(ins, 63.5, -392.5, 'N', null, { filters: ['barrel'] });
// Caging and slaughter
g.add('assembling-machine-1', 92.5, -398.5, 'N', 'caged-auog');
g.add(ins, 92.5, -400.5, 'N', null, { filters: ['auog'] });         // Auogs P -> AM
g.add('slaughterhouse-mk01', 92.5, -390.5, 'W', 'full-render-auogs');
g.add(ins, 92.5, -396.5, 'N');                                        // Caged Auogs AM -> SH
g.add(ins, 93.5, -396.5, 'S', null, { filters: ['cage'] });         // Cages SH -> AM
// Blood: SH west ports (86.5,-390.5/-388.5), GA east port (86.5,-389.5); spare under ground to a valve
for (const y of [-390.5, -389.5, -388.5]) g.add('pipe', 86.5, y);
g.add('pipe-to-ground', 86.5, -387.5, 'N');
g.add('pipe-to-ground', 86.5, -383.5, 'S');
g.add('py-overflow-valve', 86.5, -382.5, 'S');
// Parts SH -> GA (the Gene lab is placed when the start-up frees one)
g.add(ins, 86.5, -392.5, 'E'); g.add(ins, 86.5, -391.5, 'E');
// Bonemeal
g.add('fbreactor-mk01', 101.5, -390.5, 'N', 'bone-to-bonemeal-2');
g.add(ins, 98.5, -391.5, 'W', null, { filters: ['bones'] });
// Void
g.add('py-burner', 92.5, -382.5, 'N');
g.add(ins, 92.5, -384.5, 'N');
g.add('decider-combinator', 96.5, -398, 'N');
// Power
for (const [x, y] of [[57.5, -412.5], [57.5, -405.5], [57.5, -398.5], [60.5, -392.5], [66.5, -391.5], [73.5, -391.5],
  [78.5, -392.5], [80.5, -397.5], [84.5, -400.5], [90.5, -400.5], [95.5, -396.5], [98.5, -394.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-auog.json')));
