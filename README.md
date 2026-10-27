# Pyanodons, step by step

A tutorial for Factorio 2.1 with the full Pyanodons suite, written while playing through it.
[中文版](README.zh-CN.md)

Every number here was read from the game's own prototype data or measured in the engine, not
taken from wikis or memory. Each chapter ends with a section saying which is which, and links the
scripts used, so you can re-check them against your own mod versions.

## Chapters

1. [Landing to red science](chapters/01-landing-to-red-science.md)
2. [Coke, steel and crushed iron](chapters/02-coke-steel-crushed-iron.md)
3. [Ash separation and Raw coal power](chapters/03-ash-separation-raw-coal-power.md)
4. [Aluminium mining, glass making, log production and red science](chapters/04-aluminium-glass-logs.md)
5. [Tin, zinc and lead smelting](chapters/05-tin-zinc-smelting.md)
6. [Simple circuit boards](chapters/06-simple-circuit-boards.md)
7. [Copper screening, titanium smelting and duralumin](chapters/07-copper-screening-titanium-duralumin.md)
8. [Vrauks](chapters/08-vrauks.md)
9. [pY science pack 1](chapters/09-py-science-pack-1.md)
10. [Crushed-coal power](chapters/10-crushed-coal-power.md)
11. [Better lead, titanium and tin smelting](chapters/11-lead-titanium-tin-smelting.md)
12. [Nexelit mining and nickel smelting](chapters/12-nexelit-nickel.md)
13. [Geothermal power and antimony oxide](chapters/13-geothermal-antimony-oxide.md)
14. [Intermetallics and getting ready for trains](chapters/14-intermetallics-trains.md)
15. [Train preparation 1](chapters/15-train-preparation-1.md)
16. [Auogs](chapters/16-auogs.md)
17. [Batteries](chapters/17-batteries.md)

Reference: [Techniques and mechanics](research/techniques.md) (every verified mechanic, number
and design principle in one place) · [Coke, steel, crushing and Ash separation](research/coke-and-steel.md)
(the recipes, rates and byproducts behind chapter 2, and Ash separation) · [The red + pY1 factory](research/red-py1-factory.md)
(bus, blocks, Simple circuit boards and the key intermediates before trains) ·
[The author's first save](research/first-save-review.md) (what moved by hand, and the bus that replaces it) · [Railways under Pyanodons](research/py-railway.md) (no speed cap, speed and range of each composition, how Cybersyn works) · [Rail junctions at grade](research/rail-junctions.md) (the author's three junctions measured, faults, a better one) ·
[Map settings](research/map-settings.md) (Py's preset, the author's edits and what they do to the map) ·
[T.U.R.D. choices](research/turd-choices.md) (the author's picks, the ones still open, every upgrade) ·
[Mining drills](research/mining-drills.md) (what an ore costs in Raw coal with each drill, and which power pays) ·
[Geothermal power](research/geothermal.md) (how it works, measured: about 75 MW a fissure) ·
[Antimony oxide](research/antimony-oxide.md) (how much the way to trains and robots needs, and two block sizes) ·
[Blueprints](blueprints/README.md) (measured designs, ready to import).

## Setup the chapters were written against

- Factorio 2.1.21 (chapter 1's run). Space Age and Quality disabled; Elevated rails enabled.
- Pyanodons 3.1.x: pyalienlife 3.1.8, pyalternativeenergy 3.2.9, pycoalprocessing 3.1.7,
  pyfusionenergy 3.1.5, pyhightech 3.1.5, pyindustry 3.1.6, pypetroleumhandling 3.1.3,
  pypostprocessing 3.1.6, pyrawores 3.1.4.
- Earlier: chapter 1's belts-first route (its section 7), the engine measurements and the
  research notes were made on Factorio 2.1.20 with pyalienlife 3.1.7, pyalternativeenergy 3.2.8,
  pycoalprocessing 3.1.5, pyfusionenergy 3.1.4, pyhightech 3.1.4, pyindustry 3.1.5 and
  pypostprocessing 3.1.5. The recipes and buildings chapter 1 uses are the same in both.
- Non-Py mods that change the early game, called out where they matter:
  - `py_quick_start` gives a starting kit (construction robots and power armor).
  - `pump-anywhere-fork` lets offshore pumps stand on dry land.
  - `DoingThingsByHand` speeds up handcrafting with practice (not covered).
- The author's map (Py-Exploration, seed 2652821414; see [map settings](research/map-settings.md)):
  starting area 400%, ore frequency 33% and richness 400%, no cliffs, no enemy bases, no lakes
  (hence `pump-anywhere-fork`). Ore positions differ on your map; rates and
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

- `dump-data.ps1` + `analyze-py.js`: `data.raw` of your exact mod set and its localised names
  (zh-CN and en), and a summary of it. Rebuild it when your mods update: the recipe tools read it.
- `q.js <name>`: one-call lookup by internal, English or Chinese name, whole or part: the item,
  fluid, building, recipe, technology or resource in compact lines (every recipe that makes it
  with machine, time and unlocking technology and its cost, what uses it, building stats), what
  the latest save snapshot holds of it (researched, built, in the inventory, ore patches), and
  every paragraph of the research notes and chapters that mentions it (`--data`, `--notes`,
  `--all`, `--zh`). It keeps a small index of the dump (`q-index.json`), so a query takes under a
  second.
- `recipe-tree.js <item> --techs a,b`: production tree and raw totals using only the recipes
  unlocked at that point (Chinese names; `--techs save,a` adds everything researched in the
  latest save snapshot). Mined and pumped items count as raw inputs only while a drill for them
  is buildable; items from map entities (fish, trees, rocks) are marked finite, and an item with
  no recipe yet names the technologies that would give it one. Recipes no technology unlocks are
  named, never silently dropped: `sources.js`, shared with `rate-plan.js`, tells a script-run
  machine (the Digosaurus dig site, whose recipes stand in for the script and come with the
  machine) from T.U.R.D. upgrade recipes. The totals follow the first recipe listed at every step;
  barrel and canister (un)loading comes last.
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
  each machine's modules, speed and electric network, production, nearby ore) and a PNG map; also finds mining outposts, exports each as a blueprint
  string and, with `-Ticks`, runs the save one more minute to measure real mining rates and
  everything the base makes and uses per second. The snapshot is taken one second after loading:
  on the first tick machines with a tiny electric buffer read "low power" (see `status-probe/`).
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
  `check-recorder.ps1`; it also writes the factory open in Factory Planner (`/pt-fp`), read by
  `planner-summary.js` (targets, inputs, byproducts, power, every line's machines and rates).
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
- `newgame-observer/` + `summarize-newgame.js`: what a fresh game offers (also the resources,
  trees, rocks and tiles around spawn, to compare map settings); create the map with
  `--map-gen-settings` taken from a snapshot to reproduce a world.
- `belt-lab/`, `ch1-probe/`, `drill-probe/`, `inserter-probe/`, `train-probe/`, `station-probe/`:
  engine measurements behind the chapters and research notes. `run-probe.ps1 <probe>` runs one
  (copies it into the fixed setup, creates a map, runs it, prints its results, removes it; add
  `-Work C:\tmp\cf-save` to run it with the current mods). `inserter-rate-probe/`: the Mechanical
  inserter to three decimals, every drop timed (`-Ticks 36700 -Work C:\tmp\cf-save`).
  `valve-probe/`: how far a pipeline carries (320 tiles) and what a Pump and a Check valve do
  (`-Ticks 2500 -Work C:\tmp\cf-save`).
- `save-probe.ps1 -Save <save> -Probe <probe> [-Variant <name>]`: runs a measurement mod inside a
  copy of one of the author's saves (save-reading setup; the save itself is only copied), e.g.
  `steel-probe/`: the steel site of chapters 2 and 3 (empties the steel chest and the Boilers' Ash,
  sets the Soil extractors' circuit condition per variant, `ltN` for Limestone < N, `,coke` to top
  the foundries up with Coke; records every foundry's output, status and
  missing ingredient), and `rate-probe/`: the base as it stands over a longer window than the
  inspector's minute (variant `WARM,MEASURE` in seconds, e.g. `-Ticks 39700 -Variant 60,600`):
  what it makes and uses per second, and every machine's and drill's status, sampled each second
  (Boilers and Steam engines grouped by the row they stand in), and every electric network's
  mean power by generator and consumer kind. `WARM,MEASURE,STEP,names` adds a timeline: every STEP seconds what was made and used of each
  named item or fluid, the status and fluid boxes of each machine named by its tile (`@x:y`), and
  every machine group whose usual status changed; a last field `+entity@x:y[:direction[:item]]` places that entity
  when the save loads (`item`: an inserter's filter or a machine's recipe) (a what-if, the only change the probe makes); `+sink@x:y` instead empties the
  belt on that tile every tick and `+empty@x:y` the chest there every second, printing what they took
  (a block standing full, measured with its output taken away); `+off@x:y` stops the machine or
  inserter on that tile (what it takes from the rest of the base) and `+clear@x:y` empties a
  machine's input and output slots once. `vrauk-probe/`: the start-up
  of the author's Vrauk line (chapter 8): every 5 minutes (or the step given) the Vrauks, cocoons
  and Water barrels made, how the Reproductive complexes, the paddocks with Vrauks and the
  Barreling machine spent the step, and where the barrels and cocoons are; variant `fill` moves the
  Vrauks from the line's chest into free module slots every minute, `prio` sets the output priority
  of Splitters with one output belt, `barrels:N` adds Water barrels (`barrels:-N` takes them off the belts) (e.g. `-Ticks 864100 -Variant
  fill,prio,600`). `power-probe/`: a power block where it stands, finished by script where the
  author has not built it yet (ghosts in its box revived, entities placed: poles wired whatever the
  distance, inserters with a filter; infinity pipes of Water, script sources keeping its input
  belts full, sinks emptying its output belts, fuel put into its Boilers once, since a block whose
  crushers run on its own power cannot start itself), with an energy interface that takes whatever
  the block's own network has left, so its Steam engines run as hard as their steam allows: every
  step the network's power by entity, the crafts, what came in and went out, the items on its belts
  and in its Boilers, the Boilers holding Ash, the items passing each lane of chosen belt tiles
  (counted by their ids), how fast a Storage tank filled once with a fluid fuel empties (the
  fuel a fluid-burning Boiler takes), and every machine group's status (fields of the
  variant at the top of its `control.lua`). With the whole base as its box it is a load test:
  the power the base can give beyond what it uses. A block the author built into the base's
  network is measured alone by cutting its copper wires to the outside (`isolate=1`); `each=boiler`
  samples every Boiler on its own, `turn=` and `filter=` try a fix (an entity turned, an
  inserter's filter changed), and `stagger=seed:gap:name` starts its machines one by one in a
  random order, to test whether a design jams under some start phases.
- `dig-probe/` (with `save-probe.ps1 -Variant name,count,warm_s,measure_s`): a what-if for Dig
  sites: puts that many Dig-o-sauruses of that kind into every site, keeps the food slots full of
  Guts and counts the trips.
- `geo-probe/` (with `run-probe.ps1 -Ticks 8500`): geothermal power stage by stage on a lab map
  (plant on a fissure, Regenerative heat exchanger, Steam engines on 500 and 250 degree Steam),
  each on its own network, with and without +20 % mining productivity; with `save-probe.ps1
  -Variant cracks` it lists a save's Geothermal fissures (`research/geothermal.md`).
- `turd-probe/` (with `save-probe.ps1 -Ticks 10`): the T.U.R.D. upgrades researched in a save and
  the option picked for each, read through pyalienlife's own interface, with the hidden modules and
  machine replacements in place (`research/turd-choices.md`).
- `status-probe/` (with `save-probe.ps1 -Variant name,ticks`): the status and electric buffer of
  every entity of one name on every tick after a save loads, the share of each status, and the
  effects of its modules and beacons: tells a state the base is in from one tick's look.
- `wire-probe/` (with `save-probe.ps1 -Ticks 10 -Variant "x:y;x:y"`): how the entities on those
  tiles are switched by circuits: their enable and logistic conditions, what their wires connect
  to and the signals on those networks.
- `trains-probe/` (with `save-probe.ps1 -Ticks 10`): every train in a save (cars, state, manual
  or automatic, schedule with its wait conditions, fuel and burnt results, cargo) and every train
  stop (name, place, train limit, trains bound for it).
- `bp-bench.ps1 -Bench <name> [-Variant <v>]` + `bp-bench/`: the blueprint bench. Builds one
  blueprint of `blueprints/` on an empty map (the game's own blueprint building, module requests
  filled), powers every electric network from an energy interface, keeps the input belts full and
  empties the output belts (and, as fluid sinks, chosen pipes, emptied or drawn at a set rate) by script, lets labs research without end, and reports every machine's
  crafts against its recipe at its actual speed, status samples, the ingredient a waiting machine
  lacks and watched entities. One JSON file per bench in `bp-bench/benches/` (blueprint, sources,
  sinks, fluid sinks, items to prime, technologies, warm-up and measuring time, variants). Runs in the
  save-reading setup.
- `junction-bench.ps1 -Blueprint <file or name> -Mode map|traffic|edit|run|station|build [-Options <json or @file.json>]` +
  `junction-bench/` + `junction-bench.js`: the rail junction bench. Builds the rails and signals of
  one blueprint on an empty map. `map` writes its rails, rail blocks, signals, track ends and every
  path between track ends with the signals met on the way; `junction-bench.js render` draws it
  (blocks in colours, rail and chain signals, red rings on chosen places), `paths` lists the paths,
  `symmetry` lists rails and signals that differ between the four sides. `traffic` extends every
  track end with 320 tiles of signalled track, finds entrances and exits by the pathfinder, keeps a
  train (Py's locomotive and two cargo wagons by default, `locomotives` and `wagons` change it,
  optionally arriving at line speed)
  waiting on every entrance track, sends each to an exit leg by scenario (mix, straight, left,
  right; `lanes` sends each train to a random exit lane instead, to test lane changes) and reports
  trains a minute per movement, the time through the junction, where trains wait, deadlocks and
  entrances that got no train through. `edit` turns one leg's signals onto the others, makes every rail signal a
  chain signal and puts chain signals at the entrances and rail signals at the exits, then writes
  the junction as a blueprint string. `run` sends one train (`stock`, any fuel and cargo) round one
  block of a grid blueprint until its fuel is gone: speed, distance and fuel over time (range of
  each composition: [Railways under Pyanodons](research/py-railway.md)). `station` builds the whole
  blueprint with every setting (inserters, chests, combinators) around its train stop and sends
  trains to the stop with the schedule Cybersyn gives a refueler visit, optionally with more trains
  passing by behind them (`depot`: Cybersyn's depot schedule instead, several stops of one name,
  `limit` overrides their train limits): time at the stop, fuel and Ash before and after, whether the train
  stands wholly in the stop's block, trains a minute. `build` builds the whole blueprint and reports
  what could not be built (overlaps) and electric entities outside every pole's supply area. Results: [Rail junctions at grade](research/rail-junctions.md). Runs in the
  save-reading setup.
- `agent/`: lets Claude play a Py game by itself on a headless server (RCON client `a.js`, the
  `pt-agent` mod with a playerless character, rate-limit watch `quota.js`); see
  [its README](tools/agent/README.md). Its play journal is [research/agent-play](research/agent-play/journal.md).
- `publish/`: the chapters for other sites. Both versions keep the tutorial only (tool names,
  commands and "How these facts were checked" left out, by the edits in `publish/edits.js`), open
  with a note that Claude wrote them from the author's saves, and link the full chapter here.
  Output goes to `publish/out/` (not committed).
  - `steam.js [--lang en|zh] [chapter ...]`: Steam guides, which have no upload API: a local page
    with every field (title, description, each section in BBCode, at most 8,000 characters) and a
    copy button, plus the images to upload per section.
  - `bilibili.js [--lang zh|en] [chapter ...]`: Bilibili articles (专栏): Markdown for the
    editor's own importer, every table rendered to a PNG (the editor has no tables) and a 16:9
    cover per chapter (its main build behind the series name, number and title); `npm install`
    in `publish/` once for puppeteer-core, which drives the installed Edge. `bilibili-page.js`,
    run in the editor page, imports the Markdown, puts each picture and table in place through
    the editor's own image upload with its caption, sets the publish settings and uploads the
    cover; `relink()` later points a published chapter's links to later chapters at their
    Bilibili copies. `bilibili-articles.json` records each published chapter (address, article
    id, edits used). Bilibili takes at most 5 new articles a day per account, and allows 3 edits
    per article, so each chapter is relinked once, when every chapter it links to is out.
- Localised names: `factorio --dump-prototype-locale` with `locale=zh-CN` (or `en`) in the config
  writes `*-locale.json` into script-output.

## License

- **Code** (`tools/`, `research/plans/*.js`, `research/agent-play/scripts/`): [MIT](LICENSE).
- **Everything else** (chapters, research notes, images, blueprints): [CC BY 4.0](LICENSE-CONTENT),
  © 2026 Wendy-Hamlet. Share and adapt it freely, also commercially; credit "Wendy-Hamlet" with a
  link to this repository and say what you changed.
- The game graphics in the screenshots remain the property of Wube Software (Factorio) and the
  authors of the Pyanodons mods.
