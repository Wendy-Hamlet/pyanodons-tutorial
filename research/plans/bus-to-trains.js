// The whole factory up to trains as one bus: red science 60/min, pY science pack 1 30/min and
// Simple circuit boards 10/min, with the recipes of science-red-py1.js and electronic-circuit.js
// (the author's choices from their first save). The blocks are laid out so that every item that
// save carried by hand (Ash, Coke, Tin/Lead/Zinc plates, Stone, Copper and Iron plates for the
// circuits) has a belt or pipe between two blocks instead.
// Solve with: node --max-old-space-size=4096 tools/rate-plan.js research/plans/bus-to-trains.js --build
const science = require('./science-red-py1');
const circuit = require('./electronic-circuit');

module.exports = {
  title: 'Bus to trains: red 60/min + pY1 30/min + Simple circuit board 10/min',
  techs: science.techs,
  scriptRecipes: science.scriptRecipes,
  fuel: 'raw-coal',
  electricity: 'steam',
  targets: { ...science.targets, ...circuit.targets },
  recipes: { ...science.recipes, ...circuit.recipes },
  blocks: {
    iron: ['processed-iron-ore', 'iron-plate'],
    copper: ['grade-1-copper', 'grade-2-copper', 'copper-plate'],
    bricks: ['stone-brick'],
    'small parts': ['iron-gear-wheel', 'iron-stick', 'bolts', 'copper-cable', 'small-parts-01'],
    red: ['empty-planter-box', 'planter-box', 'automation-science-pack'],
    'soil and limestone': ['soil', 'limestone'],
    wood: ['wood-seeds', 'wood-seedling', 'log', 'wood', 'raw-fiber'],
    sap: ['saps'],
    moss: ['muddy-sludge', 'moss'],
    // Moondrop greenhouses: CO2 for the moss farms and Methane for Formaldehyde.
    moondrop: ['moondrop-seeds', 'moondrop', 'carbon-dioxide', 'methane', 'methanal'],
    coal: ['coal'],
    // Tar refinery: Creosote, and Coke from its Pitch.
    tar: ['creosote', 'coke', 'graphite'],
    seaweed: ['seaweed'],
    glass: ['molten-glass', 'glass', 'empty-petri-dish', 'flask'],
    'petri dish': ['agar', 'petri-dish', 'petri-dish-bacteria'],
    vrauks: ['water-barrel', 'cocoon', 'vrauks', 'caged-vrauks', 'cage'],
    latex: ['creamy-latex', 'sodium-alginate', 'formic-acid', 'latex-slab', 'latex', 'stopper'],
    cellulose: ['cellulose'],
    py1: ['fawogae-substrate', 'py-science-pack-1'],
    ceramic: ['clay', 'ceramic'],
    'tin, lead, zinc': ['tin-plate', 'lead-plate', 'zinc-plate', 'solder'],
    pcb: ['treated-wood', 'formica', 'vacuum', 'pcb1'],
    components: ['vacuum-tube', 'inductor1', 'capacitor1', 'resistor1'],
    battery: ['water-saline', 'battery-mk00'],
    circuit: ['electronic-circuit'],
  },
  machines: { ...science.machines, ...circuit.machines },
  modules: { ...science.modules, ...circuit.modules },
  drills: science.drills,
  sources: science.sources,
};
