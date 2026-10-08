# Coke, steel, crushing and Ash separation

[中文版](coke-and-steel.zh-CN.md) · [Index](../README.md)

Reference for the stage of [chapter 2](../chapters/02-coke-steel-crushed-iron.md), which follows
the author's recorded play of it. Everything here is **from data** (`tools/dump-data.ps1`,
`tools/recipe-tree.js`) unless it says *verified*; chapter 2 has what the author's blocks measured
in their game.

## The main line

The stage has two goals, both of which need steel buildings, and steel needs coke:

1. **Grade-1 iron** (the Crusher technology): a Jaw crusher turns 5 Iron ore into 3 Processed
   iron ore, and 3 Processed iron ore smelt into 1 Iron plate — **5 ore per plate instead of 8**,
   60 % more plates from the same ore. The Jaw crusher costs 30 Steel plate.
2. **Ash separation**: a Solid separator disposes of the Ash every coal-burning machine leaves:
   half of the crafts give Coal dust, a fifth give Soot (which separates into five ores) and one
   in twenty gives Iron oxide (2 per Iron plate). The Solid separator costs 50 Steel plate.
3. **Steel** comes from an Advanced foundry: 5 Coke + 20 Iron ore + 5 Limestone → 1 Steel plate.
4. **Coke**, until Steel is made, comes from two distillations: Raw coal → Coal → Coke. (The
   author's map has no Coal ore at all: `tools/inspect-save.ps1` counts every resource on the
   generated map.) Once Tar processing is researched, Coke becomes a large byproduct of Tar —
   see "Later sources of Coke".

## Technologies

| Technology | Cost | Needs | Unlocks for this stage |
|---|---|---|---|
| Coal processing 1 (done in chapter 1) | 12 red | — | Destructive distillation column MK 01, High pressure furnace MK 01, Exhaust pipe, Tailings pond; Coal from Raw coal, Coke from Coal, Limestone, Iron plate from Iron oxide |
| Steel processing | 18 red | Coal processing 1 | Advanced foundry MK 01, Steel plate, Sinkhole |
| Soil washing | 18 red | — | Washer MK 01, Sand, Muddy sludge |
| Crusher | 24 red | Steel processing, Soil washing | Jaw crusher MK 01, Processed iron ore, Iron plate from it, Gravel, Sand, Stone from bricks, Saline water |
| Ash separation | 60 red | Steel processing | Solid separator MK 01, Ash separation, Soot separation |

120 red packs in all: about 29 minutes of handcrafting recipe time at 14.3 s a pack.


## Recipes and rates

Rates are per machine at crafting speed 1 (every machine below is MK 01 with speed 1).

| Recipe | Machine | In → out | Per machine per second |
|---|---|---|---|
| Coal | Destructive distillation column | 10 Raw coal → 3 Coal + 60 Coal gas + 30 Tar + 1 Iron oxide (20 %) (2 s) | 5 Raw coal → 1.5 Coal, 30 Coal gas, 15 Tar, 0.1 Iron oxide |
| Coal gas from coal | Destructive distillation column | 10 Coal → 6 Coke + 40 Coal gas + 50 Tar + 1 Iron oxide (30 %) (3 s) | 3.33 Coal → 2 Coke, 13.3 Coal gas, 16.7 Tar, 0.1 Iron oxide |
| Limestone | Soil extractor | 400 Water → 8 Limestone (20 s) | 20 Water → 0.4 Limestone |
| Steel plate | Advanced foundry | 5 Coke + 20 Iron ore + 5 Limestone → 1 (15 s) | 0.067 Steel (4 a minute) |
| Iron plate (from Iron oxide) | Stone furnace or Advanced foundry | 20 Iron oxide → 10 (3.5 s) | 5.7 Iron oxide → 2.9 Iron plate |
| Processed iron ore | Jaw crusher | 5 Iron ore → 3 Processed iron ore + 1 Stone (2 s) | 2.5 Iron ore → 1.5 Processed, 0.5 Stone |
| Iron plate (from Processed iron ore) | Stone furnace or Advanced foundry | 3 → 1 (6 s) | 0.17 Iron plate |
| Ash separation | Solid separator | 10 Ash → 1 Coal dust (50 %) + 1 Iron oxide (5 %) + 1 Soot (20 %) (1 s) | 10 Ash → 0.5 Coal dust, 0.05 Iron oxide, 0.2 Soot |
| Soot separation | Solid separator | 2 Soot → 1 Iron ore (20 %) + 1 Copper ore (20 %) + 1 each Aluminium, Zinc and Lead ore (10 %) + 1 Ash (30 %) (1 s) | 2 Soot → 0.2 Iron ore, 0.2 Copper ore, 0.1 each Aluminium, Zinc and Lead ore, 0.3 Ash |

A percentage is the chance that a craft gives that product (Factorio 2.1's
`independent_probability`); every other amount is fixed. The author's second save bears the
chances out: its 1,338 Coal and 690 Coke came with 119 Iron oxide, and the chances give 124
(446 crafts × 20 % + 115 × 30 %). Wood also distils into Coal one to one (10 Wood → 10 Coal +
10 Coal gas + 30 Tar + 1 Iron oxide at 30 %), but Wood is what red science needs.

### Byproducts

Every distillation also makes Coal gas, Tar and Iron oxide, and the column stops when any output
is full, so each needs a way out:

| Byproduct | Ways out now | Notes |
|---|---|---|
| Coal gas | **Exhaust pipe** (1×1, no power, Coal processing 1) vents it; a High pressure furnace burns 50 into 1 Ash per second at 2 MW | The vent costs nothing to run |
| Tar | Tailings pond (18×18, stores 1,000,000); **Sinkhole** (3×3, needs 15 Steel) voids it; or Carbolic oil in a distillation column (Tar + Steam + Raw coal), which has no use yet | Store it until the Sinkhole is built |
| Iron oxide | Smelts into Iron plate, 2 to 1 | Pure gain |
| Stone (Jaw crusher) | Stone bricks, furnaces | |
| Coal dust (Ash separation) | No use yet | Store it |
| Muddy sludge (Washer) | Sinkhole | |

(The Burner, which destroys solid items, needs pY science pack 1 and Titanium plate.)

## One Advanced foundry, fully fed

| Need per second | Machines |
|---|---|
| 0.33 Coke | 0.17 distillation columns on Coal |
| 0.56 Coal | 0.37 distillation columns on Raw coal |
| 1.85 Raw coal | (the Raw coal belt carries 15) |
| 1.33 Iron ore | |
| 0.33 Limestone, 16.7 Water | 0.83 Soil extractor |

So two distillation columns (one per recipe, both mostly idle), one Soil extractor of its own
(the one making Soil for red science cannot do both) and one foundry make 4 Steel plates a
minute. Byproducts: 13.3 Coal gas, 8.3 Tar and 0.05 Iron oxide per second.

Per Steel plate: 27.8 Raw coal, 20 Iron ore, 5 Limestone (250 Water); 200 Coal gas, 125 Tar,
0.8 Iron oxide.

**The first 80 Steel plates** (Jaw crusher 30 + Solid separator 50) take 20 minutes of one
foundry, 2,222 Raw coal, 1,600 Iron ore and 400 Limestone (17 minutes of one Soil extractor).
A Sinkhole adds 15.

## The author's goal: full belts

The author's target for the stage: a full belt of Raw coal into Coke, and a full belt of Iron
ore into Steel.

- **15 Raw coal/s through both distillations**: 3 columns on Raw coal and 1.35 on Coal give
  **2.7 Coke/s**, plus 108 Coal gas, 67.5 Tar and 0.44 Iron oxide per second.
- **15 Iron ore/s into Steel**: 0.75 Steel/s (45 a minute) from 11.25 Advanced foundries, which
  need **3.75 Coke/s** and 3.75 Limestone/s (9.4 Soil extractors, 187.5 Water/s).
- So one full Raw coal belt's Coke covers 0.54 Steel/s, the Steel from **10.8 Iron ore/s**; a
  full Iron ore belt needs about 20.8 Raw coal/s through the columns (1.4 belts).
- Power, every machine working: columns 2.2 MW, foundries 13.5 MW, Soil extractors 3.75 MW —
  **19.4 MW**, that is 5.2 Steam engines on 10.5 Boilers burning 13 Raw coal/s.

## Power

Every machine of this stage is electric:

| Machine | Size | Power |
|---|---|---|
| Destructive distillation column MK 01 | 8×8 | 500 kW |
| High pressure furnace MK 01 | 7×7 | 2 MW |
| Advanced foundry MK 01 | 6×6 | 1.2 MW |
| Jaw crusher MK 01 | 7×7 | 1 MW |
| Solid separator MK 01 | 7×7 | 1.5 MW |
| Washer MK 01 | 6×6 | 400 kW |
| Soil extractor MK 01 | 7×7 | 400 kW |

One Boiler makes 7.5 Steam/s, enough for 1.85 MW (verified: a Steam engine turns 15 Steam/s into
3.7 MW). The steel line above draws 2.6 MW while every machine works (about 1.8 MW on average,
since the columns idle), on top of chapter 1's labs, Soil extractor and Flora collector: the
second Boiler, and soon a second engine pair, comes with this stage. Crushing is power-hungry:
grade-1 iron costs 2 MJ of crusher time per plate (one Jaw crusher, 1 MW, makes enough Processed
iron ore for 0.5 plates/s), so crushing the 13.5 Iron ore/s of chapter 1's first-run base would take 5.4
Jaw crushers and 5.4 MW.

## Later sources of Coke

Searched by product (every recipe whose results contain Coke), the ones that come within reach:

| Source | Technology (cost, needs) | Recipe |
|---|---|---|
| Tar | Tar processing (60 red; needs Internal combustion engine and Concrete) | In a Tar processing unit MK 01 (11×11, 500 kW, 20 Steel): 100 Tar + 100 Steam → 140 Pitch + 75 Anthracene oil + 30 Middle oil + 24 Creosote (5 s). In a distillation column: 100 Pitch + 100 Steam → 10 Coke + 30 Anthracene oil + 20 Light oil + 20 Naphthalene oil + 10 Hydrogen (5 s); 50 Anthracene oil → 5 Coke + 20 Gasoline (4 s) |
| Raw coal | Coke processing - Stage 1 (50 × (pY science pack 1 + 2 red)) | In a High pressure furnace: 10 Raw coal → 4 Coke + 20 Coke oven gas (2 s) |

From Steel processing on, the way to Tar processing costs only red: Mining with fluid (24),
Internal combustion engine (60), Concrete (24, after Crusher) and Tar processing (60) — 228 red
counting Steel processing, Soil washing and Crusher.

Per 100 Tar the Tar route gives **25.7 Coke**, but it needs 240 Steam of at least 250 °C (both
steps take Steam 1:1): 118 MJ of Boiler heat, the fuel value of 23.7 Coke or 39.5 Raw coal. The
Tar of a full Raw coal belt (67.5/s) would give 17.4 Coke/s for 162 Steam/s, 21.6 Boilers. Every
new liquid can be voided by a Sinkhole and every new gas by an Exhaust pipe.

## What the two goals give

- **Grade-1 iron**: one Jaw crusher and three Stone furnaces turn 2.5 Iron ore/s into 0.5 Iron
  plate/s (plus 0.5 Stone/s), where direct smelting gives 0.31. It saves ore, not fuel: a plate
  smelted directly burns 6 MJ (8 ore in Burner mining drills at 0.5 MJ each, 10 s of a 200 kW
  furnace), 2 Raw coal; a crushed plate burns 3.7 MJ in drills and furnace plus 2 MJ of
  electricity, which costs 4 MJ of Boiler fuel (Steam engines turn half the steam's heat into
  power), so 7.7 MJ, 2.57 Raw coal.
- **Ash separation** gets rid of Ash; it is no source of metal. The base of chapter 1's first run
  made about 6 Ash/s at 1:10. One Solid separator (10 Ash/s) turns that into 0.3 Coal
  dust/s to store, 0.12 Soot/s and 0.03 Iron oxide/s (0.015 Iron plate/s); the Soot separates
  into 0.012/s each of Iron and Copper ore, 0.006/s each of Aluminium, Zinc and Lead ore, and
  0.018 Ash/s back. The 5,668 Ash the author carried at the end of that run is about ten minutes
  of one separator.

## Verified since

In the author's game ([chapter 2](../chapters/02-coke-steel-crushed-iron.md)): five columns made
2.71 Coke/s; one Exhaust pipe vented about 88 Coal gas/s; eight foundries made 0.43–0.44
Steel/s; six Jaw crushers and 18 furnaces made 3.02 Iron plate/s and their Stone 1.52 Stone
brick/s. Still open: the Solid separator, and the designs in the design lab.
