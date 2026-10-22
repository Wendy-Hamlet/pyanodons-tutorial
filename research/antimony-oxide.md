# Antimony oxide: how much the next goals need

[中文](antimony-oxide.zh-CN.md)

The author's next block after [chapter 12](../chapters/12-nexelit-nickel.md) is Antimony oxide.
Built like the lead, titanium and tin blocks, for a full belt of 15 ore a second, it would take
a great deal of power, even standing idle part of the time. They asked (2026-10-22, game at 29:51)
how much Antimony oxide the way to trains and robots needs, to size the block by that.

Sources: the recipes of the author's mods (`tools/q.js`, data rebuilt 2026-10-18), the
research plan in [trains and robots](trains-and-robots.md), the idle draw of a crafting machine
measured with `tools/geo-probe` (see [geothermal](geothermal.md)), and the Antimony field of the
save of 29:51.

## Short answer

- **The way to trains and robots needs roughly 700 to 1,500 Antimony oxide**: 158 for the first
  trains (two locomotives, four wagons), 12 for each roboport (240 for twenty), 328 for one of
  each of the 25 new buildings of this stage that take Intermetallics, 100 for each further train
  of a locomotive and three wagons, 20 for each Oil burner.
- **0.1 Antimony oxide a second (one Basic oxygen furnace) makes 730 in two hours and 1,500 in
  four**, while the research to Construction robotics takes about five. The block takes 1.36 ore
  a second, about 6.5 MW while it runs (12.4 MW at most, 0.4 MW idle) and 5 MW of solid fuel in
  its furnace.
- **A 15-ore block would make 1.1 a second**, 4,000 an hour, and take 71 MW of electricity and
  55 MW of fuel while running: ten times what is needed.
- **Three quarters of the power is Oxygen.** Each Antimony oxide takes 50 Oxygen, and at this
  stage Oxygen comes only from electrolysis: 50 MJ of electricity an oxide. The electrolysis also
  gives 100 Hydrogen (10 MJ), almost all the fuel an Antimony drill burns for the 13.6 ore.

## 1. What takes Antimony oxide

Every recipe below is the one available at the author's research (or the trains and robots
technologies); the counts are Antimony oxide per item, worked out from the recipes.

| Item | Recipe | Antimony oxide |
|---|---|---|
| Vitreloy | 3 Titanium, 3 Copper, 3 Nickel plates, 3 Duralumin, 3 Antimony oxide → 2 | 1.5 |
| Iron nexelit antimony special alloy | 7 Iron plates, 2 Nexelit plates, 1 Antimony oxide → 2 | 0.5 |
| Intermetallics | 1 Vitreloy + 1 Iron nexelit antimony special alloy | 2 |
| Shaft MK01 | 5 Iron nexelit antimony special alloy, 5 Solder, 5 Small parts | 2.5 |
| Brakes MK01 | 2 Vitreloy, Ceramic, Copper plates, Glass, Steel, Duralumin, Small parts | 3 |
| Gearbox MK01 | 2 Shaft MK01, Duralumin, Steel, Titanium plates, 20 Fish oil | 5 |
| Battery (Battery - Stage 1) | 1 Lead Antimony Alloy (6 Lead plates + 1 Antimony oxide), Glass, Melamine, ... | 1 |
| **Locomotive** | 5 Intermetallics, 4 Shaft MK01, 1 Gearbox MK01, 4 Brakes MK01, ... | **37** |
| **Cargo wagon** / **Fluid wagon** | 5 Intermetallics, 2 Shaft MK01, 2 Brakes MK01, ... | **21** each |
| **Py roboport MK 01** | 5 Intermetallics, 2 Batteries, ... | **12** |
| **Oil burner** | 10 Intermetallics, ... | **20** |
| Long-handed inserter (Rubber) | 1 Iron nexelit antimony special alloy → 2 | 0.25 |
| Fast inserter (Logistic science) | 1 Vitreloy | 1.5 |

Rails, Train stops, Rail signals and the Construction Zone Extender take none.

**Buildings.** Intermetallics go into 25 building recipes of this stage (the train, fish,
geothermal and robot technologies with their prerequisites, `tools/building-inputs.js`), 164
Intermetallics for one of each, 328 Antimony oxide: Gas refinery MK 01 15; Scrubber MK 01,
Flotation cell MK 01, Rectisol MK 01, Compost plant MK 01, Ionic upgrader MK 01 and Oil burner 10
each; Casting unit MK 01 and Hydroclassifier MK 01 8; Phytoplankton farm MK 01 7; Electric arc
furnace MK 01 and Impact crusher MK 01 6; Py roboport MK 01, Drone recharging station, Bioreactor
MK 01, Auog paddock MK 01, Ralesia plantation MK 01, Centrifuge MK 01, Mixer MK 01 and Chemical
plant MK 01 5; Ball mill MK 01 4; Construction pynobot MK 01 and Classifier MK 01 3; Automated
factory MK 01 and Fish farm MK 01 2.

## 2. How much, and how fast

| Use | Count | Antimony oxide |
|---|---|---|
| First trains (a batch, [techniques](techniques.md) principle 24) | 2 locomotives, 4 wagons | 158 |
| Roboports for the 100 Construction pynobots MK 04 | 20 | 240 |
| One of each new building that takes Intermetallics | 25 kinds | 328 |
| Further trains | each 1 locomotive + 3 wagons | 100 each |
| Oil burners, if power still comes from fuel | each | 20 each |

The first three rows make about 730; four more trains and second copies of the common buildings
(Chemical plants for the Batteries, Casting units, Auog paddocks) bring it to about 1,500. With
[geothermal power](geothermal.md) the Oil burners of the gas block ([trains and
robots](trains-and-robots.md), section 5: seven, 140) may not be needed at all.

Time: research to Construction robotics is about 1,800 units (the train technologies 290, the
robot chain 1,480), five hours at the base's 0.1 units a second. In that time:

| Rate | An hour | 730 take | 1,500 take |
|---|---|---|---|
| 0.05 a second | 180 | 4.1 h | 8.3 h |
| **0.1 a second (one Basic oxygen furnace)** | **360** | **2.0 h** | **4.2 h** |
| 1.1 a second (15 ore a second) | 3,960 | 11 min | 23 min |

The other new materials pace the trains as much: a locomotive also takes 35 Nexelit plates (the
dig site gives about 0.1 a second, [chapter 12](../chapters/12-nexelit-nickel.md)) and 19.5 Nickel
plates.

## 3. The chain

Antimony processing - Stage 1 (researched). Per Antimony oxide:

| Step | Machine | Recipe | Per oxide |
|---|---|---|---|
| Ore | Antimony drill MK 01 (7 × 7, burns any fluid fuel, 1 MW; 1 ore a second, 1.2 with Mining productivity 2) | — | 13.64 ore |
| Screening | Automated screener MK 01 (300 kW) | 10 ore → 5 Antimony (grade 1), 3 (grade 2), 2 Stone, 0.3 Iron oxide, 5 s | 6.82 machine-seconds |
| Crushing | Jaw crusher MK 01 (1 MW) | 5 grade 1 → 10 grade 2, 0.4 Stone, 5 s | 6.82 |
| Screening | Automated screener MK 01 | 10 grade 2 → 0.8 grade 3, 5 grade 4, 3 Gravel, 10 s | 17.73 |
| Crushing | Secondary crusher MK 01 (450 kW) | 5 grade 3 → 4 grade 4, 5 s | 1.42 |
| Oxygen | Electrolyzer MK 01 (10 MW) | 300 Water → 200 Hydrogen + 100 Oxygen, 10 s | 5 |
| Oxide | Basic oxygen furnace MK 01 (burner, 5 MW) | 10 grade 4 + 50 Oxygen + 1 Plastic bar → 1, 10 s | 10 |

So 10 ore give 13 grade 2 (3 directly, 10 through the crusher), and 10 grade 2 give 5.64 grade 4:
13.64 ore an oxide.

## 4. Two sizes

| | 0.1 a second | 1.1 a second (15 ore) |
|---|---|---|
| Antimony ore | 1.36/s: 2 drills (1.14 busy) | 15/s: 13 drills |
| Screeners (grade 1 / grade 3) | 1 / 2 (0.68 / 1.77 busy) | 8 / 20 |
| Jaw crushers | 1 (0.68) | 8 |
| Secondary crushers | 1 (0.14) | 2 |
| Electrolyzers | 1 (0.5) | 6 |
| Basic oxygen furnaces | 1 | 11 |
| Plastic bars | 0.1/s | 1.1/s |
| Electricity while running | about 6.5 MW (12.4 MW with every machine busy) | about 71 MW |
| Electricity idle | 0.4 MW | 2.6 MW |
| Solid fuel (furnaces) | 5 MW | 55 MW |
| Fluid fuel (drills) | 1.1 MW; the 10 Hydrogen a second give 1.0 | 12.5 MW; Hydrogen 11 |
| By-products a second | 0.33 Stone, 0.53 Gravel, 0.04 Iron oxide, 10 Hydrogen | 3.6 Stone, 5.9 Gravel, 0.45 Iron oxide, 110 Hydrogen |

Idle draw: a crafting machine draws a thirtieth of its power when idle (measured on the
Regenerative heat exchanger: 300 kW + 10 kW); mining drills and burner machines draw nothing. Of
the idle 0.4 MW, the Electrolyzer is 333 kW.

## 5. Where

The Antimony field the save has charted is at (325, 5): 7.3 M ore on 394 tiles, 275 tiles from
the base's centre. The author has crafted 5 Antimony drills MK 01. Two ways to lay the block out:

- **All at the field**: the Electrolyzer's Hydrogen goes straight into the drills' fuel pipe;
  Plastic bars and the furnace's solid fuel are brought in, Antimony oxide goes out (0.1 a second).
- **Screening at the field, the furnace at home**: grade 4 travels (1 a second), the Electrolyzer
  and the furnace stand where Plastic and fuel already are; the drills then need another fluid
  fuel.

Every by-product needs a buffer ([techniques](techniques.md), principle 12): Stone (as bricks),
Gravel, Iron oxide, and the Hydrogen, which an Exhaust pipe can take.
