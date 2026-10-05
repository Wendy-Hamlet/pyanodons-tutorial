// Second Moondrop greenhouse for seeds (GH3), west of the seed nursery N2: with one seed
// greenhouse the Methane greenhouse GH2 could only run at ~70 % before it took every seed and the
// loop died (it did, at 16 modules). GH3 doubles the seed surplus. The pole at (47.5,-56.5)
// moves to the gap column, with one more at (48.5,-51.5) to keep both halves of the block linked.
const { Layout } = require('../layout');
const g = new Layout();
// Turned east: its first input (Water) then faces north; the Seaweed crop blocks the west side.
g.add('moondrop-greenhouse-mk01', 43.5, -55.5, 'E', 'moondrop-1');
g.add('offshore-pump', 43.5, -60.5, 'N');                     // outputs south into GH3's water input
g.add('burner-inserter', 48.5, -55.5, 'W');                   // Moondrop GH3 -> N2
g.add('burner-inserter', 48.5, -54.5, 'E');                   // seeds N2 -> GH3
g.add('small-electric-pole', 48.5, -57.5); g.add('small-electric-pole', 48.5, -51.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/methane-gh3.json')));
