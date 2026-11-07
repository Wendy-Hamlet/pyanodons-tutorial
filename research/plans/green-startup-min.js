// The least living stock that starts the green science line, made from nothing but genetics and the
// food chain (totals, not rates; "per minute" in the output means "in all"). Written after agent game 3.
//   3 Cottongut MK 01 (Creature chamber): raising takes 2 as ingredients, the Prandium lab needs >= 1 as a module
//   6 Ralesia (3 Ralesia samples): 5 give the first 8 seeds in the nursery, 1 is the plantation's module
//   8 Moondrop (2 Moondrop samples, 4 each): >= 1 greenhouse module + 5 for the first nursery craft
//   2 Auogs (Creature chamber): one module each for the Reproductive complex and the paddock
//   46 Cottongut food: 14 raisings (the 7 plain pups the first caged batch needs come at 0.5 a raising)
//     + 32 maturings (3 -> 28 Cottongut MK 01: 20 + 6 lab modules, 2 cub complex modules)
// Living inputs (Ralesia seeds, Moss, Native flora) and the raising's Seaweed, Fish eggs, Wood and
// Moondrop are listed by the report, not solved here.
// Solve with: node --max-old-space-size=4096 tools/rate-plan.js research/plans/green-startup-min.js
const base = require('./green-startup.js');
module.exports = {
  ...base,
  title: 'Green science start-up, least living stock (totals)',
  techs: [...base.techs, 'moondrop', 'auog', 'starch-mk01'],
  targets: { 'cottongut-mk01': 3, ralesia: 6, moondrop: 8, auog: 2, 'cottongut-food-01': 46 },
  recipes: {
    ...base.recipes,
    moondrop: 'moondrop-sample',
    'moondrop-codex': 'moondrop-codex',
    auog: 'auog',
    'auog-codex': 'auog-codex',
    'earth-bear-sample': 'earth-bear-sample',
    'cottongut-food-01': 'cottongut-food-01',
    starch: 'starch',
    'powdered-ralesia-seeds': 'powdered-ralesia-seeds',
    'planter-box': 'planter-box',
  },
  sources: { 'ralesia-seeds': 'the Ralesia block', 'wood-seeds': 'Wood seed assembler', seaweed: 'Seaweed crops' },
};
