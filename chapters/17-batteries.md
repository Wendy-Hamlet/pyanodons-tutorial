# Chapter 17: Batteries

[中文](17-batteries.zh-CN.md) · [Contents](../README.md) · Previous:
[Chapter 16](16-auogs.md)

This chapter follows the same recorded game from the save of 43:42 to the save of 45:20. The
author named its theme: **Batteries**. With the Auogs of chapter 16 the author built the battery
line north of the base, rebuilt it once after finding a better recipe, and brought the bus to it.
Times are game times. The numbers come from the game data, the recorder, the author's Factory
Planner draft 电池 (44:53), and the saves of 43:42 and 45:20 (`tools/inspect-save.ps1`, and
`tools/rate-probe` for one and three hours, with what-ifs).

Conclusions:

- **The line makes 6 Batteries a minute, as many as its Chemical plant can.** The first came after
  45:10; at 45:20, 32 wait in the chest. Run on from the save it keeps 6 a minute for 40 minutes,
  then about 5.3: the last two Auog paddocks often wait for Water barrels. With five more Water
  barrels in each of them it keeps 6 for the whole hour.
- **The author's redesign: Ammonia into Cyanic acid.** The first draft left 180 Ammonia a minute
  without a user. A Quenching tower makes Cyanic acid from that Ammonia, Methane and Coal (the
  author's note at 44:07); now nothing is left over and a Battery takes 11.3 Urea instead of 21.3:
  3.43 paddocks instead of 6.46. The author built 4, with 16 Auogs.
- **The bus goes north** to the line: belts of Lead plates, Zinc plates, Coke and Antimony oxide,
  pipes of Gasoline, Molten glass and Steam. The line's Hydrogen, Coal gas and Tar go back into the
  bus through Check valves; the Carbon dioxide and Muddy sludge of its Melamine are voided on the
  spot.
- **What Batteries are for next**: one in each combinator (Cybersyn's requests), two in each
  Construction pynobot and roboport, three in every 12 Logistic science packs.
- **Left alone, the save runs down within the hour and does not recover**, and research stops with
  it. The cause is not the battery line: six Ash chests at the Raw coal drills north of the base are
  full (two filled between the two saves), so the Steam for the tar refinery fails, and with it
  Coke, Tar, Acetylene and the science packs. Emptying the chests, or topping the Steam up (the
  author's test), keeps the base running.

## At a glance

| Game time | What happened |
|---|---|
| 43:42 | Save after chapter 16 |
| 43:40–44:00 | The Auog corner laid out for the battery line: Moss farms, a row of Auog paddocks, a Moondrop greenhouse, a Washer and a Soil extractor; at 43:55–44:00 robots rebuild it from a blueprint, paddocks at y −408 |
| 43:52 | Cooling tower 1 researched; next Domestication - Stage 1 |
| 44:00–44:05 | 100 Empty barrels handcrafted; Barreling Machine at (−51, −398) |
| 44:07 | Chat note: "发现氨可以转化为氰酸，重新设计" (found that Ammonia can be turned into Cyanic acid; redesigning) |
| 44:05–44:20 | Bioreactors for Liquid manure and Urea, and the Urea decomposition column at (4, −385); robots rebuild the corner again: 4 Moss farms at y −423, Moondrop greenhouses for Carbon dioxide |
| 44:18 | Domestication - Stage 1; next Fiberboard |
| 44:25–44:35 | Fluidised bed reactor for Melamine at (−1, −397) with an Exhaust pipe and a Sinkhole; a Destructive distillation column making Coal from Wood at (−57, −434); assemblers for Iron sticks and Bolts |
| 44:35–44:45 | High pressure furnace for Graphite and Smelter for Lead antimony alloy at (−50, −450) |
| 44:45–44:55 | Quenching tower for Cyanic acid at (−43, −434); a Botanical nursery and Moondrop greenhouses for Methane |
| 44:47 | Fiberboard; 44:55 Floor tiles - Stage 1; 45:09 Mycology - Stage 1; next Starch - Stage 1 |
| 44:53 | Factory Planner draft 电池 saved: 6 Batteries a minute |
| 45:00–45:05 | Chemical plant for Batteries at (5, −434), its chest beside it |
| 45:00–45:20 | The bus extended north to the line (about 1,500 belt tiles); Check valves for the line's Hydrogen, Coal gas and Tar at y −393.5 |
| 45:15–45:20 | Overflow valves where the first coke columns' Coal gas and Tar join the bus, at (−69.5, −93.5) and (−69.5, −81.5) |
| 45:20 | Save (`Py-Exploration`, 45.3 hours); 32 Batteries in the chest |

## 1. What a Battery takes

The Battery (Battery - Stage 1; Chemical plant, 10 s): a Glass, 2 Melamine, a Lead antimony alloy,
3 Bolts, 3 Graphite, 3 Zinc plates and 30 Cyanic acid (data). The chain behind the two chemicals:

| Product | Machine, time | Takes |
|---|---|---|
| 30 Ammonia + 30 Cyanic acid (Urea decomposition) | Destructive distillation column, 8 s | 20 Urea |
| 100 Cyanic acid + 50 Hydrogen | Quenching tower, 5 s | 100 Methane, 100 Ammonia, 20 Coal |
| 20 Melamine + 30 Carbon dioxide + 50 Muddy sludge | Fluidised bed reactor, 10 s | 200 Water, 20 Cyanic acid, 20 Ammonia |
| 30 Urea | Bioreactor, 8 s | 100 Liquid manure, 10 Zogna bacteria |
| 100 Liquid manure | Bioreactor, 8 s | 10 Manure, 500 Water |
| 3 to 8 Manure + 5 Empty barrels | Auog paddock, 100 s | 20 Native flora, 10 Moss, 5 Water barrels |
| 16 Moss | Moss farm, 80 s | 100 Muddy sludge, 100 Carbon dioxide, 20 Stone |
| 40 Methane | Moondrop greenhouse, 15 s | 100 Water, 100 Carbon dioxide, a Moondrop seed |
| 10 Coal + 10 Coal gas + 30 Tar + an Iron oxide | Destructive distillation column, 3 s | 10 Wood |
| 2 Graphite | High pressure furnace, 3 s | 5 Coke |
| a Lead antimony alloy | Smelter, 10 s | 6 Lead plates, an Antimony oxide |

The rest come from the bus: Zinc plates, Glass (made in the line from Molten glass), Bolts from Iron
plates. Paddocks, Moss farms and Moondrop greenhouses have −100 % speed of their own and run on
their modules (chapter 16): a paddock with 4 Auogs runs at speed 2, a Moss farm with 15 Moss at 1,
and the author's Moondrop greenhouses with 16 Moondrop at 1.5, because the Carbon capture upgrade
of chapter 5 adds a hidden module (data; `tools/save-probe.ps1 -Probe turd-probe`).

## 2. The redesign: Ammonia into Cyanic acid

A Battery takes 32 Cyanic acid (30, and 2 for its Melamine) but only 2 Ammonia, while Urea
decomposition makes the two in equal parts. The first draft (43:11, chapter 16) made all its Cyanic
acid that way: 21.3 Urea a Battery, and 30 Ammonia left over, 180 a minute at 6 Batteries.

At 44:07 the author noted "发现氨可以转化为氰酸，重新设计" (Ammonia can be turned into Cyanic acid;
redesigning). The Quenching tower's Cyanic acid recipe (Melamine, already researched) takes Ammonia
one for one, with Methane and a little Coal. Now Urea decomposition only has to make 17 of each a
Battery, the 15 spare Ammonia become Cyanic acid, and nothing is left over:

| A Battery takes | First draft (43:11) | Redesign (44:53) |
|---|---|---|
| Urea | 21.3 | 11.3 |
| Manure | 7.1 | 3.8 |
| Auog paddocks at 6 a minute (4 Auogs each) | 6.46 | 3.43 |
| Ammonia left over | 30 | 0 |
| Methane, Coal | – | 15, 3 |
| Hydrogen made | – | 7.5 |

The draft's Methane comes from a Moondrop greenhouse fed with Carbon dioxide from two more, its Coal
from Wood in a Destructive distillation column. The author built 4 paddocks with 16 Auogs; 35 more
Auogs are in the inventory.

## 3. The line

![The north part of the battery line at 45:20: top left the Smelter for Lead antimony alloy and the High pressure furnace for Graphite, beside them the Moondrop greenhouse growing Moondrop for seeds and the Botanical nursery; below, the Destructive distillation column that makes Coal from Wood, the assemblers for Iron sticks and Bolts, the Quenching tower and the greenhouses for Methane and Carbon dioxide; right the Chemical plant for Batteries and its chest; the bus comes in from the left](../images/ch17-battery.jpg)

It fills the corner north of the base, x −60 to 10, y −456 to −380, where the Zogna bacteria line of
chapter 16 already stood:

- **North**: the Smelter for Lead antimony alloy and the High pressure furnace for Graphite at
  (−50, −450), the Wood column for Coal, the assemblers for Bolts, the Quenching tower at
  (−43, −434), the Moondrop greenhouses for Methane and Carbon dioxide with their nursery, and the
  Chemical plant at (4.5, −434.5) with the Batteries' chest.
- **Middle**: 4 Moss farms at y −423 with a Jaw crusher making Stone from Stone bricks, a Washer
  and a Soil extractor for Muddy sludge, and a greenhouse for Carbon dioxide; below them the 4
  paddocks at y −408 and the Barreling Machine.
- **South**: the Zogna bacteria line of chapter 16, two Bioreactors (Liquid manure, Urea), the
  Urea decomposition column at (4, −385), and the Fluidised bed reactor for Melamine with an Exhaust
  pipe for its Carbon dioxide and a Sinkhole for its sludge.

What each stage can do, against 6 Batteries a minute (data), and how it ran in the hour after the
save (`tools/rate-probe`):

| Stage | Can make a second | Needed | Hour after the save |
|---|---|---|---|
| Batteries (1 Chemical plant) | 0.1 | 0.1 | working 96 % |
| Lead antimony alloy (1 Smelter) | 0.1 | 0.1 | working 100 % |
| Manure (4 paddocks, 16 Auogs) | 0.44 | 0.38 | working 76 % |
| Moss (4 Moss farms) | 0.8 | 0.8 with the paddocks at full speed | working 51 %, full 44 % |
| Urea (Bioreactor) | 3.75 | 1.13 | working 27 % |
| Ammonia and Cyanic acid (Urea decomposition) | 3.75 each | 1.7 each | working 40 % |
| Cyanic acid (Quenching tower) | 20 | 1.5 | working 7 % |
| Methane (greenhouse, speed 1.5) | 4 | 1.5 | working 37 % |
| Melamine (Fluidised bed reactor) | 2 | 0.2 | working 9 % |
| Graphite (High pressure furnace) | 0.67 | 0.3 | working 26 % |

The Chemical plant and the Smelter set the ceiling: both make exactly 0.1 a second. Everything else
has room, the paddocks least.

## 4. Six a minute, and the Water barrels

![The middle of the line at 45:20: at the top the four Moss farms with the Jaw crusher on the left and the Washer, Soil extractor and Carbon dioxide greenhouse on the right; below them the four Auog paddocks with four Auogs each; at the bottom left the Barreling Machine, from which the Water barrels run past the paddocks and the empty ones come back](../images/ch17-manure.jpg)

Run on from the save, the line made 0.100 Batteries a second for 40 minutes, then 0.090, 0.087,
0.080 and 0.090 in the last four 5-minute steps (`tools/rate-probe`, an hour). The Urea, Ammonia and
Cyanic acid in the pipes ran out, and the paddocks gave 0.334 Manure a second, not 0.38: they waited
for an ingredient 24 % of the time.

The ingredient is the Water barrel. The Barreling Machine fills barrels; a belt takes them past the
four paddocks, and the empty ones come back. At 45:20 the loop holds about 60 barrels: 20 in the
paddocks' input slots (10, 9, 1 and 0 from west to east), 20 empty on the belts, and up to 20 inside
the four crafts that are running. The first paddocks on the belt fill their slots first; the last
two wait. The Barreling Machine itself waited for Empty barrels 87 % of the hour.

**What-if** (`tools/rate-probe` with `add@x:y::water-barrel*5`, the player handing barrels in): five
Water barrels more in each of the last two paddocks, and the line made 0.100 a second in every step
of the hour, the paddocks working 82 %. Ten more in each did the same. The author carries 51 Empty
and 59 Water barrels.

## 5. Byproducts and the bus

![The south of the line at 45:20: left the Bioreactors for Liquid manure and Urea; in the middle the Fluidised bed reactor for Melamine with the Exhaust pipe for its Carbon dioxide and the Sinkhole for its Muddy sludge; right the Destructive distillation column for Urea decomposition; the belt up the right carries Glass and Melamine north to the Chemical plant](../images/ch17-urea.jpg)

At 6 Batteries a minute the line gives off, a second: 0.75 Hydrogen (Quenching tower), 0.9 Tar and
0.3 Coal gas (Wood column), 0.3 Carbon dioxide and 0.5 Muddy sludge (Melamine). The last two go into
the Exhaust pipe and the Sinkhole beside the reactor (measured: 0.28 and 0.47 a second flowed in).
The first three go back into the bus: Check valves facing south at y −393.5 on its Hydrogen
(x −112.5), Coal gas (x −102.5) and Tar (x −101.5) pipes. An empty belt at x −91.5 takes the Wood
column's Iron oxide back south.

The bus itself now runs north to y −456: belts of Lead plates (x −81.5, 211 tiles new), Coke
(x −71.5), Zinc plates (x −78.5), Antimony oxide (x −86.5), Stone bricks and Iron plates; pipes of
Gasoline, Molten glass and Steam. The Coke takes a priority Splitter at (−72, −253.5) into the new
belt.

**Gasoline instead of Naphthalene oil.** The north Glassworks (Molten glass, Petri dishes, Glassware)
burned Naphthalene oil at 43:42; now they and the new Smelter burn Gasoline, and the two Check valves
of the Naphthalene oil pipe are gone. In the hour after the save the base used 58 to 60 Gasoline a
second against 27 made; the two Gasoline ponds at (−158, 3) and (−139, 3), each 57 % full, hold
about ten hours of that. Naphthalene oil, used 17 a second at 43:42, now goes almost all into its
pond at (−139, −56) (595,000 free).

**Overflow valves at the first coke columns.** At 45:15–45:20 the author put Overflow valves where
the Coal gas and Tar of the coke columns at y −88 join the bus: they now pass only while the
columns' own pipes are over 80 % full. In a what-if with plain pipes there instead, the hour ran the
same.

## 6. Research and what Batteries are for

Research in this chapter: Cooling tower 1 (43:52), Domestication - Stage 1 (44:18), Fiberboard
(44:47), Floor tiles - Stage 1 (44:55), Mycology - Stage 1 (45:09). Starch - Stage 1 stands at 33 %,
then come Cottongut - Stage 1, Solidified sarcorus and Fertilizer - Stage 1: the way to the next
science pack.

Recipes that take Batteries (data):

| Recipe | Batteries |
|---|---|
| Arithmetic, Decider and Constant combinators | 1 each |
| Construction pynobot MK 01, Logistic pynobot MK 01, Py roboport MK 01 | 2 each |
| Logistic science pack (90 s, 12 packs; with 2 Poor alien samples, a Solidified sarcorus and 2 Animal samples) | 3 |
| Simple circuit board (second recipe, 5 boards) | 1 |

The combinators are what chapter 15 waited for: Cybersyn's requests need them. At 6 a minute the line
makes a combinator's Battery every 10 seconds; for the Logistic science pack, 6 a minute are enough
for 24 packs a minute.

## 7. What stands at 45:20

- **Research**: 124 technologies; Starch - Stage 1 at 33 %. The T.U.R.D. picks are unchanged (the
  Moss farm upgrade is still not picked).
- **Auogs**: 51 in all, 16 in the four paddocks and 35 in the inventory; no Auog is bred any more.
- **The battery line** as in section 3, 32 Batteries in its chest; the bus north to it.
- **Unchanged**: the rail network of chapter 15, not joined to the base; no Cybersyn station yet.

## 8. The hours after the save

The save of 45:20 run on without the player (`tools/rate-probe`, three hours):

| A second | 10 min | 20 | 30 | 40 | 50 | 60 | 90 | 120 | 180 |
|---|---|---|---|---|---|---|---|---|---|
| Tar made | 40.7 | 41.0 | 39.8 | 33.8 | 19.7 | 4.6 | 0 | 0 | 0 |
| Coke made | 11.0 | 11.1 | 10.8 | 9.2 | 5.5 | 1.2 | 0 | 0 | 0 |
| Red packs used | 0.20 | 0.20 | 0.20 | 0.20 | 0.19 | 0.11 | 0.07 | 0.04 | 0 |
| pY1 packs used | 0.10 | 0.10 | 0.10 | 0.10 | 0.09 | 0.06 | 0.03 | 0.02 | 0 |
| Batteries made | 0.100 | 0.100 | 0.100 | 0.100 | 0.088 | 0.085 | 0.012 | 0 | 0 |
| Power used (MW) | 137 | 127 | 108 | 84 | 77 | 56 | 41 | 23 | 9 |

The base runs down within the hour and does not come back: Tar flickers up once (6.8 a second at
80 minutes) and stops again; Acetylene stops with the Coke (its Calcium carbide takes Coke), and with
it the lead drills; research has almost stopped at two hours and stops at two and a half.

**The cause, step by step** (from the saves and the timelines):

1. Six wooden chests on the Raw coal field north of the base, at (24, −87), (52, −70) and (54, −79),
   store the Ash of its Burner mining drills. All six are full (16,000 Ash); two of them filled
   between the saves (from 14,145 and 14,379).
2. Behind the full chests, Burner mining drills stop with their Ash slot full (six at x 55 to 59
   alone). The belt at x 71.5 that they feed carried 1,437 Raw coal at 43:42 and 469 at 45:20.
3. That belt fuels the north row of the 24 Raw coal Boilers at (−42, 110): at 45:20, 8 of its 12
   have no fuel. Those Boilers' Steam goes past an Underflow valve at (−60.5, 110.5) into the long
   Steam pipe along the bus to the tar refinery at (−150, −100): three Tar processing units and three
   Destructive distillation columns. At 43:42 that pipe held Steam; at 45:20 it is empty, and the
   refinery works on the Steam stored near it.
4. The units' Tar refining bottoms take 100 Steam with 100 Tar, the columns' Coke recipe 100 Steam
   with 100 Pitch. When the stored Steam runs out (about 30 minutes), they slow; that Coke recipe
   and the Gasoline recipe from Anthracene oil (5 Coke besides) make most of
   the base's Coke, so Coke falls, then Acetylene, the lead drills and the science packs.

**Tests** (`tools/rate-probe` what-ifs, an hour each):

- The six Ash chests emptied every second (`empty@x:y`): the hour holds: Tar 34, Coke 9.4, packs
  as before (0.20 and 0.10), 89 MW at the end. The chests took 3.6 Ash a second.
- The author's test: an endless Steam source (`infinity-pipe`, 250 °C) behind an Underflow valve on
  the refinery's Steam pipe, so it only tops the pipe up: the hour holds the same way (Tar 34, Coke
  9.4), and the source gave 81 to 93 Steam a second.
- None of these changed the run-down: the Electrolyzers off, the battery line's Smelter off, its
  Wood column off, its Graphite furnace off, the new Overflow valves replaced by pipes, the Coke
  Splitter without priority, the Gasoline pump of the research Glassworks off, a Tailings pond on
  the Tar pipe. So the battery line is not the cause; the Ash chests were filling before it.
- The save of 43:42, run for three hours, shows the same timer: Tar holds at 34 a second for two
  hours and twenty minutes, then falls (23 at 160 minutes, 11 at 180), and research stops at three
  hours.

**Fixes** (the author's choice):

- Empty the six chests by hand: that buys time, but they fill again.
- Give the field's Ash a lasting way out, about 3.6 a second: the Solid separators of the Ash
  separation, three of them at (−42, 97.5) beside those Boilers, waited for Ash 57 % of the hour.
- The author's idea, a Raw coal Steam block for the refinery: the test needed up to 93 Steam a
  second. A Boiler takes 3.7 MW and makes 7.5 Steam a second at 250 °C (data), so about 12 Boilers,
  14.5 Raw coal and 14.5 Ash a second; that block needs its Ash handled too.

On the way it turned out how the Glassworks at y 348.5 (Molten glass for research) get their fuel:
three pumps that the author switches by circuit (`tools/wire-probe`): Hydrogen while the Hydrogen
pipe holds any, Syngas when it is empty, Gasoline only when both are.

## 9. The blueprints

- **New**: `battery` ("0.1 battery"), the line of section 3, 70 × 75 tiles: 6 Batteries a minute
  with ten more Water barrels in its loop, 5.3 without. The book now holds 47 blueprints.
- **Changed**: `simple-circuit-board`, one Pipe to ground fewer and three Small electric poles
  more; the block stood full in the hour after the save, as before.
- Still waiting: the author's supply station 固体供货站-1 (chapter 15), until a Cybersyn station is
  built.

## 10. Key points

- Count what each product takes, then let the byproduct nobody uses become an input: the
  Quenching tower turns the spare Ammonia into Cyanic acid and halves the Auogs.
- A barrel loop needs enough barrels for every machine's input slots and its running crafts; the
  first machines on the belt fill their slots first.
- A chest that stores a byproduct is a timer: the base runs until it is full. Six Ash chests at
  the Raw coal drills ended the Steam for the tar refinery, and with it Coke, Tar, Acetylene and
  research, within two hours and for good.
- To find the first cause, test what-ifs that each take one suspect away; when all fail alike, the
  cause is elsewhere. An endless source behind an Underflow valve tests a missing input and
  measures how much is missing.

## 11. How these facts were checked

- The saves of 43:42 and 45:20 (`Py-Exploration`, copied to `C:\tmp\ch16` and `C:\tmp\ch17`;
  consistency check passed): `tools/inspect-save.ps1` and `tools/summarize-save.js`; machines
  added and removed between them; the line traced with `tools/trace-layout.js` and
  `tools/manual-links.js`; production counters compared; T.U.R.D. picks with
  `tools/save-probe.ps1 -Probe turd-probe`; the pumps' circuit conditions with `-Probe wire-probe`.
- The recorder: `tools/recorder-phases.js` in 5-minute slices.
- The author's Factory Planner draft 电池 (44:53): `tools/planner-summary.js`.
- The hours after the save: `tools/save-probe.ps1 -Probe rate-probe` for one and three hours, with
  the what-ifs `add@` (Water barrels), `empty@` (Ash chests), `off@`, `remove@` with a placed Pipe or
  Splitter, `tailings-pond@` and `infinity-pipe@…::steam*250` behind a `py-underflow-valve`.
- Data facts: `tools/q.js` and the recipes, machines and modules in the data dump.
- Screenshots: taken by the author with the companion (`/pt-shots`), areas planned with
  `node tools/shots.js plan`.

Next chapter: chapter 18 (to come).
