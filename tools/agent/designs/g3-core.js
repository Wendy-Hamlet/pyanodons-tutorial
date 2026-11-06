// Game 3: the green science core east of the Slaughterhouse (part 1). Direct insertion chain:
//   Soil extractor SE (drops behind itself, into A_ground) | A_clay (Rich clay: Ash + Water) -> A_ground
//   (Ground samples) -> A_alien (Alien samples) <- A_bio (Biosamples) ; A_alien -> RCg (Research center,
//   Logistic science pack) -> chest. The sarcorus Incubator goes north of RCg (part 2).
// Assembling machine 1 is a burner (a stack of fuel lasts days at these rates).
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('soil-extractor-mk01', 108.5, -389.5, 'W', 'soil');       // drops at x 112.3: A_ground
g.add('offshore-pump', 108.5, -385.5, 'S');                       // its bottom water port
g.add('assembling-machine-1', 113.5, -389.5, 'N', 'ground-sample01');
g.add('assembling-machine-1', 113.5, -393.5, 'N', 'rich-clay');
g.add('offshore-pump', 113.5, -395.5, 'N');                       // A_clay's top water port
g.add(ins, 113.5, -391.5, 'N');                                   // Rich clay -> A_ground
g.add(ins, 115.5, -389.5, 'W');                                   // Ground samples -> A_alien
g.add('assembling-machine-1', 117.5, -389.5, 'N', 'alien-sample01');
g.add('assembling-machine-1', 117.5, -393.5, 'N', 'bio-sample01');
g.add(ins, 117.5, -391.5, 'N');                                   // Biosamples -> A_alien
g.add(ins, 119.5, -389.5, 'W');                                   // Alien samples -> RCg
g.add('research-center-mk01', 125, -390, 'N', 'logistic-science-pack');
g.add(ins, 130.5, -388.5, 'W'); g.add('wooden-chest', 131.5, -388.5); // green packs out
for (const [x, y] of [[104.5, -396.5], [104.5, -389.5], [111.5, -396.5], [118.5, -396.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/g3-core.json')));
