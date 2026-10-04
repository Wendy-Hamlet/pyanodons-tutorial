# Pyanodons, step by step

A tutorial for Factorio 2.1 with the full Pyanodons suite, written while playing through it.
[中文版](README.zh-CN.md)

Every number here was read from the game's own prototype data or measured in the engine, not
taken from wikis or memory. Each chapter ends with a section saying which is which, and links the
scripts used, so you can re-check them against your own mod versions.

## Chapters

1. [Landing to red science](chapters/01-landing-to-red-science.md)

Reference: [Techniques and mechanics](research/techniques.md) (every verified mechanic, number
and design principle in one place) · [Coke, steel, crushing and Ash separation](research/coke-and-steel.md)
(the next stage's recipes, rates and byproducts) · [The red + pY1 factory](research/red-py1-factory.md)
(bus, blocks, Simple circuit boards and the key intermediates before trains) ·
[The author's first save](research/first-save-review.md) (what moved by hand, and the bus that replaces it) · [Railways under Pyanodons](research/py-railway.md) ·
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

Everything runs against isolated Factorio setups (your mods hard-linked or copied, their own
config and write-data), so your own config, mods and saves are only ever read or copied:
`C:\tmp\cf-dump` is a fixed snapshot of your mods that every measurement runs against (rebuilt
only on purpose, with `dump-data.ps1`), and `C:\tmp\cf-save` mirrors your current mods afresh
before every save inspection (`save-env.ps1`).
Paths in the scripts match the author's machine (game in `E:\SteamLibrary`); adjust the
parameters for yours.

- `dump-data.ps1` + `analyze-py.js`: `data.raw` of your exact mod set, and a summary of it.
- `recipe-tree.js <item> --techs a,b`: production tree and raw totals using only the recipes
  unlocked at that point (Chinese names).
- `rate-plan.js <plan.js> [--build]`: solves a production plan (per-minute targets, one chosen
  recipe per item, all rates solved together so byproducts and returned cages count): machines,
  item flows, raw inputs, power, flows between the plan's blocks (bus or direct link) and what
  the machines cost to build; with `fuel` set, the fuel burnt and its Ash; `local: 'free'` makes
  water-only items in each block that uses them, `carry` moves an item packed (Stone as bricks),
  and every block lists the byproducts it must buffer. Plans live in
  `research/plans/`. `products.js` reads 2.1 product chances for it and the other recipe tools.
- `building-inputs.js <tech,...>`: which items the buildings of a stage are made of, ranked by
  how many building recipes use them (finds the key intermediates a mall has to make).
- `inspect-save.ps1 -Save <name|latest|file.zip> [-Ticks 3700]` + `summarize-save.js` +
  `render-save-map.js`: first checks that the save loads with exactly the mods and startup
  settings it was played with (it stops otherwise, unless `-AllowModChanges`); then a
  read-only snapshot of the save (research, inventory, buildings with directions and filters,
  production, nearby ore) and a PNG map; also finds mining outposts, exports each as a blueprint
  string and, with `-Ticks`, measures their real mining rates for a minute.
- `render-area.js x1 y1 x2 y2 out.png`: close-up PNG plus a character grid of one area of a
  snapshot, for reading a structure tile by tile.
- `trace-layout.js x1 y1 x2 y2`: the logistics of an area of a snapshot: belt lines with what
  they carry and who loads and unloads them, fluid networks (connected segments and their fluid)
  and every machine's inputs and outputs. Snapshots record belt contents, fluids and filter modes.
- `manual-links.js [x1 y1 x2 y2]`: what a save still moves by hand: chests only filled (collected
  by hand) or only emptied (topped up by hand), machines stocked by hand, burners refuelled by hand,
  and the items that go both ways (the links a bus should replace). Snapshots record chest and
  machine contents; `logistics.js` is the belt and inserter reading it shares with `trace-layout.js`.
- `extract-design.js <key> x1 y1 x2 y2` (or `<key> --blueprint <file>`): copies an area of a
  snapshot, or a whole blueprint file, into the design lab.
- `design-lab/`: builds designs (own ones and ones copied from saves) next to infinite sources and
  counting sinks, measures throughput, stranded items after a supply cut and drill states, and
  exports blueprints.
- `companion/`: a small mod to play with ([its page](tools/companion/README.md)): the
  blueprint book below, and a play recorder (research, chat, building activity, production;
  rotated logs) read by `recorder-summary.js` (latest state) and `recorder-phases.js` (the
  whole game as a timeline in fixed slices, used to write chapters from real play), checked by
  `check-recorder.ps1`.
- `bp-sync.js` + `companion/` + `check-companion.ps1`: moves `blueprints/` into a running
  game as one blueprint book and pulls edited blueprints back; see
  [blueprints](blueprints/README.md#syncing-with-a-running-game).
- `take-screenshots.ps1`: runs the design lab with graphics to take in-game screenshots. The Steam
  build of the game has Steam relaunch it; confirm Steam's dialog about launch arguments. The
  lab disables freeplay's crash site and intro, which would otherwise land on the designs and
  hold the game until Tab is pressed.
- `shots.js` + `/pt-shots` (companion): screenshots of the author's real game. `shots.js plan`
  lists areas, `/pt-shots` in game takes them, `shots.js pull` copies them into `images/`.
  (Loading a real save with `--benchmark-graphics` crashed the game, so this goes through the
  running game instead.)
- `newgame-observer/` + `summarize-newgame.js`: what a fresh game offers; create the map with
  `--map-gen-settings` taken from a snapshot to reproduce a world.
- `belt-lab/`, `ch1-probe/`, `drill-probe/`, `inserter-probe/`, `train-probe/`, `station-probe/`:
  engine measurements behind the chapters and research notes. `run-probe.ps1 <probe>` runs one
  (copies it into the fixed setup, creates a map, runs it, prints its results, removes it).
- `agent/`: lets Claude play a Py game by itself on a headless server (RCON client `a.js`, the
  `pt-agent` mod with a playerless character, rate-limit watch `quota.js`); see
  [its README](tools/agent/README.md). Its play journal is [research/agent-play](research/agent-play/journal.md).
- Localised names: `factorio --dump-prototype-locale` with `locale=zh-CN` (or `en`) in the config
  writes `*-locale.json` into script-output.
