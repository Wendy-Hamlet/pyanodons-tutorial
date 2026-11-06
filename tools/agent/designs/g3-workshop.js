// Game 3: the start-up workshop north of the service belt (y -416.5), as the author's temporary
// workshop of chapter 16. Native flora and Moss come off the belt by inserters; the one-time items
// (Bio containers, Petri dishes, Iron chests...) go in by hand. Outputs into chests above.
//   I1, I2  Incubators: Biosamples (Bio container + 15 Native flora)
//   G1      Gene lab: Moss gene samples (2 Petri dishes + 20 Moss), later cDNA
//   D1      Data array beside the red science belt (y -376.5): Generic earth DNA samples
const { Layout } = require('../layout');
const g = new Layout();
const row = [[17.5, 'incubator-mk01', 'bio-sample'], [24.5, 'incubator-mk01', 'bio-sample'], [31.5, 'genlab-mk01', 'moss-gen']];
for (const [x, name, recipe] of row) {
  g.add(name, x, -421.5, 'N', recipe);
  g.add('burner-inserter', x, -417.5, 'S'); // from the service belt
  g.add('burner-inserter', x, -425.5, 'S'); // output up
  g.add('wooden-chest', x, -426.5);
}
for (const x of [19.5, 26.5, 33.5, 40.5]) g.add('small-electric-pole', x, -417.5);
g.add('data-array', 30, -383, 'N', 'earth-generic-sample');
g.add('burner-inserter', 30.5, -377.5, 'S'); // red packs from the lab belt
for (const [x, y] of [[49.5, -397.5], [43.5, -393.5], [37.5, -389.5], [35.5, -384.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-workshop.json')));
