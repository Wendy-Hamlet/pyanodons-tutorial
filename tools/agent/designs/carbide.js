// Calcium carbide for the lead outpost's Acetylene: HPF-L (lime: 15 Coke + 10 Limestone ->
// 10 Lime + 100 CO2, the CO2 into a gas vent) hands Lime straight to HPF2 below it (calcium-
// carbide: 7 Coke + 2 Lime -> 10 Calcium carbide). Coke and Limestone come from one chest.
const { Layout } = require('../layout');
const g = new Layout();
g.add('hpf', 5.5, -52.5, 'N', 'lime');
g.add('py-gas-vent', 1.5, -52.5, 'N');
g.add('burner-inserter', 5.5, -48.5, 'N');                // Lime HPF-L -> HPF2
g.add('burner-inserter', 5.5, -56.5, 'N'); g.add('wooden-chest', 5.5, -57.5);
g.add('small-electric-pole', 1.5, -49.5);
// Carbide out of HPF2 through three inserters (it makes 2.5/s, one inserter moves 0.83/s).
for (const y of [-45.5, -43.5, -42.5]) { g.add('burner-inserter', 9.5, y, 'W'); g.add('wooden-chest', 10.5, y); }
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/carbide.json')));
