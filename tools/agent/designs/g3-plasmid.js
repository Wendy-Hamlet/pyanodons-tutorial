// Game 3: Plasmids (Biofactory B1) and Incubated petri dishes (Micro mine M1), north of the red
// science belt. Zogna bacteria come by pipe from the battery line's Zogna line: a branch off its
// pipe at (-15.5,-388.5), south to y -385.5, under the Urea decomposition column (x 0..7) by a
// pipe-to-ground pair, east to the Biofactory's top ports.
const { Layout } = require('../layout');
const g = new Layout();
for (const y of [-387.5, -386.5, -385.5]) g.add('pipe', -15.5, y);
for (let x = -14.5; x <= -1.5; x++) g.add('pipe', x, -385.5);
g.add('pipe-to-ground', -0.5, -385.5, 'W');
g.add('pipe-to-ground', 8.5, -385.5, 'E');
for (let x = 9.5; x <= 17.5; x++) g.add('pipe', x, -385.5);
g.add('biofactory-mk01', 17.5, -381.5, 'N', 'plasmids');
g.add('burner-inserter', 21.5, -381.5, 'W'); g.add('wooden-chest', 22.5, -381.5); // Plasmids out
g.add('micro-mine-mk01', 24.5, -394.5, 'N', 'petri-dish-bacteria');
g.add('burner-inserter', 28.5, -394.5, 'W'); g.add('wooden-chest', 29.5, -394.5); // Incubated dishes out
for (const [x, y] of [[30.5, -389.5], [23.5, -389.5], [22.5, -383.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-plasmid.json')));
