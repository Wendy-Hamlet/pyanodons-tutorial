# The red + pY1 factory: bus, blocks and key intermediates

[中文](red-py1-factory.zh-CN.md)

What a factory making Automation science (red) and pY science pack 1 (pY1) needs, block by
block, and which items several blocks share, so they belong on a bus (or, later, on Cellforge's
city-block grid). Plus the Simple circuit board on its own, and the other intermediates the
buildings before trains are made of.

All numbers are computed from the prototype data dump by `tools/rate-plan.js` from the plans in
[`plans/`](plans/), which name one recipe per item and say why. Rates are per minute, fluids in
units, machine counts fractional (round up per block), machines at crafting speed 1 unless noted.
Run `node --max-old-space-size=4096 tools/rate-plan.js research/plans/<plan>.js --build` for the
full tables.

## 1. How many red and pY1

- Every technology that costs pY1 costs **2 red + 1 pY1 per unit** (45 s per unit); the others
  cost 1 red (30 s). That holds for all 139 technologies of the era (data).
- On the way to trains (Railway + Automated rail transportation and their prerequisites, minus
  what the author had researched at 2:20) the labs still need **4,087.5 red and 870 pY1** in
  54 technologies: about 4.7 red per pY1.
- Plan: **red 60/min, pY1 30/min.** 30 pY1/min keeps the labs at full speed on pY1 technologies;
  over the whole way to trains 13/min would do, if pY1 packs pile up while red-only technologies
  run. Everything below scales linearly.
- Labs (speed 1): 60 red/min needs 30 labs on red-only technologies and 22.5 on pY1 ones.

## 2. The recipes (plan `plans/science-red-py1.js`)

Red: Automation science pack ← 2 Planter box + 10 Native flora + 2 Small parts. Planter box ←
Empty planter box + 5 Soil + 3 Ash; Empty planter box ← 4 Stone brick + 2 Wood + 1 Iron plate.

pY1: 3 packs ← 18 Basic substrate + 3 Glassware. Basic substrate (10) ← 5 Moss + 2 Incubated
petri dish + 3 Cellulose. Glassware (2) ← 4 Rubber stoppers + 100 Molten glass. Rubber stoppers
(4) ← 2 Latex + 5 Coal; Latex ← Latex slab + 150 Steam; Latex slab ← Sodium alginate + 100 Creamy
latex + **100 Formic acid**, and Formic acid comes from slaughtering vrauks (200 per vrauk; the
cage comes back).

Choices worth knowing (the author's, read from their first save, see
[first-save-review](first-save-review.md)):

- Iron through the Jaw crusher (the stage's goal): 5 Iron ore → 3 Processed iron ore + 1 Stone,
  3 Processed → 1 plate. 5 ore per plate instead of 8, plus Stone.
- Copper through the Screener and Crusher (Copper processing 1): 5 ore → 1 grade-1 + 2 grade-2
  copper, 2 grade-1 → 1 grade-2 + 2 Stone, 5 grade-2 → 2 plates in a Foundry. 5 ore per plate
  instead of 8, plus 1 Stone.
- Moss with Stone (16 per 80 s) rather than without (8 per 100 s).
- Logs with Ash (6 per 3 seedlings, 30 Ash), and Wood at 40 per 4 logs in 1 s.
- CO2 from Moondrop greenhouses, 200 per 5 s from nothing.
- The last two recipes appear in no technology: they come with the T.U.R.D. upgrades the author
  picked (Fastwood forestry upgrade, Moondrop upgrade); their save runs them.
- Py farms run on their own organisms as modules, full slots assumed: Moss farm 15 Moss
  (speed 1.07), Seaweed crop 10 Seaweed (1.1), Vrauk paddock 10 Vrauks (0.55), Fastwood forestry
  10 Trees (1.1), Sap extractor 2 Sap trees (1.5), Reproductive complex 2 Vrauks (1.5), Moondrop
  greenhouse 16 Moondrop (1.06).
- Everything that burns uses Raw coal; electricity from boilers and steam engines.

## 3. Blocks

| Block | Makes (/min) | Machines | Takes in (/min) |
|---|---|---|---|
| iron | Processed iron ore 990, Iron plate 330 | Jaw crusher 11, Stone furnace 33 | Iron ore 1,650 |
| copper | grade-1 90, grade-2 225, Copper plate 90 | Screener 4.5, Jaw crusher 2.25, Foundry 1.5 | Copper ore 450 |
| bricks | Stone brick 480 | Stone furnace 25.6 | Stone 960 |
| small parts | Small parts 120 (with gears, sticks, bolts, cable) | Burner assembling machine 2.5 | Iron plate 210, Copper plate 90 |
| red | Empty planter box 120, Planter box 120, **Red 60** | Burner assembling machine 11 | Native flora 600, Soil 600, Stone brick 480, Ash 360, Wood 240, Small parts 120, Iron plate 120 |
| soil and limestone | Soil 806, Limestone 396 | Soil extractor 23.2 | Water 60,115 |
| wood | Tree seeds 10.5, Seedlings 32, Logs 63, Wood 631 | Fastwood forestry 6.4, Botanical nursery 3.5, Wood processing unit 0.26 | Ash 316, Moss 53, Water 6,311 |
| moss | Muddy sludge 2,063, CO2 2,063, Moss 330 | Moss farm 25.8, Washer 1.4, Moondrop greenhouse 0.8 | Stone 413, Soil 206, Water 2,063 |
| coal | Coal 75 | Destructive distillation column 0.83 | Raw coal 250 |
| seaweed | Seaweed 330 | Seaweed crop 25 | Water 6,600 |
| glass | Molten glass 3,300, Empty petri dish 36, Glassware 30 | Glassworks 30 | Quartz ore 1,980, Rubber stoppers 60 |
| petri dish | Agar 36, Petri dish 36, Incubated petri dish 36 | Microorganism mine 12, High pressure furnace 3, assembler 3 | Seaweed 180, Empty petri dish 36, Steam 3,600 |
| vrauks | Water barrel 82.5, Cocoon 75, Vrauk 15, Caged vrauk 15 | **Vrauk paddock 36.4**, Reproductive complex 6.7 | Native flora 188, Moss 188, Sap 45, Cages back 15, Water 4,125 |
| latex | Sap 105, Creamy latex 3,000, Sodium alginate 30, Formic acid 3,000, Latex slab 30, Latex 30, Rubber stoppers 60 | Sap extractor 23.3, High pressure furnace 7.5, Washer 4, Slaughterhouse 2.5, Distillation column 2.5 | Limestone 180, Stone 150, Seaweed 150, Coal 75, Caged vrauk 15, Water 6,000, Steam 4,500 |
| py1 | Cellulose 54, Basic substrate 180, **pY1 30** | High pressure furnace 9, Research center 2.5, assembler 1.05 | Wood 378, Limestone 216, Moss 90, Incubated petri dish 36, Glassware 30 |

Fluids stay inside a block where they can: Molten glass with its two users, Formic acid and
Creamy latex with the Latex slab, CO2 with the moss farms.

## 4. Bus or direct link

An item that leaves its block for **several** blocks belongs on the bus; for one block it is a
direct link between neighbours. Basic belt = 900 items/min.

| Item | From | To (/min) | Total | |
|---|---|---|---|---|
| Stone | crushing 420 + mined 1,103 | bricks 960, moss 413, latex 150 | 1,523 | **bus** (2 belts) |
| Soil | soil and limestone | red 600, moss 206 | 806 | **bus** |
| Native flora | mined | red 600, vrauks 188 | 788 | **bus** |
| Ash | burners | red 360, wood 316 | 676 | **bus** |
| Wood | wood | py1 378, red 240 | 618 | **bus** |
| Limestone | soil and limestone | py1 216, latex 180 | 396 | **bus** |
| Iron plate | iron | small parts 210, red 120 | 330 | **bus** |
| Seaweed | seaweed | petri dish 180, latex 150 | 330 | **bus** |
| Moss | moss | vrauks 188, py1 90, wood 53 | 330 | **bus** |
| Water | Offshore pumps | soil and limestone 60,115, seaweed 6,600, wood 6,311, latex 6,000, vrauks 4,125, moss 2,063 | 85,215 | pipe |
| Steam | boilers | latex 4,500, petri dish 3,600 | 8,100 | pipe |
| Quartz ore | mined | glass | 1,980 | direct (2.2 belts) |
| Iron ore | mined | iron | 1,650 | direct (1.8 belts) |
| Copper ore, Raw coal | mined | copper 450, coal 250 | | direct |
| Stone brick, Small parts, Copper plate | bricks, small parts, copper | red 480, red 120, small parts 90 | | direct |
| Coal | coal | latex 75 | | direct |
| Stoppers, Sap, Empty / Incubated petri dish, Glassware | | latex→glass 60, latex→vrauks 45, glass→petri 36, petri→py1 36, glass→py1 30 | | direct |
| Cages / Caged vrauks | latex ↔ vrauks | 15 each way | | direct, **both ways** |

So the bus of this factory is **Stone, Soil, Native flora, Ash, Wood, Limestone, Iron plate,
Seaweed and Moss**, with Water and Steam as pipes. Moss is the surprise: the wood farm needs it
for seedlings, so red science depends on the moss farms too. Ash is on the bus because both red
science and the log recipe eat it.

## 5. Raw inputs, power and leftovers

| Input | /min | /s | Source |
|---|---|---|---|
| Water | 85,215 | 1,420 | 1.2 Offshore pumps (1,200/s each) |
| Steam | 8,100 | 135 | 18 boilers |
| Quartz ore | 1,980 | 33 | 33 Crystal mines |
| Iron ore | 1,650 | 27.5 | 27.5 burner drills |
| Stone | 1,103 | 18.4 | 18.4 burner drills (plus 420/min from crushing iron and copper) |
| Native flora | 788 | 13 | 13 Flora collectors |
| Ash | 676 | 11 | burnt Raw coal |
| Copper ore | 450 | 7.5 | 7.5 burner drills |
| Raw coal (for Coal) | 250 | 4.2 | 2.1 burner drills |

Power at full load: **121.9 MW electric**, 40.9 MW burner fuel (furnaces, burner assemblers and
the burner drills above), and **300 MW of fuel fluid for the 30 Glassworks** (10 MW each; Coal
gas holds 0.2 MJ per unit).

| Raw coal burnt for | /s | |
|---|---|---|
| Burner machines and drills | 13.6 | 40.9 MW |
| Process steam | 22.2 | 18 boilers (7.5 Steam/s each) |
| Electricity | 81.3 | 32.9 steam engines (3.7 MW each), 65.9 boilers |
| Total | 117.1 | 7,026/min |

Every Raw coal leaves one Ash: **7,026 Ash/min against 676 used**. The 6,350 left over are what
Ash separation has to swallow (10 Ash per second per Solid separator: about 11 of them).

Left over per minute: Coal gas 1,500, Tar 750, Meat 30, Guts 30, Chitin 15, Brain 15, Iron oxide 5.

Building every machine of the plan once (`--build`) takes, among others: 8,645 Stone brick,
6,535 Iron plate, 3,925 Small parts, 1,740 Aluminium plate (the vrauk paddocks), 1,584 Glass,
1,495 Steel, 1,394 Air-core inductors, 1,250 Tin plate, 820 Titanium plate, 423 Steam engines and
**542 Simple circuit boards** (Research centers, Slaughterhouses, Reproductive complexes,
Screeners), plus the organisms as modules (390 Moss, 384 Vrauks, 250 Seaweed, 70 Trees, 48 Sap
trees, 16 Moondrop).

The pY1 side dominates: per pY1 pack 110 Molten glass (glass is 30 of the factory's machines)
and half a vrauk (36 paddocks). If pY1 runs at 13/min instead of 30, those parts shrink to
43 %.

## 6. Simple circuit board (plan `plans/electronic-circuit.js`)

3 Simple circuit boards ← Printed circuit substrate (tier 1) + 3 Vacuum tubes + 3 Air-core
inductors + 5 Ceramic capacitors + 6 High-power resistors + 2 Solder + 1 CuZn battery (4 s,
Chipshooter). Behind them:

- Substrate ← 2 Formica + 5 Copper plate + 50 Vacuum; Formica ← 2 Treated wood + 5 Raw fiber +
  10 Sap + 50 Formaldehyde; Treated wood ← 100 Creosote + 1 Wood; Formaldehyde ← 60 Methane +
  5 Copper plate, and Methane at this point comes only from the **Moondrop greenhouse** (CO2 +
  Moondrop seeds).
- Vacuum tube ← Iron, Copper, Graphite (from Coke), Vacuum, Glass. Inductor ← Ceramic + Copper
  cable. Capacitor ← Ceramic + **Tin**. Resistor ← **Tin** + Coke + Glass. Solder ← **Tin + Lead**.
  Battery ← Copper + **Zinc** + Cellulose + Saline water.
- Creosote by Tar refining (24 per 100 Tar; the Carbolic-oil route needs 2.4 times the Tar), and
  Coke from the Pitch it leaves, as in the author's save.

Per Simple circuit board, raw: Copper ore 57, **Zinc ore 33, Tin ore 31, Lead ore 16**, Iron ore
12.5, Quartz ore 10, Stone 6, Tar 278, Water 1,004, Steam 382, Ash 15 (for the logs). Tin, Lead
and Zinc ore need the Fluid mining drill (the mines for their rock deposits come with Big mines,
much later), each with a mining fluid: Steam (tin), Acetylene (lead), Aromatics (zinc) (data).

At 10/min the circuit factory is 14 blocks: tin/lead/zinc smelting (21 Stone furnaces), copper
(Screener 5.7, Jaw crusher 2.8, Foundry 1.9), wood with sap (15 Sap extractors, 3 Fastwood
forestries), methane (6 Moondrop greenhouses), tar refinery, PCB, components, battery, ceramic,
glass, moss, soil and limestone, iron and the final assembly; 30 MW electric. Its bus: Copper
plate (4 blocks), Stone, Wood and Coke; pipes: Water, Steam, Tar, CO2, Creosote, Formaldehyde and
Vacuum. Left over: Pitch 3,486, Anthracene oil 2,204, Middle oil 833 per minute.

Where circuits go: building the red + pY1 factory once takes about 540; one of each of the 89
buildings up to trains 326; a Locomotive 10, a Train stop 5, a signal 1. 10/min covers the first
in 54 minutes.

## 7. Other key intermediates before trains

`tools/building-inputs.js railway,automated-rail-transportation` counts which items the 89
building recipes up to trains are made of:

| Item | Building recipes using it | One of each building needs | Made of |
|---|---|---|---|
| Small parts | 50 | 1,408 | gear + 3 cable + 3 bolts |
| Iron plate | 46 | 1,254 | |
| Pipe | 30 | 369 | Iron plate |
| **Steam engine** | 30 | 83 | 8 Small parts + 5 Pipe + 10 Iron plate |
| **Steel plate** | 28 | 705 | Coke + Iron ore + Limestone |
| **Simple circuit board** | 23 | 326 | section 6 |
| Stone brick | 19 | 1,060 | Stone |
| Air-core inductors | 19 | 170 | Iron stick + 8 Copper cable |
| **Duralumin** | 15 | 321 | 4 Aluminium plate + 2 Copper plate (Aluminium ore needs Coal gas to mine) |
| Glass | 13 | 464 | Molten glass |
| Lead plate | 12 | 290 | Lead ore (Acetylene to mine) |
| **Titanium plate** | 9 | 480 | Titanium ore (Acetylene to mine) |

The trains themselves add their own parts:

| Recipe | Ingredients |
|---|---|
| Locomotive | 10 Simple circuit board, 30 Steel, 20 Pipe, 2 Steam engine, 20 Small parts, 25 Duralumin, 4 Shaft MK01, 1 Gearbox MK01, 5 Intermetallics, 4 Brakes MK01 |
| Cargo wagon | 10 Small parts, 20 Iron plate, 20 Steel, 50 Titanium plate, 2 Shaft MK01, 10 Duralumin, 5 Intermetallics, 2 Brakes MK01 |
| Rail (3) | 1 Stone, 4 Bolts, 2 Treated wood, 1 Steel, **5 Solder** |
| Shaft MK01 | 5 Iron nexelit antimony special alloy, 5 Solder, 5 Small parts (50 s) |
| Gearbox MK01 | 2 Shaft MK01, 4 Duralumin, 5 Steel, 4 Titanium plate, 20 Fish oil |
| Intermetallics | 1 Vitreloy + 1 Iron nexelit antimony special alloy |
| Brakes MK01 | 10 Ceramic, 10 Copper plate, 10 Glass, 5 Steel, 20 Duralumin, 2 Vitreloy, 10 Small parts |

So besides the circuit board, the intermediates to plan production for before trains are
**Steel, Steam engines, Duralumin, Titanium plate, Solder** (circuits and every rail), **Treated
wood** (Formica and every rail), Glass and Ceramic; for the trains also the special alloy,
Vitreloy and Fish oil.

## 8. What it suggests for the bus

1. A main bus of nine items carries this factory: Stone, Soil, Native flora, Ash, Wood,
   Limestone, Iron plate, Seaweed, Moss. Copper plate joins it with the circuit factory; the
   combined plan is in [first-save-review](first-save-review.md#5-the-bus-to-trains).
2. Raw ores with one consumer (Quartz, Iron, Copper, Raw coal) go straight from the mine to their
   block; blocks that touch can hand over directly (output ports, see
   [techniques](techniques.md#machines-with-an-output-port)).
3. Water is the largest flow by far (1.4k/s); Soil and Limestone extractors take 71 % of it, so
   they sit at the pumps.
4. Two-way links (cages, barrels) keep blocks paired: vrauks next to latex.
5. Glass and power decide the pY1 rate more than anything else; size pY1 to what the labs need on
   average (about 13/min to trains) before building for 30.

Revised 2026-10-01: the plans now use the author's recipes (copper through the Screener, logs
with Ash, CO2 from Moondrop greenhouses), and `rate-plan.js` counts Factorio 2.1's product chances
(`independent_probability`), which the first version ignored; that had understated the Moondrop
greenhouses of the circuit factory (6, not 3) and overstated leftover Iron oxide.

## Sources

- Data: `tools/rate-plan.js` on `plans/science-red-py1.js` and `plans/electronic-circuit.js`;
  `tools/building-inputs.js`; technology costs and lab speed from the data dump.
- Engine: boiler and steam engine figures from [techniques](techniques.md#steam-power).
- Research state: the author's save "Py-exploration" of 2026-10-01 15:53 (`tools/inspect-save.ps1`);
  recipes: their first save "Pyanodons" ([first-save-review](first-save-review.md)).
