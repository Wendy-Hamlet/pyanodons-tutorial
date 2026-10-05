// Red science cell v1: one chain Empty planter box -> Planter box -> Automation science pack
// (at most 12 packs/min, the pack recipe's 5 s), fed by belt segments, packs on a belt past
// eight labs. Absolute coordinates in the agent's game (chain row y 17..19, x 11..21).
//
// Every machine touches one belt segment north and one south; neighbouring segments flow in
// opposite directions so they never touch. Each segment starts at a port: a belt tile with an
// inserter behind it (items on the right lane) and one on its right side (left lane), each taking
// from a chest. Ports are chests for now; producers will be belted to them later.
//
//   N1 (A1): Stone brick | Wood        S1 (A1): Iron plate
//   N2 (A2): Soil | Soil                S2 (A2): Ash | Raw coal (fuel)
//   N3 (A3): Native flora | Native flora S3 (A3): Small parts | Raw coal (fuel)
// A1 burns the Wood it is fed.
const { Layout } = require('../layout');
const g = new Layout();
const asm = 'assembling-machine-1';
const ins = 'burner-inserter';

// Chain row
g.add(asm, 12.5, 18.5, 'N', 'empty-planter-box');
g.add(asm, 16.5, 18.5, 'N', 'planter-box');
g.add(asm, 20.5, 18.5, 'N', 'automation-science-pack');
g.add(ins, 14.5, 18.5, 'W'); g.add(ins, 18.5, 18.5, 'W'); g.add(ins, 22.5, 18.5, 'W');

// Feeders: north side picks from y 15.5, south side from y 21.5
for (const x of [11.5, 12.5, 13.5, 15.5, 16.5, 17.5, 19.5, 20.5, 21.5]) g.add(ins, x, 16.5, 'N');
for (const x of [12.5, 15.5, 16.5, 17.5, 20.5, 21.5]) g.add(ins, x, 20.5, 'S');

// Segments with their feed columns, and ports (start tile, inserter behind + chest, inserter on
// the right side + chest). Southbound columns: right side = west; northbound: right side = east.
function port(x, y, dir, behind, side) {
  const back = { S: [0, -1], N: [0, 1] }[dir];
  const right = { S: -1, N: 1 }[dir];
  if (behind) { g.add(ins, x + back[0], y + back[1], dir === 'S' ? 'N' : 'S'); g.add('wooden-chest', x, y + 2 * back[1]); }
  if (side) { g.add(ins, x + right, y, right < 0 ? 'W' : 'E'); g.add('wooden-chest', x + 2 * right, y); }
}
g.path(11.5, 12.5, 'S3 E3'); port(11.5, 12.5, 'S', true, true);   // N1
g.path(17.5, 12.5, 'S3 W3'); port(17.5, 12.5, 'S', true, true);   // N2
g.path(19.5, 8.5, 'S7 E3'); port(19.5, 8.5, 'S', true, true);     // N3
g.path(11.5, 25.5, 'N4 E3'); port(11.5, 25.5, 'N', true, false);  // S1
g.path(17.5, 29.5, 'N8 W3'); port(17.5, 29.5, 'N', true, true);   // S2
g.path(19.5, 25.5, 'N4 E3'); port(19.5, 25.5, 'N', true, true);   // S3

// Packs: belt east past four labs on each side
g.path(23.5, 18.5, 'E24');
for (const x of [26.5, 32.5, 38.5, 44.5]) {
  g.add('lab', x, 14.5); g.add(ins, x, 17.5, 'S');
  g.add('lab', x, 22.5); g.add(ins, x, 19.5, 'N');
}
// Ash also reaches this belt and would block its end: a filter inserter takes it, and the packs
// the labs leave, into a chest (the data array needs red packs too).
g.add(ins, 47.5, 18.5, 'W', null, { filters: ['iron-plate'], filter_mode: 'blacklist' });  // one filter slot: blacklist g.add('wooden-chest', 48.5, 18.5);
for (const [x, y] of [[24.5, 10.5], [29.5, 14.5], [29.5, 17.5], [29.5, 22.5], [35.5, 14.5], [35.5, 22.5], [41.5, 14.5], [41.5, 22.5]]) {
  g.add('small-electric-pole', x, y);
}

const out = process.argv[2] || 'C:/tmp/cf-agent/red-science-cell.json';
console.log(JSON.stringify(g.write(out)));
