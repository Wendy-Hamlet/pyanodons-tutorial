# Chapter 11 — Better lead, titanium and tin smelting

[中文版](11-lead-titanium-tin-smelting.zh-CN.md) · [Index](../README.md) · Previous:
[chapter 10](10-crushed-coal-power.md)

This chapter follows the same recorded run from the save of 25:47. Its subject is the author's,
**better lead, titanium and tin smelting** (铅矿、钛矿和锡矿冶炼改良): the three Stage 1 processing
technologies screen the ore before it is smelted, so a plate takes far less ore and a furnace makes
far more plates. This first part covers lead and titanium, built from 26:04 to the save of 27:39;
the tin block was begun just before the save and follows in the second part. Along with them the
drills on both fields became Fluid mining drills MK 02, and Mining productivity 1 and 2 were
researched. Times are game time. Numbers come from the game's data, from the recorder's 10-minute
production windows, from the save of 27:39 (`tools/inspect-save.ps1`) and from an hour of that
save, as it stands and with the new blocks' plates taken away (`tools/rate-probe`). The author has
not exported blueprints of the new blocks.

The result: **lead takes 2 ore a plate instead of 6, titanium 5.2 instead of 10.** With its plates
taken away the lead block makes **2.9 Lead plates a second** (the old column of chapter 5: 0.49),
and the titanium block **1.15 Titanium plates a second** from 6 ore (chapter 7: 0.275); every stage
of both has room for a full belt of ore. Both stood full at the save, because nothing uses titanium
yet and the board line takes 0.267 Lead plates a second. **The two blocks share one Acetylene
supply that is too small for both at full speed**: the lead drills want 60 a second, the titanium
drills 20, and the acetylene block makes at most 49.75. An Overflow valve gives lead first call, so
once everything the lead block makes is used, the titanium drills stop within 20 minutes. While the
lead users take up to about 1.8 plates a second, both run at full speed (section 4).

## The run at a glance

| Game time | What happened |
|---|---|
| 25:51–25:56 | The west end of the crushed-coal block rebuilt by robots (six Boilers taken up and put back at (−57, 153) and (−57, 174)): the author's fix from [chapter 10](10-crushed-coal-power.md#4-the-block-alone) |
| 26:02 | Mining machines - Stage 1 researched; Mining productivity 1 next |
| 26:04–26:16 | **The lead block**: nine Automated screeners MK 01 in a row at y −70.5 (x −226.5 to −170.5), and the thirteen lead furnaces of [chapter 5](05-tin-zinc-smelting.md#7-lead-acetylene-as-the-mining-fluid) rebuilt as two rows of fifteen Stone furnaces (x −163 to −135); screeners and furnaces handcrafted on the spot, about half of them placed by robots. Lead ore stops while it is rebuilt (0.12 a second in the window ending 26:20) |
| 26:27–26:28 | The six lead drills replaced by Fluid mining drills MK 02 |
| 26:32 | Mining productivity 1 researched (+10 % ore from every drill); Mining productivity 2 next |
| 26:33 | Two more Coal dust Boilers and two Steam engines, with their own Offshore pump, at (−41.5, 382) and (−38.5, 382) (section 6) |
| 26:35–26:36 | The twelve titanium furnaces of [chapter 7](07-copper-screening-titanium-duralumin.md#3-titanium) taken away by robots |
| 26:40–27:10 | The lead block at full speed: 6.4 to 6.6 Lead ore and up to 2.9 Lead plates a second, the Acetylene block at its 50 a second; then the plates fill their store and the drills slow down |
| 26:43–27:08 | **The titanium block** laid out east of its place (x −25 to 58, y 419 to 471): 13 screeners, five Jaw crushers MK 01, two Secondary crushers MK 01, eleven Stone furnaces, partly by hand and partly by robots, moved and moved again |
| 27:05 | Mining productivity 2 researched; Tin processing - Stage 1 next |
| 27:12–27:20 | Robots move the titanium block west into its place, x −61 to 0, y 417 to 452, beside the end of the titanium ore belt; three chests for the plates |
| 27:22 | Tin processing - Stage 1 researched; Oil industry machinery - Stage 1 next |
| 27:22–27:27 | The titanium drills replaced by ten Fluid mining drills MK 02; their Raw coal and Ash belts taken away |
| 27:32–27:38 | The tin block begun at y 472 to 496 (x −59 to 10): nine screeners, six Jaw crushers, Stone furnaces; the twelve tin furnaces of chapter 5 taken away (the second part of this chapter) |
| 27:39 | The save; Oil industry machinery - Stage 1 at 62 % |

Production per second (10-minute windows from the recorder). Titanium ore is 0 until the
window ending 27:30: the old titanium column had filled its chests by about 24:10 and its
drills stood. Acetylene used above what was made came out of the full pipes.

| Window ending | Lead ore | Lead (grade 1) | Lead plates | Acetylene made / used | Titanium ore | Titanium (grade 3) | Titanium plates | pY science pack 1 | Boards |
|---|---|---|---|---|---|---|---|---|---|
| 25:50 | 1.61 | 0 | 0.27 | 14.3 / 14.2 | 0 | 0 | 0 | 0.065 | 0.100 |
| 26:00 | 1.58 | 0 | 0.27 | 14.7 / 14.7 | 0 | 0 | 0 | 0.050 | 0.100 |
| 26:10 | 0.74 | 0 | 0.12 | 6.0 / 6.2 | 0 | 0 | 0 | 0.050 | 0.100 |
| 26:20 | 0.12 | 0 | 0.02 | 0 / 0 | 0 | 0 | 0 | 0.050 | 0.100 |
| 26:30 | 1.41 | 0.63 | 1.40 | 13.8 / 13.7 | 0 | 0 | 0 | 0.050 | 0.100 |
| 26:40 | 6.56 | 1.09 | 2.11 | 48.5 / 59.0 | 0 | 0 | 0.08 | 0.050 | 0.100 |
| 26:50 | 6.38 | 1.28 | 2.90 | 50.0 / 56.8 | 0 | 0 | 0 | 0.050 | 0.100 |
| 27:00 | 5.52 | 1.09 | 1.78 | 49.2 / 49.2 | 0 | 0 | 0 | 0.050 | 0.100 |
| 27:10 | 3.84 | 0.61 | 0.34 | 47.7 / 33.3 | 0 | 0 | 0 | 0.050 | 0.100 |
| 27:20 | 0.59 | 0.10 | 0.27 | 7.2 / 4.2 | 0 | 0.22 | 0.17 | 0.050 | 0.100 |
| 27:30 | 0.58 | 0.10 | 0.28 | 17.0 / 12.2 | 2.09 | 0.32 | 0.87 | 0.050 | 0.100 |

Between the saves of 25:47 and 27:39 the base gained 31 Automated screeners MK 01 (9 to 40: nine
for lead, 13 for titanium, nine for tin), 11 Jaw crushers MK 01 (25 to 36; six of them for tin),
two Secondary crushers MK 01 (30 to 32), 16 Fluid mining drills MK 02 (6 to 22, while the MK 01
went from 45 to 28), 20 Stone furnaces (132 to 152), a second Burner, and two Boilers and Steam
engines (save snapshots).
The author left no chat notes in this part of the run.

## 1. The technologies

The recipes of this chapter come from technologies researched in chapter 10's stretch of
the run, each 50 or 55 units of 1 pY science pack 1 and 2 Automation science packs (data;
recorder):

- **Titanium processing - Stage 1** (24:15; needs Crusher 2 and Copper processing - Stage 1)
  unlocks five recipes: screening Titanium ore, crushing Titanium (grade 2), screening Titanium
  (grade 1) into grade 3, recrushing the Titanium rejects, and smelting grade 3 into plates
  (section 3).
- **Lead processing - Stage 1** (24:33) unlocks two: screening Lead ore and smelting Lead (grade 1)
  (section 2).
- **Tin processing - Stage 1** (27:22) unlocks three for tin, built after the save (the second part
  of this chapter).

Two more kinds of research helped the drills:

- The **Fluid mining drill MK 02** (from the Electric mining drill technology, 23:49) mines twice
  as fast as the MK 01 (mining speed 1 against 0.5) and runs on electricity (900 kW) instead of
  burning fuel (400 kW). It costs one MK 01, two Electric mining drills, 10 Simple circuit boards,
  50 Small parts, 10 Steel, 20 Aluminium plates and one Engine (data). The author replaced the six
  lead drills (26:27) and the titanium drills (27:22–27:27) with it.
- **Mining productivity 1 and 2** (26:32 and 27:05) add 10 % each: every drill now gives 1.2 ore
  per mining cycle (data). The extra ore uses no mining fluid, since a drill takes its fluid per
  cycle: in the window ending 26:40 (Mining productivity 1) the lead drills mined 6.56 Lead ore a
  second with 59.0 Acetylene, 10 per cycle of 1.1 ore (recorder).

Mining machines - Stage 1 (26:02) unlocks eight machines (Scrubber, Flotation cell,
Hydroclassifier, Impact crusher, Centrifuge, Rectisol, Mixer and Ball mill, all MK 01), each
needing Intermetallics; none is built yet. Research ran at 0.05 units a second up to the save,
limited by the red science ([chapter 10](10-crushed-coal-power.md#5-the-base-after-the-save);
section 6).

## 2. Lead

| Step | Machine (data) | Recipe (data) | One machine, per second |
|---|---|---|---|
| Mining | Fluid mining drill MK 02, 5 × 5, 900 kW, speed 1 | Lead ore: 1 s a cycle, 100 Acetylene per 10 ore | 1 cycle: 1.2 ore (productivity +20 %), 10 Acetylene |
| Screening | Automated screener MK 01, 7 × 7, 300 kW, speed 1 | 5 Lead ore → 1 Lead (grade 1), 3 s | takes 1.667 ore |
| Smelting | Stone furnace, speed 1 | 4 Lead (grade 1) → 10 Lead plates, 40 s | takes 0.1 grade 1, makes 0.25 plates |

A Lead plate now takes **2 Lead ore instead of 6** (the old recipe: 6 ore → 1 plate in 10 s,
[chapter 5](05-tin-zinc-smelting.md#7-lead-acetylene-as-the-mining-fluid)), and so a third of the
Acetylene: 20 per plate, 16.7 with the productivity bonus, against 60. A furnace makes 2.5 times
as many plates (0.25 a second against 0.1).

The block (x −234 to −82, y −78 to −65; screenshots below):

- **The mine.** The same six drills' places at y −151.5 (x −308.5 to −283.5), now Fluid mining
  drills MK 02: 6 cycles a second, **7.2 Lead ore a second** at full speed, which takes **60
  Acetylene a second**. The ore comes south along x −234 as before, then east along y −76.
- **Nine screeners** in a row at y −70.5 (x −226.5 to −170.5) take the ore from that belt with
  three inserters each (two for one of them) and put Lead (grade 1) on the belt below them, at y
  −66, which runs east to the furnaces. Nine take up to 15 ore a second; 7.2 need 4.3 of them.
- **Thirty Stone furnaces** in two rows of fifteen (x −163 to −135, at y −74 and y −68), each row
  laid out as the chapter 5 column: Raw coal (and the Ash going out, by filtered inserters) on the
  belt above, the grade 1 and the plates on the belt below. The grade 1 belt splits between the
  rows. Thirty take 3 grade 1 a second; the mine's 1.44 need 14.4 of them, for **3.6 Lead plates
  a second**.
- **The plates** of both rows join on one belt running east along y −73.5. A Mechanical inserter at
  (−129.5, −72.5) fills a Wooden chest at (−129.5, −71.5); the rest goes north along x −82 and east
  along y −235 to the board line, which uses 0.267 Lead plates a second.
- **Electricity:** 9 × 300 kW for the screeners and 6 × 900 kW for the drills, 8.1 MW (data); the
  furnaces and the old drills burnt Raw coal.

So the block's limit is not a machine but the Acetylene: the acetylene block of chapter 5 makes at
most 49.75 a second, the drills want 60 (section 4).

**Measured** in a copy of the save with the plates taken off the belt and out of the chest
(section 5): in the first ten minutes, while the pipes still hold Acetylene, the drills mine 7.06
Lead ore a second, their full speed. Then the pipes are empty and the block gets what the acetylene
block makes, 47.7 to 48.8 a second: **5.80 to 5.95 Lead ore and 2.85 to 3.08 Lead plates a
second**, the drills short of Acetylene 12 % of the hour. The recorder shows the same while the
author's store was filling: 6.38 Lead ore and 2.90 plates a second in the window ending 26:50, with
50 Acetylene made and 56.8 used. The screeners work 42 % of the time and the furnaces 46 %: like
the titanium block (section 3), the lead block has room for a full belt of ore, 15 a second, which
would take 125 Acetylene a second.

As saved, the block makes what the board line takes, 0.26 to 0.28 Lead plates a second, with its
drills waiting for space 92 % of the time; the chest at (−129.5, −71.5) holds 1,600 plates and the
furnaces are full.

<!-- ![The lead screening: the nine Automated screeners in a row, the ore belt above them, the Lead (grade 1) belt below](../images/ch11-lead-screening.jpg) -->

<!-- ![The lead furnaces: two rows of fifteen Stone furnaces, the plate belt leaving east past the chest](../images/ch11-lead-smelting.jpg) -->

## 3. Titanium

| Step | Machine (data) | Recipe (data) | One machine, per second |
|---|---|---|---|
| Mining | Fluid mining drill MK 02 | Titanium ore: 2 s a cycle, 40 Acetylene per 10 ore | 0.5 cycles: 0.6 ore, 2 Acetylene |
| Screening ore | Automated screener MK 01 | 5 Titanium ore → 1 Titanium (grade 1) + 1 Titanium (grade 2) at 50 %, 3 s | takes 1.667 ore |
| Crushing grade 2 | Jaw crusher MK 01, 7 × 7, 1 MW | 1 Titanium (grade 2) → 1 Stone + 1 grade 1 at 50 %, 3 s | takes 0.333 grade 2 |
| Screening grade 1 | Automated screener MK 01 | 3 Titanium (grade 1) → 1 Titanium (grade 3) + 1 Titanium rejects at 50 %, 3 s | takes 1 grade 1 |
| Recrushing rejects | Secondary crusher MK 01, 6 × 6, 450 kW | 1 Titanium rejects → 1 Gravel + 1 grade 3 at 30 %, 3 s | takes 0.333 rejects |
| Smelting | Stone furnace | 5 Titanium (grade 3) → 10 Titanium plates, 25 s | takes 0.2 grade 3, makes 0.4 plates |

Five Titanium ore give 1 grade 1 and 0.5 grade 2; crushing the grade 2 adds 0.25 grade 1 (and 0.5
Stone); the 1.25 grade 1 give 0.417 grade 3 and 0.208 rejects; recrushing those adds 0.0625 grade
3 (and 0.208 Gravel). That is 0.479 grade 3, **0.958 Titanium plates from 5 ore: 5.2 ore a plate
instead of 10** (the old recipe: 40 ore → 4 plates in 60 s, chapter 7). A furnace makes 0.4 plates
a second instead of 0.067, six times as many.

The block (x −61 to 0, y 417 to 452, at the west end of the titanium ore belt):

- **The mine.** Ten Fluid mining drills MK 02 where the eleven MK 01 of chapter 7 stood (x 264.5 to
  289.5, y 414.5 and 420.5): 5 cycles a second, **6 Titanium ore a second** at full speed, with
  **20 Acetylene a second**. Being electric, they need no Raw coal; that belt and the Ash belt are
  gone (two chests at (260.5, 412.5) and (261.5, 412.5) hold 1,032 Raw coal). The ore belt runs
  west along y 417 as before, now into the block.
- **Nine screeners** at y 422.5 (x −57.5 to −1.5) take the ore from that belt above them, three
  inserters each, and put grade 1 and grade 2 onto a belt below them (y 429) that runs east. Nine
  take up to 15 ore a second; 6 need 3.6.
- **Five Jaw crushers** at y 434.5 (x −57.5 to −29.5) take the grade 2 from that belt with filtered
  inserters and put grade 1 back on it; their Stone goes onto a belt at y 439. The screeners make
  0.6 grade 2 a second; that needs 1.8 crushers.
- **Four screeners** at y 434.5 (x −22.5 to −1.5) take the grade 1 after a Splitter, 1.5 a second
  (they could take 4), and put grade 3 and rejects onto the belts at y 439 and 441, which run west.
- **Two Secondary crushers** at y 446.5 (x −8.5 and −1.5) take the rejects, 0.25 a second (they
  could take 0.667), and put their grade 3 back; their Gravel goes to a **Burner** at (−15.5,
  449.5), which voids it on Raw coal (Gravel → 1 Ash at 20 %, 1.5 s, at speed 5: 3.3 a second; data,
  [chapter 9](09-py-science-pack-1.md#3-formic-acid-vrauks-one-cage-and-the-slaughterhouse)).
- **Eight Stone furnaces** at y 444 (x −43 to −29) take grade 3 from the belt at y 441 and put the
  plates on it: 0.575 grade 3 a second need 2.9 furnaces, for **1.15 Titanium plates a second**.
  The plates go west along y 443 into two Wooden chests at (−60.5, 441.5) and (−59.5, 441.5).
- **Three Stone furnaces** at y 450 (x −33 to −29) bake the crushers' 0.6 Stone a second into 0.3
  Stone bricks, which go west along y 449 and north along x −75 onto the bus's brick belt.
- **Electricity:** 13 screeners × 300 kW, 5 crushers × 1 MW, 2 Secondary crushers × 450 kW and 10
  drills × 900 kW: 18.8 MW (data).

The plates per ore nearly double and the drills mine 2.2 times as fast: the block can make **4.2 times
the plates of chapter 7** (1.15 a second against 0.275) with less than twice the Acetylene (20 a
second against 11 for the old drills' 2.75 ore; 17.4 per plate against 40).

**Measured** in a copy of the save with the plates taken away as they arrive (section 5): the ten
drills work all the time and give **6.00 Titanium ore a second** in every 10-minute step; the block
makes 1.47 to 1.51 Titanium (grade 1) and 0.55 to 0.60 grade 3 a second, and **1.10 to 1.18
Titanium plates a second** (after the first step, which also empties the full furnaces): the sums
above. The machines show how much room is left. The ore screeners work 40 % of the time, the Jaw
crushers 35 %, the grade 3 screeners 37 %, and wait for input the rest. **Every stage is sized
for a full belt of ore**: 15 Titanium ore a second would keep the nine ore screeners busy and need
4.5 Jaw crushers (there are five), 3.75 grade 3 screeners (four), 7.2 furnaces (eight) and 1.9
Secondary crushers (two), for 2.9 plates a second. Ten drills fill 40 % of that belt; a full belt
would take 25, and 50 Acetylene a second.

**As saved, nothing uses Titanium plates yet.** The two chests (3,200 plates) and the eight
furnaces were full at the save, and the author carries 2,028 more. In the hour after the save as
it stands the screeners fill up within 20 minutes, the ore belt by 30, and the drills work 27 % of
the hour: the jam of a product with no user yet (techniques principle 23), which frees the
Acetylene for lead (section 4).

<!-- ![The titanium block: the ore screeners along the ore belt at the top, the Jaw crushers and the grade 3 screeners below them, the furnaces, the brick furnaces and the Burner at the bottom, the plate chests at the left](../images/ch11-titanium.jpg) -->

<!-- ![The titanium mine: ten Fluid mining drills MK 02 in two rows with the ore belt between them](../images/ch11-titanium-mine.jpg) -->

## 4. Acetylene for both

The lead and titanium drills draw on one Acetylene pipe from the acetylene block of chapter 5
(four Gasifiers; 49.75 a second on the bench). The lead drills sit first on it; an Overflow valve
at (−108.5, −74.5) passes Acetylene on to the titanium only while the lead side is more than 80 %
full ([chapter 7](07-copper-screening-titanium-duralumin.md#3-titanium)). At full speed the six
lead drills want 60 a second and the ten titanium drills 20: 80 against 49.75. Measured under three
loads (section 5):

| Load | Acetylene a second | Gasifiers | Lead | Titanium |
|---|---|---|---|---|
| As saved: Lead plates used at 0.267 a second, titanium store full | 24 while the titanium drills run, then 4 | "full output" 77 % | 0.58 ore | 6.0 ore at first, none from minute 20: the block is full |
| Titanium plates all taken, Lead plates at about 1.1 a second (a first try, see section 8) | 33 to 38 | working 73 % | 2.1 to 2.3 ore | 6.0 ore, 1.15 plates, all hour |
| All plates taken | 47.7 to 48.8 after the pipes empty (about 20 minutes) | working 97 % | 5.8 to 5.95 ore, 2.9 plates | none from minute 20: the drills "missing required fluid" 73 % of the hour |

So the titanium keeps its 20 a second as long as the lead drills take at most 29.75: 2.975 cycles
a second, 3.57 Lead ore, **about 1.8 Lead plates a second**. Today the base uses 0.267, and nothing
uses titanium. If the lead users grow past that, the titanium stops without warning; the fix is
more Acetylene. A second copy of the author's `acetylene` block (49.75 a second) covers both blocks
at full speed; the 30 a second missing cost about 2.8 Coke a second (0.94 Coke per 10 Acetylene,
chapter 5).

## 5. An hour after the save of 27:39

Measured in copies of the save (`tools/rate-probe`, one minute of warm-up, then an hour in
10-minute steps; per second, each step's average). As saved:

| Minutes after 27:39 | Lead ore | Lead plates | Titanium ore | Titanium plates | Acetylene made | Boards | Power used (MW) |
|---|---|---|---|---|---|---|---|
| 0–10 | 0.59 | 0.27 | 6.00 | 0 | 24.0 | 0.100 | 113.6 |
| 10–20 | 0.58 | 0.26 | 3.90 | 0 | 17.2 | 0.100 | 111.5 |
| 20–30 | 0.59 | 0.27 | 0 | 0 | 4.2 | 0.100 | 93.9 |
| 30–40 | 0.57 | 0.26 | 0 | 0 | 4.0 | 0.100 | 92.5 |
| 40–50 | 0.57 | 0.26 | 0 | 0 | 4.5 | 0.100 | 85.0 |
| 50–60 | 0.56 | 0.28 | 0 | 0 | 4.0 | 0.100 | 75.6 |

With all Lead and Titanium plates taken away as they arrive (a belt tile emptied every tick and the
plate chests every second):

| Minutes after 27:39 | Lead ore | Lead plates | Titanium ore | Titanium plates | Acetylene made / used | Boards | Power used (MW) |
|---|---|---|---|---|---|---|---|
| 0–10 | 7.06 | 5.77 | 6.00 | 1.37 | 50.0 / 78.0 | 0.100 | 128.9 |
| 10–20 | 6.95 | 3.50 | 3.92 | 1.18 | 50.0 / 69.3 | 0.100 | 129.7 |
| 20–30 | 5.95 | 3.08 | 0 | 0.18 | 48.8 / 48.8 | 0.100 | 110.8 |
| 30–40 | 5.85 | 2.88 | 0 | 0 | 48.0 / 47.8 | 0.100 | 107.4 |
| 40–50 | 5.86 | 2.90 | 0 | 0 | 47.8 / 48.0 | 0.100 | 101.5 |
| 50–60 | 5.80 | 2.85 | 0 | 0 | 47.7 / 47.7 | 0.100 | 87.6 |

- **The first 20 minutes run on stock**: the Acetylene in the pipes (used 78 a second, made 50)
  and the Lead (grade 1) on the belts and in the furnaces (5.8 Lead plates a second at first).
- **The titanium block stops in both runs**: as saved because its plates have nowhere to go, with
  the plates taken because the lead drills take the Acetylene (section 4). With the lead taken at
  only about 1.1 plates a second (the first try) it ran all hour: 6.00 Titanium ore and 1.10 to
  1.18 plates a second in every step after the first.
- **The rest of the base is not disturbed**: the boards hold 0.100 a second in every step of every
  run, and no electric machine reported low power at up to 130 MW (the new blocks take up to 26.9
  MW at full speed; data). The demand falls in the later steps as stores elsewhere fill (chapter 10).
- With only the lead plates taken, the lead runs as in the second table (2.88 to 2.90 plates a
  second from minute 30) and the titanium as in the first.

## 6. Other changes

- **The crushed-coal block's fix** (25:51–25:56): robots rebuilt the west end of both rows as in
  the author's updated blueprint, with the second Ash inserter on the second Boiler from the west
  ([chapter 10](10-crushed-coal-power.md#7-the-blueprints)).
- **Two more Coal dust Boilers** (26:33), with two Steam engines and their own Offshore pump, at
  the east end of the Coal dust row at y 382 (x −41.5 and −38.5): eight now, which burn up to 9.9
  Coal dust a second (1.23 each; data). Chapter 10 found the base making 8.26 a second at full load
  against 7.40 that six could burn. In the hour after the save the base made 5.6 Coal dust a second
  and the eight Boilers worked 59 % of the time: the Coal dust no longer backs up.
- **Research** went on at 0.05 units a second (pY science pack 1 made at 0.05 a second in every
  window from 26:00; recorder). In the hour after the save the research center made 0.086 packs a
  second and the red science block 0.163 Automation science packs, its Empty planter box assembler
  short of ingredients 17 % of the time (80 % in chapter 10); where the extra Stone bricks come from
  was not traced. The titanium block puts 0.3 bricks a second onto the bus's brick belt.
- **Tin** (27:32–27:38): the twelve furnaces of the tin column of chapter 5 were taken away and a
  new block begun north of the tin drills: nine screeners at y 477.5 (x −49.5 to 6.5), six Jaw
  crushers at y 489.5 and 16 Stone furnaces, without power at the save. The tin drills wait until it
  runs; two chests at (−70.5, 525.5) and (−69.5, 525.5) hold 3,200 Tin plates and the author
  carries 741. That is the second part of this chapter.

## 7. Checklist

- Screen before you smelt: Lead takes 2 ore a plate instead of 6, Titanium 5.2 instead of 10, and
  a furnace makes 2.5 (lead) or 6 times (titanium) as many plates.
- The titanium chain has five steps with two by-products to place: Stone (bricks, here onto the
  bus) and Gravel (a Burner voids it).
- Size every stage for a full belt of ore, as the author did: then more drills are all it takes
  later.
- Fluid mining drills MK 02 mine twice as fast and need no fuel belt. The mining fluid is per
  cycle, so Mining productivity is free ore.
- Count the mining fluid of all the drills on one source: two blocks that each fit can together
  want more than it makes (section 4).
- A store that fills is not a fault while nothing uses the product; measure such a block with its
  output taken away.

## 8. How these facts were checked

- The run: the companion mod's recorder (run `2652821414-0`, last record 27:39), read with
  `tools/recorder-phases.js` (10-minute slices; the minute records for the order of the building)
  and `tools/recorder-log.js` (production per 10-minute window); no chat notes since 21:25
  (`tools/recorder-summary.js`).
- The save of 27:39 (`Py-Exploration`, copied to `C:\tmp\ch11` before reading; consistency check
  passed): `tools/inspect-save.ps1`, `tools/summarize-save.js`, `tools/trace-layout.js` (belt
  lines, what each machine takes and gives), `tools/render-area.js`.
- Data: recipes, machines, ore mining times and fluids, technologies (`tools/q.js`, the data dump
  of 2026-10-18).
- The hour after the save: `tools/save-probe.ps1 -Probe rate-probe -Ticks 219700 -Variant
  '60,3600,600,<items>'`, as saved and with the outputs taken away. For the second the probe got
  two pseudo-entities (new): `sink@x:y` empties the belt on that tile every tick and `empty@x:y`
  the chest on that tile every second, printing what they took. Titanium: `sink@-60.5:443.5`,
  `empty@-60.5:441.5`, `empty@-59.5:441.5`; lead: `sink@-126.5:-73.5`, `empty@-129.5:-71.5`. A
  first try with the lead sink one tile off (no belt there) left the lead chest's inserter as the
  only taker: 0.82 Lead plates a second, the inserter's limit, not the block's.
