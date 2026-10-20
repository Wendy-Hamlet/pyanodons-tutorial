// Nexelit from Tar (game 2), on the free middle of the raw coal field at x 25..52, y -101..-70.
// Placed by hand already: Destructive distillation column D (33,-93, distilled-raw-coal: 10 Raw
// coal -> 60 Coal gas + 30 Tar + 3 Coal + 0.2 Iron oxide, 2 s), fed directly by Electric mining
// drills at (32.5,-87.5) facing north and (38.5,-93.5) facing west; its Coal gas into a vent on
// its west side; two Boilers north of it (30.5/34.5,-99) with an Offshore pump and one Steam
// engine (32.5,-103.5) on the base grid burn its Coal; Quenching tower Q (44.5,-90.5, facing
// south, tar-quenching: 500 Tar + 500 Water -> 500 Tailings + Flue gas + Saline water + Soot)
// with Tar piped from D's east side, Water from a pump, Flue gas into a vent, Saline water into a
// sinkhole; Evaporator V (42.5,-81.5, nexelit-ore-1: 500 Tailings -> 1 Raw nexelit); Washer W
// (36,-81, clean-nexelit: 3 ore -> 1 clean). This adds the rest: inserters, chests, the Tailings
// pipe, W's water pump and sludge sinkhole, a Stone furnace for the plates, and the poles.
const { Layout } = require('../layout');
const g = new Layout();
const ins = (x, y, dir, filters) => g.add('burner-inserter', x, y, dir, null, filters ? { filters } : undefined);
const chest = (x, y) => g.add('wooden-chest', x, y);

ins(30.5, -97.5, 'S', ['coal']);                          // D -> Boiler 1
ins(33.5, -97.5, 'S', ['coal']);                          // D -> Boiler 2
ins(28.5, -93.5, 'E', ['iron-oxide']); chest(27.5, -93.5);
for (let y = -89.5; y <= -80.5; y++) g.add('pipe', 48.5, y);   // Tailings from Q's east side
for (const x of [47.5, 46.5, 45.5]) g.add('pipe', x, -80.5);
ins(39.5, -81.5, 'E', ['nexelit-ore']);                   // V -> W
ins(42.5, -78.5, 'N', ['tailings-dust']); chest(42.5, -77.5);
ins(42.5, -86.5, 'N'); chest(42.5, -85.5);                // Q's Soot (added after it stopped Q)
g.add('offshore-pump', 36.5, -77.5, 'S');                 // W's water from the south
g.add('pipe', 36.5, -84.5);                               // W's Muddy sludge north into a sinkhole
g.add('py-sinkhole', 36.5, -86.5, 'E');
g.add('stone-furnace', 31, -82);
ins(32.5, -81.5, 'E');                                    // W -> furnace (Clean nexelit)
ins(29.5, -81.5, 'E'); chest(28.5, -81.5);                // Nexelit plates
ins(30.5, -83.5, 'N'); chest(30.5, -84.5);                // furnace fuel
for (const [x, y] of [[30.5, -113.5], [29.5, -106.5], [28.5, -100.5], [27.5, -95.5], [27.5, -88.5],
  [34.5, -86.5], [32.5, -79.5], [40.5, -88.5], [40.5, -94.5], [45.5, -85.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/nexelit-tar.json')));
