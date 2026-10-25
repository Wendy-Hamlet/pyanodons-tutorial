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
