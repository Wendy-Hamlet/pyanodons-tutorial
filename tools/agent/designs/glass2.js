// Glass line 2 beside the quartz belt's north-south leg (belt at x 161.5). Glass costs ~56 MJ of
// fluid fuel per piece; the first line burns Tar (9/s, 1.8 MW) and made 40 Glass an hour while
// the distillers vented 29 Coal gas/s. Here a Distillation column D6 (Raw coal by 3 inserters)
// sends its Coal gas to a Gasifier (Coal gas + Water -> Syngas, 0.4 MJ instead of 0.2: 2.8x the
// energy), and only Syngas reaches the glassworks; D6's Tar goes into a sinkhole.
//   G3 (glass-1, Quartz from the belt) drops Molten glass straight into G4 (molten-glass) below.
//   Glassworks fuel boxes share their east/west positions with recipe box 5: never switch their
//   recipes (lesson 38). Unused input/output boxes that touch a pipe of the same fluid are
//   harmless as long as no recipe changes.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('glassworks-mk01', 156.5, -40.5, 'N', 'glass-1');                    // G3
g.add(ins, 160.5, -40.5, 'E');                                             // Quartz from the belt
g.add('glassworks-mk01', 155.5, -33.5, 'N', 'molten-glass');               // G4
g.add(ins, 156.5, -29.5, 'N'); g.add('wooden-chest', 156.5, -28.5);       // Glass out
// The Gasifier, turned west, has its inputs on the north side (Coal gas at x 146.5/144.5, Water
// at 149.5) and its outputs on the south side (Syngas at 146.5/144.5, Tar at 149.5). Syngas also
// comes with 30 Tar per run: Tar goes straight into a sinkhole, Syngas round to both fuel boxes.
g.add('gasifier', 147, -38, 'W', 'syngas');
g.path(142.5, -48.5, 'S6 E3', 'pipe');                                     // Coal gas D6 -> gasifier
g.path(149.5, -42.5, 'E1', 'pipe'); g.add('pipe', 150.5, -42.5); g.add('offshore-pump', 151.5, -42.5, 'E');
g.add('py-sinkhole', 149.5, -32.5, 'W');                                   // Tar (connection faces north)
g.path(146.5, -33.5, 'S3 E5 N11', 'pipe'); g.add('pipe', 152.5, -40.5);   // Syngas -> G4, G3
g.add('distilator', 147, -47, 'W', 'distilled-raw-coal');                  // D6: Coal gas west, Tar north
g.add('py-sinkhole', 148.5, -52.5, 'E');                                   // Tar (connection faces south)
for (const x of [143.5, 144.5, 146.5]) { g.add(ins, x, -51.5, 'N'); g.add('wooden-chest', x, -52.5); }
for (const y of [-47.5, -46.5]) { g.add(ins, 151.5, y, 'W'); g.add('wooden-chest', 152.5, y); } // Coal, Iron oxide
g.add('small-electric-pole', 141.5, -36.5); g.add('small-electric-pole', 141.5, -43.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/glass2.json')));
