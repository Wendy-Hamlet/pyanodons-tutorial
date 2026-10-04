// Tar refinery at tailings pond 2 (-49,69): TPU 1 (tar-refining, facing east) takes Tar from the
// pond's east connection and Steam from a Boiler to the south. Its outputs (facing east):
// Middle oil (5,-3) north into a pond, Anthracene oil (5,-1) round to a pond in the east, Pitch
// (5,3) south into a pond, Creosote (5,1) straight east into TPU 2 (treated wood).
const { Layout } = require('../layout');
const g = new Layout();
g.add('tar-processing-unit', -17.5, 71.5, 'E', 'treated-wood');
g.path(-27.5, 67.5, 'N4', 'pipe');                    // middle oil -> pond M (-25,55)
g.add('tailings-pond', -25, 55);
g.path(-27.5, 69.5, 'E2 N4 E14', 'pipe');             // anthracene -> pond A (-3,67)
g.add('tailings-pond', -3, 67);
g.path(-27.5, 71.5, 'E5', 'pipe');                    // creosote -> TPU 2
g.path(-27.5, 73.5, 'S8', 'pipe');                    // pitch -> pond P (-29,90)
g.add('tailings-pond', -29, 90);
g.add('small-electric-pole', -21.5, 64.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/tar-refinery.json')));
