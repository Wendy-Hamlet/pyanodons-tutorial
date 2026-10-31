# Chapter 18: Train preparation 2

[中文](18-train-preparation-2.zh-CN.md) · [Contents](../README.md) · Previous:
[Chapter 17](17-batteries.md)

This chapter follows the same recorded game from the save of 45:52 to the save of 49:46. Its subject is the author's: **train
preparation 2** (火车准备2). For these four hours the base hardly changed and research ran by itself, while the author tried out
stations, first at the east end of the rail network and then in a blueprint sandbox, and finished the railway designs begun in
chapter 15: refuel station, depot, item stations and fluid stations are now blueprints that work as placed. Most designs were
measured and changed in turn: the author drew a blueprint, it was measured in the engine, the author changed it. Times are game
times. The numbers come from the game data, the recorder, the save of 49:46 (`tools/inspect-save.ps1`, `tools/trains-probe`), the
source of the Cybersyn mod, and runs in the engine with Cybersyn dispatching the author's blueprints (`tools/junction-bench`, mode
`network`); all results are in [Py's railway](../research/py-railway.md).

In short:

- **The whole set of station blueprints is done, none of it on the map yet.** Each carries its own piece of main line and snaps to
  the 240 grid, so it joins the network as placed. The stubs blueprint of chapter 15 is no longer needed.
- **An item station has 24 Burner inserters and 24 Wooden chests a platform**; a 1+2 train loads or unloads 4,000 in about 210 s.
  There are versions with 1 to 4 platforms, and the 4-platform version takes extension modules.
- **A blueprint formula sets the request from the stack size**: Stack thresholds ticked, threshold 40 stacks (a full train), request
  80 stacks. Placing it, you pick only the item. An item of stack 10 travels 400 a train, one of stack 1000 travels 40,000 a train,
  every train full, and an order goes out when the stock falls to half.
- **A fluid station moves 50,000 a train, about 3 s each way**: two Pumps and two PyTanks (100 kL) piped together a platform, Fluid
  request threshold 50,000. Fluid and cargo trains can share a depot.
- **On the map**: ten two-track junctions (to x 1979), chapter 15's refuel station, depot and provider still there, one 1+2 standing
  by the refuel station without a schedule. In the inventory: 2 Locomotives, 4 Cargo wagons, 11 Train stops, 11 Cybernetic
  combinators, 10 Constant combinators and 90 Batteries. The railway is not joined to the base yet.

## What happened when

| Game time | What happened |
|---|---|
| 45:44–45:50 | Robots extend the two-track network east by two junctions: (1920, −240) and (1920, 0) |
| 45:52 | The last save of chapter 17 |
| 45:55–46:06 | First trial platform at (1713, −81): stop, Cybernetic combinator, Burner inserters, Wooden chests (135 handcrafted), belts; first Constant combinator at 46:00; a 1+2 placed and taken up again |
| 46:17–46:39 | Moved to (1739 to 1741, −81 to −117), several platforms, built and rebuilt; 3 Locomotives and 4 Cargo wagons placed at 46:31 for a trial and taken up |
| 46:19 | Cottongut - Stage 1; 46:35 mods: Cybersyn 2.1.3, factorio-charts added |
| 46:39–49:42 | **From here mostly in the blueprint sandbox** (167 of the 187 minutes to the save) |
| 46:54 | Game updated to 2.1.24 |
| 47:05–47:49 | Solidified sarcorus, Fertilizer - Stage 1, Fawogae - Stage 1 |
| 47:19 | Robots remove the trial station from the map: 192 Burner inserters, 96 Wooden chests, 124 belts and its rails |
| 48:06–48:24 | Vrauks - Stage 2, Vrauks upgrade; 48:09 mods: pypetroleumhandling 3.1.5 |
| 49:18–49:20 | In the base, two changes to belts and splitters at x −75 to −73, y 29 to 48 |
| 49:34 | Molecular decohesion - Stage 1; next Oil powerplant - Stage 1 |
| 49:46 | Save (`Py-Exploration`) |

There are no chat notes in this stretch. The author exported the station blueprints in four rounds on 2026-10-29 to 10-31 (real
time) for measuring; the sections below give the final results, and section 6 the faults fixed on the way.

## 1. Technologies

| Finished | Technology | What it gave here |
|---|---|---|
| 46:19 | Cottongut - Stage 1 | Prandium lab MK 01 and Cottongut |
| 47:05 | Solidified sarcorus | Subcritical water MK 01, Depolymerised organics, Solidified sarcorus |
| 47:34 | Fertilizer - Stage 1 | One more Fertilizer recipe |
| 47:49 | Fawogae - Stage 1 | Fawogae plantation MK 01 |
| 48:06 | Vrauks - Stage 2 | Vrauk MK 02 |
| 48:24 | Vrauks upgrade | A T.U.R.D. upgrade, not picked in the save; nor is the Moss farm upgrade of chapter 15 |
| 49:34 | Molecular decohesion - Stage 1 | Atomizer MK 01 and recipes that turn blood, meat, guts, bones and the like into metals and other materials |

All seven cost 1 pY science pack 1 + 2 Automation science packs a unit, 1,135 units in all, 0.08 a second on average from 45:42 to
49:34. Next in the queue: Oil powerplant - Stage 1, Biomass powerplant - Stage 1, Energy storage, Wind - Stage 1 and Tidal - Stage 1.

## 2. Every station carries its own main line

In chapter 15 a station joined the stubs of 棋盘格-边-车站定位, so the stubs came first and the station was lined up with them. Now
each station blueprint holds its own piece of main line (the outer lane of a 240 grid edge) and its switches, with absolute snapping
to 240: over a grid edge the blueprint snaps to its place. The stubs blueprint is no longer needed.

The rule stays that of chapter 15: **a station's train limit must not exceed the trains it holds**, or the next train waits on the
main line. Every station below was measured against it.

棋盘格-边-远程输电塔 is a set of 16 Big electric poles along a grid edge, for both kinds of edge. In Py a Big electric pole
supplies only 2 tiles around it, so every station has its own Small electric poles, and every combinator is within their reach.

## 3. 加油站-1-灰烬

As in chapter 15: a one-way loop, fuel on one side of the Locomotive, Ash taken on the other. It now carries its main line and its
loop holds 4 trains (one at the platform, three waiting), so the train limit is 4.

- 22.6 s a train, Raw coal 70 → 150, Ash 80 → 0, the whole train inside the platform block.
- A fifth train stands on the main line: a train going past takes 60.5 s instead of 30.6 s.

## 4. 车库-1

8 tracks, one stop each, limit 1; chain signal in, rail signal out. Trains run the opposite way to chapter 15's depot, and the
gathering side is 4 tiles shorter.

| Tracks | Last train in | A train going past |
|---|---|---|
| 8 | 36.4 s | 43.1 s |
| 9 | 39.0 s | 45.7 s |
| 10 | 41.7 s | 48.3 s |
| 12 | 47.2 s | 53.8 s |

Every train stands wholly in its own block. 车库-1-扩展模块 goes 4 tiles above the top track and repeats. A depot needs at least as many
tracks as there are trains: measured in chapter 15, a train beyond that has nowhere to return to.

## 5. Item stations

![物品卸货站-1-4 in the sandbox: trains leave the main line at bottom left, loop round to the right, run right to left through the four platforms and rejoin the main line on the left](../images/ch18-item-station.jpg)

物品卸货站 (requester) and 物品供货站 (provider) have the same form and differ in the direction of their belts. All numbers are for a
1+2 train (21 tiles, 40 slots).

A platform is straight, with the same on both sides of the track: a row of Burner inserters at the wagons, a row of Wooden chests, a
row of Burner inserters, then belts; 24 chests and 48 inserters in all. A requester moves goods from the wagons into the chests
and on to the belts, and the belts of the two sides join under the track; a provider does the reverse, one belt split to both sides.
All the chests are wired to the Cybernetic combinator, so what it reads is their stock.

![One platform close up: above and below the track a row of Burner inserters, a row of Wooden chests, another row of Burner inserters, belts on the outside; on the left the stop, the Cybernetic combinator and the Constant combinator](../images/ch18-item-platform.jpg)

- **24 Wooden chests of 16 slots, 384 stacks a platform**: 38,400 Iron plates. The chests separate trains from factories: a train
  unloads at once, the factory takes its time.
- **Loading 4,000 takes 211 s, unloading 210 s**: 24 Burner inserters move about 19 items a second.
- **Train limit 2**: a second train for the same platform stands wholly in the 21.3-tile curve block before it and keeps the shared
  entrance free. In no run did a train wait on the main line.
- **Each platform has its own stop and combinator**, the stop named `[item]卸货站` or `[item]供货站`, so a platform handles one
  item. You pick it in the parameter window when placing the blueprint.
- **Combinator mode**: 仅需求 (Request only) at requesters, 仅供应 (Provide only) at providers. A requester set to provide and
  request offers whatever it holds beyond its request.

## 6. Faults found in the drafts

The author fixed each of these. They are here because anyone drawing a station meets the same ones:

- **Combinator not wired**: Cybersyn reads nothing and the platform never requests. So it was on the top platform of the first draft
  and on the extension module.
- **Request below the threshold**: the first default of −1200 was under the default threshold of 2,000, no order in 10 minutes. The
  extension module's request was +4000 for a while; a positive number is no request, and no order came.
- **Chests limited to 1 slot**: 24 stacks a platform, so a train took 2,400 plates at most and an item of stack under 84 could
  never reach 2,000 and was never sent.
- **Train limit 0**: in one export the four platforms' limit was 0. Cybersyn sends no train to such a stop: 0 orders in 9 minutes.
- **Extension modules fit the 4-platform version only**. On the 1 to 3 platform versions they build, but the module's short rail
  does not reach the exit, and a loaded train stands at the provider with status `no_path`.

## 7. How much: threshold and request

Under Cybersyn trains have no fixed routes: stations report what they lack and the mod sends a train (chapter 15). A negative number
in the Constant combinator is the request; the stock in the chests and the goods on the way count against it, and what is left is
the shortage.

A train is sent when three things hold: the shortage is at least the threshold, the provider holds at least the threshold, the train
can carry the threshold. It carries the smallest of shortage, stock and capacity. The default threshold is 2,000 items. A 1+2 has 40
slots, so 2,000 of an item of stack under 50 does not fit, and such an item is never sent at the default.

**Stack thresholds** is a checkbox on the Cybernetic combinator. Ticked, the threshold counts stacks instead of items; the request
stays in items. So it means "the smallest delivery in stacks", not "how many stacks I want". It needs a Request threshold signal in
the Constant combinator as well, or the default 2,000 is read as 2,000 stacks and nothing is ever sent.

The author began with threshold 40 and −4000. Four platforms of stack-100 plates, stations starting empty, a factory taking from the
chests, 30 minutes:

| Setting | Factory, a second | Orders a platform | A train | Chests empty, s |
|---|---|---|---|---|
| −4,000, threshold 40 stacks | 5 | 2 | 4,000 | 526-538 |
| −8,000, threshold 40 stacks | 5 | 3 | 4,000 | 279-298 |
| −8,000, threshold 40 stacks | 8 | 5 | 4,000 | 280-295 |
| −4,000, threshold 20 stacks | 5 | 4 | 2,000-4,000 | 279-291 |

The 279 to 298 s are the wait for the first train. With the request equal to the threshold the shortage is enough only when the
chests are empty: the second order went out at about 1,030 s, goods came about 250 s later, and that gap repeats every round. With
twice the threshold an order goes out at half stock, the chests never emptied again, and every train was full. So **the request
should be twice the threshold**, here 80 stacks.

How many items that is depends on the item: visible items in the data mostly have stack 10, 50 or 100, but some 200 (Sand, Gravel,
Small parts, circuit boards, science packs) and some 1000 (Stone bricks, Ash). At −4000 and threshold 40 a stack-200 item comes to 20
stacks, short of 40, and is never sent.

**A blueprint parameter can work the request out from the stack size.** A number parameter takes a formula, and formulas have the
variable "Stack size of parameter N". The author's form:

- A number parameter 单列火车格数 (slots of a train) = 40, variable `p5`. The Request threshold signal uses it too, so another train
  composition changes this one number.
- The Constant combinators' base values differ from platform to platform (0, −1, −2, −3), so each formula row serves its own platform.
- Dependent parameters `-2 * p5 * p0_s`, where `p0_s` is the stack size of the item picked for parameter 0; the other platforms have
  `p1_s`, `p2_s`, `p3_s`.

Placing it you pick only the item. Measured with these results, 5 platforms (the 4-platform version and a module), a factory taking
3 a second, 60 minutes:

| Stack | Item | Request | A train | Orders | Chests empty before the first train, s |
|---|---|---|---|---|---|
| 10 | Worker's food | −800 | 400 | 28 | 150 |
| 50 | Burner inserter | −4,000 | 2,000 | 7 | 178 |
| 100 | Iron plate | −8,000 | 4,000 | 4 | 297 |
| 200 | Small parts | −16,000 | 8,000 | 3 | 488 |
| 1000 | Stone brick | −80,000 | 40,000 | 2 | 2,260 |

All full, no train on the main line, and the chests empty only before the first train. The last column is mostly the time to load a
full train, so **the first train of a stack-1000 item takes about 37 minutes**; at 19 a second every later trip takes about 35
minutes at each end, and all that time it holds a train.

## 8. Fluid stations

The rails and signals of 流体卸货站 and 流体供货站 are the item stations', tile for tile, so they go in the same places. A platform has
two Pumps, one at each Fluid wagon, and behind them two PyTanks (100 kL) wired to the combinator; the request is −200,000, the two
tanks. The train is a Locomotive and two Fluid wagons of 25,000 each.

- **50,000 a train, about 3 s to load and 3 s to unload** (item stations: 211 and 210 s).
- **Fluid request threshold 50,000**: the default for fluids is 2,000 too, so slow use sends nearly empty trains. At 100 a second a
  platform, 15 minutes: without the signal 33 to 34 orders a platform, nearly all of 2,000 to 6,000; with it 5 orders, all full.
  Stack thresholds do not touch fluids.
- **The two tanks must be joined**: each Pump serves its own tank, so with a factory on one tank the other fills, the train cannot
  empty and waits for ever (Cybersyn's unloading condition is an empty train). In the draft only the bottom platform had that Pipe: in 15
  minutes the other three took 6 orders each and jammed, holding 6 of the 8 trains. Now every platform has it.
- **With nothing used up** a platform fills after 4 trains and the orders stop; no train is left standing.
- **Cargo and fluid trains share a depot without trouble**: 4 of each for 15 minutes, cargo trains took only items, fluid trains only
  fluids, and a fluid train changed fluid between trips.

At every size, all 50,000, no train on the main line, nothing without a path:

| Platforms | Factory on one tank, 500 a second, 15 min | One provider tank fed, 10 min |
|---|---|---|
| 1 | 12 orders a platform | 30 |
| 2 | 12 | 29 |
| 3 | 12 | 28 |
| 4 | 12 | 26 |
| 6 (4-platform version and two modules) | 11-12 | 14-21 |

The author made the 4-platform version; the 1 to 3 platform versions and the two extension modules were cut the way the author cut
the item stations, and the author checked them in game. A Fluid wagon takes 5 Intermetallics, 10 Duralumin, 50 Titanium plates, 16
Steel plates, 10 Small parts, two Brakes MK 01 and more; a PyTank (100 kL) takes 2 PyTanks (40 kL), 20 Duralumin and 45 Lead plates.

## 9. How many platforms

- The 1 to 3 platform versions are exact subsets of the 4-platform version, kept from the bottom platform up. For 5 or more use
  the 4-platform version and extension modules: a module goes 12 tiles above the top platform and repeats; 5 and 6 platforms were
  both served.
- Goods on the way count against the shortage, so the request decides how many trains run at once. At −4,000 and stack 100 a
  platform has one train, orders 455 s apart, about 8.8 plates a second; at −10,000 a second train follows, 16,000 plates in 15 minutes
  against 8,000. The formula's 80 stacks allows two trains as well, and at 8 a second the chests did not empty.
- At −10,000, 8 trains, 15 minutes, 1 / 2 / 3 / 4 platforms took 4 / 8 / 11 / 15 orders.

## 10. Blueprints

The new and changed blueprints are in [blueprints](../blueprints/README.md), used as in chapter 15:

- `rail-grid-edge-big-poles`: 棋盘格-边-远程输电塔
- `rail-refuel-ash`: 加油站-1-灰烬
- `rail-depot`, `rail-depot-module`: 车库-1, 车库-1-扩展模块 (chapter 15's first version is in git history)
- `rail-requester-1` to `-4`, `rail-requester-module`: 物品卸货站-1-1 to -4, 物品卸货站-1-扩展模块
- `rail-provider-1` to `-4`, `rail-provider-module`: 物品供货站-1-1 to -4, 物品供货站-1-扩展模块
- `rail-fluid-requester-1` to `-4`, `rail-fluid-requester-module`: 流体卸货站-1-1 to -4, 流体卸货站-1-扩展模块
- `rail-fluid-provider-1` to `-4`, `rail-fluid-provider-module`: 流体供货站-1-1 to -4, 流体供货站-1-扩展模块

## 11. Key points

1. With absolute snapping a station can carry its own main line; no stubs to lay first.
2. A train limit must not exceed the trains a station holds, and must not be 0.
3. A combinator must be wired to the chests or tanks, or Cybersyn reads nothing.
4. The request should be at least twice the threshold. Equal to it, an order goes out only at empty chests.
5. Stack thresholds set the smallest delivery in stacks; they need a Request threshold signal, at most the train's slots.
6. A blueprint formula can work the request out from the item's stack size, and you pick only the item.
7. A fluid station's threshold should be a full train, and the tanks of a platform must be joined.

## 12. How these facts were checked

- The saves of 45:52 and 49:46 (`Py-Exploration`, copied to `C:\tmp\ch17` and `C:\tmp\ch18`; consistency check passed):
  `tools/inspect-save.ps1`, `tools/summarize-save.js`; trains, stops and surfaces with `tools/save-probe.ps1 -Probe trains-probe`,
  T.U.R.D. picks with `-Probe turd-probe`.
- Recorder: `tools/recorder-phases.js`, one-minute slices; the surface the player stood on from the activity log.
- Station blueprints: the author's exports of 2026-10-29 to 10-31 (`tools/bp-sync.js`). `tools/junction-bench`, modes `build`, `station`
  and `network`: `network` puts requester, depot, provider and refuel station on the four inner edges of the early grid, with
  Cybersyn dispatching 8 trains. Supply is topped up by script every 10 s and use is simulated by script (`restock`, `drain`), with no
  real belts or pipes attached; goods on belts are not counted.
- The blueprint formula runs only in the game: the Lua API cannot fill in blueprint parameters. In the runs a script set the request
  to the formula's result (`request_stacks`); the author confirmed the formula itself in game. Import and export checked with
  `tools/check-companion.ps1`.
- Cybersyn's rules: `scripts/central-planning.lua` (version 2.1.3).
- Data facts: `tools/q.js` and the data dump rebuilt on 2026-10-31.

Next chapter: chapter 19 (to come).
