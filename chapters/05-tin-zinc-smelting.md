# Chapter 5 — Tin and zinc smelting

[中文版](05-tin-zinc-smelting.zh-CN.md) · [Index](../README.md) · Previous:
[chapter 4](04-aluminium-glass-logs.md)

This chapter follows the same recorded run from 9:37 to 11:45. With red science running at 0.2 a
second, the author researched the prerequisites of Electronics - Stage 1 and Electronics itself,
and got the two metals of the Simple circuit board ready: Tin plates (for Solder, Ceramic
capacitors and High-power resistors) and Zinc plates (for the CuZn Battery). Both ores need a
mining fluid (from data): Tin ore takes Steam, Zinc ore takes Aromatics. So the author built a
steam block, a tin mine with its own smelting column 520 tiles south of the base, the first Tar
processing to make Aromatics, and a zinc mine 450 tiles east whose ore comes by belt to a smelting
column in the base. The Tar processing is not finished: its byproducts have nowhere to go yet. The
author's view: Zinc is only used in circuit boards, so the rest of the Tar products are dealt with
when the circuit boards are made and those products find uses. Alongside: a second crushed iron
block and more iron drills (Iron plates from 2 to 6 a second), a new mall that burns Wood, and the
coke columns of chapter 2 taken down. Times are game time. Numbers come from the game's data, from
the recorder's 10-minute production windows, from the save of 11:45 with one more minute measured
(`tools/inspect-save.ps1 -Ticks 3700`), and from a new probe for pipes, Pumps and Check valves
(`tools/valve-probe`, section 4).

The plan in one sentence: Tin from Steam, Zinc from Aromatics, and enough iron and parts for the
circuit stage.

## The run at a glance

| Game time | What happened |
|---|---|
| 9:36–10:33 | Research, one technology about every five minutes (what 0.2 red science a second pays for): Creosote, Acetylene, Solder - Stage 1, Seaweed - Stage 1, Petri dish, Moondrop - Stage 1, Moondrop upgrade, Ceramic, Fluid pressurization, Sap - Stage 1, and Electronics - Stage 1 at 10:33 |
| 9:40–9:50 | A steam block at y 98–120: the chapter 3 power station blueprint placed again and built without its twelve Steam engines, so 24 Boilers and 3 Solid separators. 18 more Burner mining drills on the northern coal field, filling two more belts south |
| 9:53–10:10 | A steam pipe of about 625 tiles to the tin field, 520 tiles south, with a Pump at (−103, 235); 16 Fluid mining drills on Tin ore and a smelting column of 12 Stone furnaces beside them. First Tin plates at 10:10 |
| 10:14 | Chat notes: "月落草升级选择碳捕集" — the Moondrop upgrade's choice is Carbon capture; "之前产二氧化碳的高压炉可原地替换为温室，但是要先产出月落草作为插件" — the High pressure furnace that makes Carbon dioxide can be replaced in place by a greenhouse, but Moondrop has to be grown first for its modules (section 7) |
| 10:15–10:20 | A second crushed iron block, the chapter 2 blueprint, beside the first |
| 10:20–10:35 | A new mall beside the red science line that burns Wood (blueprint 初期超市-2, section 7) |
| about 10:30 | The steel line stops with its outputs full; Coke, Coal gas and so Aluminium ore stop with it (chapter 4: the gas comes with the Coke) |
| 10:40–10:50 | More Burner mining drills on the iron field |
| 10:50–11:23 | Tar processing at the west edge (x −136, y −131 to −85): two Tar processing units MK 01 and two Destructive distillation columns MK 01, Tar from the Tailings pond, Steam from the steam block. At 11:03 the five coke columns of chapter 2 (y −88) come down |
| 11:14 | Fluid handling researched: the Check valve |
| 11:10–11:39 | An Aromatics pipe of about 930 tiles from the Tar processing to the zinc field, cut into three by two Check valves |
| 11:31 | The author takes out the two Pumps at (−103, 235) and (−101, 235), on the steam pipe to the tin field and the Tar pipe to the Glassworks: the steam pipe is to get a Check valve, the Tar pipe is to go (section 4) |
| 11:30–11:45 | 12 Fluid mining drills on Zinc ore at x 410–450, y 215–221, and about 520 tiles of belt to a smelting column of 12 Stone furnaces beside the Ash separation block |
| 11:45 | The save |

Production per second (10-minute windows from the recorder; the last row is the minute measured
after the save of 11:45):

| Window ending | Tin ore | Tin plate | Zinc ore | Zinc plate | Aromatics | Coke | Aluminium ore | Steel | Iron plate | Raw coal |
|---|---|---|---|---|---|---|---|---|---|---|
| 9:40 | 0 | 0 | 0 | 0 | 0 | 0.02 | 0.08 | 0 | 2.09 | 10.6 |
| 10:00 | 0 | 0 | 0.02 | 0 | 0 | 1.09 | 3.53 | 0.36 | 2.07 | 43.0 |
| 10:20 | 7.50 | 0.71 | 0.03 | 0 | 0 | 0.77 | 3.02 | 0.12 | 2.13 | 36.9 |
| 10:40 | 7.50 | 0.75 | 0.03 | 0.03 | 0 | 0.02 | 2.04 | 0 | 2.47 | 31.4 |
| 11:00 | 4.95 | 0.54 | 0.03 | 0 | 0 | 0.22 | 0.43 | 0 | 5.99 | 39.2 |
| 11:20 | 7.50 | 0.75 | 0.04 | 0.01 | 0.33 | 0 | 0.04 | 0 | 6.13 | 41.9 |
| 11:30 | 7.50 | 0.75 | 0.04 | 0 | 1.08 | 0.23 | 0.04 | 0 | 6.11 | 42.6 |
| 11:40 | 2.41 | 0.45 | 0.05 | 0.01 | 0 | 0 | 0.03 | 0 | 5.96 | 25.5 |
| 11:45 + 1 min | 0 | 0 | 0.03 | 0 | 0 | 0 | 0 | 0 | 3.30 | 23.3 |

Read with the timeline:

- **Tin ran at exactly 7.5 ore and 0.75 plates a second** from 10:20 to 11:30 (one window less):
  half a belt of ore (section 3). It stopped after 11:31, when the Pump on its steam pipe came out; 3,700 Tin plates
  were made in all.
- **Zinc has barely started.** The 0.03 Zinc ore a second before 11:30 is the Soot separation of
  chapter 3 (10 % Zinc ore per 2 Soot). The zinc drills ran a few minutes after 11:40 on the
  Aromatics standing in the pipe: 760 Aromatics used, about 190 ore at 4 a piece; 52 Zinc plates
  in all.
- **The Tar processing made 850 Aromatics** between about 11:15 and 11:35 and then stopped: two of
  its byproduct pipes are full (section 6).
- **Coke, Aluminium ore and Steel stop together around 10:30**, as chapter 4 found: the steel line
  is the Coke user, and the Coal gas for aluminium comes with the Coke.
- **Iron plates triple** from 2.1 to 6.1 a second when the second crushed iron block and the new
  drills come in (section 7). The base used about 3.4 a second meanwhile; the rest filled belts
  and chests, and at 11:45 14 of the 36 iron furnaces stand with full outputs, so the measured
  minute shows 3.3.

## 1. The technologies of this stage

| Technology | Cost | Researched | Unlocks what this chapter uses |
|---|---|---|---|
| Mining with fluid | 24 red | 3:58–4:06 (chapter 3) | Fluid mining drill MK 01, Tin plate (40 Tin ore → 4 plates) |
| Tar processing | 60 red | done 9:36 (chapter 4) | Tar processing unit MK 01; Tar refining bottoms and tops, Coke from Pitch, Aromatics from Light oil |
| Creosote | 60 red | 9:36–9:41 | Creosote from Anthracene, Carbolic and Naphthalene oil (not built yet) |
| Acetylene | 60 red | 9:41–9:46 | A prerequisite of Solder |
| Solder - Stage 1 | 60 red | 9:46–9:51 | Lead plate, Solder |
| Seaweed - Stage 1 | 60 red | 9:51–9:56 | Seaweed crop facility MK 01 (50 Tin plates each) |
| Petri dish | 60 red | 9:56–10:01 | A prerequisite of Moondrop |
| Moondrop - Stage 1 | 60 red | 10:01–10:06 | Moondrop greenhouse MK 01 |
| Moondrop upgrade | 65 red | 10:06–10:12 | A choice for the greenhouses (below) |
| Ceramic | 60 red | 10:12–10:17 | Ceramic, Clay pit, Electronics factory MK 01 |
| Fluid pressurization | 60 red | 10:17–10:22 | Vacuum |
| Sap - Stage 1 | 60 red | 10:22–10:27 | Sap extractor |
| Electronics - Stage 1 | 65 red | 10:27–10:33 | Zinc plate (40 Zinc ore → 4 plates), Ceramic capacitors, High-power resistors, CuZn Battery, Simple circuit board |
| Fluid handling | 65 red | 11:08–11:14 | Check valve |

Electronics - Stage 1 needs seven of these (data: Wood processing, Moondrop, Sap, Creosote,
Solder, Ceramic, Fluid pressurization); the author researched the missing ones and their own
prerequisites first, with the Moondrop upgrade in between. After
it came Repair pack, Gun turret, Stone wall, Gate, Landfill, Lamp, Automobilism, Fluid handling,
Hydrogenation and basic reforming, Radar - Stage 1, Evaporation processing 1, Military and Alloy
smelting - Stage 1 (Duralumin, Smelter MK 01), with Logistics at 78 % at 11:45. Every unit takes
30 s in a lab; at 0.2 red a second a 60-unit technology takes 300 s, which is the five-minute
rhythm of the timeline.

**The Moondrop upgrade choice.** Like the forestry upgrade of chapter 4 it offers three
sub-technologies (pyalienlife's `prototypes/upgrades/moondrop.lua`):

- *Copper*: the Moondrop recipes take 10 Copper ore, give twice the Moondrop in half the time, and
  drop their other ingredients.
- *Moon*: +35 % productivity, −50 % speed, and a Methane recipe that uses a Lamp.
- *Carbon capture* (the author's choice, 碳捕集): +50 % speed, twice the energy, and a new
  greenhouse recipe that makes 200 Carbon dioxide every 5 s from nothing.

The author chose it for the log block, whose High pressure furnace burns Coke for its Carbon
dioxide (section 7).

## 2. What Tin and Zinc are for

Recipes unlocked by the 44 technologies of the save that take the plates (data):

- **Tin plate:** Solder (2 Tin + 4 Lead), Ceramic capacitors (2 Tin + 1 Ceramic → 3), High-power
  resistors (1 Tin + 2 Coke + 1 Glass → 3), Tinned cable, and two buildings: Evaporator MK 01 (40)
  and Seaweed crop facility MK 01 (50).
- **Zinc plate:** only the CuZn Battery (10 Copper + 10 Zinc + 5 Cellulose + 250 Saline water →
  1). This is the author's point: Zinc goes into circuit boards and nothing else yet.

The Simple circuit board takes 1 Printed circuit board, 3 Vacuum tubes, 3 Air-core inductors, 5
Ceramic capacitors, 6 High-power resistors, 2 Solder and 1 CuZn Battery for 3 boards. Per board
that is **3.11 Tin plates and 3.33 Zinc plates**. The author's Factory Planner plan of 10:51 aims
at 6 boards a minute: 18.7 Tin and 20 Zinc plates a minute, 0.31 and 0.33 a second.

## 3. Tin: Steam as the mining fluid

Tin ore needs Steam to mine (data: `required_fluid`, 100 per 10 ore: **10 Steam per ore**, the
same rule as the 10 Coal gas per Aluminium ore measured in chapter 4). The nearest tin field lies
about 520 tiles south of the base, around (12, 556).

**The steam block.** The author placed the chapter 3 power station blueprint again, north of the
Ash separation block at y 98–120, and built it without its Steam engines: two rows of twelve
Boilers facing each other, the Raw coal belts outside, the Ash belts inside to three Solid
separators above, an Offshore pump at the east end. The steam that would have gone to the engines
is gathered between the rows and leaves west in one pipe. From data and chapter 3: a Boiler makes
7.5 Steam/s at 250 °C and burns 1.23 Raw coal/s doing it, so the block makes up to **180 Steam/s**.
At 11:45 all 24 Boilers stand full ("full output"): nothing draws steam.

**The pipe.** From the block it runs west to x −103, then north to the Tar processing (section 6)
and south along x −103 to the tin field: about 625 tiles of Pipe to ground to the drills, with a
Pump at (−103, 235) until 11:31 (section 4 says why the Pump, or a Check valve, has to be there).

**The mine.** 16 Fluid mining drills MK 01 in two rows of eight (y 523 and 529, x −13 to 22) drop
onto one belt between them. Each mines 0.5 ore/s, 8 for the sixteen. The drills burn fuel (400 kW):
Raw coal comes down a 587-tile belt along x 70 from the northern coal field, and their Ash goes
west, where six inserters lift it onto the Ash loop at x −93 (chapter 4, section 7). Two
inserters filtered to Raw coal take the furnaces' fuel off the drills' belt.

**The smelting column.** The ore belt joins the side of the column's belt, so all the ore lands on
the lane next to the furnaces: at most **7.5 ore/s**, half a belt, and exactly what the recorder
shows from 10:20 to 11:30. The column is the author's chapter 1 design with 12 Stone furnaces
instead of ten: ore lane and plate lane on one belt (output inserters "all but Ash"), Raw coal and
Ash on the other. From data: Tin plate is 40 ore → 4 plates in 60 s, so a furnace takes 0.667 ore/s,
less than the 0.833 its one inserter brings from a moving belt (chapter 4, section 9); 7.5 ore/s
need 11.25 furnaces, and twelve could smelt 0.8 plates/s. The lane gives **0.75 Tin plates/s**.
They go into two chests at (−71, 527): 3,700 by 11:45, enough Tin for about 1,190 Simple circuit
boards.

**What a Tin ore costs.** Its 10 Steam carry 4.94 MJ of Boiler heat (2.1 kJ per degree from 15 to
250 °C), which is 1.65 Raw coal; the drill burns another 0.27 (400 kW at 0.5 ore/s). So **one Tin
ore costs 1.9 Raw coal** and leaves as much Ash, and one Tin plate 19 Raw coal before its furnace
fuel. At 7.5 ore/s that is 14 Raw coal a second, nearly the whole output of a Raw coal module
(15/s), and 75 Steam/s, ten of the 24 Boilers.

![The tin mine: two rows of Fluid mining drills on the right, the ore belt running west between them to the twelve Stone furnaces, the two plate chests on the left; the drills' fuel belts above and below](../images/ch5-tin.jpg)

![The steam block: two rows of twelve Boilers with no Steam engines between them, the three Solid separators above](../images/ch5-steam.jpg)

## 4. A pipeline spans at most 320 tiles

Pipes that touch form one fluid segment, and a segment can only span so far: Py's Pipe and Pipe
to ground have a `max_pipeline_extent` of **320 tiles** (data; the engine's default for other
fluid boxes is 1280). A Pump or a Check valve ends a segment, so long lines need one every 320
tiles. Measured with a probe (`tools/valve-probe`): Steam lines of Pipes to ground at their full
reach (11 tiles a pair), kept full at the start, everything that arrives at the end counted:

| Line | Steam arriving per second |
|---|---|
| 55 tiles | 4,800 |
| 310 tiles | 4,800 |
| 330 tiles | **0** (the line fills and nothing comes out) |
| 625 tiles | **0** |
| 625 tiles, Pump at tile 310 | 3,880 |
| 625 tiles, Check valve at tile 310 | 4,781 |
| 625 tiles, Pump at tile 205 (420 tiles behind it) | **0** |
| An L: 200 tiles east, then 200 south | 4,800 |

The limit is the segment's extent on the map, not its length: the L of 400 tiles in a 202 × 202
box flows. Below the limit the flow is thousands a second, far above anything here (the tin drills
need 75).

**The author's pipes.** Every segment of the author's long lines stays inside 320 tiles (from the
save): the steam pipe 80 × 308 north of (−103, 235) and 125 × 293 south of it, the Tar pipe to the
Glassworks 128 × 319 and 317 × 102, the Aromatics pipe 20 × 309, 319 × 24 and 242 × 17 between its
two Check valves. So the two Pumps at y 235 were what kept the tin drills and the Glassworks
supplied. At 11:45 both places are empty: steam and Tar stand in the north halves, the south halves
are cut off (the tin drills "missing required fluid", the Glassworks' pipe still full from
before). One Check valve and one pipe in each gap would restore both lines.

**After the save** the author put a Check valve into the steam pipe (not where the Pump stood).
The Tar pipe stays cut on purpose: now that the Tar is refined, the Glassworks need not burn Tar,
and the author will take the pipe away once the Tar left in it is used up. Until then the Glass
chest is full and the Glassworks stand.

**Is a Check valve a Pump?** The author took the Pumps out because the valve seems to do the same
without power and in one tile instead of two (data: Pump 1 × 2, 29 kW, 200 per tick; Check valve 1
× 1, no energy, one-way, 200 per tick). For these lines it does: it ends a segment and passed 4,781
Steam/s in the probe. The difference shows when the far side is fuller. Two 100-tile segments
joined by the device, 40 s:

| Device | Start (near / far side) | After 40 s |
|---|---|---|
| Pump | 380 / 1,520 (20 % / 80 %) | 0 / 1,900 (far side full) |
| Check valve | 400 / 1,520 | 400 / 1,520 (nothing moves) |
| Check valve, near side fuller | 1,600 / 380 | 1,000 / 980 (levelled) |

A Pump pushes until the far side is full or the near side empty. A Check valve only lets fluid
run from the fuller side to the emptier one, never back, and stops when both are level. A supply
line whose far end is drained by drills or Glassworks always runs "downhill", so a valve serves;
a Pump is still needed to fill a tank higher than the line that feeds it, or to empty a store into
a fuller line. (A 100-tile segment of Pipes to ground holds only 1,900: a pipe holds 100 and an
underground pair counts as two pipes.)

## 5. Zinc: Aromatics as the mining fluid

Zinc ore needs Aromatics (data: 40 per 10 ore, **4 Aromatics per ore**). The nearest zinc field
lies about 450 tiles east of the base, around (432, 240).

- **The mine:** 12 Fluid mining drills MK 01 on both sides of one belt at y 218 (four north, eight
  south, x 413–448). At 0.5 ore/s each that is 6 ore/s and 24 Aromatics/s.
- **Three long belts** tie it to the base: Raw coal for the drills comes east along y 225 (379
  tiles, from the Raw coal belt on x 70), the drills' Ash goes back west along y 213 (415 tiles),
  and the Zinc ore goes west along y 218, north at x 3 and west again along y 200: about 520 tiles
  to the smelting column.
- **The Aromatics pipe**, about 930 tiles from the Tar processing at the west edge: south along x
  −114, a Check valve at (−114, 179), east along y 180–204, a Check valve at (205, 204), east to
  the drills.
- **The smelting column**, beside the Ash separation block (y 199, x −57 to −35): the same twelve
  furnaces as for tin, Zinc plate being 40 ore → 4 plates in 60 s like Tin. The ore joins from the
  side, so one lane, 7.5 ore/s at most; the drills give 6, so **0.6 Zinc plates/s** at full. At
  11:45 the plate end of the belt has no chest yet.

At 11:45 the drills stand, "missing required fluid": the pipe is empty, because the Tar processing
has stopped (next section).

![The zinc mine: Fluid mining drills on both sides of the ore belt; the Raw coal comes in on the bottom belt and round to the top one, which takes the Ash back west; the Aromatics pipe on the left](../images/ch5-zinc-field.jpg)

![The zinc smelting column (top) above the Ash separation block, with the ore, Raw coal and Ash belts coming in from the right](../images/ch5-zinc-smelting.jpg)

## 6. Aromatics from Tar

Aromatics come from Light oil, and Light oil from Tar, in three steps (data, all unlocked by Tar
processing):

| Recipe | Machine | In | Out |
|---|---|---|---|
| Tar refining bottoms, 5 s | Tar processing unit MK 01 | 100 Tar + 100 Steam | 30 Middle oil, 24 Creosote, 75 Anthracene oil, 140 Pitch |
| Tar refining tops, 4 s | Tar processing unit MK 01 | 100 Middle oil + 100 Steam | 50 Light oil, 50 Carbolic oil, 100 Naphthalene oil |
| Coke (from Pitch), 5 s | Destructive distillation column MK 01 | 100 Pitch + 100 Steam | 10 Hydrogen, 20 Light oil, 20 Naphthalene oil, 30 Anthracene oil, 10 Coke |
| Aromatics, 2 s | Destructive distillation column MK 01 | 50 Light oil | 50 Aromatics, 25 Gasoline |

**Per 100 Tar** through all four: 43 Light oil, so **43 Aromatics**, enough for 10.75 Zinc ore
(1.075 Zinc plates). Beside them come 117 Anthracene oil, 58 Naphthalene oil, 24 Creosote, 15
Carbolic oil, 14 Hydrogen, 21.5 Gasoline and 14 Coke, and 270 Steam go in.

**The author's line** has one machine for each step, at the west edge (x −136, y −131 to −85):
Tar comes from the Tailings pond, which still holds the Tar stored since chapter 2 (91,722 in the
pond and its pipe at 11:45); Steam comes from the steam block through a Check valve at (−104,
−75). One Tar refining unit could take 20 Tar/s and make 28 Pitch/s, but one column refines only
20 Pitch/s, so the column sets the pace: 14.3 Tar/s, **6.1 Aromatics/s** at most, 1.5 Zinc ore/s,
a quarter of what the twelve drills could mine.

**Why it stopped.** Each byproduct runs into a pipe that ends nowhere. In the save of 11:45 the
Anthracene oil pipe holds 3,200 of 3,200 and the Pitch pipe 2,900 of 2,900 (Naphthalene oil 1,456
of 2,800, Creosote 950 of 1,900, Carbolic oil 594 of 1,800, Gasoline 418 of 1,100, Hydrogen 136
of 1,700). Both refining machines stand "full output": the Anthracene oil, the largest byproduct,
which both of them make, has nowhere to go, and the Pitch backs up behind the stopped column. With
them stop the Light oil and the Aromatics. Made in all: 850 Aromatics, 5,600 Pitch, 3,400
Anthracene oil.

**How much is needed.** The author's plan of 6 boards a minute needs 0.33 Zinc plates/s: 3.33 ore,
13.3 Aromatics and 31 Tar a second through the whole chain, with 36 Anthracene oil a second to get
rid of. The twelve drills at full would need 24 Aromatics and 56 Tar a second. What can take the
byproducts is already researched (data): Creosote from the three oils (Creosote), Gasoline and
Coke from Anthracene oil (Tar processing), and most of them burn: Gasoline 1.2 MJ, Carbolic oil
0.35, Naphthalene oil 0.3, Anthracene oil 0.25, Hydrogen 0.1 MJ a unit, for example in Glassworks,
which burn fluid fuel (chapter 4; the author's circuit plan burns Gasoline there). The author
leaves this until the circuit boards are made and these products are needed.

![Tar processing at the west edge, from the top: the Pitch column, the Aromatics column, the tops unit and the bottoms unit; the byproduct pipes end to the right](../images/ch5-tar.jpg)

## 7. Iron, a mall that burns Wood, and the coke columns

**Iron times three.** At 10:15–10:20 robots built a second copy of the chapter 2 crushed iron block
([`crushed-iron.txt`](../blueprints/crushed-iron.txt), "3 [Iron plate]": 6 Jaw crushers, 18 iron
and 5 brick furnaces) just south of the first (crushers at y −15 and y 1), and at 10:40–10:50 the
author added Burner mining drills on the iron field: 53 of them stand in three rows at y −18 to −6
at 11:45. The windows ending 10:40 and 11:10: Iron ore 11.5 → 30.1 a second, Crushed iron ore 6.9
→ 18.0, **Iron plates 2.5 → 6.1**, what two blocks of 3 a second promise. The exported blueprint
gained one Small electric pole; nothing else changed.

**A mall that burns Wood** ([`wood-mall.txt`](../blueprints/wood-mall.txt), the author's
"初期超市-2", beside the red science line): ten Burner assembling machines make Transport belts,
Underground belts, Mechanical inserters, Pipes and Pipes to ground, with the Iron gears, Iron
sticks, Bolts, Copper cable and Small parts made on the spot. Logs, Iron plates and Copper plates
come in from the west; a Wood processing unit turns the Logs into Wood (4 Logs → 40 Wood in 1 s with
the Selective cutting heads of chapter 4), which rides on the Iron plate belt to every machine as
fuel. The products go into chests with limited slots. Why Wood (data):

- **No Ash.** Wood has no burnt result; Raw coal leaves one Ash each (3 MJ). The two earlier malls
  were fuelled by hand.
- **A Log made into Wood gives five times the heat.** A Log burns for 4 MJ; as 10 Wood it gives
  20 MJ.
- **It takes little.** A Burner assembling machine uses 75 kW: the ten at full work burn 0.375
  Wood/s, 0.04 Logs/s, out of the log block's 2.35.

The two older malls are in the author's book again under new names, 初期超市-0 (the chapter 1
mall) and 初期超市-1 (the chapter 3 belt mall), unchanged. Not measured on the bench: a mall makes
what is taken from it.

![The Wood-burning mall: the Wood processing unit at the top left, ten Burner assembling machines and their chests, the input belts from the left](../images/ch5-mall.jpg)

![The two crushed iron blocks, one above the other: Jaw crushers on the right, iron and brick furnaces on the left](../images/ch5-iron.jpg)

**The coke columns come down.** The steel line stopped at about 10:30 with its outputs full (its
eight foundries stand "full output" at 11:45). Without that Coke user the five coke columns of
chapter 2 stopped too, and with them the Coal gas: the aluminium drills stand "missing required
fluid", as chapter 4 predicted. At 11:03 the author took the columns away. Since then the only Coke
comes from the Pitch column of the Tar processing (10 per 100 Pitch; 0.23 a second in the window
ending 11:30), and there is no Coal gas in the base.

**The author's note on the log block.** The log block's High pressure furnace burns 0.31 Coke/s
into the forestries' Carbon dioxide. The Carbon capture greenhouse recipe makes 200 Carbon dioxide
every 5 s from nothing; with 16 Moondrop as modules a Moondrop greenhouse MK 01 runs at speed 1
(data: speed 0.0625, base effect −100 %, +100 % a Moondrop), so one greenhouse gives about 40 a
second against the 12.5 the block needs, and the Coke and the furnace's 2 MW are freed. The author
noted it in the blueprint: "高压炉可原地替换为月落草温室" (the furnace can be replaced in place by a
Moondrop greenhouse). One check from the blueprint: the greenhouse is 9 × 9, the furnace 7 × 7;
centred on the furnace it would overlap the Moss farm east of it, one inserter and two pipes, so
the swap needs a little rebuilding.

## 8. Checklist

- Tin plates and Zinc plates are for circuit boards: 3.11 Tin and 3.33 Zinc per Simple circuit
  board. Zinc has no other use yet.
- Tin ore is mined with Steam, 10 per ore; Zinc ore with Aromatics, 4 per ore. Both smelt 40 ore →
  4 plates in 60 s in a Stone furnace (0.667 ore/s each): twelve furnaces take half a belt.
- Steam-mined Tin costs about 1.9 Raw coal per ore (Boiler and drill): half a belt of Tin ore burns
  nearly a whole Raw coal module.
- A fluid segment spans at most 320 tiles (its box on the map, not its length). Put a Pump or a
  Check valve at least every 320 tiles, and never leave the gap empty.
- A Check valve ends a segment like a Pump, without power and in one tile, but it only lets fluid
  run from the fuller side to the emptier one. Supply lines to consumers are fine; filling a store
  above the line's level needs a Pump.
- 100 Tar make 43 Aromatics through four recipes, with 117 Anthracene oil and more byproducts. Each
  byproduct needs somewhere to go, or the line stops when its pipe fills.
- Wood is the fuel for burner buildings that should not make Ash: one Log as Wood gives 20 MJ.

## 9. How these facts were checked

- The run: the companion mod's recorder (run `2652821414-0`), read with
  `tools/recorder-phases.js` (timeline in 5-minute slices, chat notes), `tools/recorder-log.js`
  (production per 10-minute window) and its minute records (what was built and removed where, the
  Pumps' removal at 11:31, the coke columns at 11:03).
- The save of 11:45 (`Py-Exploration`, consistency check passed): `tools/inspect-save.ps1 -Ticks
  3700`, then `tools/summarize-save.js` (research, machine states, the measured minute, the drills'
  status), `tools/trace-layout.js` (belt lines, fluid segments with their contents and extent),
  `tools/render-area.js` and `tools/render-save-map.js`.
- Data: the current dump of the author's mods (`C:\tmp\cf-save\data\script-output\data-raw-dump.json`):
  mining fluids, recipes, machine speeds and energy, fuel values, `max_pipeline_extent`, the Pump
  and the Check valve; pyalienlife's `prototypes/upgrades/moondrop.lua` for the upgrade's choices.
- **Pipes and valves:** `tools/run-probe.ps1 -Probe valve-probe -Ticks 2500 -Work C:\tmp\cf-save`
  (new): steam lines of 55 to 625 tiles of Pipe to ground, an L, a Pump or a Check valve part way,
  an infinity pipe at the start and a counted sink at the end; and two 100-tile segments at 20 % and
  80 % joined by a Pump, a Check valve or a plain pipe.
- The blueprints: exported by the author with the companion mod (2026-10-11, 19:06) and pulled into
  `blueprints/`: the new Wood mall, the two older malls under their new names, one more pole in the
  crushed iron block, the author's note in the log block's description.

Next: chapter 6 (to come).

