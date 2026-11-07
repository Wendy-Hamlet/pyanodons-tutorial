# Agent play journal, game 3

Claude playing on in a copy of the author's Py-Exploration save (seed 2652821414) from game time
52:03 (the author's save of 2026-11-02 11:07), with [tools/agent](../../tools/agent/README.md)
(`setup.ps1 -Mirror`: the author's exact mods; the agent takes over the author's place and
inventory). Times are game time. Earlier games: [journal.md](journal.md), [journal-2.md](journal-2.md).

## Rules

Everything through the character's inventory, nothing created, `eval` only reads. The user's task
(2026-11-06): **a green science line of 0.05 Logistic science packs a second near the bus**; the
battery line (chapter 17) may be reused; goods move by belt, as little chest-to-chest carrying as
possible. One-time start-up stock (the first Cottongut and Ralesia, made from genetic samples) is
handled by the character; every steady flow goes by belt, pipe or direct insertion.

## Goals

- **Long-term:** 3 Logistic science packs a minute (0.05/s), every input belted.
- **Short-term, in order:**
  1. Research Logistic science pack (300 units of 2 red + 1 pY1, 45 s each); queued first at 52:03.
  2. Bio samples (Incubator: Bio container + 15 Native flora) for the genetic start-up.
  3. cDNA (Genetics lab), then the data array samples, then 3 Ralesia samples (6 Ralesia) and
     3 Cottongut MK 01 from the Creature chamber.
  4. Ralesia plantations and the Cottongut breeding up to their module counts.
  5. The steady line: Auog breeding and slaughter, Animal samples, Bio and Alien samples,
     Solidified sarcorus, the Research center.

## The plan (steady state, `research/plans/green-science.js`, data)

Logistic science pack (Research center MK 01, 90 s): 2 Alien samples + 1 Solidified sarcorus +
2 Animal samples + 3 Batteries -> 12. At 3 a minute, per minute:

| Need | How | Machines |
|---|---|---|
| 0.5 Alien sample | 4 Bio samples + 15 Ground samples -> 4 (assembler) | 1 |
| 0.5 Bio sample | 18 Ralesia seeds, 10 Bonemeal, 2 Incubated petri dishes, 12 Native flora, 5 Urea -> 4 | 1 |
| 1.9 Ground sample | 5 Rich clay (Ash + Water) + 10 Soil -> 10 | 2 + Soil extractor |
| 0.5 Animal sample | 5 Bones, 7 Meat, 3 Skin, 1 Fat, 3 Guts, 3 Brain, 1 Plasmids, 50 Blood (Genetics lab) | 1 |
| 1.67 Auogs rendered | brain-bound (1 Brain an Auog); bones 3 each = exactly the 5 Bones needed | Slaughterhouse, Auog paddock (4 Auogs), Reproductive complex (2 Auogs) |
| 0.25 Solidified sarcorus | 10 Fawogae substrate, 5 Native flora, 1 Plasmids, 50 Depolymerized organics, 20 Cottongut -> 3 (Incubator) | 1 |
| 3.1 Cottongut | 7 pups -> 6 (Prandium lab, 150 s), 4 Cottongut -> 10 pups (Reproductive complex) | 2 labs with 26 Cottongut MK 01 as modules |
| 18.6 Ralesia seeds | Ralesia plantation (12 Ralesia as modules) + Botanical nursery | 3 + 1 |
| 5.8 Moondrop | Moondrop greenhouse, 16 Moondrop as modules | 2 |
| 0.58 Plasmids | Zogna bacteria, Incubated petri dish, Flask, Lab instrument (Biofactory) | 1 |
| 4.2 Depolymerized organics | Liquid manure + Subcritical water (Reformer); Subcritical water from Pressured water + Biomass (Heat exchanger) | 1 + 1 + Vacuum pump |
| 25.7 Native flora, 12.3 Moss | mostly for the Auog breeding | flora collectors, a Moss farm |

From the battery line: 0.75 Batteries, 0.63 Urea, 4.2 Liquid manure, 11.7 Zogna bacteria a minute.
Spare from the Auogs: 142 Blood, 9.8 Meat, 3.5 Guts, 2.8 Fat, 1.8 Skin a minute (to be voided or
composted).

## Timeline

| Game time | What I did |
|---|---|
| 52:03 | Took over (character at the Borax outpost, 1924,271). Research: Logistic science pack first, then the author's queue. |
| 52:08–52:20 | Site chosen east of the battery line (x 10..90, y -466..-378): beside the Batteries, Urea, Liquid manure, Zogna bacteria and the red science belt (y -376.5). Start-up bill (`research/plans/green-startup.js`): 3 Cottongut MK 01 + 6 Ralesia take 330 Biosamples (4,950 Native flora), 18 cDNA (54 Laboratory instruments: 270 Rubber, 81 Optical sets), 90 Moss gene samples (1,836 Moss), ~320 Petri dishes, 90 Flasks, 915 red packs. Collected from output-full machines and stores: Glass, Titanium, Moss (modules), Plastic, Empty petri dishes, Lead, Steel, Duralumin. |
| 52:20–52:30 | **Service belt**: the paddock belt (y -416.5; north lane Moss, south lane Native flora) extended east from x -17.5 to 75.5. **Moss block** south of it (`designs/g3-moss.js`): 4 Moss farms on Moss-1 (sludge + CO2, no Stone), the author's interleaved two-fluid piping under them, Washer fed by a Soil extractor, a Moondrop greenhouse for CO2 (had to face west: its active output is the east port when facing north). |
| 52:30–52:40 | **Start-up workshop** (`designs/g3-workshop.js`, `g3-plasmid.js`): 2 Incubators (Biosamples, flora off the belt, 2 inserters each), Gene lab (Moss gene samples, moss off the belt), Data array beside the red belt, Biofactory for Plasmids with a Zogna branch from the battery line, Micro mine. Petri dish harvest chests on the pY1 line's two output-full Petri dish assemblers. Found the author's chapter-16 workshop in the character's trash slots (Creature chamber, Gene lab, Biofactory, Incubator, Data array, 2 Botanical nurseries, Reproductive complex, 3 paddocks, 3 Moss farms, 35 Auogs, 15 Boron trioxide, 27 Optical sets, 3 Laboratory instruments); new agent op `untrash`. Second Data array (Mouse samples) and Gene lab (cDNA) placed. |
| 52:40–52:53 | **Auog block** (`designs/g3-auog.js`) south of the belt's east end: Reproductive complex (2 Auogs) for pups, paddock (4 Auogs), two Barreling machines with their own Offshore pumps, caging assembler, Slaughterhouse, Fluidised bed reactor for Bonemeal; spare parts voided in two Py burners by inserters that each whitelist one part and run only while the Slaughterhouse holds more than 30 of it (new agent ops `wire`, `read_contents`, `cb`, `decider`). **Lens Glassworks** west of the bus (`designs/g3-lens.js`): Molten glass and Gasoline (fuel) branched off the bus pipes. |
| 52:53 | **Logistic science pack researched.** Research then cancelled (the author's queue: wind-mk01, tidal-mk01, fish-upgrade, heavy-armor, military-2, physical-projectile-damage-1) so that red packs and the pY1 line's supplies go to the start-up. |
| 52:53–53:20 | Harvest chests on the pY1 line (Petri dishes ×2, Latex, Flasks, Basic substrate); the inserter feeding Latex to the Stopper assembler disabled by a circuit condition, so all 6 Latex a minute go to the author's chapter-16 Rubber line (Latex into its chest by hand). Retrovirus Incubator beside the Hot air block (-65.5,255.5), 72 Vrauk cocoons from the paddocks. Second Micro mine. Botanical nursery (Ralesia samples) and Creature chamber (Cottongut MK 01) with Offshore pumps. 90 Moss gene samples and 326 Biosamples done; Generic, Flower samples running. Game speed 3 (170 UPS). |

| 53:20–55:14 | Latex runs, Rubber line restarted twice: its Carbon black chest and its cracker's Titanium chest are hand-filled (the author's design; a Reformer output and the inserter-fed refinery). 36 Laboratory instruments so far (lens: the 27 found + 45 from the 15 Boron trioxide, now all used). 18 Retroviruses, ~17 Plasmids, 12 cDNA. 3 Ralesia samples -> **6 Ralesia** (55:05). **Ralesia block** (`designs/g3-ralesia.js`): 3 plantations on a two-lane loop (seeds north lane, Soil south lane), seed nursery, own Soil extractor, an Electrolyzer for Hydrogen (oxygen vented); 1 Ralesia as a module in the most upstream plantation, 5 into the nursery. Stopper inserter restored (Latex in surplus: 180 waiting). 1,800 Borax fetched from the author's Borax outpost for a Boron trioxide cell. Paused at 55:14 for the quota. |

| 55:14–55:30 | **Boron trioxide cell** (`designs/g3-boron.js`): Diborane Electrolyzer on the ralesia Hydrogen (under the oxygen vent), Boric acid Electrolyzer, HPF; 2 Boron trioxide -> 6 lens -> 4 Laboratory instruments. Creature chamber started with 8 cDNA (2 Cottongut MK 01 on the way); the 9th cDNA needs 1 Coke more (no Coke in any chest: all of it is on belts; the battery line's Graphite HPF input refills from the bus). Paused at 55:30 for the quota (77 %). |

| 55:22–55:35 | New agent op `take_belt` (pick items off belts by hand); 6 Coke off the bus belt -> 6 Boron trioxide -> 18 lens -> 6 Laboratory instruments; the last Retrovirus and the 9th cDNA: the Creature chamber has all 9 (2 Cottongut MK 01 out by 55:30). Ralesia loop fixed: the Soil extractor drops behind itself (a west-facing one drops east), turned to face east; the most upstream plantation runs with 1 module. Prandium lab placed at (94,-460). Harvesters for Petri dishes and Flasks removed. 30 Fish eggs and 97 Wood seeds collected. Paused 55:35 (quota 86 %). |

| 55:35–55:50 | Temporary **food workshop** at x 101..125, y -447..-433: Washer (Saline water) -> Electrolyzer (Chlorine recipe: Sodium hydroxide; Chlorine and Hydrogen vented) -> Pulp mill (Fiberboard), Boiler, Assembling machine for Cottongut food, Solid separator for Starch. Py Steam is dear: 494 kJ a unit (water heat capacity 2.1 kJ/°C, 15->250 °C), 34 Raw coal gave ~200 Steam; the Boiler burns the stashed Logs now. First 4 Fiberboard. Stopped at quota 97 % (threshold 98 %). |

| 56:00–57:55 | User: build materials and inputs come from the bus, made on the spot only when made from nothing or Water. Coke for the food Boiler picked off the bus Coke belt (794, far more than needed: `take_belt` r=10 takes every belt in reach; kept for Boron trioxide and fuel). 12 Fiberboard. **Core part 1** (`designs/g3-core.js`, x 105..131, y -397..-385): Soil extractor drops into the Ground sample assembler, Rich clay -> Ground samples -> Alien samples <- Biosamples, Alien samples -> Research center -> chest. **Animal sample Gene lab** beside the Slaughterhouse (the free Moss gene lab moved), Blood by the 3-pipe link, spare Blood over the Overflow valve into a Sinkhole (valve and sinkhole had to be turned). Paddock moved 1 tile west: the 22x22 Reproductive complex left a 2-tile gap no inserter spans. Void thresholds lowered to 12/6/4/5/4: a Slaughterhouse stops at ~26 Meat in its output, so the first 30s never triggered. **Sarcorus branch** (`designs/g3-sarcorus.js`): service belt on to x 125.5, Compost plant (flora -> Biomass), Heat exchanger (built from the author's Gearboxes and stores: Mechanical parts need an assembler; 6 Quartz ore hand-mined at (1545,45)), Vacuum pump, Reformer, Incubator. New `route.js` (belt/pipe routing over the live map): Subcritical water pipe, Liquid manure pipe from the battery line's free bioreactor outlet (-7.5,-394.5, 156 pipes), Animal sample belt (46), Steam pipe from the pY1 steam branch (-33.5,-387.5) behind a Check valve to the Bonemeal reactor (151). Mistake: the first steam route jumped its pipe-to-ground over the manure line's, they paired and the steam line's tail filled with Liquid manure (the Check valve kept it off the bus); fixed, and route.js now never jumps over an underground and checks the ends too. Ralesia: N2's input inserter held by an empty Constant combinator (a condition needs a network), crops moved into modules by hand: 12 + 12 + 7. |

| 57:55–59:05 | All 36 Ralesia modules in (12 per plantation); nursery back on automatic, surplus seeds pass the plantations first and leave at the loop end: **seed belt** (route.js, 114 tiles) from there to the Biosample assembler, with a Native flora inserter (filter) where it crosses the service belt. **Battery belt** (172) from the battery line's chest to the Research center. Tin off the bus tin belt (x -77.5), iron off the iron belt (twice). Food: 9 powder -> 27 Starch -> 32 Cottongut food in all. **Cottongut growth**: Prandium lab 1 (94,-460) raising (1 module) gave 2 MK 01 back and 5 pups MK 01; matured with 3 then 6 modules (MK 01 go into the module slots through a recipe switch: inserting puts them in the input); 8 MK 01 at 59:03, second raising running. Prandium lab 2 (106,-460) placed for later. **Moondrop pair** (greenhouse with 16 Moondrop + nursery, 113..132 x -467..-458): a pair exports at most 1.76 Moondrop a greenhouse craft and must shed spare seeds, so the steady line needs about 3 greenhouses and 2 nurseries; it stalled once when I took its Moondrop. Still hand-fed: Plasmids (Laboratory instruments), Bonemeal, Incubated petri dishes and Urea for the Biosample assembler (no free inserter sides; Urea is all used by the battery line), Basic substrate, Cottongut. |

| 59:05–60:35 | Cottongut grown to **22 Cottongut MK 01** (20 as Prandium lab 1 modules, speed 1.0; 2 as the cub complex's modules) with 37 pups MK 01 in stock; Cottongut pups came only at the raising's 50 %: 7 took 15 raisings. Food: 8 more Fiberboard, 24 + 16 food; the food Boiler burns Logs and Wood now (the bus Coke belt near the north end was emptied by my 794 pick). **First Cottongut** at 60:20 (caged, 7 pups -> 6); a second Reproductive complex (cottongut-cub-1, 4 Cottongut -> 10 pups) at (161,-419), the free 22x22 near PL1 being the author's rail line at y -469; the loop runs by hand (pups and Cottongut carried between the two). Urea harvest chest on the battery line's urea bioreactor (-6.5,-395.5): urea there is manure-bound. New: `insert inv=modules`. Paused 60:35 for the quota. |

| 60:35–64:02 | User (2026-11-07): raw material belts from the bus, by-products back to the bus or voided. Seed belt fixed: Soil leaked onto it at the loop exit (a filter inserter now takes only seeds) and Native flora shared the seed lane and blocked it at the Biosample assembler (flora now side-loaded onto the other lane). Food workshop removed; **Cottongut cell** (`designs/g3-cottongut.js`): the Reproductive complex moved under the two Prandium labs and a sushi loop between them (56 tiles, read whole by one belt in *entire belt* mode): pups < 21, Cottongut < 24, Moondrop < 16, Ralesia seeds < 30 gate the feeding inserters; Cottongut leaves for the Sarcorus incubator only above 12 (export belt 69 tiles). Moondrop pair deadlocked twice (the nursery got under 5 Moondrop: its returns had no exit and the loop feeder took the greenhouse output): 3 greenhouse->nursery inserters against 1 feeder, a filtered nursery output to the loop, and a **second greenhouse** east of the nursery (speed 3.0 with 16 Moondrop). Slaughterhouse stopped with Fat 4, Guts 6, Cages 2 in its output (a crafter stops at twice a product's amount): void thresholds lowered to 1x (Meat 8, Guts 3, Fat 2, Skin 2, Brain 1), 2 spare Cages removed. **Barreling machine** (a furnace with every fill and empty recipe): an inserter on a belt curve never picked the Empty barrels (all on the inner lane), so the loop's east end was lengthened and the machine takes them from a straight tile. Belts: bonemeal (FBR -> Biosample assembler), plasmids (Biofactory -> Gene lab, 62; Biofactory -> Sarcorus incubator with a Basic substrate lane, 135), urea + Incubated petri dishes (the battery line's urea reactor, then Micro mine 1, -> Biosample assembler, 141), Native flora (service belt extension -> Sarcorus incubator), Incubated petri dishes (Micro mine 2 -> Biofactory), **wood** (tapped off the author's backed-up wood belt at x -60.5, 175 tiles) -> Wood seed assembler -> both Prandium labs. 4 Laboratory instruments from 20 Rubber + 60 lenses (20 Boron trioxide). Found: the author's Latex harvest chest holds 1,375 Latex, but Rubber needs Polybutadiene, i.e. Aromatics, whose only maker (light-oil-aromatics at (-135,-115)) stands for want of fluid. route.js: belt undergrounds may now cross pipe undergrounds. act.lua: `clear own=true` fixed. |

Next: Stone for the Washer, 2 more Fiberboard crafts, then the rest of the Cottongut food chain (Fiberboard in a Pulp mill: Treated wood, Raw fiber, Sodium hydroxide,
Steam; Powdered Ralesia seeds; Starch in a Solid separator; food in an Assembling machine 1), then the
first raising (1 Cottongut MK 01 as a module, 2 as ingredients, Seaweed, Fish eggs, food).

## Taken from the author's production for the start-up

Counted from the `take` results of the session (52:03-55:25); the user asked for this list. "Used" is
what the start-up needed; the rest is still in the character's inventory at 55:25.

| Item | Taken | From | Needed by the start-up | Left over |
|---|---|---|---|---|
| Glass | 894 | 3 output-full Glassworks (-56.5,-382.5), (-50.5,-239.5), (-133.5,-334.5), three visits | 330 Bio containers, machines (Incubator, Gene lab, Biofactory, Data array, plantations 3x100, lamps) | 24 |
| Titanium plate | 668 | output-full titanium furnaces (y 444) | 660 Bio containers, machines, 120 to the Rubber line's cracker | 136 |
| Moss | 332 | 8 output-full Moss farms (-14..-38, -116/-125) | 60 as Moss farm modules | 272 |
| Empty petri dish | 200 | 2 output-full Glassworks | (not used) | 200 |
| Seaweed | 100 | 2 output-full Seaweed crops | (not used yet: Cottongut food) | 100 |
| Plastic bar | 100 | output-full Biofactory (-173.5,41.5) | 20 Gene lab | 80 |
| Carbon black | 607 | Reformer output of the Rubber line, carried to its chest | ~300 Rubber | in the Rubber line |
| Coke | 8 | Graphite HPF input (2), bus Coke belt (6, `take_belt`) | 9 Boron trioxide | 0 |
| Vrauk cocoon | 76 | inputs of the 8 Vrauk paddocks | 19 Retroviruses | 0 |
| Empty planter box | 2 | red science line | 3 Planter boxes | 0 |
| Copper plate | 800 | store (-68.5,12.5) | cables, lamps | 424 |
| Lead plate | 800 | store (-129.5,-71.5), twice | 330 Bio containers | 348 |
| Steel plate | 500 | store (-8.5,-96.5) | Bio containers, machines | 416 |
| Duralumin | 200 | store (-129.5,-284.5) | machines | 32 |
| Electronic circuit | 300 | store (-11.5,-234.5) | plantations, machines (600 more came from the author's inventory for 12 codices) | 234 |
| Treated wood | 150 | store (-48.5,-208.5) | 3 Ralesia plantations | 0 |
| Borax | 1,800 | the Borax outpost's chests (2078.5,408.5) | Boron trioxide (10 a Diborane craft) | 1,648 |
| Latex | 430 | harvest chest on the pY1 Latex HPF (its Stopper inserter disabled 52:58-54:55) | ~300 Rubber | 95 in the Rubber line's chest |
| Flask | 342 | harvest chest on the pY1 Flask Glassworks | ~90 (cDNA, Retroviruses, Plasmids) | 214 |
| Petri dish | 965 | harvest chests on the two pY1 Petri dish assemblers | ~320 | 408 (+302 Incubated) |
| Basic substrate | 1,138 | harvest chest on the pY1 substrate assembler (left running too long) | 72 | 1,066 |
| Red science pack | ~1,050 | lab belt (y -376.5) by the Data arrays' inserters | 915 | ~135 in the Data arrays |
| Native flora | ~5,000 | the paddock belt (service belt) | 4,950 for 330 Biosamples | - |
| Zogna bacteria | ~350 | battery line pipe | 18 Plasmids | - |
| Hot air | ~950 | Hot air block pipe | 19 Retroviruses | - |

Over-harvested: Petri dishes, Basic substrate, Flasks and the Empty petri dishes (harvest chests ran
unattended while the research was paused). The harvesters for Petri dishes and Flasks were removed at
55:25; the Latex one stays for the Rubber the steady line needs. Still to take for the start-up:
the Cottongut food chain (~12 Treated wood, ~20 Raw fiber, ~12 Sodium hydroxide for Fiberboard,
~70 Moondrop, ~30 Fish eggs, ~40 Wood seeds).

## Where it stands (64:02)

- All parts in place; the first Solidified sarcorus waits for 2 more Cottongut; the Research center holds 4 Animal samples, 4 Alien samples, 6 Batteries.
- **Limit: Plasmids.** Every Plasmid takes a Laboratory instrument (10 Rubber per 2); Rubber needs Polybutadiene (Aromatics, none made now). The 4 instruments made are the whole supply: about 6 Animal samples, 36 packs, unless a Rubber supply is built.
- Still hand-fed or stock: Laboratory instruments; Petri dishes for the Micro mines (pY1 line taps planned); Flasks (Biofactory has 27); Basic substrate (chest of 120 on the incubator belt; the red science belt carries the author's substrate on its north lane); Ash for Rich clay (stock 100).
- Green packs go to a chest; a belt to the author's labs (east side of lab (-11.5,-370.5), ~135 tiles) is still to build. Research is cancelled since 52:53 (author's queue to restore).

## Where it stood (55:30)

- Next: 1 Coke -> 1 Boron trioxide -> 3 lens -> 2 Laboratory instruments: 1 to the Retrovirus
  Incubator (-65.5,255.5), 1 to the cDNA Gene lab with that Retrovirus and the Plasmid the
  Biofactory is making -> 9th cDNA -> Creature chamber (3rd Cottongut MK 01).

## Where it stood (55:14)

- Ralesia: loop started with 1 module; grow by moving Ralesia into module slots (12 per plantation).
- Cottongut: Creature chamber has 2 of the 9 cDNA it needs (3 crafts for 3 Cottongut MK 01); cDNA
  Gene lab holds Retroviruses, Plasmids, 5 Laboratory instruments: 3 Instruments short in all ->
  2 Boron trioxide (Diborane, Boric acid electrolyzers + HPF; Borax in the inventory, Hydrogen from
  the ralesia Electrolyzer), lens Glassworks at the bus.
- Then the Cottongut food chain (Fiberboard -> Starch -> Cottongut food) and the raising.
- Steady state still to build: the core (Research center, Alien/Bio/Ground samples, Rich clay,
  Solidified sarcorus incubator, Reformer + Heat exchanger + Vacuum pump), the Gene lab for Animal
  samples beside the Slaughterhouse, Battery belt, and a permanent Laboratory instrument supply
  (Latex -> Rubber, Boron trioxide -> lens).

## Where it stood (53:20)

- Critical path: Latex (6/min) -> Rubber -> Laboratory instruments (need 54, have 5) -> Retroviruses (3 of 18), Plasmids, cDNA (18) -> 3 Ralesia samples + 3 Cottongut MK 01.
- Then: Ralesia plantations (3, each 300 Soil, 50 Treated wood, 100 Glass), a food chain for the Cottongut start (Fiberboard -> Starch -> Cottongut food, ~35 food), Cottongut MK 01 grown from 3 to 26 by raising and maturing, then the steady line.
- To restore later: the Stopper inserter at (-53.5,-359.5) (clear its circuit condition), the research queue, the harvest chests.
