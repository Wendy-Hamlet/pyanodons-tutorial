// Lead outpost on the east edge of the lead patch around (-486,-419). Lead ore needs Acetylene
// (10 per ore), made on the spot: a Gasifier turns Calcium carbide (carried here, 1 per ore) and
// Water into Acetylene, which passes straight into two Fluid drills side by side (0.5 ore/s
// each), each dropping into a Stone furnace (6 ore -> 1 Lead plate). Power for the Gasifier
// (500 kW) from one Boiler + Steam engine. Fuel chests with inserters for the Boiler and drills.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
for (const x of [-466.5, -461.5]) {
  g.add('fluid-drill-mk01', x, -419.5, 'N');
  g.add('stone-furnace', x + 0.5, -423);
  g.add(ins, x - 1, -416.5, 'S'); g.add('wooden-chest', x - 1, -415.5);  // drill fuel
}
g.add('gasifier', -455, -419, 'N', 'acetylene');      // Acetylene out west, Water in east
g.add('offshore-pump', -450.5, -419.5, 'E');
g.add(ins, -455.5, -423.5, 'N'); g.add('wooden-chest', -455.5, -424.5);   // Calcium carbide
g.add(ins, -453.5, -423.5, 'S'); g.add('wooden-chest', -453.5, -424.5);   // Slaked lime out
g.add('boiler', -444.5, -412, 'N');
g.add('steam-engine', -444.5, -415.5, 'N');
g.add('pipe', -446.5, -411.5); g.add('offshore-pump', -446.5, -410.5, 'S');
g.add(ins, -444.5, -410.5, 'S'); g.add('wooden-chest', -444.5, -409.5);   // Boiler fuel
// The Gasifier's second product, Slacked lime, is a liquid: its box (south-west corner) drains
// into a sinkhole, or the Gasifier stops after two crafts.
g.path(-459.5, -416.5, 'S3', 'pipe');
g.add('py-sinkhole', -459.5, -412.5, 'W');
g.add('small-electric-pole', -447.5, -416.5); g.add('small-electric-pole', -450.5, -417.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/lead-outpost.json')));
