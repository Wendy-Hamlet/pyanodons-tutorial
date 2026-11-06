// Game 3: a Glassworks for Optical sets (lens: Boron trioxide + 100 Molten glass -> 3) west of the
// bus at its north end. Molten glass branches off the bus pipe at (-104.5,-386.5) and runs along
// y -391.5 to the top port; Gasoline (fuel, 10 MW) off the bus pipe at (-110.5,-382.5) to the east
// fuel port. The bus pipes run under ground at both crossings.
const { Layout } = require('../layout');
const g = new Layout();
g.add('glassworks-mk01', -118.5, -387.5, 'N', 'lens');
for (let y = -386.5; y >= -391.5; y--) g.add('pipe', -105.5, y);
for (let x = -106.5; x >= -117.5; x--) g.add('pipe', x, -391.5);
g.add('pipe', -110.5, -383.5);
for (let x = -110.5; x >= -114.5; x--) g.add('pipe', x, -384.5);
for (const y of [-385.5, -386.5, -387.5]) g.add('pipe', -114.5, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-lens.json')));
