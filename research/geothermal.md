# Geothermal power

[中文](geothermal.zh-CN.md)

The author noticed on 2026-10-22 (their game at 29:51) that Geothermal Power - Stage 1 is close
in their research queue, and wants to settle power before building further. This note explains
how geothermal power works in Py and what one fissure gives.

Sources: the data of the author's mods (`tools/dump-data.ps1`, rebuilt 2026-10-18), a new
measurement in the engine (`tools/geo-probe`, run with `tools/run-probe.ps1 geo-probe -Ticks 8500`:
each stage alone on its own electric network, 60 s per case), and the fissures of the author's
save of 29:51 (`tools/save-probe.ps1 -Probe geo-probe -Variant cracks`).

## Short answer

- **One fissure gives about 75 MW, with no fuel and no Ash.** A Geothermal plant on a Geothermal
  fissure makes 300 Geothermal water a second (with the author's Mining productivity 2), enough
  for 1.25 Regenerative heat exchangers, which make 150 Steam a second at 500 °C, enough for 10
  Steam engines at **7.64 MW each**: 76.4 MW. The plant, the exchangers and the Pressurized water
  take about 1.5 MW of it.
- **The reason is the Steam's temperature.** Py's Steam holds 2.1 kJ per degree (ten times
  vanilla's), and a Steam engine takes up to 500 °C. A Boiler makes 250 °C Steam, worth 3.70 MW an
  engine; the exchanger's 500 °C Steam is worth 7.64 MW an engine for the same 15 Steam a second.
- For comparison, the crushed-coal block of [chapter 10](../chapters/10-crushed-coal-power.md)
  gives 70 MW (52 MW net) from 30 Raw coal a second, and the whole base used 108 MW at most in the
  hour measured for [chapter 12](../chapters/12-nexelit-nickel.md).
- **The catch is distance.** The nearest of the four fissures found so far is at (−808, 287),
  about 500 tiles west of the base's west edge: a pole line to bring it home (and to start it: the
  plant runs on electricity).
- Research from now: Coke processing - Stage 1 (50 units), Hot air - Stage 1 (55, gives the
  Regenerative heat exchanger) and Geothermal Power - Stage 1 (60, gives the plant and the
  exchanger's Steam recipe): 165 units, under half an hour at 0.1 units a second. In the author's
  queue Casting - Stage 1, Boron and Iron processing - Stage 1 stand among them; moving those back
  brings geothermal forward.

## 1. The chain

| Stage | Building | Takes | Gives | Power |
|---|---|---|---|---|
| Pressurized water | Pressure pump MK 01 (2 × 2) | 500 Water | 500 Pressurized water in 2 s: 250 a second | 1 MW (drain 33 kW) |
| Geothermal water | Geothermal plant (11 × 11, a mining drill) on a Geothermal fissure | 10 Pressurized water a cycle | 100 Geothermal water at 3000 °C a cycle; 2.5 cycles a second | 1 MW |
| Steam | Regenerative heat exchanger (5 × 5), recipe Steam (geo-he-00) | 600 Geothermal water (at least 950 °C) | 300 Steam at 500 °C in 2.5 s | 300 kW (drain 10 kW) |
| Power | Steam engine | 15 Steam a second | 7.64 MW at 500 °C | — |

Measured, each stage alone (`tools/geo-probe`):

| | No mining productivity | +20 % (the author's) |
|---|---|---|
| Geothermal plant: Geothermal water made | 250.00/s at 3000 °C | 300.00/s |
| Pressurized water used | 25.00/s | 25.00/s |
| Fissure used | 2.50/s | 2.50/s |
| Plant's power | 1.000 MW | 1.000 MW |
| Exchanger: Geothermal water in, Steam out | 240.00 → 120.00/s, 500 °C | same |
| Exchanger's power | 0.310 MW | same |
| Steam engine on 500 °C Steam | 7.639 MW, 15.00 Steam/s | same |
| Steam engine on 250 °C Steam (a Boiler's) | 3.701 MW, 15.00 Steam/s | same |

Mining productivity adds Geothermal water without using more Pressurized water or more of the
fissure. The 0.310 MW of the exchanger is its 300 kW plus a 10 kW drain (a crafting machine
draws a thirtieth of its power while idle; mining drills draw nothing).

## 2. One fissure

| | Count | Power |
|---|---|---|
| Geothermal plant | 1 | −1.0 MW |
| Regenerative heat exchanger | 1.25 (build 2; the second runs at a quarter) | −0.39 MW |
| Pressure pump MK 01 | 0.1 (one pump serves ten plants) | about −0.13 MW with its drain |
| Steam engines | 10 (150 Steam a second) | +76.4 MW |
| **Net** | | **about 75 MW** |

Without Mining productivity it is 1 exchanger and 8 engines: 61.1 MW.

What it costs to build: Geothermal plant 4 Electric mining drills, 30 Steel, 10 Simple circuit
boards, 10 Engine units; Regenerative heat exchanger 50 Stone bricks, 30 Pipes, 5 Boilers, 5 Simple
circuit boards, 20 Small parts; Pressure pump MK 01 20 Iron plates, 10 Steel, 10 Small parts, 10
Pipes; and the Steam engines.

## 3. The fissures on the author's map

A fissure's amount is 2^16 × its distance from the start × the map's richness setting (4 on this
map, see [map settings](map-settings.md)), so far fissures are richer. The plant uses 2.5 a second.

| Fissure | Amount | Lasts at 2.5 a second |
|---|---|---|
| (−808.5, 286.5) | 224.9 M | 2.9 years of game time |
| (−520.5, −894.5) | 271.5 M | 3.4 years |
| (570.5, 1050.5) | 313.2 M | 4.0 years |
| (1252.5, 720.5) | 378.6 M | 4.8 years |

The base reaches from x −311 to 452 and y −379 to 597, so the nearest fissure is about 500 tiles
from its west edge, the second about 515 tiles north of its north edge. Only the charted part of
the map was searched; more may lie closer in the dark.

## 4. Building it

- The plant needs electricity before it makes any: connect the outpost to the base's network
  (a pole line also brings the 75 MW home). The Pressure pump needs Water, 25 a second.
- Geothermal water leaves the plant at 3000 °C; the exchanger accepts it from 950 °C up.
- Two exchangers on one plant share its 300 a second; ten engines on their Steam. With one
  exchanger and eight engines the fissure gives 61 MW and 60 Geothermal water a second waits.
- Geothermal Power - Stage 2 (1,400 units, needs the Logistic science pack) turns the same
  water into Pressurized steam at 1000 °C instead, in a Heat exchanger: not for this stage.
