// Chipshooter for Electronic circuits (battery-mk00 + 5 Capacitor + 3 Inductor + 6 Resistor +
// PCB + 3 Vacuum tube + 2 Solder -> 3 circuits in 4 s), east of the PCB factory. All seven
// ingredients come from one chest (about one craft per 25 s through a burner inserter).
const { Layout } = require('../layout');
const g = new Layout();
g.add('chipshooter-mk01', 81.5, -40.5, 'N', 'electronic-circuit');
g.add('burner-inserter', 81.5, -43.5, 'N'); g.add('wooden-chest', 81.5, -44.5);   // ingredients
g.add('burner-inserter', 81.5, -37.5, 'N'); g.add('wooden-chest', 81.5, -36.5);   // circuits out
g.add('small-electric-pole', 78.5, -41.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/chip.json')));
