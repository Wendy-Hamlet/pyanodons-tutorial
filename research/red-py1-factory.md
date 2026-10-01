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

Choices worth knowing:

- Iron through the Jaw crusher (the stage's goal): 5 Iron ore → 3 Processed iron ore + 1 Stone,
  3 Processed → 1 plate. 5 ore per plate instead of 8, plus Stone.
- Moss with Stone (16 per 80 s) rather than without (8 per 100 s).
- Logs from seedlings with water (4 per 3 seedlings); the Ash recipe gives 6 but costs 30 Ash.
- Py farms run on their own organisms as modules, full slots assumed: Moss farm 15 Moss
  (speed 1.07), Seaweed crop 10 Seaweed (1.1), Vrauk paddock 10 Vrauks (0.55), Fastwood forestry
  10 Trees (1.1), Sap extractor 2 Sap trees (1.5), Reproductive complex 2 Vrauks (1.5).

## 3. Blocks

| Block | Makes (/min) | Machines | Takes in (/min) |
|---|---|---|---|
| iron | Processed iron ore 990, Iron plate 330 | Jaw crusher 11, Stone furnace 33 | Iron ore 1,650 |
| copper | Copper plate 90 | Stone furnace 15 | Copper ore 720 |
| bricks | Stone brick 480 | Stone furnace 25.6 | Stone 960 |
| small parts | Small parts 120 (with gears, sticks, bolts, cable) | Burner assembling machine 2.5 | Iron plate 210, Copper plate 90 |
| red | Empty planter box 120, Planter box 120, **Red 60** | Burner assembling machine 11 | Native flora 600, Soil 600, Stone brick 480, Ash 360, Wood 240, Small parts 120, Iron plate 120 |
| soil and limestone | Soil 876, Limestone 396 | Soil extractor 23.8 | Water 63,622 |
| wood | Tree seeds 33, Seedlings 99, Logs 132, Wood 659 | Botanical nursery 11, Fastwood forestry 30, Wood processing unit 2.2 | Water 19,776, Moss 165 |
| moss | Muddy sludge 2,764, CO2 2,764, Moss 442 | Moss farm 34.6, High pressure furnace 2.9, Washer 1.8 | Stone 553, Soil 276, Coke 69, Water 2,764 |
| coke | Coal 190, Coke 69 | Destructive distillation column 2.7 | Raw coal 634 |
| seaweed | Seaweed 330 | Seaweed crop 25 | Water 6,600 |
| glass | Molten glass 3,300, Empty petri dish 36, Glassware 30 | Glassworks 30 | Quartz ore 1,980, Rubber stoppers 60 |
| petri dish | Agar 36, Petri dish 36, Incubated petri dish 36 | Microorganism mine 12, High pressure furnace 3, assembler 3 | Seaweed 180, Empty petri dish 36, Steam 3,600 |
| vrauks | Water barrel 82.5, Cocoon 75, Vrauk 15, Caged vrauk 15 | **Vrauk paddock 36.4**, Reproductive complex 6.7 | Native flora 188, Moss 188, Sap 45, Cages back 15, Water 4,125 |
| latex | Sap 105, Creamy latex 3,000, Sodium alginate 30, Formic acid 3,000, Latex slab 30, Latex 30, Rubber stoppers 60 | Sap extractor 23.3, High pressure furnace 7.5, Washer 4, Slaughterhouse 2.5, Distillation column 2.5 | Limestone 180, Stone 150, Seaweed 150, Coal 75, Caged vrauk 15, Water 6,000, Steam 4,500 |
| py1 | Cellulose 54, Basic substrate 180, **pY1 30** | High pressure furnace 9, Research center 2.5, assembler 1.05 | Wood 378, Limestone 216, Moss 90, Incubated petri dish 36, Glassware 30 |

Fluids stay inside a block where they can: Molten glass with its two users, Formic acid and
Creamy latex with the Latex slab.

## 4. Bus or direct link

An item that leaves its block for **several** blocks belongs on the bus; for one block it is a
direct link between neighbours. Basic belt = 900 items/min.

| Item | From | To (/min) | Total | |
|---|---|---|---|---|
| Stone | crushing 330 + mined 1,333 | bricks 960, moss 553, latex 150 | 1,663 | **bus** (2 belts) |
| Soil | soil and limestone | red 600, moss 276 | 876 | **bus** |
| Native flora | mined | red 600, vrauks 188 | 788 | **bus** |
| Wood | wood | py1 378, red 240 | 618 | **bus** |
| Moss | moss | vrauks 188, wood 165, py1 90 | 442 | **bus** |
| Limestone | soil and limestone | py1 216, latex 180 | 396 | **bus** |
| Iron plate | iron | small parts 210, red 120 | 330 | **bus** |
| Seaweed | seaweed | petri dish 180, latex 150 | 330 | **bus** |
| Water | Offshore pumps | soil and limestone 63,622, wood 19,776, seaweed 6,600, latex 6,000, vrauks 4,125, moss 2,764 | 102,887 | pipe |
| Steam | boilers | latex 4,500, petri dish 3,600 | 8,100 | pipe |
| Quartz ore | mined | glass | 1,980 | direct (2.2 belts) |
| Iron ore | mined | iron | 1,650 | direct (1.8 belts) |
| Copper ore, Raw coal | mined | copper 720, coke 634 | | direct |
| Stone brick, Ash, Small parts | bricks, burners, small parts | red 480, 360, 120 | | direct |
| Coal, Coke | coke | latex 75, moss 69 | | direct |
| Stoppers, Sap, Empty / Incubated petri dish, Glassware | | latex→glass 60, latex→vrauks 45, glass→petri 36, petri→py1 36, glass→py1 30 | | direct |
| Cages / Caged vrauks | latex ↔ vrauks | 15 each way | | direct, **both ways** |

So the bus of this factory is **Stone, Soil, Native flora, Wood, Moss, Limestone, Iron plate and
Seaweed**, with Water and Steam as pipes. Moss is the surprise: the wood farm needs it for
seedlings, so red science depends on the moss farms too.

## 5. Raw inputs, power and leftovers

| Input | /min | /s | Source |
|---|---|---|---|
| Water | 102,887 | 1,715 | 1.4 Offshore pumps (1,200/s each) |
| Steam | 8,100 | 135 | 18 boilers (7.5/s each, 1.23 Raw coal/s each) |
| Quartz ore | 1,980 | 33 | 33 Crystal mines |
| Stone | 1,333 | 22 | 22 burner drills (plus 330/min from crushing) |
| Iron ore | 1,650 | 27.5 | 27.5 burner drills |
| Native flora | 788 | 13 | 13 Flora collectors |
| Copper ore | 720 | 12 | 12 burner drills |
| Raw coal (for coal) | 634 | 10.6 | 5.3 burner drills |
| Ash | 360 | 6 | burnt Raw coal (1 Ash each) |

Power at full load: **121.5 MW electric**, 16.2 MW burner fuel, and **300 MW of fuel fluid for
the 30 Glassworks** (10 MW each; Coal gas holds 0.2 MJ per unit). On boilers and steam engines
(two boilers per 3.7 MW engine) the electricity alone burns about 81 Raw coal/s, the process
steam 22 more. The 18 process-steam boilers leave 22 Ash/s, far more than the 6 Ash/s red needs:
Ash separation has plenty to work on.

Left over per minute: Coal gas 4,264, Tar 2,478, Iron oxide 75, Meat 30, Guts 30, Chitin 15,
Brain 15.

Building every machine of the plan once (`--build`) takes, among others: 10,265 Stone brick,
6,555 Iron plate, 4,295 Small parts, 1,830 Aluminium plate (the vrauk paddocks), 1,777 Air-core
inductors, 1,614 Glass, 1,335 Steel, 1,250 Tin plate, 820 Titanium plate, 554 Steam engines and
**442 Simple circuit boards** (Research centers, Slaughterhouses, Reproductive complexes), plus
the organisms as modules (525 Moss, 384 Vrauks, 300 Trees, 250 Seaweed, 48 Sap trees).

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
- Creosote by Tar refining (24 per 100 Tar); the Carbolic-oil route needs 2.4 times the Tar.

Per Simple circuit board, raw: Copper ore 91, **Zinc ore 33, Tin ore 31, Lead ore 16**, Stone 24,
Iron ore 12.5, Quartz ore 10, Raw coal 43, Tar 84 (beyond what the plan's own coke distillation
leaves), Water 1,821, Steam 341. Tin, Lead and Zinc ore need the Fluid mining drill (the mines for
their rock deposits come with Big mines, much later), each with a mining fluid: Steam (tin),
Acetylene (lead), Aromatics (zinc) (data).

At 10/min the circuit factory is 14 blocks: tin/lead/zinc smelting (21 Stone furnaces), copper
(19 furnaces), wood with sap (14 Fastwood forestries, 15 Sap extractors), methane (3 Moondrop
greenhouses), PCB, components, battery, ceramic, glass, coke, moss, soil and limestone, iron and
the final assembly; 31.5 MW electric. Its bus: Copper plate (4 blocks), Stone, Wood and Coke;
pipes: Water, Steam, CO2, Creosote, Formaldehyde and Vacuum. Left over: Pitch 3,889, Anthracene
oil 2,083, Middle oil 833, Coal gas 3,093.

Where circuits go: building the red + pY1 factory once takes about 440; one of each of the 89
buildings up to trains 326; a Locomotive 10, a Train stop 5, a signal 1. 10/min covers the first
in 44 minutes.

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

1. A main bus of eight items carries this factory: Stone, Soil, Native flora, Wood, Moss,
   Limestone, Iron plate, Seaweed. Copper plate joins it with the circuit factory.
2. Raw ores with one consumer (Quartz, Iron, Copper, Raw coal) go straight from the mine to their
   block; blocks that touch can hand over directly (output ports, see
   [techniques](techniques.md#machines-with-an-output-port)).
3. Water is the largest flow by far (1.7k/s); Soil and Limestone extractors take 62 % of it, so
   they sit at the pumps.
4. Two-way links (cages, barrels) keep blocks paired: vrauks next to latex.
5. Glass and power decide the pY1 rate more than anything else; size pY1 to what the labs need on
   average (about 13/min to trains) before building for 30.

## Sources

- Data: `tools/rate-plan.js` on `plans/science-red-py1.js` and `plans/electronic-circuit.js`;
  `tools/building-inputs.js`; technology costs and lab speed from the data dump.
- Engine: boiler and steam engine figures from [techniques](techniques.md#steam-power).
- Research state: the author's save "Py-exploration" of 2026-10-01 15:53 (`tools/inspect-save.ps1`).
