# Chapter 2 — Coke, steel and crushed iron

[中文版](02-coke-steel-crushed-iron.zh-CN.md) · [Index](../README.md) · Previous:
[chapter 1](01-landing-to-red-science.md) · Next: [chapter 3](03-ash-separation-raw-coal-power.md)

This chapter follows the same recorded run as chapter 1, from 0:40, when the first distillation
column went down, to 3:37: Coke from Raw coal, Steel, the power for both, the Crusher technology,
and at last automated smelting — iron through Jaw crushers, copper in the burner smelting column.
The author built every block of this stage from their own blueprints, which are now in
[blueprints](../blueprints/README.md). Times are game time (the author also spent 1.2 hours with
the game paused in Factory Planner, which game time does not count). Numbers come from the game's
data, from the recorder's production statistics in 10-minute windows, and from running the save
of 3:37 for one more minute (`tools/inspect-save.ps1 -Ticks 3700`).

The plan in one sentence: a full belt of Raw coal into Coke, Coke and Iron ore into Steel, twelve
Boilers on a second full belt of Raw coal, and the first Steel into Jaw crushers that turn a full
belt of Iron ore into 3 Iron plates a second.

## The run at a glance

| Game time | What happened |
|---|---|
| 0:40–1:00 | Steel processing done (0:48), Soil washing done (0:58); five Destructive distillation columns, laid out twice |
| 1:00–1:10 | A Tailings pond for the Tar and an Exhaust pipe for the Coal gas |
| 1:10–1:30 | The steel site: three Advanced foundries as a trial, then eight, each under its own Soil extractor |
| 1:30–1:50 | Power: twelve Boilers and six Steam engines (placed twice); two Raw coal modules, one for the power and one for the coke. The first Tar and Coke |
| 1:50–2:00 | Iron ore drill rows on a fuel loop feed the steel site; the first 28 Steel plates |
| 2:00–2:11 | Steel axe completes by itself at 50 Steel plates (2:01); Crusher researched (2:01–2:11); a second lab (2:10); a drill field for the crushers' Iron ore |
| 2:10–2:30 | A 7-drill Raw coal module for a fuel trunk; the first Jaw crushers, tried in several places |
| 2:40–3:00 | The steel chest reaches its limit of 500 and the steel line stops; the crushed-iron block is moved to its final place |
| 3:00–3:10 | Crushed iron starts |
| 3:10–3:30 | Copper: two smelting columns on a new drill field; the old drill-and-furnace pairs come down |
| 3:30–3:37 | Trees cleared; the author scouts farther out |

Production per second (10-minute windows from the recorder; the last row is the minute measured
after 3:37):

| Window ending | Raw coal mined | Coke | Steel plate | Processed iron ore | Iron plate | Stone brick | Copper plate | Ash | Steam |
|---|---|---|---|---|---|---|---|---|---|
| 1:50 | 7.83 | 0.06 | 0 | 0 | 1.72 | 0.22 | 0.31 | 6.78 | 12.9 |
| 2:00 | 13.58 | 0.48 | 0.05 | 0 | 0.74 | 0.29 | 0.32 | 5.56 | 9.4 |
| 2:10 | 25.93 | 2.71 | 0.43 | 0 | 0.73 | 0.13 | 0.24 | 14.09 | 50.6 |
| 2:20 | 27.22 | 2.20 | 0.44 | 0 | 0.35 | 0.12 | 0.63 | 13.89 | 49.1 |
| 2:30 | 25.73 | 2.21 | 0.44 | 0 | 0.38 | 0 | 0.38 | 13.60 | 52.0 |
| 2:40 | 21.09 | 1.91 | 0.39 | 0 | 0 | 0 | 0 | 10.17 | 43.5 |
| 2:50 | 8.36 | 0.75 | 0.15 | 0 | 0.41 | 0 | 0 | 4.87 | 17.1 |
| 3:00 | 3.37 | 0.26 | 0.06 | 0 | 0.18 | 0 | 0 | 2.17 | 7.7 |
| 3:10 | 5.43 | 0 | 0 | 5.66 | 1.71 | 1.09 | 0 | 4.91 | 11.7 |
| 3:20 | 11.32 | 0 | 0 | 8.70 | 2.89 | 1.50 | 0 | 10.79 | 36.2 |
| 3:30 | 11.21 | 0 | 0 | 9.00 | 3.00 | 1.50 | 0.30 | 9.82 | 25.9 |
| 3:37 + 1 min | 14.5 | 0 | 0 | 9.05 | 3.02 | 1.52 | 1.85 | 13.5 | 27.4 |

Read with the timeline: Coke and Steel ran from 2:00 and stopped when the steel chest was full
(the author's account; the save of 3:37 shows the chest at 500); iron plates almost stopped while
the drill-and-furnace pairs came down and the crushers were not yet running; copper made nothing
from 2:30 to 3:20, until the columns took over.

![The base at 3:37. Top left: the steel site, the five distillation columns below it and the Tailings pond; the starting lake beside them. Top right: the power block and the Raw coal modules on the coal field (black). Middle: the crushed-iron block, its drill field on the iron ore (grey) to the right. Bottom left: the copper columns, fed from the copper field at the bottom right. The bus runs north along the left edge.](../images/ch2-base.jpg)

## 1. The technologies of this stage

| Technology | Cost | Researched | Unlocks what this chapter uses |
|---|---|---|---|
| Coal processing 1 (chapter 1) | 12 red | 0:33–0:39 | Destructive distillation column MK 01, Coal from Raw coal, Coal gas from Coal (with Coke), Limestone, Tailings pond, Exhaust pipe |
| Steel processing | 18 red | 0:39–0:48 | Advanced foundry MK 01, Steel plate |
| Soil washing | 18 red | 0:49–0:58 | (needed for Crusher) |
| Steel axe | Trigger: make 50 Steel plates | 2:01 | Mining by hand twice as fast; Light armor |
| Crusher | 24 red | 2:01–2:11 | Jaw crusher MK 01, Processed iron ore and the Iron plate made from it |
| Ash separation | 60 red | from 2:11, 27 % at 3:37 | Solid separator MK 01 (next chapter) |

Crusher was queued at 0:58 but got no packs until 2:01, while the author built the coke chain.
Researching it earlier would not have helped much: a Jaw crusher needs 30 Steel plates, and the
first Steel came at about 2:00.

## 2. Raw coal on three belts

This stage burns far more Raw coal than chapter 1: 26–27 a second from 2:00 to 2:30, against
4–11 in chapter 1. It comes from the Raw coal module of chapter 1 ([`raw-coal-module.txt`](../blueprints/raw-coal-module.txt),
a full belt of 15/s from nine drills):

- **Two modules side by side** at the edge of the coal field (1:40–1:50): one belt to the
  Boilers, one to the distillation columns.
- **A 7-drill cut of it** farther east (2:10–2:20), at most about 10.8 Raw coal/s (chapter 1,
  section 7), feeds a **fuel trunk** that runs south along the
  east edge of the base. Inserters move Raw coal from it onto belts running west: the fuel loops
  of the iron and copper drill fields, the furnaces of the crushed-iron block and the copper
  columns.

The pinwheels of chapter 1 stay as hand-picked reserve.

![Two Raw coal modules (four drill rows) at the edge of the coal field; their belts leave to the left, the upper one to the power, the lower one to the coke](../images/ch2-raw-coal-modules.jpg)

## 3. Power: twelve Boilers on one belt

Blueprint: [`raw-coal-power.txt`](../blueprints/raw-coal-power.txt), the author's
"初期满带原煤发电（不清灰）": early power on a full belt of Raw coal, Ash not cleared.

- **Layout.** An Offshore pump at the top, twelve Boilers in a column, six Steam engines beside
  them, and the Raw coal belt along the other side of the Boilers with **two inserters per
  Boiler**: a Boiler at full load burns 1.23 Raw coal/s, more than one inserter's 0.83/s.
- **From data.** 12 Boilers make 90 Steam/s, exactly what 6 Steam engines use (two Boilers per
  engine): **22.2 MW**, burning **14.8 Raw coal/s** at full load, which is a full belt.
- **Measured.** 49–52 Steam/s from 2:00 to 2:30 while coke and steel ran, that is 12.1–12.8 MW;
  27.4 Steam/s (6.8 MW) in the minute after 3:37, with only the crushers working.
- **No Ash inserters.** Each Boiler keeps its Ash until the 1000-Ash slot is full, then stops: in
  13.5 minutes at full load, in about 23 minutes at the 58 % load of 2:00–2:30. The author empties
  them by hand (and carried 63,680 Ash at 3:37). In the save of 3:37 five of the twelve stood with
  full Ash slots. That cost nothing then, because the load was low; but with everything running —
  columns 2.5 MW, foundries 9.6 MW, Soil extractors 3.6 MW, crushers 6 MW and the labs and Flora
  collector — the base draws **21.9 MW**, all twelve Boilers' worth. Empty them before the steel
  line runs again.

![The power block: Offshore pump at the top, twelve Boilers, six Steam engines, the Raw coal belt on the right](../images/ch2-power.jpg)

## 4. Coke: five distillation columns

Blueprint: [`coke-distillation.txt`](../blueprints/coke-distillation.txt), "2.7 [Coke]".

| Recipe (Destructive distillation column MK 01, 8×8, 500 kW) | In → out |
|---|---|
| Coal | 10 Raw coal → 3 Coal + 60 Coal gas + 30 Tar + 1 Iron oxide (20 %), 2 s |
| Coal gas (from Coal) | 10 Coal → 6 Coke + 40 Coal gas + 50 Tar + 1 Iron oxide (30 %), 3 s |

- **Ratio 3 : 2.** One column eats 5 Raw coal/s, so three take a full belt and make 4.5 Coal/s;
  one column turns 3.33 Coal/s into 2 Coke/s, so 1.35 columns would do and the author builds two.
  The block makes **2.7 Coke/s** from 15 Raw coal/s, and with it 108 Coal gas, 67.5 Tar and
  0.44 Iron oxide per second.
- **Layout.** The five columns stand in a row. Raw coal comes on a belt along the bottom of the
  three Coal columns, seven inserters each (5/s is more than six inserters move). Their Coal goes
  over the top by belt to the two Coke columns, and the Coke leaves by belt for the steel site.
  Iron oxide goes on a belt into a chest; it smelts 2 to 1 into Iron plate.
- **Byproducts, the author's way:** "焦油储存到临时尾矿池，煤气暂时销毁" — the Tar is stored in a
  temporary Tailings pond, the Coal gas is destroyed for now. A column stops when any output is
  full, so both need a way out from the first minute:
  - **Coal gas → Exhaust pipe** (part of the blueprint). It needs no power and its venting recipe
    takes 20,000 Coal gas per craft at speed 2 (from data), so one pipe has no practical limit:
    it vented about 88 Coal gas/s here from 2:00 to 2:30 (measured).
  - **Tar → Tailings pond** (18×18, holds 1,000,000; not part of the blueprint). By 3:37 it held
    160,300 Tar, 16 % of it. A Sinkhole (Steel processing) would void Tar for good.
- **Measured.** 2.71 Coke/s from 2:00 to 2:10 (partly from Coal stocked earlier), then 2.2/s,
  the pace of the steel site (5 Coke per Steel plate). In the save of 2:01 the three Coal columns
  stood with full outputs: Coke was not what held steel back.

![The coke block: the two Coke columns (left) and three Coal columns, the Raw coal belt below them, the Exhaust pipe at the top left, the Tailings pond at the bottom right and the starting lake in front](../images/ch2-coke.jpg)

## 5. Steel: eight foundries under eight Soil extractors

Blueprint: [`steel-foundries.txt`](../blueprints/steel-foundries.txt), "0.53 [Steel plate]".

Steel plate: 5 Coke + 20 Iron ore + 5 Limestone → 1 in 15 s, in an Advanced foundry MK 01 (6×6,
1.2 MW). Limestone: 400 Water → 8 in 20 s, in a Soil extractor MK 01 (7×7, 400 kW).

- **Each foundry has its own Soil extractor** right above it. A Soil extractor drops its product
  by itself 3.8 tiles below its centre, into the foundry (measured in chapter 1's research, see
  [techniques](../research/techniques.md)). One Offshore pump waters all eight. An extractor makes
  0.4 Limestone/s and a foundry needs 0.33, so no belt carries Limestone at all.
- **A circuit per pair:** the foundry reads its contents to its extractor, which runs only while
  the foundry holds fewer than 5 Limestone (read from the blueprint).
- **Two belts.** Iron ore on one, taken by two inserters per foundry (a foundry at full speed
  takes 1.33 Iron ore/s). Coke and Steel share the other: one inserter takes Coke from it, one puts Steel
  on it. At the end an inserter filtered to Steel fills a chest **limited to 500** (five slots).
- **When the chest is full** the Steel stays on the belt, the foundries fill up and stop, Coke
  backs up into the columns, and the extractors stop too: the whole chain idles until Steel is
  taken out. That is what happened from 2:40 (the author's account).
- **From data:** 0.533 Steel/s for 10.7 Iron ore, 2.67 Coke and 2.67 Limestone per second.
- **Measured:** 0.43–0.44 Steel/s from 2:00 to 2:30, 83 % of that.
- The author's note on the blueprint: "留有空间把钢接入总线（似乎没必要）" — room is left to put
  the Steel on the bus, which seems unnecessary.

**What holds it at 83 %: the circuit starts the extractor too late.** The extractor only starts
once the foundry holds fewer than 5 Limestone, that is, when the foundry has just taken its last
full batch. A foundry craft takes 15 s, the extractor's takes 20 s, so the foundry finishes and
then waits about 5 s for the next 8 Limestone, on most crafts. Measured in the engine on a copy of
the save of 3:37 (the steel chest and the Steel on the belts emptied, the Boilers' Ash cleared,
then ten minutes after a two-minute warm-up):

| Circuit condition on the Soil extractors | Steel per second | Each foundry |
|---|---|---|
| Limestone < 5 (as built) | **0.440** | 3.30 a minute, short of Limestone in 17 % of the samples |
| Limestone < 10 | **0.533** | 4.00 a minute, never short |
| None (the extractor always runs) | **0.533** | 4.00 a minute, never short |

So the block itself is right except for one number: **set the condition to Limestone < 10**. Then
the extractor starts while the foundry still holds a full batch for its next craft, so its 20 s
craft ends before the foundry needs more; it still idles 17 % of the time (no Limestone piles
up), and the eight foundries make their 0.533 Steel/s. Iron ore and Coke were never short in these runs.

One more thing the runs showed: when the chest is full, the Steel lane of the shared belt fills
too (about 270 plates here), and after the chest is emptied that backlog leaves through the one
inserter into the chest, at most 0.82 a second. Until it has drained, the foundries nearest the
chest find no gap for their Steel: with the backlog left on the belt, ten minutes gave 0.355
Steel/s as built and 0.418 with < 10. A second inserter into the chest (or two chests) would halve
that recovery (not measured).

The first 50 Steel plates completed Steel axe at 2:01; six Jaw crushers took 180 of them.

![The steel site: eight Soil extractors above eight Advanced foundries, the ore belt and the Coke-and-Steel belt below, the Offshore pump on the right](../images/ch2-steel.jpg)

## 6. Crushed iron: six Jaw crushers, 3 Iron plates a second

Blueprint: [`crushed-iron.txt`](../blueprints/crushed-iron.txt), "3 [Iron plate]".

| Recipe | Machine | In → out |
|---|---|---|
| Processed iron ore | Jaw crusher MK 01 (7×7, 1 MW) | 5 Iron ore → 3 Processed iron ore + 1 Stone, 2 s |
| Iron plate | Stone furnace | 3 Processed iron ore → 1, 6 s |
| Stone brick | Stone furnace | 2 Stone → 1, 3.2 s |

- **Ratios.** A crusher eats 2.5 Iron ore/s, so six take a full belt. Each crusher's 1.5
  Processed iron ore/s feeds three furnaces (0.5/s each), so 18 furnaces make **3 Iron plates/s**;
  the 3 Stone/s go to five brick furnaces (0.625/s each), **1.5 Stone bricks/s**.
- **Layout.** The six crushers stand in a row along the Iron ore belt, four inserters each. On
  their other side, per crusher, three inserters filtered to Processed iron ore and one filtered
  to Stone put them on separate belts. The Processed iron ore runs to a row of 18 furnaces, the
  Stone to a row of five. Every furnace has the chapter 1 arrangement: an input and an
  everything-but-Ash output inserter on the product side, a Raw coal and an Ash inserter on the
  fuel side. Plates, bricks and Ash end in chests, and plates and bricks also continue onto the
  bus (section 8).
- **Measured:** 3.02 Iron plates/s and 1.52 Stone bricks/s, from 9.05 Processed iron ore/s and
  15.1 Iron ore/s, in the minute after 3:37; exactly 3.00 and 1.50 over 3:20–3:30. The block runs
  at its label.
- **What it costs to run:** 6 MW for the crushers and 1.5 Raw coal/s for the 23 furnaces. Per
  plate that is 5 Iron ore instead of 8, and about 2.6 Raw coal instead of 2 once the crushers'
  power is counted at the Boilers ([coke and steel](../research/coke-and-steel.md), "What the two
  goals give"): crushing saves ore, not fuel. Against chapter 1's pairs, 3 plates/s would have
  taken 30 pairs and 24 Iron ore/s.

The Iron ore comes from a drill field of its own: rows of Burner mining drills on both sides of
the ore belt with fuel loops from the fuel trunk and Ash into chests, as in chapter 1's smelting
unit. It delivered a full belt, 15.1 Iron ore/s, in the measured minute.

![The crushed-iron block: six Jaw crushers on the right with the Iron ore belt below them, the row of 18 iron furnaces at the bottom and the five brick furnaces above it, the chests and the bus on the left](../images/ch2-crushed-iron.jpg)

## 7. Copper: two smelting columns

Copper cannot be crushed yet (Copper processing - Stage 1 comes after the Simple circuit board
technology; [chapter 1](01-landing-to-red-science.md#next-coke-steel-and-crushing)), so the
author smelts it directly, with chapter 1's column:
[`smelting-column.txt`](../blueprints/smelting-column.txt), "0.9375 [Iron plate]/[Copper plate]".

- Two columns of ten Stone furnaces, mirrored and fed from one Copper ore belt, take half a belt
  each: theoretical **1.875 Copper plates/s**. Raw coal comes from the fuel trunk.
- A new copper drill field of 23 drills fills the belt (15.1 Copper ore/s measured).
- **Measured:** 1.85 Copper plates/s in the minute after 3:37.
- The author's current column flows right to left with two chests at each end; the version
  measured in chapter 1 is the same column rotated half a turn, with three.

![The two copper columns: Copper ore arrives from the right, Raw coal on the black belt; plates leave at the left onto the bus](../images/ch2-copper-columns.jpg)

## 8. The start of a bus

Plates and bricks do not stop in chests. Three belts run north from the smelting along the west
edge of the base — Iron plate, Copper plate and Stone brick — and end there for now, full: a
buffer for whatever the next stage builds. A fourth belt beside them brings Coke from the columns
up to the steel site. This follows the author's rules for the bus (principles 11 and 12 in
[techniques](../research/techniques.md#design-principles-the-authors)): Stone travels as bricks,
and what needs only Water, like the foundries' Limestone, is made on the spot.

## 9. Ash

The base made 93,241 Ash by 3:37, 13.5 a second in the measured minute. The drill fields and
furnace rows put theirs into chests; the Boilers keep theirs until emptied by hand; the author
carried 63,680. Ash separation, researched next, is a way to get rid of Ash rather than a source
of metal: a Solid separator turns 10 Ash into Coal dust half of the time, Soot a fifth of the time
and Iron oxide one time in twenty ([coke and steel](../research/coke-and-steel.md)).

## 10. Checklist

- Raw coal: one full belt (a nine-drill module) for twelve Boilers, one for five distillation
  columns, and a fuel trunk for the drill fields and furnaces.
- Boilers without Ash inserters stop when 1000 Ash fill up; empty them, at the latest before
  everything runs at once (21.9 MW of 22.2).
- Distillation 3 : 2 (Coal : Coke columns); the Coal gas to an Exhaust pipe and the Tar to a
  Tailings pond from the first minute, or the columns stop.
- One Soil extractor above each Advanced foundry; no Limestone belt. If a circuit switches the
  extractor, start it below 10 Limestone, not 5 (0.533 against 0.440 Steel/s, measured).
- A limited chest at the end of the steel line stops the whole chain when enough Steel is made.
- Crushed iron: 6 Jaw crushers per full belt of Iron ore, 3 furnaces per crusher, one brick
  furnace per crusher's Stone. Copper stays in direct-smelting columns.
- Plates and bricks onto the bus, not only into chests.

## 11. How these facts were checked

- The run: the companion mod's recorder (run `2652821414-0`), read with
  `tools/recorder-phases.js` (timeline in 10-minute slices) and `tools/recorder-log.js`
  (production per 10-minute window, items and fluids). The author confirmed why steel stopped.
- The steel site in the engine: `tools/save-probe.ps1` runs a measurement mod inside a copy of
  the save; `tools/steel-probe` empties the steel chest, the Steel on the belts and the Boilers'
  Ash, sets the extractors' condition per variant, then samples every foundry each second for ten
  minutes after a two-minute warm-up (Steel made, status, the short ingredient).
- The save of 3:37 (`Py-Exploration`, consistency check passed): `tools/inspect-save.ps1`, then
  `tools/summarize-save.js`, `tools/render-save-map.js`, `tools/render-area.js` and
  `tools/trace-layout.js` (belt contents, what feeds what, machine states, Boiler Ash, the steel
  chest); the save of 2:01 for the state of the columns and foundries then.
- One more minute of the save of 3:37, measured in the engine: `tools/inspect-save.ps1 -Ticks
  3700` now also writes `production-measure.json`, everything the base made and used per second
  over that minute (printed by `summarize-save.js`).
- The blueprints: exported by the author with the companion mod and pulled into `blueprints/`;
  their layouts, recipes, filters, chest limits and circuit conditions read from the blueprint
  data. They were measured in the author's game as above, not in the design lab.
- Prototype values (recipes and chances, machine sizes and power, crafting speeds, the Exhaust
  pipe's venting recipe, the Tailings pond's capacity, technology costs and triggers): `data.raw`
  of the run's mod set (Factorio 2.1.21), dumped in the save setup.
- Computed from data, not measured: the ratios and theoretical rates, the Boilers' Ash times, the
  21.9 MW of everything running, the fuel per plate.
- Pictures: in-game screenshots with entity info (alt view), taken in the author's game with the
  companion's `/pt-shots` after 3:37.
