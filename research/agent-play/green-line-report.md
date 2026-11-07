# Green science line (agent game 3): result, bill of materials, hindsight plan

Game 3 on a copy of the author's 52:03 save; target 0.05 Logistic science packs a second (3 a minute)
near the bus, inputs by belt from the bus, by-products back to the bus or voided. Journal:
[journal-3.md](journal-3.md); plans `research/plans/green-science.js` (steady) and `green-startup.js`
(start-up). Counts below come from the live game (entity scans, production statistics) at 66:47.

## 1. The 30-minute test (66:15:31-66:45:20, game time)

| | Value |
|---|---|
| Packs made in the 30 minutes | 72 (24 -> 96 in the force's production statistics) |
| First 21 minutes | 72 packs = **3.43 a minute** (above the 3 a minute target) |
| Last 9 minutes | 0: the Animal sample Gene lab ran out of Plasmids |
| Average | 2.4 a minute = 0.04/s: **target not met** |

Why it stopped: the Biofactory's two output inserters took turns, so the 22 Plasmids made from the
preset Laboratory instruments went half to the Sarcorus incubator branch (which needs about 3 in 30
minutes) and half to the Gene lab (which needs 15). With the Gene lab blocked, Brains backed up in the
Slaughterhouse and it stopped too. Fixed after the test: the incubator branch belt is read whole and
its inserter runs only while that belt holds fewer than 3 Plasmids.

Also near their end during the test (pre-placed stock, not yet belted): Ash for Rich clay (the Ground
sample chain had 10 Ground samples left, one Alien craft needs 15), Flasks (5 left in the Biofactory),
Petri dishes (both Micro mines empty).

### What runs by itself and what does not

| Flow | State |
|---|---|
| Cottongut (2 Prandium labs, cub complex, sushi loop), Ralesia seeds, Moondrop (2 greenhouses), Wood seeds (wood tapped off the author's wood belt), Water barrels, Native flora and Moss (service belt), Auogs -> Slaughterhouse -> Animal samples, Bonemeal, Blood (spare to a sinkhole), Soil, Batteries, Urea (battery line), Liquid manure and Zogna bacteria (battery line pipes), Steam (pY1 steam branch), Depolymerized organics (Reformer, Heat exchanger, Vacuum pump), Incubated petri dishes (Micro mines -> Biosample assembler and Biofactory) | belted or piped |
| Laboratory instruments (0.58 a minute) | **preset buffer** (agreed with the user): 22 made by hand from 117 Rubber, 39 lenses, 22 chassis |
| Petri dishes (1 a minute), Flasks (0.58), Basic substrate (0.83), Ash (2.34) | pre-placed stock; routes from the pY1 line's Petri dish assembler and Flask Glassworks found no path through the pY1 block |
| Fuel of the burner assemblers and the two void burners (wood, coke) | pre-placed; the void burners take chemical fuel only (not Meat) |

## 2. Bill of materials

### 2.1 Buildings (steady line, as built)

| Building | Count | Building | Count |
|---|---|---|---|
| Prandium lab MK01 | 2 | Reproductive complex MK01 | 2 (Auog pups, Cottongut pups) |
| Moondrop greenhouse MK01 | 3 (2 Moondrop, 1 CO2 for the moss farms) | Botanical nursery | 2 (Ralesia seeds, Moondrop seeds) |
| Ralesia plantation MK01 | 3 | Auog paddock MK01 | 1 |
| Slaughterhouse MK01 | 1 | Genetics lab MK01 | 1 (Animal samples; +1 for cDNA at start-up) |
| Research center MK01 | 1 | Incubator MK01 | 1 (Sarcorus; +1 for Biosamples at start-up) |
| Biofactory MK01 | 1 | Micro mine MK01 | 2 |
| Reformer MK01 | 1 | Heat exchanger (Py) | 1 |
| Vacuum pump MK01 | 1 | Compost plant MK01 | 1 |
| Fluidized bed reactor MK01 | 1 (Bonemeal) | Soil extractor MK01 | 4 |
| Assembling machine 1 (burner) | 6 (Rich clay, Ground, Alien, Bio samples, caged Auogs, Wood seeds) | Barreling machine | 3 |
| Moss farm MK01 + Washer | 4 + 1 | Electrolyzer MK01 + HPF | 3 + 1 (Hydrogen for Ralesia; Boron trioxide cell) |
| Glassworks MK01 | 1 (lenses) | Py burner (void) | 2 |
| Sinkhole + Overflow valve | 2 + 2 (Blood; the author's Creosote) | Gas vent | 1 |
| Offshore pump | 16 | Transport belt | ~1,240 |
| Underground belt | ~86 | Pipe / Pipe-to-ground | ~370 / ~52 |
| Burner inserter | ~106 | Small electric pole | ~95 |
| Wooden chest | 21 | Constant combinator | 1 |

Start-up only (can be picked up afterwards): Creature chamber MK01, 2 Data arrays, Genetics lab and
Incubator above, the food workshop (Washer, Electrolyzer, Pulp mill, Solid separator, Boiler,
Assembling machine).

Direct ingredients of the buildings above, summed (one recipe level; sub-buildings left as items):
small parts 2,186, iron plate 3,974, steel 702, titanium 755, glass 1,134, stone bricks 1,370,
duralumin 310, aluminium 210, electronic circuits 480, copper cable 295, inductors 138, concrete 200,
treated wood 150, plastic 60, intermetallics 51, soil 1,400, pipes 530, transport belts 430 (for
undergrounds), and as sub-buildings 77 steam engines, 14 stone furnaces, 10 offshore pumps, 8 burner
mining drills, 6 labs, 4 fluid drills, 4 storage tanks, 3 tar processing units, 2 distilators, 2
gasifiers, 2 boilers, 20 planter boxes, 76 small lamps.

### 2.2 Living modules (grown in place, not crafted)

| Module | Count | Grown from |
|---|---|---|
| Cottongut MK 01 | 28 (20 + 6 in the Prandium labs, 2 in the cub complex) | 3 from the Creature chamber (9 cDNA), raised and matured with ~50 Cottongut food |
| Ralesia | 36 (12 per plantation) | 6 from 3 Ralesia samples |
| Moondrop | 48 (16 per greenhouse) | the author's Moondrop |
| Auog | 6 (4 paddock, 2 complex) | the author's stock (35 found) |
| Moss | in the 4 Moss farms | the author's Moss |

Built so far: 25 Cottongut MK 01 (speed 1.2 of the 1.3 needed: 2 more to mature in Prandium lab 2).

### 2.3 Start-up consumables (one time, measured in game 3)

330 Biosamples (4,950 Native flora), 18 cDNA (54 Laboratory instruments = 270 Rubber, 81 lenses),
90 Moss gene samples (1,836 Moss), about 320 Petri dishes, 90 Flasks, 915 red packs, 19 Retroviruses
(76 Vrauk cocoons, 950 Hot air), Cottongut food chain (Fiberboard -> Starch -> ~50 food: 20 Fiberboard,
Raw fiber, Sodium hydroxide, Seaweed, Fish eggs). Full table of what was taken from the author's
production: [journal-3.md](journal-3.md#taken-from-the-authors-production-for-the-start-up).

### 2.4 Steady inputs at 0.05/s (per minute)

| Input | Rate | Source in this save |
|---|---|---|
| Batteries | 0.75 | battery line (belt) |
| Laboratory instruments | 0.58 | none automatic: 2.9 Rubber, 0.87 lenses (0.29 Boron trioxide = Borax), 0.58 chassis (0.29 FeNxSb, 2.9 Tin, 0.29 circuits), 1.45 small parts |
| Rubber's inputs | 2.9 Latex, 145 Polybutadiene (290 Aromatics, 1.45 Titanium), 5.8 Carbon black | the author's latex block makes about 2 Latex a minute (Stone-bound) and feeds pY1 too; Aromatics come from the author's tar block once its Creosote is voided |
| Petri dishes / Flasks / Basic substrate | 1 / 0.58 / 0.83 | pY1 line (to belt) |
| Ash | 2.34 | bus Ash belt (ends at y -297) or Coal gas -> Ash in an HPF |
| Urea / Liquid manure / Zogna | 0.63 / 4.2 / ~12 | battery line |
| Native flora / Moss | 25.7 / 12.3 | author's paddock belt (service belt) |
| Wood | 2.6 | author's wood belt (tap) |
| Steam | ~50 | pY1 steam branch |
| Water | ~1,810 | offshore pumps |

## 3. Hindsight: the best-coordinated way to build it

The order that would have saved most of the work, from what game 3 ran into:

1. **Survey the supplies first, starting from the deepest input.** Green is bound by Plasmids, i.e.
   Laboratory instruments, i.e. Rubber (Latex and Aromatics), lenses (Boron trioxide, i.e. Borax by
   train) and chassis (FeNxSb, circuits). Check each in the save before placing anything: here Aromatics
   stood because the author's tar block was blocked by Creosote (fixed with an Overflow valve and a
   Sinkhole), Latex is about 2 a minute and shared with pY1, Borax is not delivered anywhere. The other
   inputs (Batteries, Urea, Manure, Zogna, flora, Moss, wood, steam) were fine.
2. **Build the Laboratory instrument supply as its own block first** (Rubber from the tar chain and
   Latex, lenses from a Borax requester station, chassis and small parts from the supermarket), and
   start the Latex expansion: everything downstream waits on it, and the genetic start-up itself needs
   54 instruments.
3. **Put the line where its inputs are.** The core sat 100-200 tiles from the bus, the pY1 line and the
   battery line, so every input became a long belt through dense blocks (wood 175 tiles, urea 141,
   plasmids 135, export 69), and two (Flasks, Petri dishes) found no path at all. Better: next to the
   battery line and the pY1 line's Biofactory side, or leave a corridor from the bus to the site.
4. **Lay out every machine with its ports and free sides decided before building.** The Biosample
   assembler has 5 item inputs but one free side; the Barreling machine, the void burners and the
   second Micro mine ended boxed in. Direct insertion where one producer feeds one consumer; a sushi
   loop (read whole in *entire belt* mode, feeders gated by level) where several machines trade several
   items (the Cottongut cell); otherwise one item per lane.
5. **Genetic start-up in parallel with step 2**, then grow the living modules in this order:
   Ralesia (36, quick), Moondrop (48, needs 3 greenhouses and a nursery with an exit for its returned
   Moondrop), Cottongut (28: raise and mature first, only then switch to caged, the food chain is
   start-up only), Auogs (6).
6. **Then the 30-minute test**, with every Plasmid going to the Gene lab first (the incubator branch
   capped at 3 on its belt).

Engine facts learned (all measured in this game):

- A crafting machine stops when any product in its output reaches twice the recipe's amount; void
  inserters must start below that (Meat > 8, Guts > 3, Fat > 2, Skin > 2, Brain > 1 for one Auog).
- An inserter on a belt curve did not pick items on the curve's inner lane (Empty barrels at the loop's
  corner); take from a straight tile.
- The Py Barreling machine is a furnace holding every fill and empty recipe; it is fed fine from a
  machine or chest, and from a straight belt tile.
- Py void burners burn chemical fuel only (wood, coal, coke, biomass), not Meat; without fuel they stop
  voiding and the Slaughterhouse stops at the 2x rule.
- A nursery's returned products have no exit unless given one; the Moondrop pair deadlocked twice.
- Mixed lanes jam at a dead end (Native flora blocked the Ralesia seed lane at the Biosample assembler).

Estimated effort with this order: the Laboratory instrument block is about as large as the green line
itself; the line, laid out once, about half of what game 3 spent (which rebuilt the Cottongut area,
the seed belt, the barrel machine twice and the void thresholds twice).

## 4. What is left to make the test pass

1. Belt Flasks and Petri dishes from the pY1 line (a path around the pY1 block, e.g. through the free
   row y -377.5 from its west end) and Basic substrate off the red science belt's north lane.
2. Ash: Coal gas -> Ash in an HPF at the bus Coal gas pipe's end (-55.5,-438.5), onto the battery belt's
   free lane, off again at the Research center; or a belt from the bus Ash belt (x -94.5, y -297).
3. Fuel belts (wood) for the two void burners and the burner assemblers.
4. Mature 2 more Cottongut MK 01 (Prandium lab 2 to 6 modules).
5. Refill the Laboratory instrument buffer (the author's Rubber line now runs on Aromatics; Latex from
   the harvest chest at (-61.5,-357.5), 1,285 left) and rerun the 30 minutes.

## 5. The least living stock that starts the line, and what it costs

The user's verdict on game 3: the core problem was not automating every product from the start and
not working on a bus. The living stock below is what has to exist before any belt can run; everything
after it grows in its own machines. Recipes from the data dump (`tools/q.js`); totals solved by
`tools/rate-plan.js research/plans/green-startup-min.js`.

| Creature | Least | Why that many | Made by | Grown in place to |
|---|---|---|---|---|
| Ralesia | 6 | 5 make the first 8 Ralesia seeds in the nursery, 1 is the plantation's module | 3 Ralesia samples (Botanical nursery, 200 s: 3 cDNA, 5 Biosamples, 1 Ralesia codex, 1 Flower sample, 1 Planter box -> 2) | 36 (12 per plantation) |
| Cottongut MK 01 | 3 | the raising takes 2 as ingredients, the Prandium lab needs at least 1 as a module (no module, no speed) | Creature chamber, 300 s each: 5 Generic samples, 1 Mouse sample, 5 Biosamples, 3 cDNA, 1 Cottongut codex | 28 (20 + 6 lab modules, 2 cub complex) |
| Moondrop | 6 (8 made) | 1 greenhouse module + 5 for the first seed craft; a sample gives 4 | 2 Moondrop samples (nursery, 200 s: 1 Moondrop codex, 2 Petri dishes, 1 Planter box), no cDNA | 48 (16 per greenhouse) |
| Auog | 2 | one module each for the Reproductive complex and the paddock | Creature chamber, 300 s each: 2 Generic samples, 5 Biosamples, 3 cDNA, 1 Auog codex, 1 Bear sample | 6 |
| Moss | 1 per Moss farm | farm module | the author's Moss | 4 farms |

Plain Cottongut pups for the first caged batch (7) come from the raising at 0.5 a craft: 14 raisings.
Growing Cottongut MK 01 from 3 to 28 then takes 32 maturings. Together: **46 Cottongut food**, 140
Seaweed, 28 Fish eggs, 32 Wood, 96 Moondrop (from the greenhouses).

Intermediates of that stock (counts): 24 cDNA (each: 3 Laboratory instruments, 1 Retrovirus, 1 Plasmid),
72 Laboratory instruments, 430 Biosamples (430 Bio containers), 120 Moss gene samples, 24 Retroviruses,
24 Plasmids, 27 Generic earth samples, 3 Mouse, 3 Flower, 2 Bear samples, 26 codices, 431 Petri dishes
(163 incubated), 60 Flasks, 46 Starch (15 Fiberboard, 15 powdered Ralesia seeds).

Raw totals (one-time):

| Raw input | Amount | Raw input | Amount |
|---|---|---|---|
| Steam | 44,270 | Molten glass | 31,160 |
| Water | 10,000 | Native flora | 6,450 |
| Moss | 2,448 | Seaweed | 2,214 (+140 raising) |
| Red science packs | 1,205 | Hot air | 1,200 |
| Tin plate | 903 | Titanium plate | 860 |
| Copper plate | 820 | Simple circuit boards | 756 |
| Glass | 722 | Zogna bacteria | 480 |
| Steel | 454 | Lead plate | 430 |
| Rubber | 360 | Ralesia seeds | 253 |
| Rubber stoppers | 240 | Small parts | 180 |
| Iron plate | 120 | Hollow inductors | 100 |
| Vrauk cocoons | 96 | Wood seeds | 58 |
| FeNxSb alloy | 36 | Boron trioxide | 36 |
| Cellulose | 29 | Iron chests | 27 |
| Soil | 25 | Fiberboard | 15 |
| Ash | 15 | Empty planter boxes | 5 |

The deepest of these are the same as for the steady line: Rubber (360: Latex + Aromatics), Boron
trioxide (36: Borax), FeNxSb (36) and the Petri dish/Flask glass chain (31,160 Molten glass). They are
the blocks to automate first; the genetics then take a few hours of machine time (Creature chamber and
sample recipes are 200-300 s each).
