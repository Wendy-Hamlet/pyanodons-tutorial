// Game 3: the Solidified sarcorus branch (core part 2).
//   CP  Compost plant (furnace, 125.5,-423.5): Native flora (and Moss) off the service belt -> Biomass
//   HX  Heat exchanger (135.5,-423.5): Biomass (inserter from CP) + Pressured water -> Subcritical water
//   VP  Vacuum pump (143.5,-423.5): Water (own Offshore pump) -> Pressured water, to HX's east port
//   RF  Reformer (145.5,-399.5): Liquid manure (top) + Subcritical water (bottom) -> Depolymerized
//       organics, west port straight to I_sar's east port along y -401.5
//   I_sar Incubator (125.5,-399.5) -> RCg below it
// The Subcritical water pipe (HX north port -> RF bottom) and the Liquid manure pipe (battery line ->
// RF top) are routed with route.js.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.path(97.5, -416.5, 'E29');                                   // service belt on to x 125.5
g.add(ins, 125.5, -417.5, 'S');                                // flora -> CP
g.add('vacuum-pump-mk01', 143.5, -423.5, 'N', 'pressured-water');
g.add('offshore-pump', 145.5, -423.5, 'E');                     // into VP's east input
for (const x of [143.5, 142.5, 141.5, 140.5, 139.5]) g.add('pipe', x, -421.5);
g.add('pipe', 139.5, -422.5); g.add('pipe', 139.5, -423.5);    // HX east port
for (let x = 129.5; x <= 138.5; x++) g.add('pipe', x, -401.5); // Depolymerized organics RF -> I_sar
g.add(ins, 125.5, -395.5, 'N');                                // Sarcorus I_sar -> RCg
for (const [x, y] of [[121.5, -401.5], [125.5, -404.5], [132.5, -404.5], [138.5, -405.5], [138.5, -412.5],
  [138.5, -419.5], [131.5, -419.5], [141.5, -420.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-sarcorus.json')));
