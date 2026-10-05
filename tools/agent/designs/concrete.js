// Concrete for the reproduction complex (rc-mk01: 100 Concrete): a Jaw crusher next to the stone
// drills (Stone -> Gravel, then switched to Gravel -> Sand; 3 per second either way) and a
// burner Assembling machine 1 with a Water pump on its north input (Lime + Gravel + Sand ->
// Concrete). Fed by hand: 100 Concrete is a one-off.
const { Layout } = require('../layout');
const g = new Layout();
g.add('jaw-crusher', -52.5, 30.5, 'N', 'stone-to-gravel');
g.add('assembling-machine-1', -45.5, 30.5, 'N', 'concrete');
g.add('offshore-pump', -45.5, 28.5, 'N');
g.add('small-electric-pole', -40.5, 30.5); g.add('small-electric-pole', -47.5, 32.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/concrete.json')));
