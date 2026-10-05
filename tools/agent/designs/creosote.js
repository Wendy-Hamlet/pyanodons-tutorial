// More Creosote for Treated wood: Tar refining gives 24 Creosote but 75 Anthracene oil per run,
// and Anthracene oil -> Creosote (50 -> 20) doubles the Creosote. TPU 3 sits on pond A's north
// connection (Anthracene oil in from the south, Creosote out of box 3, north-west), TPU 4 right
// above it takes that Creosote into its first input and makes Treated wood from Wood.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('tar-processing-unit', -1.5, 52.5, 'N', 'anthracene-oil-creosote');  // TPU 3
g.add('tar-processing-unit', -4.5, 41.5, 'N', 'treated-wood');             // TPU 4
g.add(ins, -10.5, 40.5, 'W'); g.add('wooden-chest', -11.5, 40.5);          // Wood
g.add(ins, 1.5, 40.5, 'W'); g.add('wooden-chest', 2.5, 40.5);              // Treated wood out
g.add('small-electric-pole', -11.5, 42.5); g.add('small-electric-pole', -8.5, 47.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/creosote.json')));
