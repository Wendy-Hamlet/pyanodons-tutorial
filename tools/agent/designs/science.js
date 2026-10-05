// Science block south of the quartz belt (x 40..60, y -22..-8): a Micro mine turns Petri dishes
// into Petri dish bacteria (for Fawogae substrate: 3 Cellulose + 2 bacteria + 5 Moss -> 10, by
// hand), the Research center MK01 makes pY1 packs (3 Flasks + 18 substrate -> 3 packs, 15 s).
// Chests in and out; the labs get pY1 packs by hand.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('micro-mine-mk01', 45.5, -15.5, 'N', 'petri-dish-bacteria');
g.add(ins, 45.5, -19.5, 'N'); g.add('wooden-chest', 45.5, -20.5);   // Petri dishes in
g.add(ins, 45.5, -11.5, 'N'); g.add('wooden-chest', 45.5, -10.5);   // bacteria out
g.add('research-center-mk01', 55, -15, 'N', 'py-science-pack-1');
g.add(ins, 55.5, -20.5, 'N'); g.add('wooden-chest', 55.5, -21.5);   // Flasks, substrate in
g.add(ins, 55.5, -9.5, 'N'); g.add('wooden-chest', 55.5, -8.5);     // pY1 out
g.add('small-electric-pole', 49.5, -22.5); g.add('small-electric-pole', 49.5, -17.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/science.json')));
