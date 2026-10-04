// Methane -> methanal -> formica -> PCB block, north-east of the workshop (x 46..78, y -70..-34).
//
//   GH1  Moondrop greenhouse, Moondrop (moondrop-1: 4 seeds + water)        rows -69..-61
//   N2   Botanical nursery, Moondrop seeds (5 Moondrop -> 7+ seeds, 2+ back) rows -59..-53
//   GH2  Moondrop greenhouse, Methane (methane-co2: seed + water + CO2)    rows -51..-43
//   HPF-C (coke-co2) under GH2, its output straight into GH2's south input
//   HPF-M (methanal, Copper plate) east of GH2, Pulp mill (formica), WPU (raw fiber), PCB factory
//   with its own Vacuum pump.
// Item loop: GH1 -> A -> N2; N2 -> B -> GH1 (seeds), N2 -> C -> GH2 (seeds); returned Moondrop
// N2 -> D (filter) -> 2-tile belt -> E -> N2. Greenhouses need Moondrop modules (speed +1 each).
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
const GH = 'moondrop-greenhouse-mk01';

g.add(GH, 52.5, -64.5, 'N', 'moondrop-1');
g.add('pipe', 47.5, -64.5); g.add('offshore-pump', 47.5, -63.5, 'S');
g.add(ins, 52.5, -59.5, 'N');                       // A: GH1 -> N2
g.add(ins, 50.5, -59.5, 'S');                       // B: N2 -> GH1
g.add('botanical-nursery', 52.5, -55.5, 'N', 'moondrop-seeds');
g.add(ins, 56.5, -57.5, 'W', null, { filters: ['moondrop'] }); // D: N2 -> belt
g.path(57.5, -57.5, 'S2');
g.add(ins, 56.5, -56.5, 'E');                       // E: belt -> N2
g.add(ins, 52.5, -51.5, 'N');                       // C: N2 -> GH2
g.add(GH, 52.5, -46.5, 'N', 'methane-co2');
g.add('pipe', 47.5, -46.5); g.add('offshore-pump', 47.5, -45.5, 'S');
g.add('hpf', 52.5, -38.5, 'E', 'coke-co2');         // output north into GH2
g.add(ins, 56.5, -38.5, 'E'); g.add('wooden-chest', 57.5, -38.5);      // coke
g.add('pipe', 57.5, -46.5);
g.add('hpf', 61.5, -46.5, 'S', 'methanal');         // methane in west, methanal out east
g.add(ins, 61.5, -50.5, 'N'); g.add('wooden-chest', 61.5, -51.5);      // copper
g.add('pipe', 65.5, -46.5);
g.add('pulp-mill-mk01', 68.5, -47.5, 'E', 'formica'); // input #1 faces west
g.add(ins, 68.5, -50.5, 'N'); g.add('wooden-chest', 68.5, -51.5);      // treated wood, saps
g.add('wpu-mk01', 75, -48, 'N', 'fiber-01');
g.add(ins, 75.5, -51.5, 'N'); g.add('wooden-chest', 75.5, -52.5);      // wood
g.add(ins, 71.5, -47.5, 'E');                       // raw fiber WPU -> pulp mill
g.add(ins, 68.5, -44.5, 'N');                       // formica pulp mill -> PCB
g.add('pcb-factory-mk01', 68.5, -40.5, 'N', 'pcb1');
g.add(ins, 72.5, -40.5, 'E'); g.add('wooden-chest', 73.5, -40.5);      // copper
g.add(ins, 64.5, -40.5, 'E'); g.add('wooden-chest', 63.5, -40.5);      // pcb1 out
g.add('vacuum-pump-mk01', 68.5, -35.5, 'N', 'vacuum');
for (const [x, y] of [[47.5, -36.5], [47.5, -42.5], [46.5, -49.5], [47.5, -56.5], [47.5, -61.5],
  [54.5, -59.5], [58.5, -53.5], [57.5, -50.5], [64.5, -51.5], [71.5, -50.5], [72.5, -43.5], [70.5, -36.5]]) {
  g.add('small-electric-pole', x, y);
}
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/methane-block.json')));
