// Logistic science pack (green) 3/min = 0.05/s, Claude's third agent game (copy of the author's save
// at 52:03). Steady state only: the start-up stock of the self-breeding inputs (Cottongut, Ralesia,
// Auogs as modules) is reckoned separately in research/agent-play/journal-3.md.
// Solve with: node --max-old-space-size=4096 tools/rate-plan.js research/plans/green-science.js --build
module.exports = {
  title: 'Logistic science pack 3/min (0.05/s)',
  techs: ['logistic-science-pack', 'ralesia', 'cottongut-science-mk01', 'compost', 'auog', 'fluid-handling', 'starch-mk01'],
  fuel: 'raw-coal',
  electricity: 'steam',
  targets: { 'logistic-science-pack': 3 },
  recipes: {
    'logistic-science-pack': 'logistic-science-pack',
    'alien-sample01': 'alien-sample01',
    'bio-sample01': 'bio-sample01',
    'ground-sample01': 'ground-sample01',
    'rich-clay': 'rich-clay', // 25 Ash + 500 Water -> 10 (Logistic science pack tech)
    soil: 'soil',
    'animal-sample-01': 'animal-sample-01',
    bonemeal: 'bone-to-bonemeal-2',
    // Animal parts from Auogs: brain-bound (3 a sample, 1 an Auog); Cottongut gives 2 a 5 Cottongut.
    bones: 'full-render-auogs',
    'caged-auog': 'caged-auog',
    auog: 'auog-maturing-1',
    'auog-pup': 'auog-pup-breeding-1',
    'water-barrel': 'water-barrel',
    'solidified-sarcorus': 'cottongut-science-red-seeds',
    'fawogae-substrate': 'fawogae-substrate',
    'petri-dish-bacteria': 'petri-dish-bacteria',
    plasmids: 'plasmids',
    'depolymerized-organics': 'depolymerized-organics',
    'subcritical-water': 'subcritical-water-01',
    'pressured-water': 'pressured-water',
    biomass: 'biomass-meat', // the Auogs' spare Meat
    cottongut: 'caged-cottongut-1',
    'cottongut-pup': 'cottongut-cub-1',
    ralesia: 'ralesia-1',
    'ralesia-seeds': 'ralesia-seeds',
    moondrop: 'moondrop-1',
    'moondrop-seeds': 'moondrop-seeds',
  },
  machines: { crafting: 'assembling-machine-1', 'crafting-with-fluid': 'assembling-machine-1' },
  modules: {
    'prandium-lab-mk01': { 'cottongut-mk01': 20 },
    'ralesia-plantation-mk01': { ralesia: 12 },
    'rc-mk01': { auog: 2 },
    'auog-paddock-mk01': { auog: 4 },
    'moondrop-greenhouse-mk01': { moondrop: 16 },
  },
  sources: {
    water: 'Offshore pump (Pump Anywhere)',
    'battery-mk01': 'the battery line (chapter 17)',
    'zogna-bacteria': 'the battery line',
    'liquid-manure': 'the battery line',
    urea: 'the battery line',
  },
};
