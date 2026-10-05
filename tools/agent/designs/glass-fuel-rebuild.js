// The glass line's Tar fuel network as it stood at game 15:10, written out to rebuild it after
// Molten glass got into it a second time (G2's recipe was switched from Empty petri dish back to
// Glass; the leftover Molten glass moved into G2's other, unfiltered input box, which is
// connected to the fuel pipes). Pond 1, the pipes from the distillers' Tar outputs to the pond
// and on to both Glassworks, G1 (glass-1) and G2 (molten-glass -> Glass). Never switch G2 again.
const { Layout } = require('../layout');
const g = new Layout();
g.add('tailings-pond', -15, -24);
for (let y = -25.5; y <= -20.5; y++) g.add('pipe', -24.5, y);
g.add('pipe', -25.5, -20.5);
for (let y = -22.5; y <= -15.5; y++) g.add('pipe', -5.5, y);
g.add('pipe', -4.5, -15.5); g.add('pipe', -3.5, -15.5);
g.add('pipe', -4.5, -22.5); g.add('pipe', -3.5, -22.5); g.add('pipe', -2.5, -22.5);
g.add('glassworks-mk01', 1.5, -22.5, 'N', 'glass-1');
g.add('glassworks-mk01', 0.5, -15.5, 'N', 'molten-glass');
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/glass-fuel.json')));
