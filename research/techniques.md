# Techniques and mechanics

[中文版](techniques.zh-CN.md) · [Index](../README.md)

Everything here was measured in the engine or read from the prototype data of the setup in the
[README](../README.md); the source is given for each entry. Chapter 1 explains the early ones in
context.

## Belts

| Fact | Source |
|---|---|
| A Transport belt carries 15 items/s, 7.5 per lane. | Data |
| An Underground belt spans at most 9 tiles. | Data |
| A mining drill drops onto the belt lane **nearest** to it. | Engine, `tools/belt-lab` |
| An inserter drops onto the belt lane **farthest** from it. | Engine, `tools/belt-lab` |
| Side-loading puts everything from the feeding belt onto the lane of the target belt nearest the feeding belt. | Engine (all designs below) |

**Lane filtering with an underground belt.** A belt that runs into the *side* of an underground
belt tile lets only one of its lanes through:

| Target tile (belt arriving from the south, flowing north) | Lane that passes |
|---|---|
| Entrance whose tunnel goes east | West |
| Entrance whose tunnel goes west | East |
| Exit pointing east (belt enters its back side) | East |
| Exit pointing west | West |

Rule of thumb: an entrance passes the lane *away from* its tunnel; an exit passes the lane on the
side it points to. (Engine, `tools/belt-lab`.)

## Inserters

| Fact | Source |
|---|---|
| The Mechanical inserter (Py's burner inserter) needs no fuel and no power at all. | Data (`void` energy), engine |
| It has 1 filter slot. | Data |
| Throughput: see the table below. Belt → belt: 0.83/s from a moving full belt, 0.86/s from a standing one. | Engine, `tools/inserter-probe`, `tools/design-lab` |
| The Py encyclopedia's 0.78/s for the Mechanical inserter matches one full turn at its rotation speed (0.013 turn per tick = 77 ticks); the engine moves 0.80/s chest to chest and more from a belt, where the hand meets the items. | Data, engine |

Items per second without inserter capacity bonus (Iron plates, basic belt, 60 s per case,
`tools/inserter-probe`). A machine is reached like a chest (not measured separately).

| Inserter | Chest → chest | Chest → moving belt | Moving full belt → chest | Standing full belt → chest |
|---|---|---|---|---|
| Mechanical inserter | 0.80 | 0.80 | 0.83 | 0.85 |
| Inserter (electric) | 1.25 | 1.25 | 1.25 | 1.27 |
| Long-handed inserter | 1.25 | 1.25 | 1.20 | 1.20 |
| Fast inserter | 2.50 | 2.50 | 2.82 | 2.73 |

For planning: 0.80/s per Mechanical inserter into or out of a machine, 0.83/s when it takes from
a moving belt. On the blueprint bench (chapter 4) a Mechanical inserter that never waited moved
0.80 Wood/s from the end of a belt into an assembling machine, fuel included: an ingredient
needed at 0.8/s plus the machine's fuel takes two inserters.

## Machines with an output port

| Fact | Source |
|---|---|
| Some machines drop their products themselves, like a mining drill, so they need no output inserter (inserters can add throughput): Soil extractor, Sap extractor, Wood processing unit, Sand extractor, Classifier, Ground borer, Clay pit, Casting unit (prototype field `vector_to_place_result`). | Data |
| A circuit that starts a supplier below a threshold must cover two batches when the supplier is slower than the consumer: a Soil extractor (8 Limestone per 20 s) feeding an Advanced foundry (5 per 15 s) gives 0.435 Steel/s for 8 pairs at < 5, 0.493 at < 8 and the full 0.533 from < 10 up. | Engine, `tools/save-probe.ps1` + `tools/steel-probe`; a tick model agrees (chapter 3) |
| A Soil extractor facing north drops 3.8 tiles below its centre, on the tile just past its bottom edge. A Foundry standing there gets the Limestone directly (24 Limestone in 60 s, all inside the Foundry); a belt there gets it on one lane only, the lane nearer the extractor. | Engine, `tools/inserter-probe` |
| The author's steel site stacks one Soil extractor on each Foundry this way. According to the author, a splitter can spread a port's output evenly over both lanes of a belt (not measured yet). | Author's save, author |
| Taking from a Stone furnace or Boiler, an inserter takes the product **and** the Ash, never the fuel. | Engine, `tools/ch1-probe` |
| Taking from a Burner mining drill, an **unfiltered** inserter also pulls the fuel out and starves the drill; filtered to Ash it takes only Ash. | Engine, `tools/ch1-probe` |

## Burner machines, fuel and Ash

| Fact | Source |
|---|---|
| Stone furnace: 8 ore → 1 plate in 10 s (0.1 plate/s), 200 kW, 1 fuel slot. | Data, engine |
| Burner mining drill: mining speed 1, 500 kW, 1 fuel slot: 1 ore/s, 2 Raw coal/s, burns 0.167 Raw coal/s. | Data, engine |
| Coal-type fuels (Raw coal, Coal, Coke, …) leave 1 Ash per item; Logs and Wood leave nothing. | Data |
| The burnt-result slot holds 1000 Ash; when full the machine stops. At full load on Raw coal: Boiler 13.5 min, Burner mining drill 100 min, Stone furnace ~4 h. | Data, engine |
| Mining productivity is free output: +10 % gives 2.17 Raw coal/s per drill with unchanged fuel use. | Engine (one-off probe) |
| A Burner mining drill that cannot drop its ore ("waiting for space") burns nothing: 0.01 MJ in a minute, against 14.5 MJ for a working one. | Engine, `tools/drill-probe` |
| An inserter never takes fuel out of a furnace, so one filtered to everything *but* Ash (blacklist) takes only the product. | Engine (`tools/ch1-probe`), seen in the author's run |
| Ash separation (a red technology) is the early way to get rid of Ash: a Solid separator MK 01 (electric, 1.5 MW) turns 10 Ash per second into Coal dust (50 %), Soot (20 %) and Iron oxide (5 %). | Data (`data-raw-dump.json`) |
| Ash separation returns half the fuel it costs: 10 Ash take 1.5 MJ of electricity (3 MJ of Boiler fuel) and give 0.5 Coal dust (1.5 MJ). Separating all Ash costs about 5 % more Raw coal. Coal dust is a 3 MJ fuel like Raw coal, stacks to 100 and burns to Ash again. | Data ([chapter 3](../chapters/03-ash-separation-raw-coal-power.md)) |
| Soot separation: 2 Soot → Iron ore and Copper ore 20 % each, Ash 30 %, Aluminium, Zinc and Lead ore 10 % each, 1 s. Iron oxide smelts 20 → 10 Iron plates in 3.5 s in a Stone furnace (5.7 Iron oxide/s per furnace). | Data; the author's game (chapter 3) |
| A Solid separator at full speed needs 13 Mechanical inserters on Ash (13 × 0.83 = 10.8/s from a moving belt). | Data, inserter measurement; the author's design |

## Steam power

| Fact | Source |
|---|---|
| Boiler: 3.7 MW, 7.5 Steam/s at 250 °C, 1.23 Raw coal/s at full load. | Data, engine |
| Steam engine: 15 Steam/s → 3.7 MW. **Two boilers per engine.** | Data, engine |
| Offshore pump needs no power; with `pump-anywhere-fork` it works on land. | Data, engine |
| The electric network loads every Steam engine that has steam by the same share of what it can deliver. Two engines behind two Coal dust Boilers (one engine's steam) take two shares, so those Boilers run twice as hard as the rest and burn the Coal dust first (the author's trick). In the author's save the computed share, 2.0 Coal dust/s, matched the 2.03/s burnt. | Data; the author's save (chapter 3) |
| Boilers pass water along their row. The author's 24-Boiler station had its Offshore pump at one end and a three-tile gap between its halves, so only 12 Boilers had water (22.2 of 44.4 MW); three pipes per row closed it (all engines running afterwards). | The author's saves (chapter 3) |

## Distillation byproducts

| Fact | Source |
|---|---|
| Exhaust pipe: no power; its venting recipe takes 20,000 Coal gas per craft at speed 2. One pipe vented about 88 Coal gas/s, the whole output of five distillation columns. | Data; the author's game ([chapter 2](../chapters/02-coke-steel-crushed-iron.md)) |
| Tailings pond: 18×18, holds 1,000,000 of one fluid. The author's held 160,300 Tar after about 75 minutes of coke making. | Data; the author's save |
| A column stops as soon as one output has no way out: with the Exhaust pipe removed, the author's five columns filled their Coal gas pipes within minutes and stopped Coke, and with it Steel. A Tailings pond is no store for gas: pycoalprocessing's script empties every gas that enters a pond (counting 15 % of it as pollution), so on the Coal gas pipe it is just another vent. Tanks (Storage tanks: 10,000–30,000) hold minutes of it. | The author's save, the author; `pycoalprocessing/scripts/tailings-pond.lua`; data (chapter 3) |
| Aluminium ore can only be mined with Coal gas as the mining fluid (Fluid mining drill, Mining with fluid). A Fluid mining drill MK 01 mines 0.5 ore/s with 10 Coal gas per ore and burns fuel (400 kW): the author's seven took 35.3 Coal gas/s for 3.52 ore/s. | Data; the author's recorder ([chapter 4](../chapters/04-aluminium-glass-logs.md)) |
| Coal gas comes only with Coke: three Raw coal → Coal columns feeding two Coal → Coal gas columns make 240 Coal gas and 150 Tar per 6 Coke, so every Coke taken lets them make 40 Coal gas and 25 Tar (4 Aluminium ore). With no Coke user the columns stop and the aluminium drills run dry. The author's windows: 0.88 Coke/s (steel) → 35 Coal gas/s → 3.5 ore/s; 0.3 Coke/s (a High pressure furnace) → 12 → 1.2; none → 0. | Data; the author's recorder (chapter 4) |
| Glassworks MK 01 burn a fluid fuel, 10 MW each. On Tar (0.2 MJ) a busy one takes 50 Tar/s; the author's melter and caster made 0.2 Glass/s on 56 Tar/s, 280 Tar per Glass. | Data; the author's recorder (chapter 4) |
| Distillation gives Iron oxide by chance, 20 % of the Coal crafts and 30 % of the Coal gas crafts: the author's 1,338 Coal and 690 Coke came with 119 Iron oxide, 124 expected. | Data; the author's save |

## Farms, logs and red science

| Fact | Source |
|---|---|
| Moss farms and Fastwood forestries have a base effect of −100 % speed: empty they do nothing. Their slots take only their own module (Moss, Tree), +100 % each; full they run at speed 1 (15 × 0.0667 and 10 × 0.1). | Data; blueprint bench (chapter 4) |
| A balanced log block: 10 Moss farms : 8 Botanical nurseries : 16 Fastwood forestries make 2.0 Moss, 1.2 Tree seedlings and 2.4 Logs a second, 2.348 net after the Wood for the Tree seeds; they take Ash 12, Stone bricks 1.25, Coke 0.31 and about 316 Water a second, and about 13 MW. The chain needs a few Logs to start. | Data; bench `log-production`: 2.336 Logs/s |
| Fastwood forestry upgrade (a TURD technology) offers Dry storage (Fiber), Selective cutting heads (Wood processing unit: 4 Logs → 40 Wood in 1 s instead of 20 in 4 s) and Internal burner (forestries −50 % energy, +50 % speed and productivity, twice the Ash). | pyalienlife `prototypes/upgrades/fwf.lua` |
| Red science at 0.2/s is one Burner assembling machine; it needs 0.4 Planter boxes/s, that is 2.0 Soil/s (one Soil extractor running all the time), 0.8 Wood/s plus fuel and 1.6 Stone bricks/s into the Empty planter box machine (two Mechanical inserters each at their limit), and 2 Native flora/s (two Flora collectors MK 01). | Data; bench `red-science`: 0.196/s with one Wood inserter, 0.200 with two |
| A Solid separator block with Ash belts above and below the row needs both fed: one basic belt brings 15 Ash/s, half of what three separators take. | Bench `ash-separation`: 50 % with one belt, 100 % with both |

## Research

| Fact | Source |
|---|---|
| Steam power and the Automation science pack technology are triggers: make 10 Iron plates / 10 Copper plates. Furnace output counts, from all furnaces together. | Data, engine |
| Plates made before the prerequisite is researched still count. | Engine, `tools/ch1-probe` |
| Mining productivity 1 (+10 %) costs 90 × (red + pY science pack 1) and needs Mining machines - Stage 1. | Data |

## Design principles (the author's)

1. **Two belts, one input and one output each.** Each belt beside a machine column carries its
   input on the lane next to the machines and collects an output on the outer lane (inserters
   drop there anyway). Every output inserter is filtered.
2. **Input inserter downstream, separator right after the last machine.** Then nothing is left
   stranded on a belt when supply stops: after draining, 0 ore remained with this placement and 4
   with the opposite one; throughput is the same (engine, `tools/design-lab`).
3. **Separate lanes at the end with an underground belt** and collect into chests.
4. **One dedicated fuel drill per raw coal module.** It feeds a service belt that passes every
   drill and tunnels under the output belt; 9 drills give exactly one full belt. With 8 drills
   the best possible is 14.67/s, because the drills burn 1.33 Raw coal/s themselves; 8 become
   possible only after Mining productivity 1, and then need tapping from the output belt, which
   costs more parts than the drill it saves.
5. **Fuel lines.** A drill row whose output belt U-turns behind it becomes its own service belt
   (coal lands on the inner lane) and can continue as a fuel line (Raw coal + Ash) for other burner
   rows. Raw-coal-filtered inserters take pure coal off such a line.
6. **One fuel tap per smelting column.** A column of 10 furnaces burns 0.667 Raw coal/s; one
   inserter moves 0.83/s from a passing Raw coal belt onto the start of the fuel belt, dropping
   onto its inner lane. A full Raw coal belt fuels about 22 columns.
7. **Opening order.** Handcraft all red science until Wood is mass-produced; automate Iron plates
   (and Raw coal) first. In their second game the author puts drills before belts: early belts
   and inserters are dear, so the first plates become Burner mining drills dropping straight into
   Stone furnaces. From data: a Basic transport belt costs 11 Iron ore + 3 Copper ore per tile
   (1.375 Iron plates + 0.375 Copper plates); a Burner inserter 68 Iron ore + 12 Copper ore, more
   than a Burner mining drill (66 Iron ore + 18 Copper ore + 5 Stone), which mines its iron back
   in 66 seconds on an iron patch.
8. **Smelting unit.** Ore drill rows and a 10-furnace column on one fuel loop; the drill rows cover
   the whole ore strip and hold more drills than needed, because downstream drills take over when
   upstream ones mine out and blocked drills burn nothing. Uneven rows are mined-out spots. A unit
   burns about 2.0 Raw coal/s and takes it with three taps (3 × 0.83/s).
9. **One column blueprint for every plate.** Plate-side output inserters filtered to everything
   but Ash (blacklist), so the same blueprint smelts iron or copper.
10. **Mall.** Once handcrafting holds you up (in the author's first run: 48 minutes of recipe time
   in 77 minutes, 28.5 of them behind Small parts), assemblers make the building materials into
   chests. Not balanced — every machine just produces; the items needed in very large numbers
   (Transport belts, Mechanical inserters) come first and their bottlenecks are raised later.
11. **Make on the spot what needs nothing or only Water** (Soil, Limestone, Seaweed, Sap, CO2 from
   Moondrop greenhouses, Vacuum, Methane ...): each block that uses one runs its own machines for
   it, so every block balances itself and these items stay off the bus. `rate-plan.js` finds them
   (plan option `local: 'free'`); see [first-save-review](first-save-review.md#5-the-bus-to-trains).
12. **Every byproduct gets a buffer**, so that a consumer that stops cannot jam its producer.
   **Stone travels as Stone bricks**: they stack to 1,000 against Stone's 50 (an iron chest holds
   32,000 bricks, i.e. 64,000 Stone, against 1,600 Stone), and a Jaw crusher turns 4 bricks back
   into 8 Stone where Stone is needed, for some fuel (smelting) and power (crushing). The bus then
   carries half as many items. Plan option `carry` in `rate-plan.js`.
13. **Ash on belts to Solid separators, not into chests.** Every fuel loop and furnace row passes its
   Ash lane on to one Ash belt ending at the separators; their Coal dust goes back into Boilers and
   furnaces, their Soot into Soot separation, their Iron oxide into furnaces, each through a buffer
   chest. Size the separators for the Ash already piled up, not only for what the base makes.
14. **Burn byproduct fuel first** by giving its Boilers one Steam engine more than their steam needs
   (see Steam power).
15. **Product before disposal.** An Ash loop passes the blocks that need Ash for a product (logs,
   planter boxes) before it reaches the separators, which get what is left.
16. **Priority by circuit.** Where one machine feeds two users, let the second user's inserter run
   only while the first holds enough: the author's forestry passes Logs to the belt only while the
   Wood processing unit next to it holds 2 or more.

## Trains

See [Railways under Pyanodons](py-railway.md): no speed cap in Py (measured top speeds and
braking distances), Ash and empty containers from locomotive fuel, 3.5-tile MK 02/MK 04 wagons,
and one platform layout that serves both 7-tile and 3.5-tile wagons.
