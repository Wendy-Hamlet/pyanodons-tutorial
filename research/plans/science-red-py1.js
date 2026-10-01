// Red science 60/min and pY science pack 1 30/min: the factory of the red + pY1 era (up to
// trains). Every technology that costs pY1 costs 2 red + 1 pY1 per unit, so 30/min keeps the labs
// fed at 60 red/min; red-only technologies leave the pY1 line idle.
// Solve with: node --max-old-space-size=4096 tools/rate-plan.js research/plans/science-red-py1.js --build
// One recipe per item: the author's choices, read from their first save ("Pyanodons", 27 h, up to
// Simple circuit boards), else the simplest one unlocked on the way to trains. Anything not listed
// is a raw input (mined, pumped, burnt, or a byproduct of the plan itself).
module.exports = {
  title: 'Red science 60/min + pY science pack 1 30/min',
  // Recipes unlocked on the way to trains, plus Fluid handling for the Water barrels of the vrauks.
  techs: ['railway', 'automated-rail-transportation', 'fluid-handling'],
  // Enabled by the T.U.R.D. upgrades the author chose (Fastwood forestry upgrade, Moondrop
  // upgrade): no technology lists them, their first save runs them.
  scriptRecipes: ['log-wood-fast', 'moondrop-co2'],
  // Everything that burns uses Raw coal (the map has no Coal ore); electricity from steam engines.
  fuel: 'raw-coal',
  electricity: 'steam',
  targets: { 'automation-science-pack': 60, 'py-science-pack-1': 30 },
  recipes: {
    // ---- red science ----
    'automation-science-pack': 'automation-science-pack',
    'planter-box': 'planter-box',
    'empty-planter-box': 'empty-planter-box',
    'stone-brick': 'stone-brick',
    'small-parts-01': 'small-parts-01',
    'iron-gear-wheel': 'iron-gear-wheel',
    'copper-cable': 'copper-cable',
    bolts: 'bolts',
    'iron-stick': 'iron-stick',
    // Iron through the Crusher (the stage's goal): 5 ore -> 1 plate + 1 Stone instead of 8 -> 1.
    'iron-plate': 'low-grade-smelting-iron',
    'processed-iron-ore': 'grade-1-iron-crush',
    // Copper through the Screener and Crusher (Copper processing 1), as in the author's save:
    // 5 ore -> 1 grade-1 + 2 grade-2; 2 grade-1 -> 1 grade-2 + 2 Stone; 5 grade-2 -> 2 plates.
    'copper-plate': 'copper-plate-4',
    'grade-1-copper': 'grade-2-copper',
    'grade-2-copper': 'grade-1-copper-crush',
    soil: 'soil',
    // Wood farm as in the author's save: 6 logs per 3 seedlings with 30 Ash (log3), and the
    // upgraded Wood processing unit recipe (40 Wood per 4 logs in 1 s).
    wood: 'log-wood-fast',
    log: 'log3',
    'wood-seedling': 'wood-seedling',
    'wood-seeds': 'wood-seeds',
    // ---- pY science pack 1 ----
    'py-science-pack-1': 'py-science-pack-1',
    'fawogae-substrate': 'fawogae-substrate',
    moss: 'Moss-2', // 16 Moss per 80 s with 20 Stone, against 8 per 100 s without
    'muddy-sludge': 'muddy-sludge',
    // CO2 from Moondrop greenhouses after the Moondrop upgrade (200 per 5 s from nothing), as in
    // the author's save; before it, Coke -> CO2 in a High pressure furnace.
    'carbon-dioxide': 'moondrop-co2',
    coal: 'distilled-raw-coal', // for the Rubber stoppers
    'petri-dish-bacteria': 'petri-dish-bacteria',
    'petri-dish': 'petri-dish',
    agar: 'agar',
    seaweed: 'seaweed-1',
    'empty-petri-dish': 'empty-petri-dish',
    'molten-glass': 'glass-1',
    cellulose: 'cellulose-00',
    limestone: 'extract-limestone-01',
    flask: 'flask',
    stopper: 'stopper',
    latex: 'latex',
    'latex-slab': 'latex-slab',
    'sodium-alginate': 'sodium-alginate',
    'creamy-latex': 'creamy-latex',
    saps: 'sap-01',
    // Formic acid from slaughtering vrauks; the cage comes back, so the cage recipe runs 0 times.
    'formic-acid': 'full-render-vrauks',
    'caged-vrauks': 'caged-vrauks',
    cage: 'cage',
    vrauks: 'vrauks-1', // the paddock; empty barrels come back like the cages
    cocoon: 'vrauks-cocoon-1',
    'water-barrel': 'water-barrel',
  },
  // Blocks: what is made together. Fluids stay inside a block where possible (Molten glass with
  // its two users, Formic acid and Creamy latex with the Latex slab), since they need pipes.
  blocks: {
    iron: ['processed-iron-ore', 'iron-plate'],
    copper: ['grade-1-copper', 'grade-2-copper', 'copper-plate'],
    bricks: ['stone-brick'],
    'small parts': ['iron-gear-wheel', 'iron-stick', 'bolts', 'copper-cable', 'small-parts-01'],
    red: ['empty-planter-box', 'planter-box', 'automation-science-pack'],
    'soil and limestone': ['soil', 'limestone'],
    wood: ['wood-seeds', 'wood-seedling', 'log', 'wood'],
    moss: ['muddy-sludge', 'carbon-dioxide', 'moss'],
    coal: ['coal'],
    seaweed: ['seaweed'],
    glass: ['molten-glass', 'empty-petri-dish', 'flask'],
    'petri dish': ['agar', 'petri-dish', 'petri-dish-bacteria'],
    vrauks: ['water-barrel', 'cocoon', 'vrauks', 'caged-vrauks', 'cage'],
    latex: ['saps', 'creamy-latex', 'sodium-alginate', 'formic-acid', 'latex-slab', 'latex', 'stopper'],
    py1: ['cellulose', 'fawogae-substrate', 'py-science-pack-1'],
  },
  machines: {
    crafting: 'assembling-machine-1',
    smelting: 'stone-furnace',
    'copper-plate-4': 'advanced-foundry-mk01',
  },
  // Py farms run on their own organisms as modules; full slots assumed (+100 % speed each).
  modules: {
    'moss-farm-mk01': { moss: 15 },
    'seaweed-crop-mk01': { seaweed: 10 },
    'vrauks-paddock-mk01': { vrauks: 10 },
    'fwf-mk01': { 'tree-mk01': 10 },
    'sap-extractor-mk01': { 'sap-tree': 2 },
    'rc-mk01': { vrauks: 2 },
    'moondrop-greenhouse-mk01': { moondrop: 16 },
  },
  drills: { 'raw-coal': 'burner-mining-drill', 'iron-ore': 'burner-mining-drill', 'copper-ore': 'burner-mining-drill', stone: 'burner-mining-drill' },
  sources: {
    water: 'Offshore pump',
    steam: 'boilers (see the fuel table)',
    ash: 'burnt Raw coal (see the fuel table)',
  },
};
