# Pyanodons, step by step

A tutorial for Factorio 2.1 with the full Pyanodons suite, written while playing through it.
[中文版](README.zh-CN.md)

Every number here was read from the game's own prototype data or measured in the engine, not
taken from wikis or memory. Each chapter ends with a section saying which is which, and links the
scripts used, so you can re-check them against your own mod versions.

## Chapters

1. [Landing to red science](chapters/01-landing-to-red-science.md)

Reference: [Techniques and mechanics](research/techniques.md) (every verified mechanic, number
and design principle in one place) · [Railways under Pyanodons](research/py-railway.md) ·
[Blueprints](blueprints/README.md) (measured designs, ready to import).

## Setup the chapters were written against

- Factorio 2.1.20. Space Age and Quality disabled; Elevated rails enabled.
- Pyanodons 3.1.x: pyalienlife 3.1.7, pyalternativeenergy 3.2.8, pycoalprocessing 3.1.5,
  pyfusionenergy 3.1.4, pyhightech 3.1.4, pyindustry 3.1.5, pypetroleumhandling 3.1.3,
  pypostprocessing 3.1.5, pyrawores 3.1.4.
- Non-Py mods that change the early game, called out where they matter:
  - `py_quick_start` gives a starting kit (construction robots and power armor).
  - `pump-anywhere-fork` lets offshore pumps stand on dry land.
  - `DoingThingsByHand` speeds up handcrafting with practice (not covered).
- The author's map: starting area 400%, ore frequency 33% and richness 400%, no cliffs, no
  enemy bases, no lakes (hence `pump-anywhere-fork`). Ore positions differ on your map; rates and
  recipes do not.

## Conventions

- Names are the English in-game names; the Chinese version uses the names of the `aotixzhcn` /
  `aotixpy` translation mods.
- Rates assume the machine runs continuously at crafting or mining speed 1 unless stated.
- "Verified" means observed in the engine; "from data" means computed from prototype values.

## Tools (`tools/`)

Everything runs against an isolated Factorio setup in `C:\tmp\cf-dump` (your mods hard-linked,
its own config and write-data), so your own config, mods and saves are only ever read or copied.
Paths in the scripts match the author's machine (game in `E:\SteamLibrary`); adjust the
parameters for yours.

- `dump-data.ps1` + `analyze-py.js`: `data.raw` of your exact mod set, and a summary of it.
- `recipe-tree.js <item> --techs a,b`: production tree and raw totals using only the recipes
  unlocked at that point (Chinese names).
- `inspect-save.ps1 -Save <name> [-Ticks 3700]` + `summarize-save.js` + `render-save-map.js`:
  read-only snapshot of a save (research, inventory, buildings with directions and filters,
  production, nearby ore) and a PNG map; also finds mining outposts, exports each as a blueprint
  string and, with `-Ticks`, measures their real mining rates for a minute.
- `render-area.js x1 y1 x2 y2 out.png`: close-up PNG plus a character grid of one area of a
  snapshot, for reading a structure tile by tile.
- `extract-design.js <key> x1 y1 x2 y2`: copies an area of a snapshot into the design lab.
- `design-lab/`: builds designs (own ones and ones copied from saves) next to infinite sources and
  counting sinks, measures throughput, stranded items after a supply cut and drill states, and
  exports blueprints.
- `bp-sync.js` + `companion/` (a mod) + `check-companion.ps1`: moves `blueprints/` into a running
  game as one blueprint book and pulls edited blueprints back; see
  [blueprints](blueprints/README.md#syncing-with-a-running-game).
- `take-screenshots.ps1`: runs the design lab with graphics to take in-game screenshots. The Steam
  build of the game has Steam relaunch it; confirm Steam's dialog about launch arguments.
- `newgame-observer/` + `summarize-newgame.js`: what a fresh game offers; create the map with
  `--map-gen-settings` taken from a snapshot to reproduce a world.
- `belt-lab/`, `ch1-probe/`, `train-probe/`, `station-probe/`: engine measurements behind the
  chapters and research notes.
- Localised names: `factorio --dump-prototype-locale` with `locale=zh-CN` (or `en`) in the config
  writes `*-locale.json` into script-output.
