// Electronics block next to the science block: two Electronics factories, one on Resistors
// (2 Coke + Glass + Tin -> 3) and one on Capacitors (Ceramic + 2 Tin -> 3), chest in and out.
// A chipshooter run of 3 circuits takes 6 Resistors and 5 Capacitors.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
for (const [x, recipe] of [[65.5, 'resistor1'], [72.5, 'capacitor1']]) {
  g.add('electronics-factory-mk01', x, -15.5, 'N', recipe);
  g.add(ins, x, -18.5, 'N'); g.add('wooden-chest', x, -19.5);   // inputs
  g.add(ins, x, -12.5, 'N'); g.add('wooden-chest', x, -11.5);   // outputs
}
// Graphite for the Vacuum tubes (5 Coke -> 2) in an HPF east of them.
g.add('hpf', 79.5, -15.5, 'N', 'graphite');
g.add(ins, 79.5, -19.5, 'N'); g.add('wooden-chest', 79.5, -20.5);
g.add(ins, 79.5, -11.5, 'N'); g.add('wooden-chest', 79.5, -10.5);
for (const [x, y] of [[56.5, -22.5], [61.5, -18.5], [68.5, -18.5], [75.5, -18.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/electronics.json')));
