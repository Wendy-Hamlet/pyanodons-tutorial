// Twelve burner drills on the eastern Raw coal patch, each into a chest (a burner drill nets about
// 0.8 Raw coal/s after its own fuel). Added at game 22:00: Raw coal ran 16 000/h short while the
// pY1 chain's distillers and the outposts burned it. Rounds collect the chests from the far east
// stop. A burner drill facing north drops at (x-0.35, y-1.3).
const { Layout } = require('../layout');
const g = new Layout();
for (const [x, y] of [[227, 9], [241, 9], [243, 9], [245, 9], [247, 9], [249, 9], [251, 9], [253, 9], [255, 9], [257, 9], [225, 12], [227, 12]]) {
  g.add('burner-mining-drill', x, y, 'N');
  g.add('wooden-chest', x - 0.5, y - 1.5);
}
console.log(JSON.stringify(g.write(process.argv[2] || 'C:/tmp/cf-agent/coal-drills-east.json')));
