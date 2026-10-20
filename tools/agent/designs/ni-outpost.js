// Nickel outpost on the east edge of the field at x -288..-257, y 64..127 (game 2). Two Fluid
// mining drills MK 02 drop their ore into one Jaw crusher (grade-1-nickel, 5 ore -> 1 Grade 1 +
// 0.5 Stone): the south drill (-259.5,94.5) faces north, the north drill (-259.5,82.5) south.
// Syngas comes from the base's line at x -107.5 through a Check valve and an underground pipe
// along y 98.5, up x -256.5 to the south drill's east side, and under the crusher to the north
// drill's east side. Two Stone furnaces make the plates (1 Grade 1 -> 1 plate, 10 s), fuel from
// chests; plates and the crusher's Stone go into chests.
const { Layout } = require('../layout');
const g = new Layout();
const ins = (x, y, dir, filters) => g.add('burner-inserter', x, y, dir, null, filters ? { filters } : undefined);
const chest = (x, y) => g.add('wooden-chest', x, y);

g.add('fluid-drill-mk02', -259.5, 94.5, 'N');
g.add('fluid-drill-mk02', -259.5, 82.5, 'S');
g.add('jaw-crusher', -259.5, 88.5, 'N', 'grade-1-nickel');
g.add('stone-furnace', -254, 86);
g.add('stone-furnace', -254, 89);
ins(-255.5, 85.5, 'W', ['grade-1-nickel']);
ins(-255.5, 88.5, 'W', ['grade-1-nickel']);
ins(-255.5, 90.5, 'W', ['stone']); chest(-254.5, 90.5);
ins(-252.5, 85.5, 'W'); chest(-251.5, 85.5);          // plates
ins(-252.5, 88.5, 'W'); chest(-251.5, 88.5);          // plates
ins(-254.5, 84.5, 'N'); chest(-254.5, 83.5);          // fuel for the north furnace
ins(-253.5, 90.5, 'S'); chest(-253.5, 91.5);          // fuel for the south furnace
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/ni-outpost.json')));
