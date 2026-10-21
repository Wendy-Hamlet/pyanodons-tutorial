# Mining drills: what an ore costs in Raw coal

[中文](mining-drills.zh-CN.md)

The author asked on 2026-10-21 (their game at 28:53, before Oil burners): counted in Raw coal,
which is cheaper, the Electric mining drill or the Burner mining drill, and which Fluid mining
drill should the fluid ores get? Their guess: Burner drills for the first, MK 02 for the second.
Their plan for later: once they make Intermetallics, Moondrop greenhouses make Methane for power,
power stops being the limit, and Electric drills and Fluid drills MK 02 can go everywhere.

Sources: the data of the author's mods (`tools/dump-data.ps1`, rebuilt 2026-10-18), the Burner
drill's rates verified in [chapter 1](../chapters/01-landing-to-red-science.md), the crushed-coal
block measured in [chapter 10](../chapters/10-crushed-coal-power.md), the Oil burner measured in
[trains and robots](trains-and-robots.md) (section 5), and the Moondrop greenhouse's power and
seed loop in [techniques](techniques.md).

## Short answer

- **Raw coal: Burner drills.** A Burner drill burns 0.083 Raw coal for each Raw coal it mines; an
  Electric drill's power costs 0.147 Raw coal in the crushed-coal block, 1.8 times as much.
- **Fluid ores: MK 01, not MK 02.** An MK 01 burns 0.267 Raw coal an ore; an MK 02's power costs
  0.529, twice as much: it takes more energy per ore (0.9 MJ against 0.8) and that energy is
  electricity.
- **In Raw coal the difference is small.** The 13 MK 02 drills on tin would save 3.4 Raw coal a
  second as MK 01s, less than two Burner drills mine. What counts more: MK 01 needs twice the drills
  and a fuel belt and an Ash inserter at each; MK 02 takes power-station capacity, which the author
  is short of now.
- **After Intermetallics, Oil burners double the power from a fuel.** On Syngas made from Raw coal,
  an Electric drill costs what a Burner drill does and an MK 02 about 10 % more than an MK 01: then
  build them everywhere. **But Moondrop Methane does not make power**: a Methane greenhouse's
  3.2 MW is less than the 3.46 MW it, its Carbon dioxide and its seeds take (section 5).

## 1. The drills (data)

A drill mines (mining speed ÷ the ore's mining time) ores a second. Raw coal's mining time is 0.5,
so a Burner drill mines 2 Raw coal a second (verified, chapter 1); Iron, Copper, Aluminium, Lead,
Tin and Zinc ore take 1, Titanium, Chromium and Nickel ore 2.

| Drill | Size | Mines | Mining speed | Power | Energy | MJ per ore of mining time 1 |
|---|---|---|---|---|---|---|
| Burner mining drill | 2 × 2 | 4 × 4 | 1 | 500 kW | fuel | 0.5 |
| Electric mining drill | 3 × 3 | 5 × 5 | 2 | 1 MW | electric | 0.5 |
| Fluid mining drill MK 01 | 5 × 5 | 7 × 7 | 0.5 | 400 kW | fuel | 0.8 |
| Fluid mining drill MK 02 | 5 × 5 | 9 × 9 | 1 | 900 kW | electric | 0.9 |
| Fluid mining drill MK 03 | 5 × 5 | 11 × 11 | 2 | 1.2 MW | electric | 0.6 |

- The mining fluid is set on the ore, not on the drill, and is used per ore mined: the same for
  every Fluid drill. Aluminium ore takes Coal gas, Lead and Titanium ore Acetylene, Tin ore Steam,
  Zinc ore Aromatics, Chromium and Nickel ore Syngas.
- Burner drills burn at 100 %. Every coal fuel (Raw coal, Coal, Crushed coal, Coal dust, Coke)
  leaves one Ash; the burnt-result slot holds 1,000 and the drill stops when it is full: after
  100 minutes for a Burner drill on Raw coal, 125 for an MK 01. An inserter taking it out must be
  filtered to Ash, or it takes the fuel too ([techniques](techniques.md)).
- MK 02 is made from an MK 01, 2 Electric mining drills, 10 Simple circuit boards, 50 Small parts,
  10 Steel plates, 20 Aluminium plates and an Engine unit; MK 03 comes with Mining machines - Stage 3
  (900 units, Chemical science among them).

## 2. What a megajoule costs in Raw coal

| Energy | Raw coal per MJ | How |
|---|---|---|
| Raw coal burnt | 0.333 | 3 MJ a Raw coal |
| Crushed coal and Coal burnt | 0.273 | Crushed coal: 3 Raw coal → 1 Crushed coal (6 MJ) + 2 Coal (4 MJ) + 30 % Coal dust, so 4.67 MJ a Raw coal; the Secondary crusher MK 01 draws 465 kW (measured) for each Raw coal a second |
| Electricity, crushed-coal block | 0.588 | Boiler 100 %, Steam engine 50 %; measured: 30 Raw coal/s, 70 MW, minus crushers 14 MW and Ash separators 4.6 MW: 51 MW net, 1.70 MJ a Raw coal |
| Electricity, Raw coal station | 0.750 | Chapter 3's station: 44.4 MW from 30 Raw coal/s, about 40 MW net of its separators |

The drills feeding the blocks are not counted in their net power (they are what this note
compares).

## 3. Raw coal per ore

| Drill | MJ per ore | Cheapest energy | Raw coal per ore | Other energy |
|---|---|---|---|---|
| Burner mining drill, Raw coal | 0.25 | Crushed coal | 0.068 | Raw coal: 0.083 |
| Electric mining drill, Raw coal | 0.25 | crushed-coal block | 0.147 | Raw coal station: 0.188 |
| Fluid mining drill MK 01 | 0.8 | Crushed coal | 0.218 | Raw coal: 0.267 |
| Fluid mining drill MK 02 | 0.9 | crushed-coal block | 0.529 | Raw coal station: 0.675 |

On Iron or Copper ore (mining time 1) the first two rows double; on Titanium ore (2) the last two.
The ratios stay: Burner drills at least 1.8 times cheaper than Electric ones, MK 01 about half of
MK 02.

## 4. What the difference is worth

The tin field ([chapter 11](../chapters/11-lead-titanium-tin-smelting.md)): 13 MK 02 drills,
13.48 Tin ore a second, 11.7 MW, which the crushed-coal block makes from 6.9 Raw coal a second.
The same ore from 26 MK 01 drills burns 3.5 Raw coal a second: 3.4 a second less, under two Burner
drills' net on Raw coal (1.83 a second each).

- **MK 01 costs drills, room and logistics:** twice the drills on twice the patch area, a fuel belt
  along them and an Ash inserter at each.
- **MK 02 costs power-station capacity:** in the crushed-coal block those 11.7 MW net take 6.9
  Raw coal a second through 7 crushers and 16 MW from 4.3 Steam engines (the crushers and
  separators take the rest). At 25:47 the base used 99.6 MW, and a load test found the engines
  could give about 50 to 60 MW more, falling as their fuel ran short; the tin field came after
  that. While power is short, that is the reason to give new fluid ores MK 01 drills.
- Electric drills on Raw coal are the same trade: the base's 146 Burner drills as Electric drills
  would take 73 MW ([trains and robots](trains-and-robots.md)).

## 5. After Intermetallics: the Oil burner

An Oil burner (10 Intermetallics; Oil industry machinery - Stage 1 is researched) burns a fluid
fuel at 200 %, so with its four Steam engines a fuel's value comes out as power one to one:
measured, 14.8 MW of Syngas gave 14.805 MW. That is twice a Boiler's.

### Moondrop Methane does not pay for itself

With the author's T.U.R.D. pick, Carbon capture, a Moondrop greenhouse MK 01 with its 16 Moondrop
runs at speed 1.5 and draws 1.35 MW (450 kW × 3, measured). One greenhouse on Methane (100 Water +
100 Carbon dioxide + 1 Moondrop seed → 40 Methane, 15 s):

| Per Methane greenhouse | MW |
|---|---|
| 4 Methane a second (0.8 MJ each) in an Oil burner | **+3.20** |
| The greenhouse | −1.35 |
| 10 Carbon dioxide a second: 1/6 of a greenhouse on the Carbon dioxide recipe (200 in 5 s) | −0.23 |
| 0.1 seeds a second: 1.39 greenhouses growing Moondrop (4 seeds → 4 Moondrop, 140 s), whose Moondrop the Botanical nursery turns into seeds (2.8 Moondrop → 7.5 seeds, net 0.072 seeds a second a greenhouse) | −1.88 |
| The nursery (busy 11 % of the time) | −0.01 |
| **Net** | **−0.26** |

Even with free seeds it would be 1.6 MW a greenhouse. Methane becomes a power source only with
other recipes, both far off: Fertilizer (1 Fertilizer + 100 Water + 1 seed → 80 Methane in 5 s;
the Fertilizer technology needs Chemical science, and Moondrop - Stage 2) or the Lamp recipe of
the Moon light pick (60 Methane in 2 s, no seed), which needs a T.U.R.D. reselect
([T.U.R.D. choices](turd-choices.md)).

### Fuels that do give power

- **Syngas from Raw coal** (planned in [trains and robots](trains-and-robots.md), from the data and
  the measured Oil burner; not built yet): 30 Raw coal a second through Destructive distillation
  columns and Gasifiers, 100.8 MW, its machines 8.5 MW: 3.08 MJ of power a Raw coal (1.8 times the
  crushed-coal block), 0.325 Raw coal a megajoule, plus 198 Tar and 9 Coal a second.
- **Fluids left over today** (measured there): Gasoline 18 a second (21.6 MW in Oil burners) and
  Naphthalene oil 9.4 a second (2.8 MW).

### The drills on Syngas power

| Drill | Raw coal per ore | Against |
|---|---|---|
| Electric mining drill, Raw coal | 0.081 | Burner drill 0.083 (0.068 on Crushed coal) |
| Fluid mining drill MK 02 | 0.293 | MK 01 0.267 (0.218 on Crushed coal) |
| Fluid mining drill MK 03 | 0.195 | the cheapest |

So the author's plan holds with Syngas instead of Methane: once Oil burners burn Syngas, the
electric drills cost about what the burner ones do and save the fuel belts, the Ash and half the
drills; build them widely.
