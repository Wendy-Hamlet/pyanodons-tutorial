// Antimony oxide at the antimony outpost (game 2): a Basic oxygen furnace (347.5,10.5,
// sb-oxide-01: 10 Grade 4 + 50 Oxygen + 1 Plastic -> 1 oxide, 10 s) under screener B, whose
// Grade 4 inserter (347.5,6.5) now drops straight into it. The Secondary crusher's Grade 4 goes
// through a chest at (352.5,7.5) into its east side; B's Gravel moves to the north side. Oxygen
// comes from the Electrolyzer (339.5,20.5) up x 343.5 into the furnace's north input at
// (344.5,6.5); the vent behind an Overflow valve takes only the surplus. Plastic and fuel from
// chests on the south side, the oxide into a chest there.
const { Layout } = require('../layout');
const g = new Layout();
const ins = (x, y, dir, filters) => g.add('burner-inserter', x, y, dir, null, filters ? { filters } : undefined);
const chest = (x, y) => g.add('wooden-chest', x, y);

ins(349.5, -1.5, 'S', ['gravel']); chest(349.5, -2.5);
ins(352.5, 6.5, 'N'); chest(352.5, 7.5); ins(351.5, 7.5, 'E');
ins(345.5, 14.5, 'S'); chest(345.5, 15.5);   // plastic
ins(349.5, 14.5, 'S'); chest(349.5, 15.5);   // fuel
ins(347.5, 14.5, 'N'); chest(347.5, 15.5);   // Antimony oxide
for (const x of [340.5, 341.5, 342.5, 343.5]) g.add('pipe', x, 20.5);
for (let y = 19.5; y >= 6.5; y--) g.add('pipe', 343.5, y);
g.add('pipe', 344.5, 6.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/sb-bof.json')));
