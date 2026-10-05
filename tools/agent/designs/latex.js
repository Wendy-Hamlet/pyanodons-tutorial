// Latex block south of the vrauk area (x 100..140, y -50..-31; the quartz belt runs at y -27.5).
//   Washer (creamy-latex: Limestone + Saps + Water), turned south, straight into the first input
//   (north-west) of distilator D5 (latex-slab: Sodium alginate + Creamy latex + Formic acid).
//   HPF-A (sodium-alginate: Stone + Limestone + Seaweed + Water), turned south so its Water
//   input faces west, hands Alginate to D5 by inserter.
//   D5 hands Latex slabs to HPF-L2 (latex: slab + 150 Steam), Steam from a Boiler turned west.
//   Slaughterhouse (full-render-vrauks: caged Vrauks -> 200 Formic acid + meat, chitin, guts,
//   brain and the Cage back), turned south; Formic acid by pipe along y -32.5 into D5's south
//   input. (The slaughterhouse needs 50 circuits and 40 titanium: placed last.)
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('distilator', 114, -38, 'N', 'latex-slab');                          // D5
g.add('washer', 113, -45, 'S', 'creamy-latex');
g.add('offshore-pump', 112.5, -48.5, 'N');
g.add(ins, 116.5, -47.5, 'E'); g.add('wooden-chest', 117.5, -47.5);       // Limestone, Saps
g.add('hpf', 105.5, -38.5, 'S', 'sodium-alginate');                        // HPF-A
g.add('offshore-pump', 101.5, -38.5, 'W');
g.add(ins, 105.5, -42.5, 'N'); g.add('wooden-chest', 105.5, -43.5);       // Stone, Limestone, Seaweed
g.add(ins, 109.5, -38.5, 'W');                                             // Alginate HPF-A -> D5
g.add(ins, 118.5, -38.5, 'W');                                             // Latex slab D5 -> HPF-L2
g.add('hpf', 122.5, -38.5, 'N', 'latex');                                  // HPF-L2
g.add('boiler', 127, -38.5, 'W');
g.add('offshore-pump', 127.5, -36.5, 'S');
g.add(ins, 126.5, -40.5, 'N'); g.add('wooden-chest', 126.5, -41.5);       // Boiler fuel
g.add('slaughterhouse-mk01', 134.5, -38.5, 'S', 'full-render-vrauks');
g.path(134.5, -32.5, 'W22 N2', 'pipe');                                    // Formic acid -> D5
g.add(ins, 136.5, -44.5, 'N'); g.add('wooden-chest', 136.5, -45.5);       // caged Vrauks in (north side)
g.add(ins, 132.5, -44.5, 'S'); g.add('wooden-chest', 132.5, -45.5);       // meat, cages... out (north side)
for (const [x, y] of [[109.5, -45.5], [109.5, -41.5], [117.5, -43.5], [124.5, -43.5], [131.5, -45.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/latex.json')));
