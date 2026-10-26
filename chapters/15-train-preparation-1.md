# Chapter 15: Train preparation 1

[中文](15-train-preparation-1.zh-CN.md) · [Contents](../README.md) · Previous:
[Chapter 14](14-intermetallics-trains.md)

This chapter follows the same recorded game from the save of 35:07 to the save of 41:05. The
author named its theme: **train preparation 1**. Very little was added to the base; the author
designed the railway instead. They chose the train, designed the junction, the lane change and the
pieces of a 240-tile grid, then a refuel station and a depot for Cybersyn, and laid the first stretch
of track east of the base, beside a large Raw coal field. Most of the designing went together with
measurements: the author drew a design, it was measured in the engine, the author changed it. Times are
game times. The numbers come from the game data, the recorder's 10-minute production windows, the
save of 41:05 (`tools/inspect-save.ps1` and the new `tools/trains-probe`), the source of the Cybersyn
mod, and measurements of the author's blueprints in the engine (`tools/junction-bench` and
`tools/train-probe`); the full results are in [Railways under Pyanodons](../research/py-railway.md)
and [Rail junctions at grade](../research/rail-junctions.md).

Conclusions:

- **The train is one Locomotive and two Cargo wagons** (21 tiles, 40 slots). With no speed cap in
  Py it reaches 245 km/h, and a full load of Raw coal (150, 450 MJ) lasts 750 seconds of driving,
  about 50 km. Cargo adds no weight. Two locomotives run twice as fast but need 610 tiles to stop.
- **The road is four tracks, two lanes each way, built first as two tracks** on the outer lanes. Of
  the author's three junctions the ordinary crossing was the best; with a lane change outside each
  entrance and one at each exit it passes 36.8 to 38.5 trains a minute in mixed traffic without
  locking. The early two-track version passes 32 to 33.
- **The refuel station fills a train in 22.6 seconds** and takes all its Ash out; **the depot**
  parks 8 trains, one per track, and grows by a module per track. Both sit on stubs beside the
  main line, so each has a train limit: a train that finds no room would wait on the main line.
- **Cybersyn cannot deliver yet.** A station that requests items needs a constant combinator, and
  in Py every combinator except Cybersyn's own takes a Battery. The author makes Batteries next.
- **On the map:** eight two-track junctions east of the base (x 480 to 1680), the refuel station,
  the depot, two trains standing without schedules. The track is not yet joined to the base.
- **Left alone, the save runs down within 40 minutes** (measured): research had stopped for want of
  Stone, so the Glassworks that burn Syngas and Hydrogen for its Molten glass stood full, and the
  two gases backed up into the coke block and the Tar line, taking Coke, Acetylene and Aromatics with
  them. The author found the Stone shortage at 41:08 and fixed it; in the game the base kept running.
  Zinc, stopped since chapter 13, runs
  again since the author turned an Overflow valve into a Check valve just after the save.

## At a glance

| Game time | What happened |
|---|---|
| 35:07 | Save after chapter 14's screenshots |
| 35:10–35:40 | First rails east of the base, laid by hand and by robots, partly taken up again |
| 35:21 | Moss farm upgrade researched (a T.U.R.D. upgrade; no option picked yet); next Battery - Stage 1 |
| 35:40–36:10 | Signals: 55 rail and 50 chain signals handcrafted and placed |
| 36:20 | Battery - Stage 1 researched; next Machine Components - Stage 1 |
| 36:20–37:30 | Junctions built, tried and taken up again around x 730 to 1130, y −35 to 50 |
| 36:54 | Machine Components - Stage 1; next Circuit network |
| 37:31 | Circuit network; next Cybersyn train network |
| 37:40–38:20 | **The network placed as blueprints** along y −240; robots build it over the next two and a half hours |
| 37:51 | Cybersyn train network; next Fluid wagon |
| 38:06 | Fluid wagon. Mods: Blueprint Sandboxes added, Cargo Bays and Unloaders removed; 38:11 Ore Eraser added |
| 38:30–39:10 | A supply station at (1473, −81): belts, 24 inserters, a splitter; locomotives and wagons placed and taken up several times |
| 38:42 | Energy generation 1; 39:31 Non Renewables - Stage 1 |
| 39:20–39:40 | **Refuel station** at (1407, −159) |
| 39:40–39:50 | An Electric mining drill on the Raw coal field at (1376.5, −83.5) and a belt to the refuel station |
| 39:50–40:10 | Robots build the square of the grid at x 1440 to 1680, y −240 to 0 |
| 40:00 and 41:00 | Handcrafted: two Locomotives and four Cargo wagons |
| 40:10–40:40 | **Depot** at (1619, −131 to −159), eight tracks |
| 40:20 | Coal Power - Stage 1; next Renewables - Stage 1 (the queue also holds Advanced combinators) |
| 40:40–40:50 | The supply station rebuilt |
| 40:50–41:05 | In the base: a Tar processing unit at (−136.5, −230.5) making Creosote from Naphthalene oil, with an Underflow valve |
| 41:05 | Save (`Py-Exploration`, 41.1 hours) |
| 41:05–41:07 | Screenshots; **the Aromatics Overflow valve on the bus at (−113.5, 179.5) becomes a Check valve**: the zinc drills run again; save at 41:07 |

There are no chat notes in this stretch. The author designed most of the rail pieces as blueprints
and had them measured between 2026-10-24 and 2026-10-25 (real days); the sections below follow
that order rather than the game clock.

## 1. Research

| Researched | Technology | What it gave here |
|---|---|---|
| 35:21 | Moss farm upgrade | A T.U.R.D. upgrade; no option picked in the save (section 10) |
| 36:20 | Battery - Stage 1 | **Battery** (Chemical plant, 10 s: Glass, 2 Melamine, Lead-antimony alloy, 3 Bolts, 3 Graphite, 3 Zinc plates, 30 Cyanic acid → 1), and a Simple circuit board recipe that takes one |
| 36:54 | Machine Components - Stage 1 | Mechanical Parts 01, Utility Box MK01, Electronics MK01, Control Panel MK01 |
| 37:31 | Circuit network | Arithmetic, decider and constant combinators (**each takes a Battery**), Power switch, Programmable speaker, Display panel |
| 37:51 | Cybersyn train network | **Cybernetic combinator** (5 Copper cable + 5 Simple circuit boards: no Battery) |
| 38:06 | Fluid wagon | Fluid wagon |
| 38:42 | Energy generation 1 | Molten salt, Electric boiler, Salt mine |
| 39:31 | Non Renewables - Stage 1 | Heat exchanger MK01, High-pressure steam turbine MK 01, steam cooling |
| 40:20 | Coal Power - Stage 1 | Coal powerplant MK 01, Hot Molten Salt, Pressurized steam |

About 1,950 units in six hours: 0.09 a second, what the red science line has supported since
chapter 11. At the save Renewables - Stage 1 is at 64 % (its Aerial blimp MK 01 takes 100
Batteries); after it come Advanced combinators (the Selector combinator, made of Decider
combinators, so Batteries again), Warehousing, Construction robotics, Cooling tower 1,
Domestication - Stage 1 and Fiberboard.

## 2. Which train: one Locomotive and two Cargo wagons

The author weighed three compositions and asked how far each goes on a full load of Raw coal and how
fast it runs. Py removes the speed cap from all rolling stock, so speed is set by power, weight and
air resistance alone ([Railways under Pyanodons](../research/py-railway.md)). Every fuel slot full:
3 × 50 Raw coal × 3 MJ = 450 MJ a Locomotive. Measured in the engine: top speed, acceleration and
braking on 10,000 tiles of straight track (`tools/train-probe`), range by sending each train round
one block of the author's two-track grid (an 850-tile lap through four junctions) until its fuel ran
out (`tools/junction-bench`, mode `run`).

| Composition | Length | Cargo slots | Top speed | 0 → 200 km/h | Braking from top speed | On a full load |
|---|---|---|---|---|---|---|
| **1 Locomotive + 2 Cargo wagons** | 21 tiles | 40 | 245 km/h | 15.1 s | 145 tiles | **50.4 km** |
| 2 Locomotives + 2 Cargo wagons | 28 tiles | 40 | 518 km/h | 6.5 s | 610 tiles | 106.1 km |
| 1 Locomotive + 4 Cargo wagons | 35 tiles | 80 | 216 km/h | 34.6 s | 122 tiles | 44.2 km |
| 1 Locomotive + 4 Advanced cargo wagons | 21 tiles | 80 | 228 km/h | 22.5 s | 59 tiles | 46.7 km |

- **A Locomotive burns its full 600 kW whenever it drives**, at top speed too: with no speed cap it
  never stops pulling. So a load always lasts 750 seconds of driving, and the distance is that
  time multiplied by the speed. Standing still (in manual mode) it burned nothing.
- **Cargo adds no weight**: the 1+2 train with both wagons full of Raw coal ran exactly like the
  empty one.
- **The fuel sets only the range**: Raw coal, Coal, Crushed coal and Coke have no speed bonus in
  the data. Crushed coal (6 MJ, stacks of 100) fills a Locomotive with 1,800 MJ, four times as far
  at the same speed (measured).
- **A Locomotive facing backwards neither pulls nor burns** while the train goes forwards; it only
  adds weight (230 km/h against 245).
- **In the author's junction** all three run without locking; 2+2 gets more trains through, 1+4
  more wagons ([Railways under Pyanodons](../research/py-railway.md)).

**The author chose 1+2.** It takes one Locomotive (each needs 5 Intermetallics, 25 Duralumin and four
Brakes MK 01, chapter 14), and every later design is sized for its 21 tiles. Railway - Stage 2
(py2) brings the Advanced cargo wagon, 3.5 tiles long: four of them carry twice the cargo in the
same 21 tiles, and the platform layout of [Railways under Pyanodons](../research/py-railway.md)
serves both kinds of wagon.

## 3. The road: four tracks, a lane change and the junction

The author's road has four tracks: two lanes each way, right-hand traffic, lanes 6 tiles apart
(the inner ones 5 tiles from the road's centre line, the outer ones 11). They drew three
junctions at grade (an ordinary crossing, a cloverleaf and a roundabout), each with a lane change (an
X between the two lanes of one direction) at every entrance and exit, and asked which was best or
whether there was a better one. A new tool measured them: `tools/junction-bench` builds a
junction's rails and signals on an empty map, asks the engine for its blocks and paths, then sends
trains of one Locomotive and two Cargo wagons through it from every lane at up to 200 km/h, to
random exits, for 15 minutes ([Rail junctions at grade](../research/rail-junctions.md)).

What the measurements found:

- **The lane change locked two trains.** Neither lane had a chain signal before the X. A train on
  the inner lane waiting to cross to the outer one stood in the inner lane's block, a train on the
  outer lane waiting to cross the other way stood in the outer lane's block, and each needed the
  other's block. The cloverleaf locked like this within the first minute of mixed traffic.
- **The roundabout's north entrance had five signals facing the wrong way**, and rail signals on
  its ring let trains stop on the ring: four trains each waiting for the next piece of ring lock
  it.
- **The cloverleaf at grade gains nothing**: its loops exist to pass over the crossing on bridges;
  at grade every left turn crosses the core twice. It is 2.8 times the area and the slowest.
- **The ordinary crossing was the best**: the shortest paths (left turn 81 to 84 tiles, the
  roundabout 109 to 122, the cloverleaf 235 to 240), the most trains a minute (about 30 as drawn),
  and no lock in any of its runs.

The rules behind the fixes, each measured:

1. **Chain signal in, chain signals inside, rail signal out.** Every signal from just before a
   train's path first shares track with another path until it has passed the last such point is a
   chain signal; the exit is a rail signal, and the block after it must hold a whole train (21
   tiles). A rail signal inside a junction only where a waiting train fits wholly and blocks no other
   path.
2. **A lane change decides before its first switch**: a chain signal on both lanes before the X.
   With them the X is also the fastest shape: 20.7 trains a minute with half the trains changing
   lanes, against 17.3 for `\/` (two one-way crossovers one after the other) and 15.4 for `\` and
   `/` apart with a waiting place between.
3. **No rail signals on a roundabout's ring.**

The author adopted the ordinary crossing with a lane change at each exit, then moved the entrance
lane change outside the junction: their stations branch off the outer lane, and a train leaving a
station must still reach the inner lane before the junction. Their lane change at first lacked the
two entrance chain signals and locked in three runs of four; with them the layout passes **36.8,
38.5 and 38.3 trains a minute** in mixed traffic, never locking (the junction as first drawn: about
30). Of its signals, three per lane change could go without any loss and the author took them out;
every other one was needed (without the chain signal on the inner right-turn curve all four
entrances locked at once).

## 4. The grid and the early two-track version

The author's city blocks are 240 tiles apart. Their blueprints snap to a 240 grid: the junction
(120 × 120), a grid edge (two junctions and the 120-tile stretch between them, a rail signal in the
middle of each lane), and a whole square of four junctions. Each comes in an **early two-track
version**: one track each way, laid on the outer lanes' places, so the inner lanes can be added
later without moving anything. Measured with the same mixed traffic:

| Blueprint | Trains a minute | |
|---|---|---|
| 十字路口 (four-track junction) | 36.8, 38.5, 38.3 | no lock |
| 十字路口-初期 (two-track junction) | 32.2, 33.0, 32.5 | no lock |
| 棋盘格-铁轨 (square of four four-track junctions, as a whole) | 66.1, 70.8 | no lock |
| 棋盘格-铁轨-初期 (the same, two-track) | 57.8, 58.5 | no lock |

In the two-track version each exit has a single track for three directions, and the block after
its exit signal runs 78.5 tiles to the signal in the middle of the stretch. One more rail signal on
every exit track, 25 tiles after the exit signal, raised the two-track square to 64.3 and 62.5
trains a minute (the four-track square gains nothing from it). The author has not added it yet.

## 5. Where stations join: the stubs

Stations sit inside the blocks, beside the road. The author's 棋盘格-边-车站定位 is the two-track grid
edge with a pair of stubs on each side of the stretch: an entrance branching off the main line and
an exit merging back, 6 tiles apart. A station is a loop that fits a pair; the refuel station and
the depot below are both made so.

The main line has a chain signal before the branch, and the branch itself has none. So a station's
first waiting place joins the main line's block at the switch, and a train that finds the station
full stops before that chain signal, **on the main line**, until there is room. Hence the rule for
every station on these stubs: **its train limit may not exceed the trains it holds inside**. Cybersyn
sends no more trains to a station than its train limit.

## 6. The refuel station

![The refuel station at 41:05, beside the road at x 1440 (right): trains come in by the upper track, go round the loop and stop at the platform below it, where a 1+2 train stands; Mechanical inserters fuel the Locomotive from below, where the fuel belt comes up from the Raw coal drill in the south, and take its Ash out above; the blue towers are Big electric poles still to be built](../images/ch15-refuel.jpg)

The author's 加油站-1, for 1+2 trains: a one-way loop with a 22-tile platform and a Cybernetic
combinator in refueler mode. Beside the Locomotive's place, 5 Mechanical inserters fuel it from 5
wooden chests limited to one slot each, which a belt keeps full; on the other side 5 inserters with
an Ash filter empty its burnt-result slots into chests that unload onto a second belt. In the game
the fuel belt comes from an Electric mining drill on the Raw coal field at (1376.5, −83.5).

Measured with `tools/junction-bench` in a new mode, `station`: the whole blueprint built with every
setting (filters, chest limits), and trains with 70 Raw coal and 80 Ash sent to it with the schedule
Cybersyn writes for a refueler visit (stop until 100 ticks of inactivity):

- **Each train leaves after 22.6 seconds with 150 Raw coal and no Ash.** The inactivity condition
  waits for the inserters: fuel and Ash going in and out count as activity.
- Each train stands wholly inside the platform block; four trains in a row are served 1.7 a minute.
- Cybersyn accepts the train: its automatic allow-list (read from its source) rejects at a refueler
  any train with a wagon beside an inserter, and here the inserters stand only beside the
  Locomotive.
- **The loop holds three trains**: one at the platform and two waiting. A fourth stopped on the main
  line: a train passing by took 66.7 seconds behind four refuel trains, 35.9 behind three, 24.9
  alone. The author set the stop's train limit to 3.
- The author also named the stop (a blueprint's unnamed stop gets a random name each time) and
  added a Small electric pole: Py's Big electric pole powers only 2 tiles around it, so it had not
  reached the combinator.
- The five Ash chests hold 16,000 Ash each, about a thousand refuels in all.

A train refuels when it is at most half full (Cybersyn's default threshold: 75 Raw coal), that is
after at least 375 seconds of driving, so one station like this serves about ten trains (an
estimate from the two measurements).

## 7. The depot

![The depot at 41:05, beside the road at x 1680 (right): trains come in by the upper track, go round the loop and turn into one of the eight tracks, each with its stop 车库 and a Cybernetic combinator, and leave by the merge on the right; all eight tracks are empty](../images/ch15-depot.jpg)

Under Cybersyn, empty trains wait at depots. The author's 车库-1 is another loop for the same stubs:
a rail signal at the entrance and one in the middle of the loop make two waiting places, then the
track splits onto eight depot tracks (chain signal in, rail signal out, a stop 车库 and a combinator in
depot mode on each) that merge into the exit. Measured the same way, with the schedule Cybersyn
gives a train at its depot (the depot's name, until 100 ticks of inactivity, as its only record) and a
train passing by behind them on the main line (34.1 seconds alone):

| Depot | Trains sent | What happened |
|---|---|---|
| First draft: 4 tracks, train limit 2 | 8 | **Only one parked.** The second took the second place at that same stop and waited in the entrance for its track, for good; everyone behind it, the passing train too, stood on the main line |
| Train limit 1 | 4 | One per track, 4 seconds apart; the passing train got through |
| Train limit 1 | 5 | Four parked; the fifth found every stop full and stopped where it was, on the main line |
| 8 tracks, no signal at the entrance | 8 | All parked, the last after 65.2 s; the passing train 81.5 s |
| **8 tracks, rail signals at the entrance and mid-loop (final)** | 8 | **All parked after 44.4 s**; the passing train 59.8 s |

- **Train limit 1 per depot track.** Each track holds one 1+2 train. Cybersyn's own command
  `/cybersyn-abolish-same-depot` also sets depot stops to 1 (from its source).
- **At least as many depot tracks as trains**: a train with no free place stops on the main line.
- **No waiting place behind a depot stop.** With Cybersyn's depot bypass (on by default) a train on
  its way back to the depot can already take an order (from its source): the one waiting behind a
  parked train could be given a delivery and then wait until the parked one leaves.
- **More tracks**: 车库扩展模块 is a copy of the bottom track, laid 4 tiles below it. Tested up to
  27 tracks (19 modules): they build on the grid edge without touching anything and every train parks,
  the far tracks a little slower (10 seconds apart instead of 5).

## 8. How Cybersyn works, and why it waits for Batteries

The author had only run fixed trains between two stations before. Under Cybersyn (version 2.1.2,
read from its source) trains have no route of their own: they wait empty at depots, and the mod writes
each one a schedule for one delivery at a time.

- **One Cybernetic combinator beside a stop** puts it on the network; its mode says what the stop is:
  **station** (its input is the station's stock: a positive signal is stock to provide, a negative
  one a need to request), **depot**, **refueler**, and two optional helpers.
- **The planner** works 30 times a second, a couple of stations at a time: it reads each station's
  input (counting what trains already bring or fetch), then matches one item at a time: the requester with the highest priority (then the one
  served longest ago), the provider with the highest priority nearest to it in a straight line and
  holding at least the threshold, and a free train on the same network with room for the threshold,
  allowed at both stations, **the largest first**, then the nearest.
- **The schedule it writes**: provider, wait until the order is loaded; requester, wait until empty;
  back to the depot. After unloading, a train at or below half fuel goes to a refueler; one with
  enough fuel may take the next order on its way back (depot bypass). A train must come back empty.
- **The default request threshold is 2,000 items**, and a train must have room for it: in 1+2's 40
  slots, items that stack below 50 can never be sent until the station gets its own threshold or
  uses "stack thresholds".

**What works now.** Wires come with Steam power, and the Cybernetic combinator needs no Battery, so
depots, refuelers and providers (chests wired straight to the combinator) can all be built. A
requester cannot: its need is a negative signal, the amount wanted minus what is there, and only a
constant combinator makes one. Constant, arithmetic and decider combinators each take a Battery in
Py; no other buildable entity in the mod set gives a constant signal. With no requester there is no
delivery, so **Cybersyn sends no train until the base makes Batteries**. The author tried a provider
(固体供货站-1, loading straight from belts): its combinator had no wire, so it reported no stock, and its
"Circuit condition" box was ticked, which keeps a loaded train waiting for a signal nobody sends
(measured: full after 120 seconds, still standing at 180). They set the providers aside until
Batteries come.

## 9. What stands in the game at 41:05

![A two-track junction of the network at (960, −240), 41:05: trains keep right; each entrance splits after a chain signal onto the right-turn curve and the track to the core, each exit merges; the north and south legs end in stubs for roads still to come; Small electric poles run along the middle of the road](../images/ch15-junction.jpg)

East of the base, beside the Raw coal field at (1413, −76) (480.7 million, the largest the
inspector lists), the author has laid the first stretch of the network, all two-track:

- **Eight junctions**: six along y −240 at x 480, 720, 960, 1200, 1440 and 1680, and the square
  of the grid closed at y 0 by (1440, 0) and (1680, 0). Between them 120-tile stretches with a rail
  signal in the middle of each track. In all 3,557 straight, 140 half-diagonal and 492 curved
  rails (5,313 Rails), 333 chain and 135 rail signals.
- **Power** from the base's network by about 500 Small electric poles along the roads; the 31 Big
  electric poles planned along the two north-south roads are still ghosts.
- **Stations** on the stubs of the road at x 1440: the refuel station (west side) with its fuel
  from an Electric mining drill on the Raw coal field, and the dropped supply station (east side);
  on the road at x 1680 the depot, eight tracks, all empty. All ten Cybernetic combinators are
  powered and working.
- **Two trains**, each one Locomotive and two Cargo wagons, both empty and without a schedule: one at
  the refuel platform in manual mode with a full load of Raw coal, one at the supply station with no
  fuel at all (read from the save with the new `tools/trains-probe`). One more Locomotive, two Cargo
  wagons and 926 Rails are in the author's inventory.
- **Not yet joined to the base**: the westernmost track ends at x 421.

## 10. Other changes in the base

- **Rails**: the chapter 14 block made 0.4 a second in most windows, 6,174 Rails after 35:07; the
  windows from 37:00 to 38:10 show none (no Solder or Treated wood either), after which it ran at
  0.4 again. The network used 5,313.
- **Creosote**: at 40:50 the author added a Tar processing unit at (−136.5, −230.5) making Creosote
  from Naphthalene oil (50 → 30, 2 s, data), its output through an Underflow valve at (−129.5,
  −224.5) into the Creosote pipe (an Underflow valve passes fluid only while the far side is below
  80 %, chapter 6). The Treated wood for rails takes Creosote: 800 a minute in the author's updated
  plan "铁轨" (37:23). The Tar line made 23.2 Naphthalene oil a second in these windows and used 15
  to 17.
- **Moss farm upgrade** is researched (35:21) but no option is picked in the save. Its four options
  (from pyalienlife's source): Spore sterilization (each Moss recipe takes a Chlorinated water,
  made from Pressurized water, Chlorine and Plastic; 40 % more Moss, a quarter less time), Coarse
  substrate re-vitalization (the Moss recipes also give Coarse fraction, the farms take 50 % more energy),
  Internal bioreactor (no pollution, two recipes that turn refined gases back, farms built with a
  Bioreactor), High density culture (Moss without Muddy sludge).
- **Zinc**: the 12 zinc drills had stood for lack of Aromatics since chapter 13, and the base made
  under 0.02 Zinc plates a second. The author found why: the bus's Aromatics Overflow valve at
  (−113.5, 179.5) passes only while its near side is over 80 % full, and the Aromatics tailings pond
  (−139, −38) upstream of it never let the pipe fill that far. Right after the save they replaced it
  with a Check valve. In the save of 41:07 eleven of the twelve drills work; an hour of that save
  gives 7.2 Zinc ore and 0.72 Zinc plates a second until, after 40 minutes, the plates fill the
  space behind the furnaces (nothing uses them yet). Each Battery takes 3; the base's containers held
  2,141 at 41:05, enough for about 700.
- **Mods**: Blueprint Sandboxes added at 38:06 (a place to design blueprints apart from the base),
  Cargo Bays and Unloaders removed; Ore Eraser added at 38:11.
- **Plans in Factory Planner**: "铁板" (39:34), Iron plates by casting, 810 a minute from Iron ore,
  Borax and Wood, with 10.8 Electrolyzers for the Oxygen (112 MW); "物流科技包（绿瓶）" (39:56), 3
  Logistic science packs a minute in a Research center MK 01 from 0.75 Batteries, 0.5 Animal samples,
  0.5 Poor alien samples and 0.25 Solidified sarcorus a minute.

## 11. The hour after the save

The save of 41:05, run for an hour without the player (`tools/rate-probe`), does not hold:

| A second (10-minute steps) | 10 min | 20 | 30 | 40 | 50 | 60 |
|---|---|---|---|---|---|---|
| Coal gas made | 41.3 | 37.1 | 10.1 | 0 | 0 | 0 |
| Tar made | 29.0 | 25.9 | 6.4 | 0 | 0 | 0 |
| Coke made | 9.1 | 7.7 | 1.9 | 0 | 0 | 0 |
| Power used (MW) | 75.2 | 61.3 | 41.3 | 28.4 | 25.4 | 24.4 |

The save of 41:07, with the author's check valve, does the same; switching off the new Creosote unit
changes nothing. The game itself had started down the same road: Tar fell from 48 a second in the
window to 40:30 to 31, 25 and 17 in the three windows before the save.

What stops it, read from the machines' fluid boxes; the cause is the author's finding:

1. **Coal gas has nowhere to go.** The coke block's first columns (Raw coal → 60 Coal gas + 30 Tar
   + 3 Coal) stand "full output" with their Coal gas box full already in the save. Its users are the
   aluminium drills (which take it only while the Intermetallics line takes Aluminium plates) and,
   past the Overflow valve, the three Gasifiers. Their Syngas has one big user: the Glassworks at
   y 348.5 burn it, and Hydrogen, as fuel (chapter 8) for the Molten glass whose Flasks go into the
   pY1 packs. **Research had stopped for want of Stone.** The author: the Stone came from crushing,
   as a byproduct of the circuit-board and Intermetallics lines, and both stood. The recorder shows
   it: from 40:40 Stone fell from 8 to 4.3 a second, red packs used from 0.2 to 0.01, Molten glass
   from 10 to 2.9 and Syngas from 34 to 11; in the save the labs stand "missing science packs".
   Without Coal the next columns make no Coke and no Tar; without Coke the 20 Coke boilers that give
   the Tar line its Steam go out, and Acetylene (lead drills), Calcium carbide and the rest that run
   on Coke follow; without Tar there is no Aromatics (zinc, plastic) and no Creosote (Treated wood
   for rails).
2. **Hydrogen has nowhere to go.** With an Exhaust pipe on the Coal gas pipe (at (−101.5, −168.5))
   the coke block runs again, Tar is held at 40 a second by its one user (chapter 14), and after 40
   minutes everything stops a second time: the pitch refining columns (100 Pitch + 100 Steam →
   10 Hydrogen + Light oil, Naphthalene oil, Anthracene oil and Coke) stand "full output" with Hydrogen
   in their output box, Pitch backs up into tar refining, Tar into the coke block. In that run the base
   used 9.5 Hydrogen a second in the first ten minutes and none after: the same Glassworks burned no
   more.

With an Exhaust pipe on the Coal gas pipe and one on the Hydrogen pipe by the pitch columns (at (−161.5,
−130.5)) the whole hour runs: Coal gas 54, Tar 34, Coke 10, Pitch 48 a second, 49 MW at the end,
the same in a second run. Both are needed: with only the first the base stops at 40 minutes. The
Exhaust pipes were only a test in a copy of the save. **The author's fix was the Stone**: at 41:08 their
note says "发现缺石矿" (Stone is short), and by 41:30 eight Electric mining drills on Stone and twelve
Stone furnaces for bricks fed research again (chapter 16). Stone rose to 17–19 a second, Molten glass
to 14–15 and Syngas to 47–51, and the game never ran down: Tar stayed at 34 to 50 a second up to
43:40, and the save of 43:42 runs the whole hour (Coal gas 27 to 39, Tar 34, Coke 9.5 a second).
A block that stands because nobody takes its product is normal here; these two gases are different,
because the Coke and Tar the whole base needs come out of the same machines, and their outlet is
research.

## 12. The blueprints

The rail pieces of this chapter are in the book (`/pt-book`), each with its measurements; the
[blueprint list](../blueprints/README.md#railway) has the details: the lane change (换道结构), the
four-track and two-track junctions, the grid edges and squares, the grid edge with station stubs
(棋盘格-边-车站定位) and its Small electric poles, the refuel station (加油站-1), the depot (车库-1)
and its extension module.

The blocks of chapters 11 to 14 came in with this chapter too: lead, titanium and tin screening,
nexelit and nickel, the geothermal site, antimony oxide, Intermetallics, the fish oil for Gearboxes,
the rails block and the Coke boilers (焦炭销毁). Each matched, entity for entity, the block measured in
its chapter's save, so its description gives that chapter's numbers. The mall 初期超市-2 and the
Simple circuit board block changed a little (a chest limit; two chests taking Glass and Ceramic out).
The book now holds 45 blueprints.

## 13. Key points

- In Py a Locomotive burns full power whenever it moves: a load of fuel is a fixed driving time
  (750 seconds of Raw coal), and the distance follows from the speed. Cargo weighs nothing; a
  Locomotive facing backwards pulls nothing.
- At-grade junctions: chain signal in, chain signals inside, rail signal out; a rail signal inside
  only where a whole train fits and blocks nobody; a lane change needs a chain signal on both lanes
  before its first switch.
- A station on a branch whose main-line signal is a chain signal must hold every train sent to it:
  set its train limit to the trains it holds. A depot needs one track per train, train limit 1.
- In Py, Cybersyn needs a constant combinator for every requesting station, and so Batteries.
  Depots, refuelers and providers work without.
- A gas that comes out of the same machines as something the base needs must always have an outlet:
  here Coal gas (with Coke and Tar) and Hydrogen (with the Tar line). Their outlet was the Glassworks
  that burn them for research, so research standing still stopped the Coke.

## 14. How these facts were checked

- Recording: the companion's recorder (run `2652821414-0`, to 41:05), read with
  `tools/recorder-phases.js` (10-minute slices), `tools/recorder-summary.js` and the production
  records of the activity log; no chat notes in this stretch. Factory Planner: "铁轨" (37:23),
  "铁板" (39:34), "物流科技包（绿瓶）" (39:56), read with `tools/planner-summary.js`.
- The saves of 41:05 and 41:07 (`Py-Exploration`, copied to `C:\tmp\ch15`; consistency check passed):
  `tools/inspect-save.ps1 -Ticks 3700`, `tools/summarize-save.js`, `tools/render-area.js`. The trains
  and stops with the new `tools/trains-probe` (`save-probe.ps1 -Probe trains-probe`): state, schedule,
  fuel, cargo of every train, name and train limit of every stop. T.U.R.D. picks with
  `tools/turd-probe`.
- Data: recipes, fuel values, rolling stock, pole supply areas (`tools/q.js`, the data of
  2026-10-18); option names from the zh-CN locale (aotixpy).
- Trains: `tools/train-probe` (straight track) and `tools/junction-bench` mode `run` (a train round a
  block of the grid until its fuel is gone).
- Junctions, lane changes, grid pieces: `tools/junction-bench` modes `map` (blocks, paths, signals on
  each path), `traffic` (mixed traffic from every lane, 15 minutes, several seeds) and `edit`; the
  stations: modes `station` (the whole blueprint with all settings, trains with Cybersyn's refueler,
  depot or loading schedule, a passing train on the main line) and `build` (overlaps, pole coverage).
- Cybersyn: the source of cybersyn 2.1.2 (`scripts/central-planning.lua`, `train-events.lua`,
  `factorio-api.lua`, `layout.lua`, `settings.lua`).
- The blueprints of chapters 11 to 14: each compared entity by entity with the save snapshots of
  chapters 11 to 15.
- The hour after the save: `tools/save-probe.ps1 -Probe rate-probe -Ticks 219700` on both saves, with
  timelines of these products and the fluid boxes of a pitch column and two tar refining units
  (`@x:y`); what-ifs `off@-136.5:-230.5` (the new Creosote unit), `py-gas-vent@-101.5:-168.5:south`
  and `py-gas-vent@-161.5:-130.5:south`; the recorder's windows of Stone, packs, Molten glass and
  Syngas from 40:20 to 42:00 and the save of 43:42 run for an hour the same way.
- Screenshots: taken by the author with the companion (`/pt-shots`) at 41:05, areas planned with
  `node tools/shots.js plan`.

Next: [chapter 16](16-auogs.md).
