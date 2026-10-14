# Chapter 6 — Simple circuit boards

[中文版](06-simple-circuit-boards.zh-CN.md) · [Index](../README.md) · Previous:
[chapter 5](05-tin-zinc-smelting.md)

This chapter follows the same recorded run from 13:28 to 16:40. The plan was the Printed circuit
substrate (tier 1); the author went on and built the whole Simple circuit board: one block north of
the base (blueprint `simple-circuit-board`, labelled 0.1 boards a second) that makes the substrate,
Vacuum tubes, the three small parts (Ceramic capacitors, High-power resistors, Air-core inductors),
Solder and the CuZn Battery. Before it could run, Moondrop had to be started: the substrate's
Formica needs Formaldehyde, the Formaldehyde Methane, and the Methane comes from a Moondrop
greenhouse. Around the block the author laid a bus of seven belts from the smelting columns, about
630 tiles long, moved the quartz field's Glassworks next to the bus and piped its Molten glass about
690 tiles north, and turned the Tar line's Naphthalene and Carbolic oil into Creosote for the Treated
wood. The first boards came a few minutes before the save of 16:08. The author expected the line
not to hold its output for long, without knowing what would give out first; measured, it held 40
minutes. The author then tidied the Tar line in half an hour, and from the save of 16:40 the whole
chain runs on, with only Naphthalene oil and Gasoline gathering in their ponds, kept for later
technologies. Times are game time. Numbers come from the game's data, from the recorder's 10-minute
production windows, from the save of 16:08 (`tools/inspect-save.ps1`, which now also records each
machine's modules, speed and electric network) and the save of 16:40, from an hour after the first
save in 5-minute steps (`tools/rate-probe`, which can now print such a timeline), the same hour
with the coke block's pole put back, two hours after the second save, and from the blueprint bench
for the author's corrected acetylene block.

The result: the block is held at 0.1 boards a second by one greenhouse's Methane. At 16:08 the
base kept it there for about 40 minutes; then the Zinc plates on the bus were used up, and once the
boards stopped, the Tar line stopped too, because its Creosote had no other user. After the
author's tidy-up every byproduct of the Tar line has a way out and nothing stops in three hours
measured; the boards run at 0.1 a second while the aluminium drills still take Coal gas, and at
0.07 once their ore is gone, about two and a half hours after the save (section 8).

## The run at a glance

| Game time | What happened |
|---|---|
| 13:25–13:36 | Research: Cellulose - Stage 1 (13:25), Kerogen processing (13:30), Shale oil development (13:36). The last research of the chapter: from 13:36 every open technology needs pY science pack 1 too, and the labs stand |
| 13:30–13:55 | A new site north of the base (x −65 to −30, y −230 to −195): 14 Sap extractors, three Wood processing units, a Botanical nursery, a Tar processing unit for Treated wood; 28 Planter boxes handcrafted |
| 13:40–13:55 | Seaweed crop facilities placed and taken away again, and four Moondrop greenhouses handcrafted. Chat note at 13:45: "月落草需要一点海藻启动，后续py1再做海藻完整产线" — Moondrop needs a little Seaweed to start; the full seaweed line comes later, with pY science pack 1 (section 2) |
| about 13:50 | The lead furnaces are full: the lead drills, the acetylene block and the Tar line stop (Aromatics 4.5/s in the window ending 13:50, 0 from 14:10), as chapter 5 measured for about 20 minutes after its save |
| 14:00–14:10 | 200 Air-core inductors and 80 Tinned cables handcrafted for four Moondrop codexes, and eight Petri dishes; the greenhouses and nurseries moved into their places (y −212 to −203); a High pressure furnace for Formaldehyde |
| 14:10–14:20 | A Pulp mill MK 01 (Formica), a PCB factory MK 01 (the substrate) and a Pressure pump MK 01 (Vacuum) at x −24 to −13, y −228 to −219. The first Moondrop from 14:20 |
| 14:20–14:45 | About 630 tiles of belt by hand; the quartz field's Glassworks moved to (−57, 348), its Quartz ore brought 356 tiles by belt, and a Molten glass pipeline laid north beside the steam pipe (about 210 Pipes to ground, 14:30–14:40). Molten glass from 14:40 |
| 14:45–15:00 | At the Tar line's north end (x −137): a Tar processing unit for Creosote from Carbolic oil (two others placed and taken away), a Gasifier for Syngas from Coal gas; a Tailings pond taken away. The Tar line's Coke now also runs on a belt of about 300 tiles to the new block (section 4), and the Tar line runs again while that belt fills (Aromatics 4.7 and 6.2/s in the windows ending 14:50 and 15:00) |
| 15:00–15:05 | A Moondrop greenhouse on Carbon dioxide at (−47, −116), in the log block, where its High pressure furnace made Carbon dioxide (the author's note of 10:14, section 2) |
| 15:00–15:40 | The electronics part of the block: four Electronics factories MK 01 (Vacuum tubes, High-power resistors, Air-core inductors, Ceramic capacitors); Burner assembling machines for Copper cable, Solder and the CuZn Battery; a Clay pit and High pressure furnaces for Ceramic, Graphite and Cellulose, with two Soil extractors for Limestone; two Jaw crushers and four Washers for Saline water; a Glassworks for Glass |
| 15:45–16:05 | The bus finished: about 1,700 more tiles of belt; the second Tailings pond taken away; more pipe; the Chipshooter machine MK 01 at (−15, −232) (15:50–15:55) |
| 16:05 | A Tar processing unit for Creosote from Naphthalene oil at (−136, −198) |
| 16:08 | The save: 30 Simple circuit boards in the block's chest. The screenshots of this chapter are taken (`/pt-shots`) |
| 16:10–16:35 | More Tar refining: a second Tar refining unit (16:10–16:15), a second Pitch column (16:15–16:20), a third Anthracene oil column (16:30–16:35) |
| 16:10–16:30 | Ten Boilers burning the Tar line's surplus Coke for its Steam, placed at y −75, then at y −253, then at y −257; 107 Basic splitters and three valves handcrafted from the first boards |
| 16:20–16:40 | An Underflow valve on the steam block's pipe (16:20–16:25); an Overflow valve and a Sinkhole for Creosote (16:25–16:30); an Overflow valve for Coal gas and an Exhaust pipe for the Syngas (16:35–16:40) |
| 16:35–16:40 | The coke block's pole put back; the Tar pond and the Naphthalene oil unit taken away |
| 16:40 | The second save (section 7) |

Production per second (10-minute windows from the recorder):

| Window ending | Methane | Formaldehyde | Molten glass | Zinc plate | Lead plate | Tin plate | Aromatics | Acetylene | Coke | Creosote |
|---|---|---|---|---|---|---|---|---|---|---|
| 13:30 | 0 | 0 | 0.52 | 0.13 | 0.49 | 0 | 4.83 | 30.2 | 3.46 | 2.64 |
| 13:50 | 0 | 0 | 0 | 0.12 | 0.31 | 0 | 4.50 | 28.8 | 2.69 | 2.52 |
| 14:00 | 0 | 0 | 0 | 0.07 | 0.09 | 0 | 0.92 | 5.50 | 0.55 | 0.52 |
| 14:10 to 14:40 | 0 | 0 | 0 to 0.63 | 0 to 0.01 | 0.01 | 0 | 0 | 0 | 0 | 0 |
| 14:50 | 2.33 | 1.92 | 2.00 | 0.03 | 0 | 0.35 | 4.67 | 0 | 2.81 | 2.64 |
| 15:00 | 2.60 | 1.58 | 2.00 | 0.15 | 0.01 | 0.71 | 6.17 | 0 | 3.67 | 15.3 |
| 15:10 | 0 | 0 | 2.00 | 0.11 | 0 | 0.73 | 0.42 | 0 | 0.27 | 3.66 |
| 15:20 to 15:50 | 0 | 0 to 0.58 | 2.00 | 0 to 0.01 | 0 | 0.73 | 0 to 1.25 | 0 | 0 to 0.76 | 0 to 1.14 |
| 16:00 | 1.07 | 0.83 | 2.00 | 0.09 | 0.68 | 0.67 | 5.33 | 27.3 | 3.16 | 4.79 |
| 16:10 | 4.00 | 3.33 | 2.00 | 0.15 | 0.51 | 0.34 | 6.17 | 29.8 | 3.68 | 10.3 |
| 16:20 | 4.00 | 3.33 | 2.00 | 0.15 | 0.51 | 0.37 | 7.25 | 30.0 | 4.33 | 22.2 |
| 16:30 | 4.00 | 3.33 | 2.00 | 0.19 | 0.51 | 0.40 | 7.25 | 30.5 | 4.23 | 12.3 |
| 16:40 | 4.00 | 3.33 | 2.00 | 0.23 | 0.50 | 0.38 | 10.5 | 29.5 | 7.06 | 10.4 |

Read with the timeline:

- **The Tar line stopped at about 13:50 and stood for an hour.** The lead furnaces filled, as
  chapter 5 had measured in a copy of its save; while nothing used Lead plates that was expected
  (techniques, principle 23). It ran again from 14:45 to 15:05 while the new Coke belt to the block
  filled (2,700 Coke lie on it at the save), and from 16:00, when the Solder began to take Lead.
- **Methane in two bursts:** the methane greenhouse filled the new Formaldehyde furnace and pipe
  (14:50, 15:00), then waited for the Pulp mill to take Formaldehyde (from 15:50).
- **Molten glass at 2.00 a second from 14:40 to the save:** one Glassworks melting Quartz all the
  time, filling about 690 tiles of pipe north (7,452 Molten glass in it at the save).
- **Tin plates at 0.73 a second from 14:50:** the tin column's chests were full (chapter 5); with
  the bus, its plates go north, and 3,061 Tin plates lie on the bus at the save.
- The recorder lists no Simple circuit board in the window ending 16:00: the boards came in the
  last eight minutes before the save (30 in the chest). From 16:20 the windows show 0.12 boards a
  second, the Methane greenhouse at its full 4 a second.
- **The tidy-up shows from 16:30:** Aromatics 7.25 → 10.5 and Coke 4.2 → 7.1 a second in the window
  ending 16:40, with the second refining unit and the coke block's Tar (23.6 Tar a second made in
  that window).

## 1. The technologies of this stage

Every recipe of the board was researched in chapter 5; this chapter needed no new technology.

| Technology | Cost | Researched | Unlocks what this chapter uses |
|---|---|---|---|
| Electronics - Stage 1 | 65 red | 10:27–10:33 | Simple circuit board, Printed circuit substrate (tier 1), Formica, Formaldehyde, Vacuum tube, Graphite, Ceramic capacitors, High-power resistors, CuZn Battery, Cellulose, Saline water, Zinc plate; Chipshooter machine, PCB factory and Pulp mill MK 01 |
| Ceramic | 60 red | 10:12–10:17 | Clay, Ceramic, Air-core inductors; Clay pit and Electronics factory MK 01 |
| Fluid pressurization | 60 red | 10:17–10:22 | Vacuum; Pressure pump MK 01 |
| Sap - Stage 1 | 60 red | 10:22–10:27 | Sap extractor MK 01, Sap, Sap seeds, Sap tree |
| Petri dish | 60 red | 9:56–10:01 | Agar (from Seaweed), Petri dish, Empty petri dish |
| Moondrop - Stage 1 | 60 red | 10:01–10:06 | Moondrop greenhouse MK 01, Methane, Moondrop (from a codex), Moondrop codex, Moondrop seeds, Moondrop |
| Moondrop upgrade | 65 red | 10:06–10:12 | The author's choice, Carbon capture: greenhouses +50 % speed, twice the energy, and Carbon dioxide from nothing |
| Creosote | 60 red | 9:36–9:41 | Treated wood; Creosote from Carbolic oil and from Naphthalene oil |
| Solder - Stage 1 | 60 red | 9:46–9:51 | Lead plate, Solder |
| Hydrogenation and basic reforming | 65 red | 11:14–11:19 | Syngas from Coal gas |

The three researched at the start of the chapter are not used yet: Cellulose - Stage 1 (Cellulose
from Wood and Sodium hydroxide), Kerogen processing (the Retorter; its Kerogen is mined with a
technology not researched) and Shale oil development (Condensates from Shale oil, the Olefin plant,
the Reformer). After 13:36 the six labs stand: every technology still open needs pY science pack 1
as well as red (18 of them, data), and the author makes no pY science pack 1 yet.

## 2. Moondrop, for the substrate's Methane

The substrate is where Moondrop comes in (data):

- Printed circuit substrate (tier 1), PCB factory: 2 Formica + 5 Copper plates + 50 Vacuum → 1, 5 s.
- Formica, Pulp mill: 2 Treated wood + 5 Raw fiber + 10 Sap + 50 Formaldehyde → 1, 10 s.
- Formaldehyde, High pressure furnace: 60 Methane + 5 Copper plates → 50, 4 s.
- Methane, Moondrop greenhouse: 100 Water + 100 Carbon dioxide + 1 Moondrop seeds → 40, 15 s.
  With the author's technologies it is the only Methane recipe: the others need technologies not
  researched yet, or the upgrade's other choice, Moon.

**Getting the first Moondrop.** A greenhouse (speed 0.0625) has a base effect of −100 % speed and
takes only Moondrop as modules, +100 % each: without the upgrade it does nothing empty and runs at
speed 1 with all 16 (data). The author's Carbon capture puts a hidden beacon with a +800 % speed
module (and +200 % energy) on every greenhouse (pyalienlife's T.U.R.D. script and data), so an
empty greenhouse already runs at speed 0.5 and a full one at 1.5, which the inspector reads in the
save. The
first Moondrop come from a Botanical nursery, by the recipe that makes Moondrop from a codex:
1 Moondrop codex + 2 Petri dishes + 1 Planter box + 1,000 Water → 4 Moondrop, 200 s. A codex is
handcrafted from 2 Glass, 50 Air-core inductors and 20 Tinned cables; a Petri dish is an Empty petri dish (the Glassworks at the quartz
field made them in chapter 5) and one Agar, and Agar is 5 Seaweed + 100 Steam in a High pressure
furnace. This is the author's note of 13:45: "月落草需要一点海藻启动，后续py1再做海藻完整产线"
(Moondrop needs a little Seaweed to start; the full seaweed line comes later, with pY science pack
1). The Seaweed crop facilities stood from 13:40 to 13:55; at 14:00–14:10 the author handcrafted
200 Air-core inductors and 80 Tinned cables, four codexes and eight Petri dishes: enough for four
crafts, 16 Moondrop.

**Moondrop multiplies itself.** Moondrop seeds, nursery, 5 s: 5 Moondrop → 2 Moondrop back (and
with 10 % chance 1 to 3 more) + 7 seeds (and with 25 % chance 1 to 3 more); on average 2.8 Moondrop
become 7.5 seeds. Moondrop, greenhouse, 140 s: 4 seeds + 100 Water → 4 Moondrop. The first Moondrop
were made at about 14:20 (recorder); by the save the author's five greenhouses hold 80 as modules.
In the block two greenhouses grow Moondrop and one nursery makes seeds; at speed 1.5 the two give
0.086 Moondrop a second, which the nursery turns into 0.23 seeds, 0.14 more than the two
greenhouses take back. The Methane greenhouse uses 0.1 seeds a second. Measured over the hour after
the save: 0.165 seeds made and 0.164 used, the two Moondrop greenhouses working 75 % of the time:
the loop holds itself.

**The fourth greenhouse makes Carbon dioxide** (Carbon capture: 200 every 5 s from nothing, 60 a
second at speed 1.5) for the Methane greenhouse, which takes 10. A fifth stands in the log block at
(−47, −116) on the same recipe, where the High pressure furnace burned Coke for the forestries'
Carbon dioxide: the swap the author noted at 10:14, "之前产二氧化碳的高压炉可原地替换为温室，但是要先产出月落草作为插件"
(the furnace that made Carbon dioxide can be replaced in place by a greenhouse, once Moondrop is
grown for its modules). Chapter 5 put one greenhouse at 40 Carbon dioxide a second; with the
upgrade it is 60.

![The log block's west end at 16:08: the Moondrop greenhouse on Carbon dioxide where the High pressure furnace stood, beside the Moss farms](../images/ch6-co2.jpg)

## 3. The block

![The board block at 16:08, north up: Clay pit, furnaces, Electronics factories and Washers along the top, the 14 Sap extractors in two rows, the Chipshooter machine and the PCB factory on the right, the greenhouses and the nursery at the bottom](../images/ch6-boards.jpg)

Blueprint `simple-circuit-board` ("0.1[item=electronic-circuit]", 578 entities, x −60 to −2,
y −264 to −202 in the save). The Simple circuit board (Chipshooter machine): 1 substrate + 3 Vacuum
tubes + 3 Air-core inductors + 5 Ceramic capacitors + 6 High-power resistors + 2 Solder + 1 CuZn
Battery → 3, 4 s. Every machine of the block, with what 0.1 boards a second asks of it (data; each
machine's speed read in the save: 1, the greenhouses 1.5, the Sap extractors 1 with two Sap trees
each):

| Part | Recipe | Machines | Needed for 0.1 boards/s | Busy |
|---|---|---|---|---|
| Simple circuit board | as above | 1 Chipshooter | 0.1/s | 13 % |
| Printed circuit substrate (tier 1) | 2 Formica + 5 Copper plates + 50 Vacuum → 1, 5 s | 1 PCB factory | 0.033/s | 17 % |
| Formica | 2 Treated wood + 5 Raw fiber + 10 Sap + 50 Formaldehyde → 1, 10 s | 1 Pulp mill | 0.067/s | 67 % |
| Formaldehyde | 60 Methane + 5 Copper plates → 50, 4 s | 1 High pressure furnace | 3.33/s | 27 % |
| Methane | 100 Water + 100 Carbon dioxide + 1 seed → 40, 15 s | 1 greenhouse | 4.0/s | **100 %** |
| Carbon dioxide | → 200, 5 s | 1 greenhouse | 10/s | 17 % |
| Sap | → 4, 80 s | 14 Sap extractors | 0.67/s | 95 % |
| Raw fiber | 10 Wood → 2, 10 s | 2 Wood processing units | 0.33/s | 83 % |
| Treated wood | 100 Creosote + 1 Wood → 2, 2 s | 1 Tar processing unit | 0.13/s | 13 % |
| Vacuum | → 200, 2 s | 2 Pressure pumps | 4.2/s | 2 % |
| Vacuum tube | 5 Iron + 2 Copper plates + 2 Graphite + 50 Vacuum + 2 Glass → 2, 7 s | 1 Electronics factory | 0.1/s | 35 % |
| Graphite | 5 Coke → 2, 3 s | 1 High pressure furnace | 0.1/s | 15 % |
| Glass | 50 Molten glass → 5, 3 s | 1 Glassworks | 0.17/s | 10 % |
| High-power resistors | 1 Tin plate + 2 Coke + 1 Glass → 3, 5 s | 1 Electronics factory | 0.2/s | 33 % |
| Ceramic capacitors | 1 Ceramic + 2 Tin plates → 3, 5 s | 1 Electronics factory | 0.17/s | 28 % |
| Air-core inductors | 2 Ceramic + 20 Copper cable → 5, 5 s | 1 Electronics factory | 0.1/s | 10 % |
| Copper cable | 1 Copper plate → 2, 0.5 s | 1 Burner assembling machine | 0.4/s | 10 % |
| Ceramic | 10 Clay + 1 Coke → 5, 5 s | 1 High pressure furnace | 0.096/s | 10 % |
| Clay | 100 Steam → 3, 4 s | 1 Clay pit | 0.19/s | 25 % |
| Solder | 2 Tin + 4 Lead plates → 1, 6 s | 1 Burner assembling machine | 0.067/s | 40 % |
| CuZn Battery | 10 Copper + 10 Zinc plates + 5 Cellulose + 250 Saline water → 1, 10 s | 1 Burner assembling machine | 0.033/s | 33 % |
| Cellulose | 7 Wood + 4 Limestone → 1, 10 s | 2 High pressure furnaces | 0.17/s | 83 % |
| Limestone | 400 Water → 8, 20 s | 2 Soil extractors | 0.67/s | 83 % |
| Saline water | 10 Stone + 100 Water → 50, 20 s | 4 Washers | 8.3/s | 83 % |
| Stone | 4 Stone bricks → 8, 5 s | 2 Jaw crushers | 1.67/s | 52 % |
| Wood | 4 Logs → 40, 1 s | 2 Wood processing units | 2.9/s | 4 % |
| Moondrop, seeds | above | 2 greenhouses, 1 nursery | 0.1 seeds/s | 70 % |

**The label is the Methane greenhouse.** One greenhouse at speed 1.5 makes 40 Methane every 10 s,
4 a second: 3.33 Formaldehyde, 0.067 Formica, 0.033 substrates, 0.1 boards. Every other machine has
room to spare; the Sap extractors come next at 95 %. Measured in the save: the greenhouse worked
100 % of the hour, Methane 4.000 a second.

**What the block takes from outside, per second at 0.1 boards** (data, from the table): Copper
plates 1.13 (Formaldehyde 0.33, the Battery 0.33, Copper cable 0.2, substrate 0.17, Vacuum tubes
0.1), Iron plates 0.25, Tin plates 0.31, Lead plates 0.27, Zinc plates 0.33, Coke 0.40, Stone bricks
0.83, Logs 0.29, Molten glass 1.67, Creosote 6.7, Steam 6.4 (the Clay pit), and Gasoline 0.8 for
its own Glassworks (10 MW at 10 %; Gasoline 1.2 MJ). Water comes from its three Offshore pumps.

**The boards go into a chest** (30 at the save): nothing uses them yet.

## 4. The bus and the pipes

![Where the bus turns east into the block (16:08)](../images/ch6-bus.jpg)

The block's inputs arrive from the west (from the save):

- **The bus**: seven belts side by side at x −82 to −73, running north to the block. Lead (x −82)
  joins at y −69 from the lead column; Zinc (x −79) at y 199 from the zinc column (12 Stone
  furnaces, chapter 5); Tin (x −78) from the tin column at y 528; Copper (x −74) at y 17; Iron
  (x −73) at y −18 and −3 from the crushed iron blocks; Stone bricks (x −75) at y −23 and −8; Logs
  (x −76) at y −148 from the log block. The four plate belts start at about y 365, beside the Soot
  separation of chapter 3, where short empty belts already join them; from there to the block they are
  about 630 tiles long, the tin belt 790.
- **Coke**: a belt of about 300 tiles from the Tar line's distillation columns (x −179) south to
  y −78, east to x −72 and north to the block. 2,700 Coke lie on it at the save.
- **Molten glass**: from the Glassworks at (−57, 348), which melts Quartz ore brought 356 tiles by
  belt from the two Crystal mines at x 292–301; about 690 tiles of pipe north beside the steam pipe,
  in three segments split by Check valves at y 179.5 and −74.5 (7,452 Molten glass in them at the
  save).
- **Gasoline** for both Glassworks: from the Tar line and its Gasoline pond (x −139, y 3), through
  Check valves at (−111.5, −135.5) north to the block and at (−111.5, 179.5) south to the melting
  Glassworks.
- **Steam** for the Clay pit, from the steam pipe of chapter 5, with a new Check valve at
  (−103.5, −74.5).
- **Creosote**: one pipe segment (57 pipes, x −136 to −58) joins the Tar refining unit's Creosote
  output, the two new Creosote units at (−137, −187) (Carbolic oil) and (−137, −199) (Naphthalene
  oil, from its Tailings pond, 41,499 at the save) and the block's Treated wood unit, the only user
  (at 16:08; section 7 for the change).

![The zinc column at y 199 at 16:08: Zinc ore from the east, plates west onto the bus](../images/ch6-zinc.jpg)

![The melting Glassworks at (−57, 348) at 16:08, the Quartz belt from the east, the bus belts to the west](../images/ch6-glass.jpg)

![The Tar line's north end at 16:08: the Creosote units for Naphthalene oil (top) and Carbolic oil, and the Gasifier for Syngas below them; the Naphthalene unit came out again at 16:35–16:40](../images/ch6-creosote.jpg)

## 5. An hour after the save of 16:08

The author expected the line not to hold 0.1 boards a second for long. Measured in a copy of the
save of 16:08 (`tools/rate-probe`, one minute of warm-up, then an hour in 5-minute steps; per
second, each step's average):

| Minutes after the save | Boards | Zinc plates made / used | Lead plates | Tar used | Coke | Creosote made / used | Aromatics | Gasoline used | Molten glass | What changes in that step |
|---|---|---|---|---|---|---|---|---|---|---|
| 0–5 | 0.120 | 0.15 / 0.40 | 0.51 | 14.3 | 3.70 | 20.6 / 20.7 | 6.17 | 10.2 | 2.00 | The Creosote pipe fills |
| 5–10 | 0.120 | 0.15 / 0.40 | 0.51 | 14.3 | 3.67 | 20.6 / 8.7 | 6.17 | 10.1 | 2.00 | The Treated wood unit's Creosote box full (400) |
| 10–15 | 0.120 | 0.17 / 0.40 | 0.51 | 11.7 | 3.50 | 16.8 / 7.0 | 5.83 | 9.3 | 2.00 | The Tar refining unit stops "full output", Creosote in its output box |
| 15–20 | 0.120 | 0.15 / 0.40 | 0.51 | 4.3 | 2.28 | 5.9 / 6.0 | 3.67 | 9.3 | 2.00 | The Naphthalene oil unit stops "full output" too |
| 20–25 | 0.120 | 0.11 / 0.40 | 0.51 | 5.3 | 1.35 | 7.1 / 7.0 | 2.33 | 9.3 | 2.00 | The carbide furnaces wait for Coke |
| 25–30 | 0.120 | 0.05 / 0.40 | 0.51 | 5.0 | 1.30 | 6.8 / 7.0 | 2.00 | 7.5 | 1.53 | The Gasifiers wait for carbide: Acetylene 30 → 15 |
| 30–35 | 0.120 | 0.07 / 0.40 | 0.50 | 4.7 | 1.20 | 6.2 / 6.0 | 2.00 | 3.1 | 0.53 | The melting Glassworks runs out of Gasoline |
| 35–40 | 0.110 | 0.04 / 0.40 | 0.23 | 5.0 | 1.28 | 6.9 / 7.0 | 2.33 | 3.5 | 0.63 | The lead drills wait for Acetylene |
| 40–45 | 0.040 | 0.07 / 0.07 | 0.24 | 5.3 | 1.35 | 7.1 / 7.0 | 2.33 | 3.6 | 0.77 | **The Battery machine waits for Zinc plates** |
| 45–50 | 0.010 | 0.05 / 0.07 | 0.23 | 3.7 | 0.97 | 4.9 / 5.0 | 1.50 | 2.5 | 0.57 | |
| 50–55 | 0.020 | 0.04 / 0.03 | 0.15 | 1.3 | 0.33 | 1.9 / 2.0 | 0.50 | 0.9 | 0.20 | PCB factory and Pulp mill stand full |
| 55–60 | 0.010 | 0.03 / 0.03 | 0.03 | 0 | 0 | 0 / 0 | 0 | 0 | 0 | The Tar line stands, with Tar in its boxes |

Over the hour, 0.086 boards a second. Read it from the bottom of the chain up:

- **The block holds 0.1 boards a second, and a little more while it lasts.** For 35 minutes it made
  0.120 a second: the greenhouse's 0.033 substrates a second are 0.1 boards, the rest came from
  the substrates and parts stored on the belts. The Methane greenhouse worked all hour.
- **The Zinc plates ran out first.** 724 Zinc plates lay on the bus and in the block at the save;
  the block used 0.40 a second, the zinc column made 0.15 at best. At 40 minutes the bus was empty,
  the Battery machine waited, and the boards fell to what the Zinc made: 0.01 to 0.04 a second.
- **The Tar line slowed at 15 minutes and stopped at 55.** Its Creosote has one user, the Treated
  wood unit, and three makers on one pipe: the Tar refining unit (24 per 100 Tar), and the new units
  turning Carbolic oil and the pond's Naphthalene oil into Creosote. Once the pipe was full the Tar
  refining unit waited with Creosote in its output box (read every 5 minutes: 76 to 92 in a box
  that would not take the next 24), and ran only as fast as Treated wood was made: 4 to 5 Tar a
  second instead of 14. With it fell the Aromatics (6.2 → 2.0, the Zinc), the Coke (3.7 → 1.3, so
  the Acetylene and the Lead), and the Gasoline. When the boards stopped, the Formica stopped, the
  Treated wood stopped, and with its last user the Creosote pipe stopped the Tar line altogether.
- **That stop does not clear by itself:** the boards wait for Zinc, the Zinc for Aromatics, the
  Aromatics for the Tar line, and the Tar line for the boards to use Creosote again.
- **Glass would have been next.** The melting Glassworks burns Gasoline (10 MW, 8.3 Gasoline a
  second when busy); with the Tar line slow, the Gasoline pond's 4,534 lasted about half an hour.
  About 7,500 Molten glass in the pipe kept the block's Glass coming while the boards ran.
- The Tar pond itself was not the limit: 26,381 Tar at the save, about 23,000 used in the hour.

**With the coke block's pole put back** (the author cut it at 13:28, to use up the pond's Tar
first; the same hour with a Small electric pole placed at (−55.5, −92.5) when the save loads): the
coke block makes 6.1 to 6.6 Tar a second, so the pond fills again, but the boards follow the same
course (0.120 for 35 minutes, 0.110, 0.040, 0.010). Its Coal gas goes to the three aluminium drills
(about 10 a second, 1.16 Aluminium ore a second; 8,200 ore are left under them, about two hours of
it). The new Gasifier on Coal gas stands "full output" all hour: its Syngas pipe ends at
(−108.5, −176.5), so the Syngas has no way out yet.

## 6. What the boards ask of the Tar line

The author's rule (techniques, principle 23) applies from here: the circuit boards are the main
product, and their line is complete, so the chain must keep running, no byproduct may jam it, and
each product needed steadily should not hang on another. What 0.1 boards a second asks of the Tar
line, from data (per 100 Tar the author's line gives 43 Aromatics, 25.7 Coke, 68 Gasoline and 24
Creosote, plus 58 Naphthalene oil and 15 Carbolic oil, which their new units turn into 35 and 15
more Creosote):

| For | Needs per second | Tar per second |
|---|---|---|
| Zinc plates 0.33 (CuZn Battery) | 13.3 Aromatics (4 per ore, 10 ore a plate) | **31** |
| Gasoline for Glass, 1.67 Molten glass | about 7.8 Gasoline (melting at 83 %, casting at 10 %, 10 MW each) | 11.5 |
| Lead plates 0.27 and the block's Coke | 1.9 Coke (0.94 per Lead ore, 0.40 in the block) | 7.4 |
| Treated wood 0.13 | 6.7 Creosote | 28 from refining alone |

- **Zinc sets the Tar rate: 31 a second**, and one Tar refining unit takes at most 20 (100 Tar
  in 5 s), one Pitch column 20 Pitch a second against the 43 that 31 Tar give. Before the Creosote
  filled, the author's line ran at 14.3 Tar a second: 6.2 Aromatics, 0.15 Zinc plates, enough for
  0.046 boards. The 0.12 of the first 40 minutes was the Zinc stock.
- **At 31 Tar a second everything else is surplus**: 8 Coke (1.9 used), 21 Gasoline (7.8 used),
  7.4 Creosote from the refining alone (6.7 used), more with the Naphthalene and Carbolic oil
  units. Every surplus needs a way out, or it stops the line as the Creosote did.
- **Lead and Zinc are coupled**, as the author noted after chapter 5: both hang on the Tar line, the
  Zinc on its Aromatics and the Lead on its Coke. At 16:08 the line ran at the pace of its slowest
  way out, the Creosote, and that pace was set by the boards themselves. Section 7 shows how the
  author gave each byproduct a way out, section 8 what the Tar line gives then.

What the data offers, for the author to weigh (all available now): Creosote's only use is Treated
wood, but a Tailings pond stores it and a Sinkhole takes it away (Void Creosote, 20,000 a craft);
and Tar processing has a Destructive distillation column recipe, named after its main product
Carbon dioxide, that gives Aromatics straight from Tar: 350 Tar → 100 Aromatics + 500 Flue gas +
100 Carbon dioxide + 1 Rich clay in 2.5 s, gases and one item for byproducts.

## 7. The author's tidy-up, 16:10–16:40

After the measurements of section 5 the author reworked the Tar line in half an hour (recorder;
the save of 16:40):

- **More Tar refining.** A second Tar refining unit at (−147.5, −85.5) (16:10–16:15), a second
  Pitch column at (−146, −127) (16:15–16:20) and a third Anthracene oil column at (−157, −139)
  (16:30–16:35): two refining units take up to 40 Tar a second (data: 100 in 5 s each).
- **The coke block runs again.** The pole at (−55.5, −92.5) is back (16:35–16:40); the block's Tar
  goes straight to the refining units, and the Tar pond at (−10, −72) is taken away (16:35–16:40),
  with its Tar. The block's Coke joins the Coke belt to the board block at (−72, −83).
- **Coke burnt for the Tar line's Steam.** The Coke belt now runs on past the board block, west
  along y −255, to ten Boilers at y −257 (x −160 to −133; placed at y −75 first and moved twice,
  16:10–16:30). Their Steam goes into the pipe that feeds both refining units, the tops unit, both
  Pitch columns and the Clay pit. Coke the Lead and the block do not take is burnt there, so it can
  no longer stop a column. The steam block's pipe got an Underflow valve at (−60.5, 110.5)
  (16:20–16:25), which lets Steam through only while the far side is under 80 % full (data).
- **A way out for Coal gas and Creosote**, through Overflow valves, which let a fluid through only
  while the near side is over 80 % full (data):
  - Coal gas: the aluminium drills take it first; past an Overflow valve at (−129.5, −168.5) the
    rest goes to the Gasifier (Syngas from coal gas), whose Syngas now goes to an Exhaust pipe at
    (−108.5, −176.5) (16:35–16:40) and whose Tar joins the refining units' Tar pipe.
  - Creosote: once the Treated wood unit's pipe is full, past an Overflow valve at (−116.5, −91.5)
    into a Sinkhole at (−116.5, −89.5) (16:25–16:30). Void Creosote takes 20,000 a craft (data), so
    the Sinkhole fills and empties in batches.
  - The Naphthalene oil unit came out again (16:35–16:40). Naphthalene oil and Gasoline go into
    their two Tailings ponds: the author's choice, since both should have uses once more
    technologies are unlocked.
- **The first boards' first use.** An Overflow or Underflow valve takes one Simple circuit board
  (data; Fluid handling), and so does a Basic splitter: the author handcrafted the three valves and
  107 splitters (110 boards; three splitters placed by 16:40). By the save 261 boards were made,
  146 of them in the chest.

## 8. Two hours after the save of 16:40

Measured in a copy of the save of 16:40 (`tools/rate-probe`, one minute of warm-up, then two hours
in 10-minute steps; per second, each step's average; the ponds at the end of each step):

| Minutes after 16:40 | Boards | Batteries | Zinc plates made / used | Aluminium ore | Coal gas | Tar | Aromatics | Coke | Creosote made / to Treated wood | Naphthalene oil pond | Gasoline pond |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0–10 | 0.110 | 0.040 | 0.32 / 0.40 | 1.56 | 32.0 | 30.0 | 12.4 | 8.41 | 11.3 / 6.5 | 49,831 | 18,252 |
| 10–20 | 0.100 | 0.040 | 0.30 / 0.40 | 1.08 | 26.8 | 26.7 | 12.3 | 8.00 | 11.2 / 7.0 | 59,792 | 24,338 |
| 20–40 | 0.100 | 0.040 | 0.31 / 0.40 | 1.04 | 26.6 | 26.7 | 12.3 | 8.01 | 11.2 / 6.5 | 79,615 | 36,533 |
| 40–60 | 0.100 | 0.031 | 0.31 / 0.31 | 1.05 | 26.7 | 26.7 | 12.1 | 7.93 | 10.7 / 6.8 | 99,039 | 48,250 |
| 60–80 | 0.100 | 0.031 | 0.31 / 0.31 | 1.05 | 26.7 | 26.7 | 12.0 | 7.89 | 10.5 / 6.8 | 118,165 | 59,732 |
| 80–100 | 0.100 | 0.030 | 0.29 / 0.30 | 1.04 | 27.0 | 26.9 | 11.5 | 7.59 | 10.4 / 6.5 | 136,772 | 70,505 |
| 100–110 | 0.100 | 0.028 | 0.30 / 0.28 | 0.69 | 23.7 | 24.8 | 10.8 | 7.04 | 9.7 / 7.0 | 145,458 | 75,218 |
| 110–120 | **0.090** | 0.028 | 0.25 / 0.28 | 0.53 | 21.9 | 23.7 | 10.3 | 6.60 | 9.3 / 6.5 | 153,686 | 79,334 |
| 150–180 (second run) | 0.070 | 0.023 | 0.22 / 0.23 | 0.04 | 16.7 | 20.4 | 8.75 | 5.64 | 8.0 / 4.6 | 198,192 | 99,930 |

(Rows of 20 minutes are the mean of two steps.)

- **Nothing stops.** Every byproduct of the Tar line leaves: the Coke is used as fast as it is made
  (the Boilers burn what the Lead and the block leave), the Creosote goes 6.5 to 7 a second to
  Treated wood and the rest into the Sinkhole, which voided its first 20,000 between minutes 50
  and 60 (19,556 → 1,750 in its box), the Syngas (23.3 a second) into the Exhaust pipe, and the
  Lead plates are made as they are used (0.27 a second from minute 50). The Methane greenhouse
  worked all two hours.
- **Naphthalene oil and Gasoline gather, as the author intends**: about 16 and 9.4 a second over
  the two hours. A Tailings pond holds 1,000,000 (data): at these rates the Naphthalene oil pond is
  full in about 15 more hours, the Gasoline pond in more than a day.
- **The boards: 0.100 a second for 110 minutes, 0.090 in the last ten.** What sets them is Zinc
  again, now steadily. The Tar line takes the coke block's Tar as it comes, 26 to 27 a second (its
  two refining units together can take 40), and its 12 Aromatics a second make 0.30 Zinc plates,
  0.030 Batteries, 0.09 boards. The 0.1 of the first 110 minutes also used the 328 Zinc plates and
  995 Zinc ore stored at the save, and the Batteries made from them in the first 40 minutes.
- **The Tar comes with the Coal gas, and one Coal gas user is running out.** The coke block makes
  Tar only as fast as its Coal gas is taken: by the aluminium drills first, and past the Overflow
  valve by the Gasifier, at most 16.7 a second (50 every 3 s, data). The three drills had 341,
  3,124 and 4,354 Aluminium ore under them at 16:40 and mine 0.5 a second each: the first stopped
  within ten minutes, the second at about 100. Coal gas fell from 27 to 22 a second, Tar from 27
  to 24, Aromatics to 10.3, and the boards to 0.090.
- **With the aluminium ore gone** (a second run: half an hour from 2.5 hours after the save) the
  Gasifier is the only way out for the Coal gas, 16.7 a second. The coke block then makes about
  10 Tar a second and the Gasifier 10 more (30 per 50 Coal gas, data): 20.4 in all, Aromatics 8.75,
  Zinc plates 0.22, and the boards settle at 0.07 a second. Nothing else changes: every byproduct
  still leaves, and the two ponds still fill (Naphthalene oil 11.8 and Gasoline 5.0 a second).
- In short: the line now runs without stopping, as the author expected. Its rate follows the Tar,
  and the Tar follows how much Coal gas the coke block can hand on: 27 a second to the drills and
  one Gasifier at 16:40 (0.1 boards), 16.7 to the Gasifier alone once the drills' ore is gone
  (0.07 boards).

## 9. Other changes

- **The acetylene block corrected.** The author moved the pole at the end of its Coke belt and laid
  the belt tile there, as chapter 5 suggested. Exported on 2026-10-14 and run on the bench again:
  49.75 Acetylene a second, all four Gasifiers at 100 % (43.2 before).
- **The ponds.** The Creosote and Carbolic oil ponds were taken away at 14:45–14:50 and 15:50–15:55
  (which first, the recorder does not say), the Tar pond at 16:35–16:40. Two are left: Naphthalene
  oil (38,694 at 16:40) and Gasoline (10,781).

## 10. Checklist

- Start Moondrop with a little Seaweed: Agar → Petri dishes, plus a Moondrop codex and a
  Planter box, gives 4 Moondrop in a nursery; seeds and greenhouses multiply them. A greenhouse
  needs 16 Moondrop as modules for speed 1 (with Carbon capture: 0.5 empty, 1.5 full).
- Label a block by its scarcest machine: one Methane greenhouse is 0.1 boards a second.
- A stock buys time, not rate: 724 Zinc plates gave 40 minutes of 0.12 boards, then the boards
  fell to the Zinc the Tar line makes.
- A byproduct with one user runs its line at that user's pace; if that user needs the line, a
  stop does not clear by itself (Creosote → Treated wood → boards → Zinc → Tar line).
- Give every byproduct a way out before the main product depends on the line, behind an Overflow
  valve so the real users come first: a pond for what later technologies will use, a Sinkhole or
  an Exhaust pipe for the rest, and Boilers for surplus Coke (their Steam back into the line).
- Once the main product's line is complete, run the whole base for an hour or two before calling
  it done (`tools/rate-probe` with a timeline), and look for outlets that will run out: here the
  aluminium drills' ore, one of the two takers of the Coal gas that sets the Tar.

## 11. How these facts were checked

- The run: the companion mod's recorder (run `2652821414-0`), read with `tools/recorder-phases.js`
  (timeline in 5-minute slices, chat notes, what was built and handcrafted where) and
  `tools/recorder-log.js` (production per 10-minute window).
- The saves of 16:08 and 16:40 (`Py-Exploration`, consistency check passed): `tools/inspect-save.ps1 -Ticks
  3700`, which now records each crafting machine's modules, its speed and the electric network
  of every entity; `tools/summarize-save.js`; `tools/trace-layout.js` (the bus lines and where they
  are joined, the pipe segments and which machines share one: the Creosote segment);
  `tools/render-area.js` and `tools/render-save-map.js`; the Zinc plates, Coke and Tin plates on
  the belts and the ponds' contents from the snapshot's `entities.json`.
- **An hour of the base:** `tools/save-probe.ps1 -Save Py-Exploration -Probe rate-probe -Ticks
  219700 -Variant 60,3600,300,<names>`: `tools/rate-probe` now takes a step and a list of items,
  fluids and machine tiles (`@x:y`), and every step prints what was made and used of each, the
  watched machines' status and fluid boxes, and every machine group whose usual status changed.
  Run with the rates first, then again with the Tar refining unit, the Creosote units and the
  melting Glassworks read every step (the same numbers both times), and once with
  `+small-electric-pole@-55.5:-92.5` (the probe places that pole when the save loads: the only
  change it makes). On the save of 16:40: `-Ticks 435700 -Variant 60,7200,600,<names>` (two hours,
  the Tar refining units, the ponds, the Sinkhole, a coke Boiler and the melting Glassworks read
  every step; `@x:y` now reads any entity with fluid boxes) and `-Ticks 648100 -Variant
  9000,1800,600,<names>` (half an hour from 2.5 hours after the save).
- **The acetylene block on the bench:** `tools/bp-bench.ps1 -Bench acetylene` on the exported
  blueprint. The board block was not run on the bench: its greenhouses' speed and their Carbon
  dioxide recipe come from the Moondrop upgrade chosen in the save, which an empty bench map does
  not have; it was measured where it stands instead.
- Data: the current dump of the author's mods (`C:\tmp\cf-save\data\script-output\data-raw-dump.json`):
  recipes, machine speeds, base effects and module slots, the Glassworks' energy, Gasoline's fuel
  value, which technology unlocks what, the other Methane, Aromatics and Creosote recipes;
  pyalienlife's `prototypes/upgrades/moondrop.lua` for Carbon capture.
- The blueprints: exported by the author with the companion mod on 2026-10-14, 15:00, and pulled
  into `blueprints/`: the new board block (`simple-circuit-board.txt`, its description added) and
  the corrected acetylene block. The tidy-up of section 7 is not in a blueprint.
- The screenshots: taken by the author at 16:08 with the companion mod (`/pt-shots`).
- The valves: `py-overflow-valve` and `py-underflow-valve` in the data (mode, 80 % threshold,
  recipe); the Carbon capture module and the hidden beacon: pyalienlife's `scripts/turd/turd.lua`
  and `carbon-capture-module-mk01` in the data; the open technologies and their science packs
  from the data and the save's research list.

Next: chapter 7 (to come).
