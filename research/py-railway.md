# Railways under Pyanodons (Factorio 2.1, Py 3.1.x, elevated-rails on)

Facts below come from `tools/dump-data.ps1` (data.raw of the player's exact mod set), from
`tools/train-probe` and `tools/junction-bench` (measured in the engine), and for Cybersyn from the
mod's own source (cybersyn 2.1.2), not from wikis.

## Unlock order

| Technology | Science | Unlocks |
|---|---|---|
| railway (after automation-2) | red + py1 | rail, locomotive, cargo-wagon |
| automated-rail-transportation | red + py1 | train-stop, rail-signal, rail-chain-signal |
| fluid-wagon | red + py1 | fluid-wagon |
| cybersyn-train-network (+ circuit-network) | red | cybersyn-combinator (5 Copper cables + 5 Simple circuit boards) |
| elevated-rail | red + py1 + green | rail-ramp (4x16), rail-support (3x3, range 11) |
| railway-mk02 | + py2 | mk02 locomotive / wagons, `rail-2` (12 rails per craft) |
| railway-mk03 | + chemical, py3 | ht locomotive / wagons |
| railway-mk04 | + production, py4, military | mk04 locomotive / wagons |

## Rolling stock

| Tier | Locomotive | Fuel (burnt result) | Wagon | Tiles per car | Cargo |
|---|---|---|---|---|---|
| mk01 | 600 kW, 2000 kg, braking 10, 3 fuel + 3 burnt slots | chemical / biomass (ash), nuclear fuel | cargo-wagon | 7 | 20 slots / 25k fluid |
| mk02 | 900 kW, 1600 kg, braking 18, 5 slots | fluid canisters (empty canister), nuclear fuel | mk02-wagon (Advanced cargo wagon) | **3.5** | 20 slots / 25k |
| mk03 | 1.6 MW, 1200 kg, braking 45, 1 slot | nexelit battery (used battery) | ht-generic-wagon | 7 | 80 slots / 75k |
| mk04 | 2.4 MW, 1000 kg, braking 81, 1 slot | quantum battery (used battery) | mk04-wagon | **3.5** | 80 slots / 75k |

Locomotives are 7 tiles per car in every tier. Station geometry for 7-tile wagons (mk01, mk03)
does not fit 3.5-tile wagons (mk02, mk04), and a locomotive followed by a 3.5-tile wagon is
5.25 tiles apart.

Py gives the mk01 locomotive a burnt-result inventory (`pycoalprocessing` entity-updates), so
every tier returns something to collect at refuelling: ash, empty canisters or used batteries.
Ash stacks to 1,000, so the 3 burnt slots never fill before the fuel is gone.

## No speed cap

`pycoalprocessing` sets `max_speed = nil` on the vanilla locomotive and wagons, and Py's own
stock never sets it, so top speed is limited only by power, weight and air resistance
(air resistance is divided by train weight: longer trains with the same power/weight run faster).

Measured on straight track, empty wagons (`tools/train-probe`):

| Composition | Top speed | Braking from top speed |
|---|---|---|
| mk01 1-2, coal | 245 km/h (90% after ~20 s) | 145 tiles |
| mk01 1-4, coal | 216 km/h | 122 tiles |
| mk01 2-4, coal | 486 km/h | 576 tiles |
| mk01 1-2, nuclear fuel | 676 km/h | 1112 tiles |
| mk02 1-4, fuel canister | 330 km/h | 97 tiles |
| mk03 1-2, nexelit battery | 918 km/h | 436 tiles |
| mk04 1-4, quantum battery | >= 1907 km/h (track ended) | 799 tiles |

Re-run: `powershell -ExecutionPolicy Bypass -File tools\run-probe.ps1 train-probe -Ticks 25000`
(results are the `CF-PROBE` log lines).

## Range on raw coal, and the compositions the author weighs (2026-10-25)

The author asked how far 1+2, 2+2 and 1+4 go on a full load of Raw coal and how fast they run.
Every fuel slot full: 3 slots × 50 Raw coal × 3 MJ = 450 MJ a Locomotive. Range measured with
`tools/junction-bench` mode `run`: the train goes round one block of the author's 棋盘格-铁轨
(an 850-tile lap through four of their junctions, right turns, rail waypoints mid-stretch) until
the fuel is gone. Speeds, acceleration and braking from `tools/train-probe` (10,000 tiles of
straight track).

| Composition | Length | Cargo slots | Top speed | 0 → 200 km/h | Braking from top speed | Distance on a full load | Driving time |
|---|---|---|---|---|---|---|---|
| 1 Locomotive + 2 Cargo wagons | 21 tiles | 40 | 245 km/h | 15.1 s, 532 tiles | 145 tiles | 50.4 km (+0.4 coasting) | 750 s |
| 2 Locomotives + 2 Cargo wagons | 28 tiles | 40 | 518 km/h | 6.5 s, 196 tiles | 610 tiles | 106.1 km (+1.4 coasting) | 750 s |
| 1 Locomotive + 4 Cargo wagons | 35 tiles | 80 | 216 km/h | 34.6 s, 1,338 tiles | 122 tiles | 44.2 km (+0.4 coasting) | 750 s |
| 1 Locomotive + 4 Advanced cargo wagons | 21 tiles | 80 | 228 km/h | 22.5 s, 830 tiles | 59 tiles | 46.7 km (+0.4 coasting) | 750 s |
| 1 Locomotive + 2 Cargo wagons + 1 Locomotive facing back | 28 tiles | 40 | 230 km/h | | | 47.7 km, then stands with the rear Locomotive's 450 MJ untouched | 750 s |

- A Locomotive burns its full 600 kW whenever it drives, at top speed too (with no speed cap it
  never stops pulling): 450 MJ is 750 s of driving for every composition, and the distance is
  that time × the speed. Standing in manual mode for 30 s burned nothing.
- Cargo does not count: 1+2 with both wagons full of Raw coal (1,000 each) ran exactly like
  empty (train weight 4,000 either way, same lap times, same distance).
- Raw coal, Coal, Crushed coal and Coke have no speed or acceleration multiplier in the data, so
  the fuel only sets the range: Crushed coal (6 MJ, stacks of 100) fills a Locomotive with
  1,800 MJ, four times Raw coal (measured: the same speed curve, 1,800 MJ loaded).
- A Locomotive facing backwards neither pulls nor burns while the train goes forwards; it only
  adds weight (230 against 245 km/h). It is only worth having where trains reverse.
- 2+2 doubles speed and range a load, but needs 610 tiles to stop from 518 km/h, two and a half
  times the 240-tile grid, and a second Locomotive (5 Intermetallics, 25 Duralumin, 4 Brakes
  MK 01 ...).
- Advanced cargo wagons (railway-mk02, py2) carry 1+4's 80 slots in 1+2's 21 tiles.

### Longer trains in the author's junction

The same bench as the junction verdict (`tools/junction-bench` traffic, mixed traffic, every
lane fed, trains arriving at up to 200 km/h, 15 minutes, seeds 1-3, the grid seeds 1-2); wagons
a minute are trains a minute × wagons a train.

| Blueprint | Composition | Trains a minute | Wagons a minute |
|---|---|---|---|
| 十字路口 | 1+2 (the verdict) | 36.8, 38.5, 38.3 | 74-77 |
| 十字路口 | 2+2 | 41.1, 42.1, 41.3 | 82-84 |
| 十字路口 | 1+4 | 23.8, 24.0, 25.3 | 95-101 |
| 棋盘格-铁轨 | 1+2 (the verdict) | 66.1, 70.8 | 132-142 |
| 棋盘格-铁轨 | 2+2 | 78.5, 76.3 | 153-157 |
| 棋盘格-铁轨 | 1+4 | 42.5, 43.0 | 170-172 |

No deadlock with any composition. The junction's signals were laid out for 21-tile trains, yet
28 and 35 tiles fit as well: 2+2 gets more trains through (they accelerate twice as fast), 1+4
fewer trains but the most wagons. The slowest 1+4 train took 296 s through a busy grid junction
(252 s for 1+2).

## One platform for 7-tile and 3.5-tile wagons

1 locomotive + 2 cargo-wagons and 1 locomotive + 4 mk02-wagons are both 21 tiles long. Measured
with `tools/station-probe` (an inserter on every tile beside the platform; offsets are tiles
relative to the train stop tile, trains running towards +x):

```
offset           -21 ............ -14 ............ -7 ..... -1
1+2 cargo-wagon     .222222.111111.LLLLLL
1+4 mk02-wagon      444433332221111LLLLLL
```

- The vanilla pattern (6 inserters per wagon, 1-tile gaps at -14 and -7) still gives every
  mk02-wagon 3 inserters per side.
- A continuous row from -21 to -7 (15 per side) serves both: mk02 wagons get 3-4 each, and the 3
  extra tiles idle for 7-tile wagons.
- The tiles-to-wagon grouping differs between the two, so a platform must not rely on fixed
  per-wagon inserter groups (e.g. one item per wagon via fixed filters).
- Locomotive tiles are -6..-1 (refuelling inserters go there).
- Py's burner-inserter (Mechanical inserter) has a void energy source: it needs neither fuel nor
  power.

## The author's first refuel station (2026-10-25)

The author chose 1+2 (one Locomotive, two Cargo wagons) and built 加油站-1 (export of 12:39; the
final version of 13:41 is `blueprints/rail-refuel.txt`): a one-way turnaround loop that fits the station stubs of their
棋盘格-边-车站定位 (the early grid edge plus, on each side of the stretch, an entrance and an exit
stub 6 tiles apart), a 22-tile platform, a Cybernetic combinator in refueler mode, on one side 5
Mechanical inserters fuelling from 5 one-slot wooden chests fed by a belt, on the other 5
inserters (filter Ash) emptying the Locomotive's burnt slots into chests that unload onto a second
belt.

Measured with `tools/junction-bench` mode `station` (the whole blueprint built with every
setting; trains with 70 Raw coal and 80 Ash get the schedule Cybersyn gives a train it sends to a
refueler: the stop's own rail for 1 tick, then the stop until 100 ticks of inactivity):

- Every train leaves with 150 Raw coal and 0 Ash after 22.6 s: the inactivity condition waits for
  the inserters (fuel and Ash going in and out count as activity).
- The train stands wholly inside the platform block; four trains in a row are served 1.7 a
  minute.
- Cybersyn's automatic allow-list (from its source) rejects, at a refueler, any train with a wagon
  standing beside an inserter; here the inserters stand only beside the Locomotive, so 1+2 is
  accepted.
- On the grid piece (`map` of the composite): the main-line block between the chain signal before
  the diverge and the one between diverge and merge also holds the entrance stub and the
  station's diagonal, and the main-line signal in front of it is a chain signal. The loop holds the
  train being refuelled and two waiting; a fourth train waits on the main line. A train going
  past behind three refuel trains took 35.9 s, behind four 66.7 s (alone 24.9 s). A train limit
  of 3 on the stop keeps the queue off the main line (Cybersyn sends no more trains to a refueler
  than its train limit).
- The blueprint's train stop has no name, so every copy gets a random one.
- Py's Big electric pole supplies only 2 tiles around it (data), so the combinator is unpowered. A
  refueler works anyway (Cybersyn reads only its settings and wires); a station's combinator must
  be powered, as Cybersyn reads no signals from an unpowered one.
- The Ash chests hold 16 slots × 1,000 Ash each, 80,000 in all: about a thousand refuels.

The author's final version (13:41) names the stop 加油站, sets its train limit to 3 and adds a
Small electric pole wired to the big one: rebuilt in the engine, the combinator stands in a pole's
supply area, and the four trains refuel exactly as before (22.6 s, 70 → 150, Ash 0).

## The author's depot (2026-10-25)

车库-1 (export of 14:20): a turnaround loop for the same stubs as the refuel
station. The entrance splits into four parallel diagonal tracks that join again at chain signals,
then a single track round the loop splits onto four depot tracks (chain signal in, rail signal
out, 22 tiles between, a stop 车库 with train limit 2 and a combinator in depot mode on each), which
merge into the exit. The entrance with its four diagonals is one block (no signal where they split),
so it holds one train.

Measured with `tools/junction-bench` mode `station` on the grid piece with stubs (trains get
Cybersyn's depot schedule: the depot's name with 100 ticks of inactivity as the only record; a
train going past follows them on the main line, 31.1 s alone):

| Train limit | Trains sent | What happened |
|---|---|---|
| 2 (as built) | 8 | One parked. The second took the second slot of that same stop and waited in the entrance block for its track, for good; everyone behind, the train going past included, stood on the main line; three depot tracks stayed empty |
| 2 (as built) | 5 | Four parked, one per track; the fifth waited in the entrance block for good; the train going past got through (49.2 s) |
| 1 | 4 | One per track, each wholly inside its block, 4 s apart; the train going past 45.0 s |
| 1 | 5 | Four parked; the fifth found every stop full and stopped where it was, on the main line; the train going past never got through |

- Each depot track holds one 1+2 train, so the right limit is 1. Cybersyn's own command
  `/cybersyn-abolish-same-depot` sets depot stops without a limit to 1 (from its source).
- A network needs at least as many depot slots (all stops of the depot's name together) as trains.
- More tracks follow the same pattern (chain in, rail out, limit 1); the space to the junction
  limits how many.
- A waiting place behind each depot stop (to allow limit 2) does not suit Cybersyn's depot bypass
  (on by default): a train returning to the depot is already available for orders (from its
  source), so the one waiting behind a parked train can be given a delivery and then has to wait
  until the parked one leaves. With bypass off (a depot combinator setting) only trains standing
  at a depot stop get orders, but every train then drives back to the depot after each delivery.

The author's revision (export of 15:18): eight tracks, train limit 1 each, the entrance diagonals
gone (one track to the loop) and with them the rail signal at the entrance; plus 车库扩展模块, one
more track, a copy of the bottom one: laid 4 tiles below the bottom track it joins the loop's
switch column and the exit merge. Measured the same way (a train going past alone: 34.1 s):

| Depot | Trains sent | Parked (wholly inside their track's block) | Train going past |
|---|---|---|---|
| 8 tracks | 1 | 1 | 39.4 s |
| 8 tracks | 8 | all, the last after 65.2 s | 81.5 s |
| 8 tracks, a rail signal back at the entrance | 1 | 1 | 37.0 s |
| 8 tracks, a rail signal back at the entrance | 8 | all, the last after 51.9 s | 67.8 s |
| 10 tracks (2 modules) | 10 | all | 98.6 s |
| 27 tracks (19 modules) | 27 | all, 5 s apart at the near tracks, 10 s at the far ones, the last after 227.6 s | 248.3 s |

- With no signal at the depot's entrance (nor on the stub), the whole loop belongs to the
  main-line block at the diverge: the main line stays closed until each train has gone round the
  loop. A rail signal at the entrance (on the last straight joint before the curve, 1647.5,-168.5
  in the blueprint) frees it as soon as the train is in.
- Up to 19 modules (27 tracks) build on the grid piece with stubs without touching anything
  (tested that far). Every track is one more train in the switch column and the exit merge, which
  are single blocks, so the far tracks take longer to reach and to leave.

The author's final version (15:42) puts a rail signal back at the entrance and adds one in the
middle of the loop: 8 trains parked in 44.4 s, the train going past behind them 59.8 s (65.2 and
81.5 without the entrance signal). Imported as `blueprints/rail-depot.txt` and
`rail-depot-extension.txt`.

## Cybersyn before batteries (2026-10-25)

Constant, arithmetic and decider combinators each take a Battery (battery-mk01) in Py (data:
5 Copper cable + 2 or 5 Simple circuit boards + 1 Battery); the Cybernetic combinator does not
(5 Copper cable + 5 Simple circuit boards). Red and green wires come with Steam power (its
`unlock-circuit-network` effect), so they are there from the start. Battery - Stage 1 (175 × red +
py1) makes the Battery from Glass, 2 Melamine, Lead-antimony alloy, 3 Bolts, 3 Graphite, 3 Zinc
plates and 30 Cyanic acid; Melamine and Cyanic acid need Ammonia, which at this stage comes from
Auog manure (see [Trains and robots](trains-and-robots.md)). Logistic science packs take Batteries
too. The only other constant signal source in the mod set, aerial-base-combinator, is part of Py's
aerial blimp base.

What Cybersyn can do with only its own combinator and wires (from its source):

- Depot and refueler: need nothing else.
- Provider: its input is its stock, positive signals; chests wired straight to the combinator do.
- Requester: needs a negative signal, the amount wanted minus what is there; with no constant
  combinator there is nothing to make it, so no request, and Cybersyn sends no train at all
  (a delivery needs a requester and a provider).
- Per-station thresholds and priorities are signals too. The request threshold has a map setting
  (default 2,000 items) and a per-combinator "stack thresholds" box that needs no signal.

## The author's first provider (2026-10-25)

固体供货站-1 (export of 15:42, a first draft, not imported): a loop for the same stubs (laid turned
half round), train limit 3, a 22-tile platform, 24 Mechanical inserters loading the two wagons
straight from two belt rows fed by one belt through a splitter; the combinator set to provide
only.

- Its combinator has no wire, so it reports no stock and would never be sent a train. With no
  buffer chests there is also little to report (a belt holds a few hundred items).
- Its setting value 801 also ticks "Circuit condition": Cybersyn then adds "signal-check > 0" to
  the loading order, which only a signal sent to the stop satisfies. Measured with that order:
  the train was full (2,000 Raw coal) after 120 s and still standing at 180 s.
- Measured with Cybersyn's loading order (2,000 Raw coal) and both belt rows kept full: 2,000 in
  about 100 s (101.1 and 99.7 s), the 24 inserters' rate; fed by one belt split in two it cannot
  be faster than 15 a second, and without chests a train waits for whatever the belt brings.

## The author's station set, first drafts (2026-10-29)

Export of 22:30, not imported: every station now carries its own piece of main line (the outer lane
x 11 of a 240 grid edge, absolute snapping) with the switch off and back, so the stub piece
棋盘格-边-车站定位 is gone. New: 加油站-1-灰烬 (refueler, limit 4), 车库-1 (8 tracks, trains run the
other way than before), 物品需求站-1-4 and 物品供货站-1-4 (four platforms, each its own stop
"[item=…]卸货站" / "[item=…]供货站", limit 2, 24 Mechanical inserters and 24 wooden chests a platform,
blueprint parameters for item and amount, default request −1200), their extension modules (a fifth
platform) and 车库-1-扩展模块; plus 棋盘格-边-远程输电塔, Big electric poles along a grid edge.

Measured with `tools/junction-bench` (mode `build` for every draft; `station` for the refueler and
the depot; `network`: the early grid with requester, depot, provider and refueler on its four inner
edges, Cybersyn running 8 trains):

- Everything builds and every combinator is in a pole's supply area; the requester and provider
  extensions join cleanly as a fifth platform; the pole piece builds on both grid edges.
- Refueler: 22.6 s a train, Raw coal 70 → 150, Ash 80 → 0, the train wholly in the platform block;
  the loop holds the train at the stop and three waiting, so limit 4 fits (a fifth waits on the main
  line: a train going past 60.5 s instead of 30.6).
- Depot: 8 trains parked 3.4 s apart, the last after 37.5 s, each wholly in its block; a train
  going past behind them 44.3 s (the old depot 59.8 s).
- Stations under Cybersyn (amount 10,000, chests restocked and emptied every 10 s, 20 minutes): a
  second train for a busy platform waits wholly in the 21.3-tile curve block in front of it, so the
  shared entry column stays free and limit 2 fits; no train ever waited on the main line. Loading or
  unloading 2,400 plates takes 126 s (24 inserters, about 19 a second). Trains low on fuel refuel
  after unloading (26–27 s, 50 → 150).

Faults found:

- The top platform of 物品需求站-1-4 and the requester extension: the Cybernetic combinator and the
  constant combinator have no wire (their chests are wired only to each other), so Cybersyn reads
  nothing and the platform never requests.
- The default request −1200 is below the request threshold of the author's save (2,000, the default):
  ten minutes, not one delivery; with 4,000 the deliveries came.
- The provider's chests are limited to one slot each, 24 stacks a platform: a train takes at most
  2,400 plates (of 4,000), and an item stacking to fewer than 84 never reaches 2,000, so it is never
  sent (measured with Mechanical inserters, stack 50: 1,200 in stock, request failed, no delivery).
- The provider extension's stop is named "[item=…]卸货站", the requesters' name.
- Three requester combinators are set to provide and request, the fourth and the extension to
  request only (from the source: one that provides offers what its chests hold beyond the request).

Correction: this list first also said 车库-1-扩展模块 does not fit the new depot. It does: turned 180°
and laid above the top track (the author's point; only the unturned module had been tried). Measured
on the 22:30 depot: all 9 tracks one block each, 9 trains parked, the last after 40.8 s, each wholly
in its block; a train going past 47.8 s.

## The station set, revised (2026-10-31)

Export of 14:18, not imported yet. The author fixed the faults above (chests unlimited, all requesters
request only, all platforms wired, request −4000, stop names), added one-, two- and three-platform
versions (物品需求站-1-1/-2/-3, 物品供货站-1-1/-2/-3), and made 车库-1 4 tiles shorter on the collector
side, its module redone to match (no turning needed now). The refueler and the pole piece are
unchanged, so their results above stand. Cybersyn is 2.1.3 now (only an elevator fix after 2.1.2).
Same tools; requester, depot, provider and refueler on the four inner edges of the early grid, 8 trains.

- Depot: 8 trains, the last parked after 36.4 s, a train going past 43.1 s. With modules above the top
  track, 9 / 10 / 12 tracks: last 39.0 / 41.7 / 47.2 s, going past 45.7 / 48.3 / 53.8 s; every train
  wholly in its block.
- The blueprints' own settings, 1 to 4 platforms, 15 minutes each (chests restocked and emptied every
  10 s): every order 4,000 plates or just under, a full train; loading 4,000 takes 211 s, unloading
  210 s. No train on the main line, none without a path.
- Request −4,000 means one train per platform at a time, since Cybersyn counts what is on its way: a new
  order 455 s after the last, about 8.8 plates/s a platform. Request 10,000, 15 minutes, 8 trains, 1 / 2 /
  3 / 4 platforms: 4 / 8 / 11 / 15 orders (one platform: 16,000 plates against 8,000); the second train
  waits wholly in the curve block, sampled every 10 s, never on the main line.
- Modules join 1-4 only. 1-4 + one module (five platforms) and + two (six): every platform served. On
  1-1, 1-2 and 1-3 the module builds without complaint, but its left stub misses the exit (1-1: it crosses
  the exit line and ends; the column it should extend exists only in 1-4): the train loads, then stands at
  the provider with `no_path` (on 1-1 still there after 20 minutes).

Left in the 14:18 export:

- 物品需求站-1-扩展模块 still has +4000 (constant combinator and parameter default): its platform got no
  order in 10 minutes, the other four got two each. With −4000 it works (above).
- 物品供货站-1-4, top platform: three chests still limited to one slot, (66.5,127.5), (67.5,122.5), (74.5,122.5):
  33,900 plates instead of 38,400; loading no slower (207 s against 211 s).

An item stacking to fewer than 50 is not sent at the default threshold (from the source,
`central-planning.lua`: a train needs slots >= threshold / stack, rounded up, and 1+2 has 40; 2,000 / 50 =
40). Measured at −4000: Mechanical inserters and Raw coal (stack 50) 2,000 a train; Empty fuel canisters
(20) and Worker's food (10) no order in 5 minutes, others within 21 s. Cures, both measured: the
Request threshold signal in that platform's constant combinator (800 on the canisters: 800 a train), or
Stack thresholds on its combinator with a threshold of 20 (Worker's food: 400 a train). Plates,
batteries and Intermetallics stack to 100; below 50 are mostly buildings and canisters.

## Fluid stations and stack thresholds (2026-10-31)

Export of 14:52. The two faults left above are fixed, measured: the requester module's platform gets its 4,000 and
every provider platform holds 38,400 plates. The item set is imported (`blueprints/rail-requester-*`, `rail-provider-*`,
`rail-depot*`, `rail-refuel-ash`, `rail-grid-edge-big-poles`).

**流体卸货站-1-4, 流体供货站-1-4** (not imported yet). Rails and signals are the item stations', tile for tile. A
platform: two Pumps, one at each wagon, two PyTanks (100 kL) wired to the combinator; request −200,000, the two tanks.
Tested with 1+2 on Fluid wagons (25,000 each), `network` mode:

- The Pumps meet the wagons: 50,000 a train, about 3 s to load and 3 s to unload (the item stations: 211 s and 210 s).
  Four platforms, 8 trains, tanks refilled and emptied every 10 s: 49 orders in 4 minutes, all 50,000, no train on the main line.
- With nothing used up the tanks fill (199,900 to 200,000) after 4 trains a platform and the orders stop; no train is left standing.
- Mixed network (two grid cells, item and fluid stations, 4 cargo + 4 fluid trains, one depot, 15 minutes): the cargo trains took
  only items, the fluid trains only fluids; a fluid train changes fluid between trips without trouble (Cybersyn waits for an
  empty train at the requester); nothing without a path.

Faults:

- Only the bottom platform has a Pipe joining its two tanks. Each Pump serves its own tank, so on the other three a factory
  piped to one tank leaves the other full, and a train that cannot empty waits for ever (Cybersyn's unloading condition is
  "empty"). Used at 500/s from one tank, 15 minutes: 6 orders on each of the three, then jammed with 2 trains each, 6 of the
  8 trains; the bottom platform 39 orders. The same at the provider with one tank fed: 2 orders each, then trains wait for a
  full load that cannot come; bottom platform 26. With a Pipe at (68.5,116.5), (68.5,128.5) and (68.5,140.5) on both
  blueprints: 33-38 and 26 orders on every platform, no jam.
- The default fluid threshold is the item threshold, 2,000 (the fluid map setting is 0, off), so slow use sends nearly empty trains.
  Used at 100/s a platform, 15 minutes: 33-34 orders a platform, nearly all of 2,000-6,000 on a 50,000 train. With the Fluid
  request threshold signal at 50,000 in the constant combinator: 5 orders a platform, all full. Stack thresholds do not touch fluids.
- Small: the provider's parameters are named 需求流体 and run from the top platform down (parameter-3 first), the
  requester's from the bottom up. The stops are named `[item=parameter-k]…`; whether the game shows a fluid's icon there
  cannot be tested headless (the name does not matter to Cybersyn: four stops of one name ran fine).

**Stack thresholds** (`central-planning.lua` lines 367, 592, 688, 736-737, 999-1002; checkbox on the requester's combinator).
The threshold counts stacks of the item instead of items; nothing else changes. So it is the smallest delivery, not the amount
wanted: a train is sent when the shortage is at least that many stacks, the provider holds that many, and the train has
that many slots (1+2: 40). Each train carries min(shortage, stock, 40 stacks). The request stays in items.

Measured on five platforms with stacks 10, 50, 100, 200, 1000 (Worker's food, Mechanical inserters, Iron plates,
Small parts, Stone bricks), per train:

| Setting | 10 | 50 | 100 | 200 | 1000 |
|---|---|---|---|---|---|
| Ticked, no threshold signal, −4000 | none | none | none | none | none |
| Threshold 20, −4000 | 400 | 2,000 | 4,000 | 4,000 | none (4 stacks) |
| Threshold 40, −4000 | 400 | 2,000 | 4,000 | none (20 stacks) | none |
| Threshold 40, request 80 stacks | 400 | 2,000 | 4,000 | 8,000 | 40,000 |

Without the signal the default 2,000 is read as 2,000 stacks, so nothing is ever sent. The threshold must be at most 40. The
request must be at least threshold x stack. At stack 100 a threshold of 20 is the 2,000 of today. A full train of stack
1000 is 40,000 items, about 35 minutes through 24 inserters at the measured 19 a second (computed).

## Cybersyn 2.1.2: how it runs

Read from the mod's source (`scripts/central-planning.lua`, `train-events.lua`,
`factorio-api.lua`, `layout.lua`, `settings.lua`); in-game names from its zh-CN locale. With
pypostprocessing its technology costs 200 red science only.

Vanilla trains run a fixed schedule. Under Cybersyn trains have no route of their own: they wait,
empty, at depots, and the mod writes each one a schedule for one delivery at a time, from a
station that has an item to one that needs it.

**Parts.** One Cybernetic combinator (Cybersyn 协同控制运算器) beside a Train stop makes that stop
part of the network; the combinator's mode says what the stop is:

| Mode | What it does |
|---|---|
| Station (站台) | Its input is the station's inventory: a positive signal is stock it can provide, a negative one a need it requests. Usually the station's chests wired in, plus a constant combinator holding minus the amount wanted. Switches: provide only, request only (default both). |
| Depot (车库) | Where empty trains wait for orders. A train joins the network the first time it stops at a depot empty, and belongs to that depot's network. |
| Refueler (加油站) | Trains low on fuel go there after a delivery. |
| Station control (站台控制) | Optional second combinator: per-item request thresholds and priority as input; outputs the deliveries on their way and the number of trains coming (signal T). |
| Wagon control (车厢控制) | Optional, one beside each wagon position: at a provider it outputs what that wagon should load and sets its slot filters. |

Station signals (virtual): request threshold (请求阈值), station priority (站台优先级), locked slots
per cargo wagon (每车厢锁定格数); the network is a signal too (default signal A; the "each" signal for several networks).

**One cycle.** The planner runs every second tick (30 times a second, map setting), each time
polling 2 stations or making up to 2 deliveries (map setting), in two phases that repeat:

1. Poll: every station's input is read. Cybersyn adds what trains are already bringing or
   fetching, so a station does not ask twice for the same items. An item is requested when
   −(count + incoming) is at least the request threshold; it is provided when count − outgoing
   is above 0.
2. Dispatch, one delivery at a time, items in random order:
   - requester: highest priority, then the one served longest ago;
   - provider: highest priority, then the nearest to the requester in a straight line; it must
     hold at least the threshold;
   - train: parked at a depot (or returning to one, see bypass), on the same network, with
     enough room for the threshold, allowed at both stations; highest depot priority, then the
     **largest capacity**, then the nearest to the provider in a straight line.
   - Amount: the request, at most the provider's stock and the train's capacity.

**The train's schedule.** Cybersyn adds temporary records: provider, wait until the items of the
order are loaded; requester, wait until empty (optionally also inactivity, or a circuit
condition); then the depot, the only permanent record (wait 100 ticks of inactivity). Before each
station comes a temporary record on that stop's own rail (wait 1 tick), so the train goes to that
exact stop even when several stations share a name. A train must come back to the depot empty:
one with cargo left is held there with an alert.

**After unloading.**
- Fuel threshold (default 0.5): if the least-filled Locomotive's fuel slots are that full or
  less (stacks held / slots), the train goes to the nearest refueler; with Raw coal that is 75 or
  fewer of 150, about 6 minutes of driving left. With no refueler it goes back to its depot.
- Depot bypass (on by default): with enough fuel the train is available again on its way back
  and can take the next delivery without reaching the depot.
- A stop's train limit caps how many deliveries go to that station at once.

**Things that bite.**
- The default request threshold is 2,000 items, and a train qualifies only if it has room for
  it: in 1+2's 40 slots, items stacking to fewer than 50 can never be delivered (alert "no train
  has capacity") until the station gets its own threshold signal or uses stack thresholds.
- Mixed train sizes on one network: at equal depot priority the largest free train is picked
  first.
- The vanilla train stop priority must stay at 50 (Cybersyn misroutes otherwise; command
  `/cybersyn-fix-priorities`), and a depot must not share its name with a station.
- A new or blueprinted station waits 20 s (map setting) before joining.
- The Cybersyn manager (Ctrl+T) lists stations, trains, deliveries and alerts.
