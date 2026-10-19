# Trains and robots: a first plan

[中文](trains-and-robots.zh-CN.md)

The author's next two goals after chapter 10 are trains and robots in quantity; with both, the
base can move to city blocks. A short-term goal comes first: the drills and smelting of the
technologies just unlocked, which take a lot of power. This note plans the way there from the
author's save of 2026-10-18 20:35 (25.8 h, Py-Exploration).

Sources: the data of the author's current mods (`tools/dump-data.ps1`, rebuilt the same day:
pycoalprocessing 3.1.8, pyalternativeenergy 3.2.11), the save inspector, `tools/rate-probe`
(10 minutes of the base as it stands), `tools/power-probe` (a 30-minute load test of the whole
base, and an Oil burner placed beside it), all in copies of the save. Rates the data gives for a
script-run machine (the Dig-o-saurus' Dig site) are marked: they still need a measurement.

## 1. Where the base stands (measured)

- **Research runs at 0.05 units a second, half its speed.** Every technology here costs 1 pY
  science pack 1 + 2 red a unit. Red science came out at 0.100/s (the line is built for 0.2): its
  Empty planter box machine (-42.5,-168.5) was short of ingredients 80 % of the time, holding Wood
  and Iron plates but no Stone bricks; the brick belt coming in from the west at y -167 carried 8
  bricks. The pY1 Research center stood with a full output 64 % of the time. Five Labs take
  0.111 units/s, so with bricks for the red line research doubles to 0.1 units/s.
- **Power: 99.6 MW used, all of it made** by the 49 Steam engines. Load test (an energy interface
  taking whatever is left): the engines gave 161.2 MW on average, 56.6 MW more than the base used,
  but falling (168.6, 162.5, 152.5 MW in the three 10-minute steps). The crushed-coal block's
  crushers were never short of Raw coal but made only 8.07 crafts a second (24.2 Raw coal of 30):
  one crusher never runs (a Pipe to ground turned the wrong way stops its Coal Boiler), and the
  lower row's crushers wait to put out their Coal dust, more than the six Coal dust Boilers burn
  once the whole base runs ([chapter 10](../chapters/10-crushed-coal-power.md), sections 4 and 5).
  Some Raw coal Boilers at y 230–260 filled with Ash (1,000). So about 50 MW is spare today, and less
  under a long load.
- Plates made per second: Aluminium 0.612, Lead 0.260, Tin 0.173 (0.310 used: the stock goes
  down), Solder 0.067. Never made in this game: Nexelit plates, Antimony oxide, Nickel plates,
  Vitreloy, Iron nexelit antimony special alloy, Intermetallics. In the author's inventory: 100
  Construction pynobots MK 04.

## 2. Research: order and time

| Step | Technologies | Units | At 0.05/s | At 0.1/s |
|---|---|---|---|---|
| The queue now | rest of Mining machines - Stage 1, Mining productivity 1 and 2, Tin processing - Stage 1, Composting, Water animals - Stage 1, Assembly 2 | 463.5 | 2.6 h | 1.3 h |
| Trains | Trains & railway - Stage 1, Automated rail transportation, Fluid wagon | 290 | 1.6 h | 0.8 h |
| Fish farm | Microbiology - Stage 1, Separation, Fish - Stage 1 | 250 | 1.4 h | 0.7 h |
| Oil burner | Oil industry machinery - Stage 1 (its prerequisites are done) | 80 | 0.4 h | 0.2 h |
| Construction robots | Casting, Chromium processing, Coke processing and Hot air (Stage 1 each), Rubber, Boron, Laboratory Equipment, Genetics - Stage 2, Ralesia, Auogs - Stage 1, Melamine, Battery - Stage 1, Construction robotics | 1,480 | 8.2 h | 4.1 h |
| **All** | 27 | 2,563.5 | 14.2 h | 7.1 h |

Logistic robots need 20 more technologies (3,770 units), among them Niobium and the Logistic
science pack itself, and from Nitrogen - Stage 1 on the green pack: the next stage, not this one.
Mining productivity 1 and 2 (190 units, 32 minutes at 0.1/s) can also wait until after the train technologies.

## 3. Trains

Key materials per vehicle (the recipes the technologies above unlock, expanded to plates):

| | Locomotive | Cargo wagon | Fluid wagon |
|---|---|---|---|
| Aluminium plates (most as Duralumin) | 514 | 254 | 334 |
| Copper plates | 316.5 | 160.5 | 200.5 |
| Titanium plates | 23.5 | 63.5 | 63.5 |
| Nexelit plates (3 Raw nexelit each) | 35 | 15 | 15 |
| Antimony oxide | 37 | 21 | 21 |
| Nickel plates | 19.5 | 13.5 | 13.5 |
| Lead / Tin plates (Solder) | 120 / 60 | 40 / 20 | 50 / 20 |
| Fish oil | 20 | – | – |
| Shaft MK 01 crafting (50 s each) | 300 s | 100 s | 100 s |

A rail (3 per craft: 1 Stone, 4 Bolts, 2 Treated wood, 1 Steel, 5 Solder) costs 1.67 Solder, that
is 3.33 Tin and 6.67 Lead plates; at today's 0.067 Solder/s, 1,000 rails take 6.9 hours. A Train
stop is 5 Simple circuit boards, 6 Iron plates, 6 Iron sticks and 3 Steel; a Rail signal 1 board
and 5 Iron plates. (Trains & railway - Stage 2 makes 12 rails from 2 Solder, but needs pY science pack 2.)

Where the new materials come from:

- **Nexelit**: Nexelit processing - Stage 1 (done) unlocks the Dig-o-saurus and its Dig site. A
  script runs the dig site; its recipes in the data, for calculators, give 2 Raw nexelit for a
  Meat, 1 for Guts or Dried meat, 8 for Worker's food, 10 s each. The Vrauk slaughterhouse makes
  0.107 Meat and 0.107 Guts a second, burnt now: by those recipes 0.32 ore/s, 0.107 Nexelit
  plates/s, three locomotives an hour. To measure before building on it. The dig site costs 50
  Steel, 30 Duralumin, 10 boards, 50 Lead, 100 Titanium and 100 Small parts; a Dig-o-saurus (Creature
  chamber, 120 s) 30 Moss gene samples, 10 Generic earth DNA samples (15 red science each), 10 Petri
  dishes, 50 Titanium, 1,000 Saline water. The other way, Tar quenching and an Evaporator, costs
  1,500 Tar a Nexelit plate. The nearest Natural nexelit field: (-140,556), 108M.
- **Antimony oxide**: Antimony drill MK 01 (1 MW, burns a fluid fuel) on Antimony at (325,5), 7.3M;
  Automated screeners and crushers down to Grade 4, then a Basic oxygen furnace (10 Grade 4 + 50 Oxygen + 1
  Plastic): 13.6 ore an oxide.
- **Nickel**: Fluid mining drill with Syngas on Nickel ore at (-256,96), 30.4M; 5 ore → 1 Grade 1
  (Jaw crusher) → 1 plate.
- **Fish oil**: 8 Fish → 100 Fish oil (Slaughterhouse). Fish in water are finite (the author):
  hand-picked Fish only start the Fish farm, whose speed comes from Fish as modules (base −100 %,
  +100 % a Fish, 7 slots). A round of eggs and breeding gives 13 Fish more than it takes.
- **Solder**: Lead processing - Stage 1 (done) has the screener route, 2 Lead ore a plate instead
  of the 6 the base uses now; Tin processing - Stage 1 (queued) 6 Tin ore a plate instead of 10.
- **Duralumin**: Smelter MK 01, 4 Aluminium + 2 Copper plates, 4 s (0.197/s measured with one
  Burner inserter per chest).

The first trains are a deliberate batch (techniques principle 24): two locomotives and four
wagons need 130 Nexelit plates, 158 Antimony oxide, 93 Nickel plates and 2,044 Aluminium plates
(56 minutes of today's Aluminium). Their first lines go to the fields these materials come from.

## 4. Robots

- **Construction robots are already there**: the 100 Construction pynobots MK 04 in the inventory fly at 0.24 (MK 01:
  0.08) and carry 5 (MK 01: 1). Construction robotics only has to give the roboports.
- Py roboport MK 01: construction radius 40, logistics 30, 4 robot slots. It costs 45 Aluminium,
  22.5 Copper, 20 Steel, 20 Small parts, 17.5 Iron, 10 Antimony oxide, 7.5 Titanium, 7.5 Nickel,
  5 Nexelit plates, 5 boards and 2 Batteries. The Py Construction Zone Extender MK01 (radius 60,
  350 kW, no robots) is only 20 Steel, 20 Small parts, 15 Iron plates and 5 boards.
- **Batteries need an Auog farm.** Battery (Battery - Stage 1): Glass, 2 Melamine, Lead Antimony
  Alloy, 3 Bolts, 3 Graphite, 3 Zinc plates and 30 Cyanic acid. Melamine and Cyanic acid take
  Ammonia, and at this stage Ammonia comes only from Urea decomposition; Urea from Auog manure
  (liquid manure and Zogna bacteria).
- Personal roboport (225 units after Construction robotics): radius 15, 10 robots, powered by a
  Portable gasoline generator (180 kW, burning filled canisters such as Gasoline canisters).

## 5. Power

What the upgrades take: an Electric mining drill 1 MW for the speed of two Burner drills (the base
has 146 Burner drills: 73 MW if all were replaced; burner drills also burn fuel and leave Ash in
the fields, electric ones move both to the power station). Electric arc furnace 18 MW
(Aluminium processing - Stage 1: 1.25 Aluminium plates/s each, 2 ore a plate instead of 10).
Automated screener 300 kW, Ball mill 1 MW, Impact crusher 500 kW, Casting unit 500 kW.

**Fluid fuel gives twice the power of solid fuel.** An Oil burner burns its fuel at 200 %, a
Boiler at 100 %, and Steam engines turn Steam into power at 50 %. Measured: an Oil burner with
four Steam engines took 37.01 Syngas/s (14.8 MW of fuel) and gave 14.805 MW. A solid fuel in a
Boiler gives half its value (the crushed-coal block: 140 MW of fuel, 70 MW).

- Surplus fluids today: Gasoline made 27.4/s, used 9.4/s: 18/s is 21.6 MW (the author keeps
  Gasoline for later technologies); Naphthalene oil 9.4/s more than used is 2.8 MW.
- A gas block, by the data and the measured Oil burner: 30 Raw coal/s in 6 Destructive distillation columns (10 Raw
  coal → 60 Coal gas, 30 Tar, 3 Coal, 2 s) and 11 Gasifiers (Syngas from coal gas: 50 Coal gas + 100
  Water → 70 Syngas, 30 Tar, 1 Ash, 3 s) give 252 Syngas/s: 7 Oil burners, 28 Steam engines, 100.8 MW. Its
  machines take 8.5 MW and the drills 7.5 MW: about 85 MW net, plus 198 Tar and 9 Coal a second
  and only 3.6 Ash. The crushed-coal block on the same two belts: 70.0 MW, about 44 MW net, 30
  Ash/s. Not yet built or benched.

## 6. The plan

1. Now: Stone bricks for the red science line. Research doubles, every time above halves.
2. Research: the queue, then the three train technologies; Oil industry
   machinery - Stage 1 early (80 units) for Oil burners; then the Fish farm and the robot chain.
3. While it researches, the materials for the first trains: a Dig site with Dig-o-sauruses (measure
   it first), an antimony and a nickel outpost, the screener route for Lead and Tin and a Solder
   line, a Fish farm started with hand-picked Fish.
4. First trains as a batch, two locomotives and four wagons; the first lines to those fields.
5. Power before the big upgrade: Oil burners on surplus fluids, then a gas block; only then
   Electric mining drills and Electric arc furnaces.
6. Construction robotics: roboports and zone extenders for the 100 MK 04 robots; then a mall for
   trains and one for roboports.
7. City blocks (Cellforge) with trains and construction robots. Logistic robots come with green
   science.
