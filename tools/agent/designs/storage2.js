// Warehouse extension and ash disposal south of the east warehouse block (x 30..41, y 5..12).
// The warehouse filled up (ash alone took 558 of its stacks), so stash_all stopped storing,
// the inventory stayed full and upkeep missed whole collections. 24 iron chests (768 stacks)
// (Ash comes in at ~11/s from all the burners: 40 stacks an hour.)
const { Layout } = require('../layout');
const g = new Layout();
for (const y of [5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 11.5]) for (let x = 30.5; x <= 41.5; x++) g.add('iron-chest', x, y);  // rows 7.5/8.5 added at game 18:00, 9.5-12.5 at 19:20
for (const y of [5.5, 6.5, 7.5, 8.5]) for (let x = 44.5; x <= 55.5; x++) g.add('iron-chest', x, y);  // added at game 20:30
// py-burners voiding Ash (3.3/s each), researched at game 22:10.
for (const x of [58.5, 62.5, 66.5]) g.add('py-burner', x, 10.5, 'N', 'ash-pyvoid');
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/storage2.json')));
