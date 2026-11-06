// Game 3: Boron trioxide cell for Optical sets (lens). Hydrogen from the ralesia Electrolyzer's row
// (37.5,-451.5) up under the oxygen vent to the Diborane Electrolyzer (east-facing, 34,-462); its
// Diborane west and over the top to the Boric acid Electrolyzer (26,-462) left port; Water by its own
// pump into the right port; Boric acid down to a High pressure furnace (27.5,-444.5) on Coke.
const { Layout } = require('../layout');
const g = new Layout();
g.add('pipe', 37.5, -452.5);
g.add('pipe-to-ground', 37.5, -453.5, 'S'); g.add('pipe-to-ground', 37.5, -458.5, 'N');
g.add('pipe', 37.5, -459.5); g.add('pipe', 37.5, -460.5);
for (let y = -464.5; y >= -467.5; y--) g.add('pipe', 30.5, y);
for (let x = 29.5; x >= 25.5; x--) g.add('pipe', x, -467.5);
g.add('pipe', 25.5, -466.5); g.add('pipe', 25.5, -465.5);
g.add('offshore-pump', 27.5, -465.5, 'N');
for (let y = -458.5; y >= -449.5; y--) g.add('pipe', 27.5, y);
for (let x = 28.5; x <= 31.5; x++) g.add('pipe', x, -449.5);
for (let y = -448.5; y >= -444.5; y--) g.add('pipe', 31.5, y);
g.add('hpf', 27.5, -444.5, 'N', 'boron-trioxide');
for (const [x, y] of [[38.5, -456.5], [38.5, -463.5], [32.5, -466.5], [29.5, -466.5], [32.5, -446.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-boron.json')));
