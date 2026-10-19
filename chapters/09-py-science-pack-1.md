# Chapter 9 — pY science pack 1

[中文版](09-py-science-pack-1.zh-CN.md) · [Index](../README.md) · Previous:
[chapter 8](08-vrauks.md)

This chapter follows the same recorded run from the save of 21:35 to the save of 23:31, and the
author's fixes up to the save of 23:40. Its goal is the author's: **pY science pack 1 at 0.1 a second**, the Factory Planner factory "pY科技包1型" (6 a
minute). The Vrauk line of chapter 8 gives the Formic acid; around it the author built the latex
chain (Seaweed, Sodium alginate, Creamy latex, Latex slabs, Latex), Rubber stoppers and Glassware,
the Research center MK 01 that makes the pack, and moved the labs beside it. Research started again
at 21:55 with Burner, the first technology since 13:36. The author exported the whole line as a
blueprint, `py-science-pack-1`, together with the copper block of chapter 7 (`copper-screening`).
Times are game time. Numbers come from the game's data, from the recorder's 10-minute production
windows, from the save of 23:31 (`tools/inspect-save.ps1`), from two-hour runs of that save
(`tools/rate-probe`), from the blueprint bench (`tools/bp-bench.ps1`) and from the author's Factory
Planner plan (`tools/planner-summary.js`).

The result: every machine of the chain is in place, and the Vrauk line runs at full output, 3 Vrauks
a minute, which is exactly what 0.1 packs a second need: a pack costs half a Vrauk. In the last
recorder window before the save the chain made 0.070 packs a second. But **the Basic substrate does
not reach the Research center**: its belt ends one tile before the machine, and the center took its
substrate from a chest filled by hand. In a copy of the save it makes 6 packs and stops, and within
15 minutes everything behind it is backed up as far as the Slaughterhouse. With one inserter added
at (−36.5, −376.5), the line makes **0.100 packs a second**, and its Molten glass burns up the
Syngas, as the author expected: the boards hold 0.1. But then the whole base runs, burning twice
the Raw coal and making twice the Ash, and **after 40 minutes the Ash takes the power down**: the
Soot separator cannot put its Ash out, the Ash separators cannot put their Soot out, the Boilers
fill with Ash, and at 60 minutes the base has no electricity left (section 7).

The author then fixed the substrate, gave the by-products a Burner and changed how the Soot
separator's Ash joins the Ash belt (23:31–23:40), expecting the Ash handling may not be complete
yet. Measured on the save of 23:40, the pack line runs by itself, but the power still fails, at 40
to 60 minutes: the Ash loop has one way off, too small for twice the Ash (section 7).

## The run at a glance

| Game time | What happened |
|---|---|
| 21:35–21:45 | Three more Seaweed crop facilities MK 01 at y −334.5 (x −46.5 to −20.5); a High pressure furnace for Sodium alginate at (−56.5, −341.5), a Jaw crusher for its Stone at (−56.5, −333.5) and a Soil extractor for its Limestone at (−56.5, −348.5); an Offshore pump at (−21.5, −341.5) |
| 21:45–21:55 | Four Sap extractors MK 01 at y −345.5 (x −35.5 to −20.5), a Washer for Creamy latex at (−48, −346) and a second Soil extractor at (−41.5, −346.5); a Destructive distillation column for Latex slabs at (−48, −355) and a High pressure furnace for Latex at (−56.5, −355.5); the Slaughterhouse MK 01 of chapter 8 placed at (−31.5, −354.5) |
| 21:55 | Research starts again: Burner (50 units, each 1 pY science pack 1 + 2 Automation science packs, 45 s) |
| 21:55–22:05 | An assembler for Rubber stoppers at (−52.5, −361.5); their Coal from Wood: a Wood processing unit MK 01 at (−57, −362) and a Destructive distillation column on Coal gas from wood at (−46, −363); a Glassworks for Glassware at (−56.5, −373.5) |
| 22:05–22:20 | The Research center MK 01 at (−42, −372) and an assembler for Caged vrauks at (−23.5, −358.5); the six labs beside the old science corner (y −173.5 and −167.5) taken up; about 790 tiles of belt: the Basic substrate and the red science run east, north along x 48 and back west along y −376 |
| 22:15–23:35 | Labs placed, moved and placed again: five in the end, at x −16.5 and −11.5, y −370.5 to −358.5 |
| 22:20–22:30 | Pipes: Naphthalene oil from the pipe of chapter 8 north to the Glassware Glassworks, cut by a Check valve at (−117.5, −272.5); the Wood column's Coal gas and Tar south (a Check valve at (−102.5, −74.5) on the Coal gas) |
| 22:30–22:35 | Eight chests of Ash at y 285 to 312 (x −32.5 to −17.5) taken away with their inserters |
| 22:35 | One Cage handcrafted |
| 22:40 | A fourth Destructive distillation column cracking Anthracene oil at (−168, −139) (50 Anthracene oil → 20 Gasoline + 5 Coke, 4 s; data) |
| 22:50 | Ten more Boilers at y −260 (x −159.5 to −132.5) beside the ten Coke Boilers of chapter 6, built by robots with their fuel belt; an Offshore pump moved from (−161.5, −256.5) to (−129.5, −256.5) |
| 23:05–23:15 | The Concrete corner beside the acetylene block laid one tile west (Sinkhole, Jaw crusher) |
| 23:31 | The save: 48 packs made since 21:35, Burner at 75 % |
| 23:33 | Burner researched; Quartz processing - Stage 1 next |
| 23:31–23:40 | The author's fixes: the substrate inserter at (−36.5, −376.5) and the substrate chest taken away (section 5); the four by-product chests replaced by one chest and one Burner at (−35.5, −362.5), whose Ash goes by a new belt along y −359.5 and x −94.5 into the Ash line at a Splitter at (−95, −251.5) (section 3); the Soot separator's Ash put onto the Ash belt at x −92.5 by an inserter at (−91.5, 370.5) instead of a side-load, and a Splitter at (−92, 383.5) where a second Ash belt joins it (section 7) |
| 23:40 | The save (end of the chapter); the line exported again |

Production per second (10-minute windows from the recorder):

| Window ending | Vrauks | Caged vrauks | Formic acid | Sodium alginate | Latex | Rubber stoppers | Glassware | Basic substrate | pY science pack 1 | Boards |
|---|---|---|---|---|---|---|---|---|---|---|
| 21:40 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0.105 |
| 22:00 | 0.003 | 0 | 0 | 0.048 | 0 | 0 | 0 | 0 | 0 | 0.045 |
| 22:20 | 0.003 | 0 | 0 | 0 | 0 | 0 | 0 | 0.783 | 0 | 0.070 |
| 22:40 | 0.010 | 0 | 0 | 0 | 0 | 0 | 0 | 0.283 | 0 | 0.110 |
| 23:00 | 0.017 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0.120 |
| 23:20 | 0.037 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0.130 |
| 23:30 | 0.053 | 0.042 | 8.0 | 0.077 | 0.077 | 0.147 | 0.073 | 0 | 0.070 | 0.075 |

Until 23:20 every new Vrauk went back into the line as a module, as chapter 8 expected; at the save
all 84 slots are full, and in the last window the Vrauks went to the Slaughterhouse. The Basic
substrate assembler of chapter 8 stopped after 22:40 because nothing took its product off the belt.

## 1. From Vrauk to pack

pY science pack 1 has a short recipe and a long chain behind each of its two ingredients (data;
English names from the mods):

| Step | Machine in the author's line | Recipe (data) | Machines for 0.1 packs/s |
|---|---|---|---|
| pY science pack 1 | Research center MK 01 (−42, −372), speed 1 | 18 Basic substrate + 3 Glassware → 3, 15 s | 0.5 |
| Glassware | Glassworks MK 01 (−56.5, −373.5) | 4 Rubber stoppers + 100 Molten glass → 2, 3 s | 0.15 |
| Rubber stoppers | Burner assembler (−52.5, −361.5) | 2 Latex + 5 Coal → 4, 5 s | 0.25 |
| Coal | Destructive distillation column (−46, −363), Wood from a Wood processing unit (−57, −362) | 10 Wood → 10 Coal + 10 Coal gas + 30 Tar + 1 Iron oxide, 3 s | 0.08 |
| Latex | High pressure furnace (−56.5, −355.5) | 1 Latex slab + 150 Steam → 1, 10 s | **1.0** |
| Latex slab | Destructive distillation column (−48, −355) | 1 Sodium alginate + 100 Creamy latex + 100 Formic acid → 1, 5 s | 0.5 |
| Formic acid | Slaughterhouse MK 01 (−31.5, −354.5) | 1 Caged vrauk → 200 Formic acid + 2 Meat + 2 Guts + 1 Chitin + 1 Brain + 1 Cage, 10 s | 0.5 |
| Caged vrauk | Burner assembler (−23.5, −358.5) | 1 Vrauks + 1 Cage → 1, 0.5 s | 0.03 |
| Vrauks | The Vrauk line (chapter 8) | 3 a minute at full output | **all of it** |
| Creamy latex | Washer (−48, −346) | 2 Saps + 2 Limestone + 100 Water → 100, 8 s | 0.8 |
| Saps | 4 Sap extractors MK 01 at y −345.5, 2 Sap trees each (speed 1) | → 4, 80 s | 4 |
| Sodium alginate | High pressure furnace (−56.5, −341.5) | 5 Seaweed + 5 Stone + 100 Water + 4 Limestone → 1, 5 s | 0.5 |
| Seaweed | 3 Seaweed crop facilities MK 01 at y −334.5, 10 Seaweed each (speed 1) | 200 Water → 10, 50 s | 2.5 |
| Stone | Jaw crusher (−56.5, −333.5) | 4 Stone bricks → 8, 5 s | 0.3 |
| Limestone | 2 Soil extractors (−56.5, −348.5) and (−41.5, −346.5) | 400 Water → 8, 20 s | 1.5 |
| Basic substrate | Burner assembler (−13.5, −285.5), chapter 8 | 5 Moss + 2 Incubated petri dishes + 3 Cellulose → 10, 3.5 s | 0.2 |

**One pack costs half a Vrauk.** Per pack: 1 Glassware, 2 Rubber stoppers, 1 Latex, 1 Latex slab,
100 Formic acid, which is half a Caged vrauk. 0.1 packs a second therefore need 0.05 Vrauks a
second, 3 a minute: the whole output of the chapter 8 line, with no margin. The Latex furnace is the
other step that works all the time (one Latex per 10 s). The rest of the chain has room: one
Research center for half its speed, one Glassworks for 15 %. The author's plan has the same
numbers (`planner-summary.js --factory pY`: 6 packs a minute, 3 Caged vrauks, one Latex furnace).

Per pack the line also takes 6 Basic substrate, 50 Molten glass for the Glassware and 2.5 Coal; at
0.1 a second, 15 Steam for the Latex and, with the Agar of chapter 8, 27 Steam a second.

## 2. The latex column

The new machines stand in a column west of the Vrauk line, x −57 to −20, from y −334 north to −373
(screenshot below):

- **Seaweed and Sodium alginate** (y −341 to −334): three Seaweed crop facilities beside the three of
  chapter 8, an Offshore pump for their water, a Jaw crusher that breaks Stone bricks into Stone, a
  Soil extractor for Limestone and the alginate furnace. Seaweed comes off the belt at 0.5 a second
  for 0.1 packs; the three new facilities make 0.6.
- **Creamy latex** (y −346): four Sap extractors with two Sap trees each (speed 1.0: 0.05 Saps a
  second each, 0.2 together, the 0.2 the Washer needs), the Washer and a second Soil extractor.
- **Latex slabs and Latex** (y −355): the distillation column takes Sodium alginate by belt and
  Creamy latex and Formic acid by pipe; the Latex furnace beside it takes the slabs and Steam.
- **Rubber stoppers and Glassware** (y −373 to −361, section 4) and the Research center at the top.

![The lower half of the latex column: the Soil extractor and the Sodium alginate furnace at the left, the Washer for Creamy latex and a second Soil extractor, the four Sap extractors, the three new Seaweed crop facilities, the Jaw crusher for Stone at the bottom left; the Slaughterhouse at the top edge (taken after the author's fix)](../images/ch9-latex.jpg)

## 3. Formic acid: Vrauks, one Cage and the Slaughterhouse

The Vrauk line's output (chapter 8) now goes by belt to the Caged vrauk assembler at
(−23.5, −358.5) instead of a chest. The assembler puts a Vrauk into a Cage; the Slaughterhouse beside it
renders it in 10 s into 200 Formic acid, by-products and the Cage, which goes back to the assembler.

**One Cage is enough.** The author handcrafted one (22:35), and it is the only Cage in the save: in
the assembler at 23:31. One round takes the Slaughterhouse's 10 s and the inserters' moves; at 0.1
packs a second a Vrauk arrives every 20 s. In the run with the substrate inserter (section 7) the
Slaughterhouse renders 0.05 Caged vrauks a second for two hours: the single Cage keeps up.

**The by-products** went into four Wooden chests at (−24.5, −352.5) to (−24.5, −349.5), one each
for Meat, Chitin, Guts and Brains (58, 29, 58, 29 at the save of 23:31). A Wooden chest has 16 slots and
these items stack to 100 (data), so each holds 1,600. At 3 Vrauks a minute the line makes 0.1
Meat and 0.1 Guts a second: **those two chests would have been full about 4.3 hours after the
save**, the Chitin and Brain chests twice as late, and then the Slaughterhouse and the packs would
have stopped.
North of the Slaughterhouse stood four ghosts of the Burner, the building the technology of
the same name, then being researched, unlocks.

**The author's fix (23:35–23:40).** Burner was researched at 23:33. The four chests went; one
inserter, filtered to everything but Cages, now puts all the by-products into one Wooden chest at
(−32.5, −361.5), and another feeds them from it into one Burner at (−35.5, −362.5), which burns
Wood from the Wood processing unit's belt (chemical fuel, 180 kW; data). The Burner runs a void
recipe for each of them, one item per 1.5 s at speed 5, 3.3 a second; the line makes 6 by-products
per Vrauk, 0.3 a second, a tenth of what one Burner takes. It does not make them vanish entirely:
every void recipe gives back 1 Ash at 20 % (data), 0.06 Ash a second here, which a new belt takes
west along y −359.5 and south along x −94.5 into the Ash line at a Splitter at (−95, −251.5).

## 4. Rubber stoppers and Glassware

- **Coal from Wood.** A Rubber stopper needs Coal (5 for 4). The author makes it on the spot: a Wood
  processing unit turns Logs into Wood (4 → 40, 1 s) and a Destructive distillation column turns
  Wood into Coal, Coal gas, Tar and Iron oxide (10 Wood → 10 Coal + 10 Coal gas + 30 Tar + 1 Iron
  oxide, 3 s; data). At speed 1 the column could give 3.3 Coal a second; the stoppers take 0.25 at
  0.1 packs, so it stands "output full" almost all the time (section 7). A filtered inserter at
  (−49.5, −367.5) takes the Iron oxide out; the Coal gas goes south by a new pipe through a Check
  valve at (−102.5, −74.5), the Tar by another to the Tar refining units at (−147.5, −85.5).
- **Rubber stoppers** in a Burner assembling machine at (−52.5, −361.5): 2 Latex + 5 Coal → 4, 5 s.
- **Glassware** in a Glassworks at (−56.5, −373.5): 4 Rubber stoppers + 100 Molten glass → 2, 3 s.
  The Molten glass comes up the pipe along x −104.5 (chapters 6 and 8), 5 a second at 0.1 packs. The
  fuel is **Naphthalene oil**, the author's stored by-product of the Tar line (chapter 6): a new pipe
  takes it from the pipe that already fed the Petri dish Glassworks at (−56.5, −267.5) north to this
  one, behind a Check valve at (−117.5, −272.5) (the 320-tile limit, techniques principle 18).

## 5. The Research center and the labs

The Research center takes Glassware from a two-tile belt beside the Glassworks and Basic substrate
from a Wooden chest at (−37.5, −378.5) through one inserter, and puts the packs onto the red science
belt that runs to the labs.

**The substrate's belt.** The Basic substrate leaves its assembler of chapter 8 at (−13.5, −285.5),
runs east along y −272 to x 48, north along x 48 and west along y −376.5, sharing the belt with the
red science, which comes up from the old science corner at y −176 on the other lane. A Splitter at
(−34.5, −376) filters the red science to its left output, which turns south and east to the labs;
everything else, the substrate, goes on west to (−35.5, −376.5), and there the belt ends, one tile
from the Research center. No inserter takes from it. At the save 244 belt tiles hold substrate,
about a thousand, and its assembler stands "output full". The Research center holds 36 and the
chest 37; the 48 packs made since 21:35 used 288, so the substrate went into the chest by hand.
The blueprint exported at 20:34 had the same gap. One inserter at (−36.5, −376.5), taking from the
belt end and dropping into the Research center, closes it (section 7). **The author put exactly that
inserter in at 23:35–23:40** and took the chest away; the blueprint exported afterwards has it.

![The top of the line after the author's fix: the Glassware Glassworks at the top left, the Research center, the Splitter that sends the red science to the five labs on the right; below them the Wood column, the Latex slab column, the Latex furnace and the Wood processing unit at the left, the Burner for the by-products in the middle, the Slaughterhouse and the Caged vrauk assembler at the bottom](../images/ch9-science.jpg)

**The labs.** Five Labs at x −16.5 and −11.5 (y −370.5 to −358.5), fed from the red science belt.
Burner costs 50 units of 1 pY science pack 1 and 2 Automation science packs, 45 s each, like the
pY technologies queued after it (50 to 55 units; data). Five labs at speed 1 would take 5/45 = 0.111
units a second, a little more than 0.1 packs a second: the packs set the pace, 8 to 9 minutes per
technology, and the labs then take 0.2 red science a second, the whole output of the red science
block of chapter 4.

## 6. Steam

The Latex furnace takes 150 Steam per Latex, 15 a second at 0.1 packs, and the Agar furnace of
chapter 8 another 12. Both hang on the steam pipe of the ten Coke Boilers of chapter 6 at y −257,
one segment from y −355 to −75 (save). At 22:50 robots built a second row of ten Boilers at y −260
with an inserter and a fuel belt each; at the save they have no fuel, and their belt along y −262.5
is empty.

## 7. Two hours after the save

Copies of the save were run for two hours (`tools/rate-probe`, rates in 5- or 10-minute steps): as
saved, and three times with one inserter added at (−36.5, −376.5), watching in turn the pack chain,
the boards and fuel gases, and the power stations and the Ash (75 minutes). The runs with the
inserter agree with each other.

| | As saved | With the inserter |
|---|---|---|
| pY science pack 1 per second | 0.02 in the first 5 minutes (6 packs), then 0 | **0.100** for 40 minutes, 0.07 to 55 minutes, 0 from 60 minutes |
| Boards per second | 0.058 (two-hour average) | 0.095 to 0.130 for 40 minutes, then down to 0 |
| Raw coal burnt per second | 36.6 | 69 to 79 |
| Steam per second | 215 | 414 to 473 |
| Ash made / separated per second | 41 / 44 | 76 to 87 / 60 to 83, from 45 minutes 13 |
| Electricity | enough for two hours | "low power" from 45 minutes, none from 60 minutes to the end |

**As saved.** The Research center makes two crafts (6 packs) and then stands short of substrate
for the rest of the two hours. The Glassware backs up (its Glassworks "output full" from 10 minutes), then the Rubber
stoppers, the Latex slabs, the Latex and the Slaughterhouse (15 minutes). The Vrauk line goes on
making 3 Vrauks a minute that nobody takes. The rest of the base is the base of chapter 8: the
Syngas Gasifiers stand "output full" 80 % of the time, the zinc drills miss their fluid 74 %, and
the boards average 0.058 a second.

**With the inserter, the line works.** Every step of section 1 runs at its planned rate from the
first five minutes: 0.100 Glassware, 0.200 Rubber stoppers, 0.100 Latex, 0.050 Caged vrauks, 10
Formic acid and 0.600 Basic substrate a second (the thousand on the belt first). The Research center
works about half the time, the Latex furnace all the time. **The Syngas is used up, as the author expected:**
the base now takes 12 Molten glass a second (2 as saved) for the Glassware and the Petri dishes, so
the Glassworks at y 348.5 burn what the Tar line makes; Syngas used 44 to 59 a second against 44 to 54 made, Gasoline 35
against 27 from 20 minutes on, and the boards hold 0.095 to 0.130 a second. The stored Gasoline (167,000 in the pond at
(−139, 3)) goes down by about 8 a second, enough for about 6 hours; the Naphthalene oil (248,000)
still grows, by 3 to 9 a second.

**Then the electricity fails.** With the whole chain at work, the base burns twice the Raw coal of
the as-saved run and makes twice the Ash. The twelve Ash separators could take 120 a second (10
each; data), but from 25 minutes only about 60 a second is separated and the rest piles up on the
Ash belts. The Soot separator at (−56.5, 365.5) puts its own Ash (30 % of its output; data) onto one
of those belts at (−53.5, 370.5): with that belt full it stands "output full" through the whole run
(28 % of the time in the as-saved run), the Soot no longer moves, and from 40 minutes the Ash
separators, whose Soot cannot leave, stand "output full" too. The Ash then backs up into the
Boilers: the station at y 260 and 273 stops with its Ash slot full at 40 to 45 minutes, half of the
four Coal dust Boilers at y 382 at 45, the station at y 230 and 243 at 60. Their Steam engines run dry, the
base goes to "low power" at 45 minutes and to no power at 60, and nothing starts it again, since
the Ash separators and the Soot separator themselves run on electricity. It is a loop, like the
zinc and the Tar of chapter 6: the Ash separation needs the Soot separation, whose Ash needs the
Ash separation.

![The Soot separator at (−56.5, 365.5): Soot comes in from the belt above, the ores go into the chests and Stone furnaces on its right, its Ash onto the belt below (taken after the author's fix)](../images/ch9-soot.jpg)

**What it means.** The pack line itself is complete with one inserter. What the base lacks is room
for twice the Ash once everything runs. Not measured yet, from data: the Burner that is now being
researched burns Ash and Soot, 3.3 a second each, but every item it burns gives back 1 Ash in 5
(data): a Burner on Ash removes 2.7 a second, so about ten would take the 25 a second that piled
up, and one would take the Soot; and the Soot separator's Ash needs a way out that does not depend on
the Ash separators.

**After the author's fix (save of 23:40).** The author then put the inserter in, gave the
by-products a Burner (section 3) and let the Soot separator's Ash onto the Ash belt at x −92.5 by an
inserter at (−91.5, 370.5) instead of a side-load, on the belt's other lane; a second Ash belt now
joins it through a Splitter at (−92, 383.5). In their words the Ash handling may not be complete
yet, but the Soot separator's Ash no longer jams its belt. Measured the same way for two hours:

| Minutes after the save | 10 | 20 | 30 | 40 | 50 | 60 on |
|---|---|---|---|---|---|---|
| pY science pack 1 per second | 0.100 | 0.100 | 0.095 | 0.080 | 0.025 | 0 |
| Boards per second | 0.130 | 0.130 | 0.100 | 0.075 | 0.025 | 0 |
| Ash made / separated per second | 89 / 78 | 87 / 59 | 77 / 55 | 68 / 28 | 24 / 4 | 0 |

The pack line and its by-products work: the Burner takes the 0.1 Meat and 0.1 Guts a second as they
come. The power does not hold. The Soot separator again stands "output full" from the first
minutes, half the Coal dust Boilers at y 382 fill with Ash at 20 minutes, the station at y 260 and
273 at 30 to 40, the base goes to "low power" at 40 minutes and has stopped by 60. The Ash still
has nowhere to go. In the save of 23:40 the Ash loop, north along x −92.5 and back south along
x −93.5, is full along its whole length, and its only way off is the belt at y 205.5 into the three
separators at y 210.5; meanwhile four of the twelve separators, two of the three at y 97.5 among
them, stand short of Ash in front of nearly empty belts. A free lane does not help when both lanes
of the loop are full. The Ash needs more ways off the loop: to the separators that wait for it, or
into Burners on the loop (2.7 a second each). Not measured yet.

## 8. Other changes

- **The labs moved** from the old science corner (six, y −173.5 and −167.5) to the Research center
  (five), with the red science belt extended east and north to them (section 5).
- **Anthracene oil cracking:** a fourth Destructive distillation column at (−168, −139), 50
  Anthracene oil → 20 Gasoline + 5 Coke, 4 s (data). In the two-hour runs the four columns stand
  "short of fluid" two thirds of the time: the Anthracene oil, not the columns, sets their pace.
- **A second row of Boilers** at y −260 (section 6), without fuel so far.
- **The Concrete corner** beside the acetylene block (chapter 8, section 7) moved one tile west and
  is now part of the `acetylene` blueprint (section 9).
- **Eight chests of Ash** at y 285 to 312 taken away with their inserters (22:30–22:35). The
  Ash in all the base's chests: 208,000 at 21:35, 222,000 at 23:31 (both saves).
- **A chest of Air-core inductors** beside the board block: an inserter at (−38.5, −251.5) takes them
  from the Electronics factory into a Wooden chest (400 at the save).

## 9. The blueprints

The author exported the book at 20:34 (real time), just before the save of 23:31, and the line again
at 22:56 after the fixes; `tools/bp-sync.js pull` reports two new designs and three changed ones:

- **`py-science-pack-1`** (new), "0.1 [pY science pack 1]": the whole line of chapters 8 and 9,
  x −60 to 48, y −377 to −264 in save coordinates, the 8 paddocks and 2 complexes, the latex column,
  the Research center, 5 labs and the Burner. The first export (20:34) had the gap of section 5 and
  four Burner ghosts; the file is the author's second export (22:56, after the fixes), with the
  substrate inserter, the by-product chest and the Burner. Not run on the bench: the Vrauk line needs
  100 minutes to fill its slots from a few Vrauks, and the Moondrop greenhouse's speed comes from the
  Carbon capture upgrade chosen in the save; it was measured where it stands (section 7).
- **`copper-screening`** (new), "3 [Copper plate]": the copper block of chapter 7, x −70 to 53,
  y 10 to 21, without the drill field; measured there at 3.01 plates a second.
- **`acetylene`** (changed): with the Concrete corner and the author's note "额外产一点标准混凝土" (a
  little Standard concrete besides). Bench: 49.92 Acetylene a second (49.75 before). The corner made
  no Concrete in the bench's 30 minutes; in the author's game it made 0.02 to 0.05 a second after
  23:10 (recorder).
- **`iron-oxide-smelting`** (changed): input and output inserters swapped, the same design mirrored.
  Bench: 1.713 Iron oxide and 0.857 Iron plates a second, as before.
- **`simple-circuit-board`** (changed): the inserter and chest for Air-core inductors (section 8).

## 10. Checklist

- pY science pack 1 costs half a Vrauk: 0.1 packs a second take 3 Vrauks a minute, a full Vrauk line
  of 8 paddocks and 2 complexes, and one Latex furnace working all the time. One Cage is enough.
- Follow every product to the machine that takes it. A belt that ends one tile short looks fine for
  a while when a chest beside the machine was filled by hand; a copy of the save run without the
  player shows it within minutes.
- Give the Slaughterhouse's by-products a way out before their chests fill (4.3 hours for Meat and
  Guts at 3 Vrauks a minute): the Burner, the first pY science pack 1 technology, burns them and
  gives back 1 Ash in 5.
- A new line that makes the base work harder makes more Ash. Before it runs, check that every Ash
  separator gets Ash and that the Soot separator's Ash and the separators' Soot can always leave;
  otherwise the Ash stops the Boilers and the electricity with them. A loop belt of Ash needs as
  many ways off as Ash comes on: when it is full, a free lane is no help, and everything that drops
  onto it (here the Soot separator) stops too.
- The author's Syngas call holds: once the pack line runs, its Molten glass burns the Syngas and the
  stored Gasoline (about 8 a second net), and the boards stay at 0.1.

## 11. How these facts were checked

- The run: the companion mod's recorder (run `2652821414-0`, last record 23:31), read with
  `tools/recorder-phases.js` (timeline in 5-minute slices), `tools/recorder-log.js` (production per
  10-minute window) and `tools/recorder-summary.js` (notes: none since 21:25).
- The author's plan: the Factory Planner factory the companion writes out
  (`tools/planner-summary.js --factory pY`, saved at 23:06).
- The save of 23:31 (`Py-Exploration`, copied before reading; consistency check passed):
  `tools/inspect-save.ps1`, `tools/summarize-save.js`, `tools/render-area.js`,
  `tools/manual-links.js`; what changed since 21:35 from the two saves' `entities.json`; fluid
  segments, belt contents and inserter pick-up and drop positions from the snapshot.
- **Two hours after the save:** `tools/save-probe.ps1 -Probe rate-probe -Ticks 435700 -Variant
  60,7200,300,<names>;@-42:-372`, as saved and with `,+burner-inserter@-36.5:-376.5:east`; again
  with the inserter and the boards, Zinc plates, Molten glass, Syngas, Gasoline, Hydrogen,
  Naphthalene oil and Tar (10-minute steps); and with the inserter for 75 minutes
  (`-Ticks 274000 -Variant 60,4500,300,...`) watching Ash, Coal dust, Soot, Iron oxide, Raw coal,
  Coke, Steam and Water, with the probe now also grouping Boilers and Steam engines by row. Stored
  fluids and the Soot separator's inserters from the save's snapshot. The save of 23:40 (after the
  author's fix): `tools/inspect-save.ps1`, the same two-hour run as saved, the Ash belts followed
  tile by tile in its snapshot.
- The blueprints: `tools/bp-sync.js pull` (the author's export of 20:34 real time), compared entity by
  entity with the files before; `tools/bp-bench.ps1 -Bench acetylene` and
  `-Bench iron-oxide-smelting` on the new versions.
- Data: the current dump of the author's mods (`C:\tmp\cf-save\data\script-output\data-raw-dump.json`):
  recipes, machine speeds, module effects (Moondrop, Carbon capture), the Burner's void recipes,
  stack sizes, technology costs; English names from the mods' `locale/en`.
- The screenshots: taken by the author with the companion mod (`/pt-shots`) after the fix, areas
  planned with `node tools/shots.js plan`.

Next: [chapter 10, crushed-coal power](10-crushed-coal-power.md).
