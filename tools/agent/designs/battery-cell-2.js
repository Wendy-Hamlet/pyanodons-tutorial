// Battery cell 2 south of the quartz belt, east of the duralumin smelter: the first cell makes one
// Battery per 100 s because its Washer gives 50 Saline water per 20 s and a Battery takes 250.
// Same layout: Washer turned south straight into a burner Assembling machine 1. Cellulose is
// carried by the rounds from the first cell's HPF (it makes enough for both).
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('washer', 101, -22, 'S', 'saline-water');
g.add('offshore-pump', 100.5, -25.5, 'N');
g.add(ins, 104.5, -22.5, 'E'); g.add('wooden-chest', 105.5, -22.5);   // Stone
g.add('assembling-machine-1', 100.5, -17.5, 'N', 'battery-mk00');
g.add(ins, 102.5, -17.5, 'E'); g.add('wooden-chest', 103.5, -17.5);   // Zinc, Copper, Cellulose
g.add(ins, 100.5, -15.5, 'N'); g.add('wooden-chest', 100.5, -14.5);   // Batteries out
// Its own Cellulose HPF (one HPF makes 0.1/s, a cell at full speed needs 0.1/s): the HPF's output
// inserter drops into the cell's ingredient chest.
g.add('hpf', 108.5, -17.5, 'N', 'cellulose-00');
g.add(ins, 104.5, -17.5, 'E');                                          // Cellulose -> chest
g.add(ins, 108.5, -21.5, 'N'); g.add('wooden-chest', 108.5, -22.5);   // Wood, Limestone
for (const [x, y] of [[91.5, -5.5], [97.5, -9.5], [97.5, -16.5], [97.5, -21.5], [104.5, -19.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/battery-cell-2.json')));
