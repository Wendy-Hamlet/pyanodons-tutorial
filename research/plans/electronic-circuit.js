// Electronic circuit 10/min: the key intermediate of the buildings before trains (26 building
// recipes up to trains use it; one of each needs 330). Building the red + pY1 factory of
// science-red-py1.js needs about 440 (Research centers, Slaughterhouses, Rearing complexes), which
// 10/min makes in 44 minutes; every number scales linearly.
// Solve with: node --max-old-space-size=4096 tools/rate-plan.js research/plans/electronic-circuit.js --build
module.exports = {
  title: 'Electronic circuit 10/min',
  techs: ['railway', 'automated-rail-transportation'],
  // T.U.R.D. upgrade recipes the author's first save runs (see science-red-py1.js).
  scriptRecipes: ['log-wood-fast', 'moondrop-co2'],
  fuel: 'raw-coal',
  electricity: 'steam',
  targets: { 'electronic-circuit': 10 },
  recipes: {
    // The Battery mk00 recipe (3 circuits); the mk01 battery one gives 5 but needs Battery mk01,
    // a pY1 technology beyond the way to trains.
    'electronic-circuit': 'electronic-circuit',
    // ---- printed circuit board ----
    pcb1: 'pcb1',
    vacuum: 'vacuum',
    formica: 'formica',
    'treated-wood': 'treated-wood',
    // Creosote by Tar refining (Tar processing, on the way to trains): 24 per 100 Tar. The route
    // through Carbolic oil (Coal processing 1) needs 2.4 times the Tar: 1000 per 100 Creosote.
    creosote: 'tar-refining',
    'raw-fiber': 'fiber-01',
    methanal: 'methanal',
    // Methane comes only from the Moondrop greenhouse at this point (CO2 + Moondrop seeds).
    methane: 'methane-co2',
    'moondrop-seeds': 'moondrop-seeds',
    moondrop: 'moondrop-1',
    'carbon-dioxide': 'moondrop-co2', // as in the author's save
    saps: 'sap-01',
    // ---- components ----
    'vacuum-tube': 'vacuum-tube',
    graphite: 'graphite',
    glass: 'molten-glass',
    'molten-glass': 'glass-1',
    inductor1: 'inductor1', // Ceramic + cable: 4 cable per inductor instead of 8 + an Iron stick
    ceramic: 'ceramic',
    clay: 'clay',
    capacitor1: 'capacitor1',
    resistor1: 'resistor1',
    solder: 'solder-0',
    'battery-mk00': 'battery-mk00',
    'water-saline': 'saline-water',
    cellulose: 'cellulose-00',
    // ---- plates (same choices as science-red-py1.js) ----
    'tin-plate': 'tin-plate-1',
    'lead-plate': 'lead-plate-1',
    'zinc-plate': 'zinc-plate-1',
    'copper-cable': 'copper-cable',
    'copper-plate': 'copper-plate-4', // Screener and Crusher, as in science-red-py1.js
    'grade-1-copper': 'grade-2-copper',
    'grade-2-copper': 'grade-1-copper-crush',
    'iron-plate': 'low-grade-smelting-iron',
    'processed-iron-ore': 'grade-1-iron-crush',
    // Coke from the Pitch that Tar refining leaves (as in the author's save); no Coal needed.
    coke: 'pitch-refining',
    limestone: 'extract-limestone-01',
    wood: 'log-wood-fast',
    log: 'log3',
    'wood-seedling': 'wood-seedling',
    'wood-seeds': 'wood-seeds',
    moss: 'Moss-2',
    'muddy-sludge': 'muddy-sludge',
    soil: 'soil',
  },
  blocks: {
    iron: ['processed-iron-ore', 'iron-plate'],
    copper: ['grade-1-copper', 'grade-2-copper', 'copper-plate', 'copper-cable'],
    'tin, lead, zinc': ['tin-plate', 'lead-plate', 'zinc-plate', 'solder'],
    'soil and limestone': ['soil', 'limestone'],
    wood: ['wood-seeds', 'wood-seedling', 'log', 'wood', 'raw-fiber', 'saps'],
    moss: ['muddy-sludge', 'moss'],
    tar: ['creosote', 'coke', 'graphite'],
    glass: ['molten-glass', 'glass'],
    ceramic: ['clay', 'ceramic'],
    methane: ['moondrop-seeds', 'moondrop', 'carbon-dioxide', 'methane', 'methanal'],
    pcb: ['treated-wood', 'formica', 'vacuum', 'pcb1'],
    components: ['vacuum-tube', 'inductor1', 'capacitor1', 'resistor1'],
    battery: ['water-saline', 'cellulose', 'battery-mk00'],
    circuit: ['electronic-circuit'],
  },
  machines: {
    crafting: 'assembling-machine-1',
    smelting: 'stone-furnace',
    'copper-plate-4': 'advanced-foundry-mk01',
  },
  modules: {
    'moss-farm-mk01': { moss: 15 },
    'fwf-mk01': { 'tree-mk01': 10 },
    'sap-extractor-mk01': { 'sap-tree': 2 },
    'moondrop-greenhouse-mk01': { moondrop: 16 },
  },
  drills: { 'raw-coal': 'burner-mining-drill', 'iron-ore': 'burner-mining-drill', 'copper-ore': 'burner-mining-drill', stone: 'burner-mining-drill' },
  sources: {
    water: 'Offshore pump',
    steam: 'boilers (see the fuel table)',
    ash: 'burnt Raw coal (see the fuel table)',
    tar: 'Raw coal distillation (the coke site) or the Tailings pond',
  },
};
