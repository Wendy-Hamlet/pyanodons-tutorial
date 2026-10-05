// Creature block (x 100..122, y -9..18) for the first Vrauks, all items, chests in and out:
//   Incubator (bio-sample: Bio container + 15 Native flora, 10 s) hands Bio samples through an
//   inserter / chest / inserter link to the Data array (earth-generic-sample: Iron chest + 15 red
//   packs + 10 Bio samples, 25 s). Genlab (moss-gen: 2 Petri dishes + 20 Moss) below the
//   incubator, Creature chamber (vrauks: 10 Petri dishes + 10 Native flora + 3 Moss-gen + 2 Earth
//   samples + Vrauks codex, 400 s) below the data array.
const { Layout } = require('../layout');
const g = new Layout();
const ins = 'burner-inserter';
g.add('incubator-mk01', 103.5, -2.5, 'N', 'bio-sample');
g.add(ins, 103.5, -6.5, 'N'); g.add('wooden-chest', 103.5, -7.5);
g.add(ins, 107.5, -2.5, 'W'); g.add('wooden-chest', 108.5, -2.5); g.add(ins, 109.5, -2.5, 'W');
g.add('data-array', 115, -2, 'N', 'earth-generic-sample');
g.add(ins, 115.5, -7.5, 'N'); g.add('wooden-chest', 115.5, -8.5);
g.add(ins, 115.5, 3.5, 'N'); g.add('wooden-chest', 115.5, 4.5);
g.add('genlab-mk01', 103.5, 10.5, 'N', 'moss-gen');
g.add(ins, 103.5, 6.5, 'N'); g.add('wooden-chest', 103.5, 5.5);
g.add(ins, 103.5, 14.5, 'N'); g.add('wooden-chest', 103.5, 15.5);
g.add('creature-chamber-mk01', 116.5, 12.5, 'N', 'vrauks');
g.add(ins, 116.5, 6.5, 'N'); g.add('wooden-chest', 116.5, 5.5);
g.add(ins, 116.5, 18.5, 'N'); g.add('wooden-chest', 116.5, 19.5);
for (const [x, y] of [[89.5, 5.5], [96.5, 5.5], [99.5, -0.5], [106.5, 1.5], [109.5, 1.5], [99.5, 6.5], [109.5, 8.5]]) g.add('small-electric-pole', x, y);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/creature.json')));
