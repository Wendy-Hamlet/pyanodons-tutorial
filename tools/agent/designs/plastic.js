// Plastic for the genlab and the Creature chamber (aromatics-to-plastic: 50 Aromatics + 100 Syngas
// -> 1 Plastic bar, in a Biofactory). Below the duralumin plant:
//   D8 (tar-distilation) takes D7's Tar straight into its north input; read with \`boxes\`: Tar
//   in on all four sides, Flue gas out north/south, CO2 out west/east, Aromatics out at the
//   south-east corner only (83.5,19.5 -> 84.5,19.5). Flue gas and CO2 go into vents. Pipes must
//   keep off the other free connections (84.5,14.5 Tar, 84.5,17.5 CO2).
//   The Biofactory gets Aromatics from D8 and Syngas from the duralumin gasifier's second output.
const { Layout } = require('../layout');
const g = new Layout();
g.add('distilator', 80, 16, 'N', 'tar-distilation');                 // D8
g.add('py-gas-vent', 81.5, 20.5, 'W');                               // Flue gas (connection faces north)
g.add('py-gas-vent', 75.5, 17.5, 'N');                               // CO2 (connection faces east)
g.add('small-electric-pole', 84.5, 8.5); g.add('small-electric-pole', 84.5, 12.5);
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/plastic.json')));
