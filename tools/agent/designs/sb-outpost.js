// Antimony outpost on the field at x 320..351, y 0..31 (game 2). The machines stand already:
// Antimony drill MK 01 (331.5,9.5) facing north drops its ore into Automated screener A
// (331.5,2.5, sb-grade-01); Jaw crusher J (339.5,2.5, sb-grade-02); Automated screener B
// (347.5,2.5, sb-grade-03); Secondary crusher S (355.5,2.5, sb-grade-04); Electrolyzer E
// (338,17, hydrogen): its Hydrogen fuels the drill, its Oxygen is vented for now.
// This adds the inserters (filtered where a machine has several products), chests and pipes.
const { Layout } = require('../layout');
const g = new Layout();
const ins = (x, y, dir, filters) => g.add('burner-inserter', x, y, dir, null, filters ? { filters } : undefined);
const chest = (x, y) => g.add('wooden-chest', x, y);

// A -> J: Grade 1. A -> belt -> B: Grade 2 (0.3/s). A's Stone and Iron oxide -> chest.
ins(335.5, 1.5, 'W', ['sb-grade-01']);
ins(331.5, -1.5, 'S', ['sb-grade-02']);
g.path(331.5, -2.5, 'E17');
ins(347.5, -1.5, 'N');
ins(329.5, -1.5, 'S', ['stone', 'iron-oxide']); chest(329.5, -2.5);
// J -> B: Grade 2 (1/s, two inserters); J's Stone -> chest.
ins(343.5, 1.5, 'W', ['sb-grade-02']);
ins(343.5, 3.5, 'W', ['sb-grade-02']);
ins(339.5, 6.5, 'N', ['stone']); chest(339.5, 7.5);
// B -> S: Grade 3. B's Grade 4 and Gravel -> chests. S's Grade 4 -> the Grade 4 chest's twin.
ins(351.5, 2.5, 'W', ['sb-grade-03']);
ins(347.5, 6.5, 'N', ['sb-grade-04']); chest(347.5, 7.5);
ins(345.5, 6.5, 'N', ['gravel']); chest(345.5, 7.5);
ins(355.5, 6.5, 'N'); chest(355.5, 7.5);
// Water: Offshore pump east of the electrolyzer into its north inputs.
g.add('pipe', 339.5, 13.5); g.add('pipe', 340.5, 13.5);
// Hydrogen: (335.5,20.5) west, then north into the drill's fuel input at (331.5,13.5).
for (let x = 335.5; x >= 331.5; x--) g.add('pipe', x, 20.5);
for (let y = 19.5; y >= 13.5; y--) g.add('pipe', 331.5, y);
// Oxygen: one pipe tile to a vent.
g.add('pipe', 339.5, 20.5);
// Poles: the line ends at (327.5,13.5).
for (const [x, y] of [[334.5, 13.5], [335.5, 6.5], [342.5, 6.5], [349.5, 6.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/sb-outpost.json')));
