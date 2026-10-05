// Battery cell (battery-mk00: 5 Cellulose + 10 Zinc plate + 10 Copper plate + 250 Saline water)
// east of the methane block. A Washer (Stone + Water -> Saline water), turned south, puts its
// output straight into the north fluid input of a burner Assembling machine 1; an HPF makes
// Cellulose (Wood + Limestone) and hands it over by inserter; Zinc and Copper come from a chest.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('washer', 89, -60, 'S', 'saline-water');
g.add('offshore-pump', 88.5, -63.5, 'N');
g.add(ins, 85.5, -60.5, 'W'); g.add('wooden-chest', 84.5, -60.5);   // Stone
g.add('assembling-machine-1', 88.5, -55.5, 'N', 'battery-mk00');
g.add(ins, 86.5, -55.5, 'W'); g.add('wooden-chest', 85.5, -55.5);   // Zinc, Copper
g.add('hpf', 94.5, -53.5, 'N', 'cellulose-00');
g.add(ins, 90.5, -55.5, 'E');                                       // Cellulose HPF -> assembler
g.add(ins, 98.5, -53.5, 'E'); g.add('wooden-chest', 99.5, -53.5);   // Wood, Limestone
g.add(ins, 88.5, -53.5, 'N'); g.add('wooden-chest', 88.5, -52.5);   // batteries out
for (const [x, y] of [[78.5, -51.5], [83.5, -56.5], [89.5, -52.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/battery-cell.json')));
