# Blueprints

[中文版](README.zh-CN.md)

The author's blueprint book for the tutorial so far. Import a file's content with the in-game
"Import string" button; `book.txt` holds all of them as one blueprint book (order and label in
`book.json`). Explanations: [chapter 1](../chapters/01-landing-to-red-science.md),
[chapter 2](../chapters/02-coke-steel-crushed-iron.md),
[chapter 3](../chapters/03-ash-separation-raw-coal-power.md),
[chapter 4](../chapters/04-aluminium-glass-logs.md),
[chapter 5](../chapters/05-tin-zinc-smelting.md) and
[chapter 6](../chapters/06-simple-circuit-boards.md).

Where the numbers come from: the two burner designs of chapter 1 were built and run in the engine
by `tools/design-lab` (5 minutes of game time, rates measured after the first minute), in the
versions shown in the lab pictures below; the files now hold the author's current versions,
turned round but otherwise the same (noted per design). The chapter 2 designs were measured where
they stand in the author's game: the recorder's production statistics (10-minute windows) and one
minute of the save of 3:37 run by `tools/inspect-save.ps1 -Ticks 3700`; they have not been run in
the design lab. The chapter 3 designs likewise, in the save of 6:13 (one more minute) and, for
the steel site, in engine tests on a copy of that save (`tools/save-probe.ps1`). From chapter 4 on,
designs are also run on the blueprint bench (`tools/bp-bench.ps1`): the blueprint alone on an empty
map, unlimited power, full input belts, emptied output belts, crafts counted against each
machine's full speed.

| File | In game | What it is | Measured |
|---|---|---|---|
| `burner-mall.txt` | 初期超市-0 | The author's first mall: 6 Burner assembling machines, no belts, making Small parts and Air-core inductors | Not measured |
| `smelting-column.txt` | 0.9375 [Iron plate]/[Copper plate] | The author's smelting column: 10 Stone furnaces on half a belt of ore, for iron or copper | Earlier version, iron and copper each: 0.91 plates/s, 0.60 Ash/s, no mixed items, 0 ore left after the supply stops. Two current ones on copper: 1.85 plates/s together |
| `raw-coal-module.txt` | 15 [Raw coal] | The author's raw coal module: 9 Burner mining drills filling one belt | Earlier version: 15.00 Raw coal/s, 1.40 Ash/s into chests |
| `raw-coal-power.txt` | 初期满带原煤发电（不清灰） | 12 Boilers and 6 Steam engines on one belt of Raw coal, no Ash inserters | 49–52 Steam/s (12.1–12.8 MW) at the load of 2:00–2:30; full output 22.2 MW from data |
| `coke-distillation.txt` | 2.7 [Coke] | 3 + 2 Destructive distillation columns, Raw coal to Coal to Coke; since chapter 5 a sixth column turns surplus Coke into Coal gas and Tar (its inserters run while the belt end holds 4 Coke or more), and no Exhaust pipe | Chapter 2 version: 2.71 Coke/s (2:00–2:10), about 88 Coal gas/s vented. Bench of the chapter 5 version: 2.70 Coke/s with the Coal gas taken; Coke not taken: all of it into Tar (70.2 Tar/s); Coal gas taken at only 20/s: 18 % (0.5 Coke, 12.5 Tar/s); Coal gas not taken: stops ([chapter 5](../chapters/05-tin-zinc-smelting.md#6-aromatics-from-tar-and-where-the-rest-goes)) |
| `steel-foundries.txt` | 0.533 [Steel plate] | 8 Advanced foundries, each under its own Soil extractor (runs while the foundry holds under 10 Limestone); Steel into a chest limited to 500 | Engine tests on copies of the saves: 0.533 Steel/s with < 10 (the file), 0.493 with < 8, 0.440 and 0.435 with < 5 (chapter 2's version, 0.43–0.44 in play) ([chapter 3](../chapters/03-ash-separation-raw-coal-power.md#9-steel-limestone--8)) |
| `crushed-iron.txt` | 3 [Iron plate] | 6 Jaw crushers, 18 iron furnaces and 5 brick furnaces on a full belt of Iron ore | 3.02 Iron plate/s and 1.52 Stone brick/s; two copies (one more Small electric pole since chapter 5): 6.1 Iron plates/s |
| `burner-belt-mall.txt` | 初期超市-1 | The author's second mall: 7 Burner assembling machines making Mechanical inserters, Transport belts and Small parts from the bus's plates | Not measured (stocked its chests and stopped) |
| `raw-coal-power-two-belts.txt` | 两满带原煤发电 | 24 Boilers and 12 Steam engines on two belts of Raw coal, Ash to 3 Solid separators on top | 44.4 MW and 29.6 Raw coal/s from data. At 6:13 only the east half had water (22.2 MW at most; 49.5 Steam/s, 12.2 MW with the Coal dust Boilers, in the minute after); the author has since piped it across, all engines running at 6:14 |
| `ash-separation.txt` | 灰烬分离 | 3 Solid separators between two Ash belts, 13 inserters each; Coal dust, Soot and Iron oxide out through buffer chests. In the author's base only the belt above is fed | Bench: 50 % with the belt above full (15 Ash/s), 100 % with both (29.9 Ash/s); 20–32 Ash/s separated by both separator groups together in play (5:20–6:10) |
| `soot-separation.txt` | 烟煤分离 | 1 Solid separator on Soot; each ore into its own chest and Stone furnace (Coal dust as fuel) | 0.5–1.3 Soot/s used (5:50–6:13); Zinc and Lead ore wait in the chests |
| `iron-oxide-smelting.txt` | 氧化铁处理 | 2 Stone furnaces, Iron oxide to Iron plates (2 : 1), one input inserter each | Bench: 1.717 Iron oxide/s, 0.85 Iron plates/s, furnaces at 15 % (the inserters set the pace); 0.7–0.9 Iron oxide/s in play (6:00–6:13) |
| `coal-dust-power.txt` | 煤粉处理 | 2 Boilers on Coal dust and 2 Steam engines (one more than the steam needs, so Coal dust burns first) | 2.03 Coal dust/s burnt in the minute after 6:13, about the two-engine share computed from data |
| `log-production.txt` | 2.348 [Log] | Logs: 10 Moss farms, 8 Botanical nurseries, 16 Fastwood forestries, a Wood processing unit for the Tree seeds; Ash, Stone bricks and Coke in, Logs out | Bench: 2.336 Logs/s (nurseries and forestries at 100 %), Ash 12, Stone bricks 1.25, Coke 0.31 a second ([chapter 4](../chapters/04-aluminium-glass-logs.md#6-the-log-block)). The author's note: the High pressure furnace can become a Moondrop greenhouse (9 × 9 against 7 × 7, so a little rebuilding; [chapter 5](../chapters/05-tin-zinc-smelting.md#8-iron-copper-a-mall-that-burns-wood-and-the-coke-columns)); done in the author's base at 15:00–15:05 ([chapter 6](../chapters/06-simple-circuit-boards.md#2-moondrop-for-the-substrates-methane)), the file still has the furnace |
| `red-science.txt` | 0.2 [Automation science pack] | Red science for six labs: 8 Burner assembling machines, a Soil extractor and a Wood processing unit; Native flora, plates, Ash, Logs and Stone bricks in | Bench: 0.200/s (the author's update after 9:37; 0.196 with one Wood inserter) ([chapter 4](../chapters/04-aluminium-glass-logs.md#8-red-science-at-02-a-second)) |
| `wood-mall.txt` | 初期超市-2 | The author's third mall, beside red science: 10 Burner assembling machines make Transport belts, Underground belts, Mechanical inserters, Pipes and Pipes to ground; a Wood processing unit turns Logs into Wood, the fuel, carried with the Iron plates | Not measured (a mall makes what is taken); fuel from data: 0.375 Wood/s at full work ([chapter 5](../chapters/05-tin-zinc-smelting.md#8-iron-copper-a-mall-that-burns-wood-and-the-coke-columns)) |
| `acetylene.txt` | 50 [Acetylene] | Acetylene for the lead drills: 2 Soil extractors into a Lime furnace, 2 Calcium carbide furnaces, 4 Gasifiers; an Evaporator dries the Slaked lime back into Lime, a Washer turns its Gravel into Saline water for a Sinkhole; 2 Offshore pumps. Coke in from the west (left lane), Acetylene out by one pipe east | Bench: 49.75 Acetylene/s, every machine at 100 %: the author's corrected version (2026-10-14; [chapter 6](../chapters/06-simple-circuit-boards.md#7-other-changes)). The chapter 5 version made 43.2/s (86 %): one input inserter of the second carbide furnace reached for the pole where the Coke belt ended ([chapter 5](../chapters/05-tin-zinc-smelting.md#7-lead-acetylene-as-the-mining-fluid)) |
| `simple-circuit-board.txt` | 0.1 [Simple circuit board] | Simple circuit boards: Chipshooter machine, PCB factory, Pulp mill, 4 Electronics factories, 4 Moondrop greenhouses (Methane, Carbon dioxide, two growing Moondrop) and a nursery, 14 Sap extractors, Burner assembling machines for Copper cable, Solder and the CuZn Battery, Clay pit, Washers, Glassworks. Plates, Coke, Stone bricks and Logs in by belt from the west; Creosote, Molten glass, Gasoline and Steam by pipe; boards into a chest | Set by its one Methane greenhouse (4 Methane/s at speed 1.5, the save's Carbon capture upgrade): 0.1 boards/s, every other machine below 100 % (Sap extractors 95 %). Measured where it stands: 0.120/s for 35 minutes on stored parts, then down with the Zinc plates on the bus. Not run on the bench: the greenhouses' speed and Carbon dioxide recipe come from the upgrade chosen in the save ([chapter 6](../chapters/06-simple-circuit-boards.md#3-the-block)) |

## How the blueprints are labelled

- **Name:** the theoretical output per second (from the recipe and belt numbers, not the
  measurement) followed by the main product's icon, written as rich text, e.g.
  `15[item=raw-coal]`. Blocks without one product, like the mall and the power block, are named
  by what they are.
- **Icons:** chosen by what the design does (the product, or the products it can make).
- **Description:** what goes in and comes out, how to start it, and the measured numbers, in
  English and Chinese. The game keeps only the first **500 bytes** of a blueprint description
  (Chinese characters take 3 bytes each), so `tools/bp-sync.js push` refuses longer ones.

## Raw coal module

![Raw coal module running in the design lab (the earlier version; the file holds it mirrored top to bottom)](../images/raw-coal-module.jpg)

- Two drill rows face one output belt; each row fills one lane.
- One drill feeds only the service belt, which runs behind both rows and tunnels under the
  output belt. Fuel travels on the inner lane; Ash-filtered inserters put Ash on the outer lane;
  at the end an underground belt lets only the Ash lane through into two chests.
- To start it, put a few Raw coal into the fuel drill. Needs Raw coal under every drill. Near the
  edge of a field the full module may not fit; the author's first run used a 7-drill cut of it
  there.

## Smelting column

![Smelting column running in the design lab (the earlier version; the file holds it rotated half a turn, with two chests at each end)](../images/smelting-column.jpg)

- Ten Stone furnaces in a row between two belts flowing the same way. One belt: ore on the lane
  next to the furnaces, plates come back on the outer lane. The other: Raw coal next to the
  furnaces, Ash on the outer lane.
- Plate-side inserters take **everything but Ash** (blacklist filter): nothing else can come out
  of a furnace on that side, so the same blueprint smelts iron or copper. Ash-side inserters are
  filtered to Ash.
- Feed ore by side-loading onto the ore belt's furnace-side lane (half a belt, 7.5 ore/s) and
  Raw coal the same way onto the other belt (0.67/s; one tap from a passing Raw coal belt is
  enough).
- At the end, a pair of underground belts on each belt lets only the outer lane through, into the
  chests (one Mechanical inserter moves 0.811–0.857 items/s from the end of a belt, depending on
  the lane; the current version uses two per belt).
- On Aluminium ore (chapter 4) each furnace runs at half speed: it could take 1.667 ore/s, its one
  ore inserter brings 0.833. On the bench a full ore lane (7.5/s) feeds nine furnaces and gives
  0.75 Aluminium plates/s.

## Chapter 2 to 6 blocks

Pictures and explanations are in [chapter 2](../chapters/02-coke-steel-crushed-iron.md):
`raw-coal-power` (section 3), `coke-distillation` (4), `steel-foundries` (5, and chapter 3
section 9), `crushed-iron` (6); and in [chapter 3](../chapters/03-ash-separation-raw-coal-power.md):
`burner-belt-mall` (section 2), `ash-separation` (4), `raw-coal-power-two-belts` (5),
`coal-dust-power` (6), `soot-separation` and `iron-oxide-smelting` (7); and in
[chapter 4](../chapters/04-aluminium-glass-logs.md): `log-production` (sections 5 and 6),
`red-science` (8), and the bench test of `ash-separation` (7); and in
[chapter 5](../chapters/05-tin-zinc-smelting.md): the new `coke-distillation` (section 6), `acetylene` (section 7), `wood-mall` and the second `crushed-iron` (section 8); and in
[chapter 6](../chapters/06-simple-circuit-boards.md): `simple-circuit-board` (section 3) and the corrected `acetylene` (section 7).
The burner mall is in [chapter 1](../chapters/01-landing-to-red-science.md#5-the-first-mall-035040).

## Syncing with a running game

`tools/companion` is a small mod (no prototypes besides two shortcut buttons) that moves this
folder in and out of the game:

1. `node tools/bp-sync.js push` rebuilds `book.txt` and the mod's `book.lua` from these files.
2. In game, the "Tutorial blueprint book" shortcut (or `/pt-book`) puts the book into your
   cursor. In single player it first reloads the mod scripts from disk (`game.reload_mods()`),
   so a push made while the game runs is picked up without reloading the save.
3. Hold the book (from the inventory or the blueprint library) and press "Export held
   blueprint" (or `/pt-export`); it writes `script-output/py-tutorial-companion/export.txt`.
4. `node tools/bp-sync.js pull` matches the exported blueprints to these files by label,
   rewrites only those whose content changed, adds new ones, reports missing ones (never deletes)
   and pushes again. `--dry` only reports. A changed design has to be measured again before its
   numbers above are trusted.

`tools/check-companion.ps1` checks the round trip in the engine: the book imports cleanly (every
blueprint with its label, entity count and full description), an unchanged export pulls as
"unchanged", and an edited one shows exactly the edits (one changed, one relabelled as new plus
missing).
