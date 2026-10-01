# Chapter 1 — Landing to red science

[中文版](01-landing-to-red-science.zh-CN.md) · [Index](../README.md)

Goal of this chapter: get from an empty map to researching with Automation science packs (red
science), with iron and copper plates and Raw coal produced automatically. On the way you meet the
things Py changes in the very first hour: expensive smelting, Ash, a different steam ratio and two
free technologies. The chapter follows the author's opening: red science is handcrafted, and the
first automation goes into Raw coal and plates.

Every mechanic mentioned here is also listed, with its source, in
[Techniques and mechanics](../research/techniques.md).

## 1. What you start with

| Source | Items |
|---|---|
| Freeplay start | 8 Iron plate, 1 Wood, Pistol, 500 Firearm magazine, 10 Burner mining drill, 1 Stone furnace |
| Crashed-ship wreckage | 100 Iron plate, 50 Copper plate |
| Crashed ship | 8 Firearm magazine, 5 Iron chest |
| `py_quick_start` (not Py) | 100 Construction pynobot MK 04, Power armor MK2 with 4 personal roboports MK2, 55 portable solar panels, 2 exoskeletons, night vision, belt immunity |

With `py_quick_start` you can let robots build from minute one; without it, everything below is
placed by hand.

Fifteen recipes are available at the start:

| Recipe | Ingredients → result | Made in |
|---|---|---|
| Iron plate | 8 Iron ore → 1 (10 s) | Stone furnace |
| Copper plate | 8 Copper ore → 1 (10 s) | Stone furnace |
| Stone brick | 2 Stone → 1 (3.2 s) | Stone furnace |
| Wood | 4 Log → 20 (4 s) | Hand |
| Stone furnace | 5 Stone | Hand |
| Iron stick | 1 Iron plate → 2 | Hand |
| Bolts | 2 Iron stick → 2 | Hand |
| Iron gear wheel | 2 Iron plate | Hand |
| Copper cable | 1 Copper plate → 2 | Hand |
| Small parts | 1 Iron gear wheel + 3 Copper cable + 3 Bolts → 2 | Hand |
| Mechanical inserter | 5 Iron plate + 2 Small parts | Hand |
| Burner mining drill | 3 Small parts + 1 Stone furnace + 3 Iron plate | Hand |
| Transport belt | 1 Iron plate + 1 Small parts → 2 | Hand |
| Underground belt | 10 Iron plate + 10 Transport belt → 2 | Hand |
| Wooden chest | 2 Wood | Hand |

Smelting cannot be done by hand: the first thing to place is the Stone furnace you start with.

## 2. What works differently from vanilla

| Topic | Py behaviour | Source |
|---|---|---|
| Smelting | 8 ore per plate, 10 s per plate: a Stone furnace makes 0.1 plate/s | Verified |
| Stone furnace | 200 kW | From data |
| Burner mining drill | Mining speed 1 at 500 kW: 1 ore/s, 2 Raw coal/s (Raw coal mines twice as fast); burns 0.17 Raw coal/s | Verified |
| Mechanical inserter | Needs no fuel and no power at all; has 1 filter slot | Verified |
| Ash | Burning coal-type fuel leaves 1 Ash per item in a burnt-result slot; the machine stops when that slot is full | Verified |
| Boiler | 3.7 MW, makes 7.5 Steam/s at 250 °C, burns 1.23 Raw coal/s at full load | Verified |
| Steam engine | Uses 15 Steam/s for 3.7 MW: **one engine needs two boilers** (vanilla is the other way round) | Verified |
| Offshore pump | Needs no power; with `pump-anywhere-fork` it also works on dry land | Verified |
| Lab | 5×5, 60 kW | From data |

### Ash

Raw coal, Coal, Coke and the other coal-type fuels leave 1 Ash per item burnt. Logs and Wood
leave nothing. The burnt-result slot holds 1000 Ash; when it is full the machine shows
"burnt result output full" and stops. Burning Raw coal at full load, that takes:

| Machine | Time until the slot is full |
|---|---|
| Boiler | 13.5 minutes |
| Burner mining drill | 100 minutes |
| Stone furnace | about 4 hours |

How to get Ash out (all verified):

- An inserter taking from a **Stone furnace or Boiler** takes the product *and* the Ash, never the
  fuel. Unfiltered, it puts both on the same belt.
- Two filtered Mechanical inserters on a furnace separate them cleanly: one filtered to the
  plate, one filtered to Ash.
- An **unfiltered** inserter taking from a **Burner mining drill** also pulls the drill's fuel out
  and starves it. Filter it to Ash.

Ash is not waste: red science needs 6 Ash per pack (section 4), so route it to production.

## 3. The first two technologies are free

Both are *trigger* technologies: they complete by themselves when you produce something.

| Technology | Trigger | Unlocks |
|---|---|---|
| Steam power | Make 10 Iron plate | Pipe, Pipe to ground, Offshore pump, Boiler, Steam engine, Small electric pole, Air-core inductors |
| Automation science pack (needs Steam power) | Make 10 Copper plate | Automation science pack, Lab, Flora collector MK 01, Soil extractor MK 01, Soil, Planter box, Empty planter box, Wood processing unit MK 01 |

Verified details:

- Plates from furnaces count; they are counted across all your furnaces.
- Copper plates made *before* Steam power completes still count. Smelt iron and copper at the
  same time from the start and both technologies finish together.

## 4. Opening strategy: handcraft red science, automate plates

Red science is cheap to handcraft and needed in small amounts at first:

- Handcrafting one pack, including its Planter boxes, Small parts and Wood, takes **14.3 s**
  (sum of the recipe times; smelting, Soil and Native flora come from machines).
- The first four red technologies (Assembly, Coal processing 1, Soil washing, Steel processing)
  need 60 packs: about **14 minutes** of handcrafting, done in the background.

Plates are the real bottleneck: 8:1 smelting means 44 Iron ore per pack, and every building
costs plates. So the author automates **Raw coal** and **iron and copper plates** first
(sections 6 and 7) and handcrafts every red pack until Wood is mass-produced (a later chapter);
only then is red science automated.

## 5. Belt tricks you will use

No splitters early on, so lanes do the sorting (all verified in the engine):

- A mining drill drops onto the lane **nearest** to it; an inserter drops onto the lane
  **farthest** from it; side-loading puts everything onto the target lane nearest the feeding
  belt.
- A belt running into the side of an underground belt lets only one lane through. For a belt
  flowing north: into an entrance whose tunnel goes east, the west lane passes; tunnel west, the
  east lane; into the back of an exit pointing east, the east lane; pointing west, the west lane.
  (An entrance passes the lane away from its tunnel; an exit passes the lane on the side it
  points to.)
- A Mechanical inserter moves 0.82 items/s from a belt into a chest and 0.83 items/s from a
  moving full belt onto another belt.

## 6. Raw coal: the 9-drill module

Blueprint: [`blueprints/raw-coal-module.txt`](../blueprints/raw-coal-module.txt) (the author's
design). Measured: **15.0 Raw coal/s, a full belt**, plus 1.40 Ash/s collected in chests.

- Two rows of Burner mining drills face one output belt; each row fills one lane (8 drills, 16/s
  capacity for 15/s).
- The ninth drill, at the upstream end of one row, drops only onto the **service belt**. That belt
  runs behind the first row, tunnels under the output belt with an underground belt, and runs
  behind the second row. Each drill has one inserter feeding it fuel from the service belt and
  one Ash-filtered inserter putting its Ash on the belt's outer lane.
- At the end of the service belt an underground belt lets only the Ash lane through, into two
  chests (1.40 Ash/s is more than one inserter's 0.82/s). The fuel lane backs up as a buffer.
- To start it, put a few Raw coal into the fuel drill; it feeds itself and everyone else.

Why not 8 drills: 8 drills mine 16/s but burn 1.33/s themselves, so at most 14.67/s leaves. With
Mining productivity 1 (+10 %, which adds output without adding fuel use, verified) 8 would be
enough, but then fuel has to be tapped off the output belt mid-way, which costs more parts than
the drill it saves.

## 7. Iron and copper: the smelting column

Blueprints: [`iron-smelting-column.txt`](../blueprints/iron-smelting-column.txt),
[`copper-smelting-column.txt`](../blueprints/copper-smelting-column.txt) and
[`smelting-column-with-fuel-tap.txt`](../blueprints/smelting-column-with-fuel-tap.txt). The
principles are the author's. Measured: **0.91 plates/s and 0.60 Ash/s** per column, no mixed
items.

- **Size.** Half a belt of ore is 7.5/s; a Stone furnace eats 0.8 ore/s, so 10 furnaces take half
  a belt (the theoretical output is 0.94 plates/s; 0.91 was measured).
- **Two belts, one input and one output each.** West belt: ore on the lane next to the furnaces,
  plates on the outer lane. East belt: Raw coal next to the furnaces, Ash on the outer lane.
  Inputs enter by side-loading onto the inner lane; output inserters (filtered to the plate or to
  Ash) drop onto the outer lane by themselves.
- **Input inserter downstream, separator right after the last furnace.** On each furnace the input
  inserter takes the downstream tile and the output inserter the upstream one, and the
  underground separator follows the last furnace directly. Then nothing is stranded when supply
  stops: after the ore ran out, 0 ore was left on the belt, against 4 with the inserters swapped.
  Throughput is the same either way.
- **Collection.** At the top the underground belts pass only the outer lanes: plates into two
  chests (two inserters, since one moves only 0.82/s), Ash into one.
- **Fuel.** A column burns 0.667 Raw coal/s. One inserter moving Raw coal from a passing Raw coal
  belt onto the start of the fuel belt (placed east of it, so the coal lands on the inner lane) is
  enough: with a single tap all 10 furnaces kept working. A set of iron and copper columns needs
  2 taps; one full Raw coal belt fuels about 22 columns.

## 8. Red science

### Recipe tree

```
Automation science pack  (5 s, handcraftable)
├─ 2 Planter box  (2 s, handcraftable)
│  ├─ 1 Empty planter box  (1 s, handcraftable)
│  │  ├─ 4 Stone brick        ← Stone furnace ← 2 Stone each
│  │  ├─ 2 Wood               ← 4 Log → 20 Wood (hand or Wood processing unit)
│  │  └─ 1 Iron plate         ← Stone furnace ← 8 Iron ore
│  ├─ 5 Soil                  ← Soil extractor MK 01: 800 Water → 16 Soil (8 s)
│  └─ 3 Ash                   ← burnt coal-type fuel
├─ 10 Native flora            ← Flora collector MK 01 on a Native flora patch
└─ 2 Small parts  (handcraftable)
   ├─ 1 Iron gear wheel, 3 Copper cable, 3 Bolts
```

Raw materials per pack: **44 Iron ore**, 12 Copper ore, 16 Stone, 10 Native flora, 6 Ash,
500 Water, 0.8 Log. The iron is the expensive part, because of 8:1 smelting.

### Buildings you need

| Building | Size | Power | Rate at speed 1 | Build cost |
|---|---|---|---|---|
| Offshore pump | 2×2 | none | 1200 Water/s | 3 Pipe, 2 Small parts |
| Boiler | 3×2 | burns fuel | 7.5 Steam/s | 1 Stone furnace, 4 Pipe |
| Steam engine | 3×5 | makes 3.7 MW | uses 15 Steam/s | 8 Small parts, 5 Pipe, 10 Iron plate |
| Soil extractor MK 01 | 7×7 | 400 kW | 2 Soil/s, 100 Water/s | 2 Burner mining drill, 10 Air-core inductors, 30 Iron plate, 15 Small parts |
| Flora collector MK 01 | 7×7 | 100 kW | 1 Native flora/s (from data) | 2 Burner mining drill, 1 Soil extractor MK 01, 5 Air-core inductors, 10 Small parts, 20 Iron plate, 1 Steam engine |
| Lab | 5×5 | 60 kW | 1 red per 30 s | 10 Small parts, 4 Transport belt |
| Wood processing unit MK 01 (optional) | 6×6 | 500 kW | Logs → Wood | 5 Log, 20 Iron plate, 1 Steam engine, 15 Small parts, 2 Burner mining drill, 50 Copper cable |

Air-core inductors: 1 Iron stick + 8 Copper cable. Pipe: 1 Iron plate. Small electric pole:
1 Log + 2 Copper cable.

The Flora collector costs a whole Soil extractor and a Steam engine; build it once you have a
few hundred iron plates.

### For later: what a steady 0.1 pack/s takes

When red science is eventually automated, one pack every 10 s keeps three labs busy (each lab
uses one pack per 30 s on these technologies).

| Need per second | Machines (speed 1) |
|---|---|
| 0.55 Iron plate (4.4 Iron ore) | 5.5 Stone furnaces, 4.4 Burner mining drills |
| 0.15 Copper plate (1.2 Copper ore) | 1.5 Stone furnaces, 1.2 Burner mining drills |
| 0.8 Stone brick (1.6 Stone) | 2.6 Stone furnaces, 1.6 Burner mining drills |
| 1 Soil (50 Water) | 0.5 Soil extractor |
| 1 Native flora | 1 Flora collector |
| 0.6 Ash | Coal-fuelled furnaces alone make about 0.64/s |
| 0.08 Log | a few trees now and then |

Electricity: about 0.5–0.7 MW, well within one Steam engine on two Boilers (3.7 MW).

### Suggested order

1. Place the Stone furnace and Burner mining drills on iron and copper; fuel them with Logs until
   you reach Raw coal (Logs leave no Ash).
2. Smelt 10 Iron plate and 10 Copper plate: Steam power and the red-science technology unlock.
3. Build the Raw coal module (section 6) and the first iron and copper smelting columns
   (section 7).
4. Offshore pump → two Boilers → one Steam engine; put an Ash inserter on each Boiler.
5. Soil extractor, Flora collector on Native flora, Labs, Small electric poles.
6. Handcraft red science (14.3 s a pack) with Ash from the smelting columns' chests.

## 9. What to research next

| Technology | Cost | Unlocks |
|---|---|---|
| Assembly | 12 red | Burner assembling machine MK 01 (burns fuel, 75 kW), Iron chest |
| Coal processing 1 | 12 red | Destructive distillation column MK 01, High pressure furnace MK 01, Iron plate from iron oxide, Coal gas (from coal, wood or coke), Coal, Limestone, Carbon dioxide, Carbolic oil, Tailings pond, Exhaust pipe |
| Soil washing | 18 red | Washer MK 01, Muddy sludge, Sand |
| Steel processing (after Coal processing 1) | 18 red | Steel plate, Steel chest, Advanced foundry MK 01, Sinkhole, Multiblade "fish" turbine |
| Gun turret, Stone wall, Repair pack | 60 red each | Only needed on maps with enemies |

Coal processing 1 opens the better iron route and is the subject of the next chapter; Assembly
brings the Burner assembling machine for later automation. Mining productivity 1 (90 × red +
pY science pack 1) is not needed for the Raw coal module.

## 10. Checklist

- Every Boiler has an Ash inserter (it fills in 13.5 minutes at full load).
- Inserters taking Ash from Burner mining drills are filtered to Ash.
- Every output inserter is filtered, and every belt that carries an input and an output ends in
  an underground separator right after the last machine.
- Input inserters sit on the downstream tile of each machine.
- Two Boilers per Steam engine; one fuel tap per smelting column.
- Early fuel: Logs and Wood leave no Ash; switch to Raw coal when you want Ash for red science.

## 11. How these facts were checked

- Prototype values (sizes, power, recipes, technology costs and triggers): `tools/dump-data.ps1`
  dumps `data.raw` for the exact mod set; `tools/recipe-tree.js` expands recipe trees and adds up
  raw materials.
- Starting items and recipes: `tools/newgame-observer` inside a fresh map.
- Verified in the engine by `tools/ch1-probe`: furnace and drill rates, Ash stopping machines,
  which inserters take Ash or fuel, filtered furnace output, boiler steam and fuel, steam engine
  power, trigger technology behaviour, offshore pump on land.
- Belt lanes, underground lane filtering and inserter rates: `tools/belt-lab`.
- The Raw coal module was read from the author's save with `tools/inspect-save.ps1`, copied with
  `tools/extract-design.js`, and run with the smelting columns, the fuel tap and the drain test in
  `tools/design-lab`, which also exported the blueprints.
- Mining productivity adding output without fuel: a one-off engine probe.
- From data only, not yet measured: Flora collector and Soil extractor rates, lab consumption,
  handcrafting time.
