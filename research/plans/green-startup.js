// One-time start-up of the green science line (agent game 3): 3 Cottongut MK 01 (Creature chamber)
// and 6 Ralesia (Ralesia sample, Botanical nursery), the least that starts the Prandium lab
// (2 Cottongut MK 01 as ingredients + 1 as a module) and the Ralesia plantation (5 Ralesia for
// the first 8 seeds + 1 as a module). "Per minute" here means "in all".
// Solve with: node --max-old-space-size=4096 tools/rate-plan.js research/plans/green-startup.js
module.exports = {
  title: 'Green science start-up: 3 Cottongut MK 01 + 6 Ralesia (totals)',
  techs: ['logistic-science-pack', 'ralesia', 'cottongut-science-mk01', 'xenobiology', 'genetics-mk02', 'biotech-machines-mk01'],
  targets: { 'cottongut-mk01': 3, ralesia: 6 },
  recipes: {
    'cottongut-mk01': 'cottongut',
    ralesia: 'ralesia-sample',
    'earth-mouse-sample': 'earth-mouse-sample',
    'earth-generic-sample': 'earth-generic-sample',
    'earth-flower-sample': 'earth-flower-sample',
    'cottongut-codex': 'cottongut-codex',
    'ralesia-codex': 'ralesia-codex',
    'bio-sample': 'bio-sample',
    'bio-container': 'bio-container',
    cdna: 'cdna',
    retrovirus: 'retrovirus',
    plasmids: 'plasmids',
    'moss-gen': 'moss-gen',
    'lab-instrument': 'lab-instrument',
    'equipment-chassi': 'equipment-chassi',
    lens: 'lens',
    'petri-dish-bacteria': 'petri-dish-bacteria',
    'petri-dish': 'petri-dish',
    'empty-petri-dish': 'empty-petri-dish',
    agar: 'agar',
    'fawogae-substrate': 'fawogae-substrate',
    flask: 'flask',
    'small-lamp': 'small-lamp',
    'tinned-cable': 'tinned-cable',
    'copper-cable': 'copper-cable',
  },
  machines: { crafting: 'assembling-machine-1', 'crafting-with-fluid': 'assembling-machine-1' },
};
