# Techniques and mechanics

[中文版](techniques.zh-CN.md) · [Index](../README.md)

Everything here was measured in the engine or read from the prototype data of the setup in the
[README](../README.md); the source is given for each entry. Chapter 1 explains the early ones in
context.

## Belts

| Fact | Source |
|---|---|
| A Transport belt carries 15 items/s, 7.5 per lane. | Data |
| An Underground belt spans at most 9 tiles. | Data |
| A mining drill drops onto the belt lane **nearest** to it. | Engine, `tools/belt-lab` |
| An inserter drops onto the belt lane **farthest** from it. | Engine, `tools/belt-lab` |
| Side-loading puts everything from the feeding belt onto the lane of the target belt nearest the feeding belt. | Engine (all designs below) |
| A belt tile fed from one side only, with no belt behind it, is a curve, not a side-load: both lanes of the feeding belt go on. With a belt behind it (even an empty one) it side-loads onto the near lane. | Engine, `tools/belt-lab` |
| A Splitter splits each lane evenly between its two outputs and keeps it on its lane: fed on the E lane only, both outputs carry it on the E lane (51 and 52 items after 20 s). | Engine, `tools/belt-lab` |
| **Lane balancer** (the author's): a Splitter, then its two outputs side-loaded into one belt from opposite sides, so that each output fills one lane. The Splitter makes the two outputs equal, whatever the lanes of the input: fed on one lane only, the merged belt carries 37 and 34 items on its two lanes after 20 s. | The author; engine, `tools/belt-lab` |
| A Splitter with a belt on one output only still sends items to the other output, and keeps 4 of them there (2 per lane) for good: fed on both lanes, 12 items stand on it against 8 with the output priority set to the side that has the belt. A chain of such Splitters loses 4 items at each one before anything reaches its end. Better than the priority, the community's trick the author used on the eight such Splitters of the Vrauk line (chains where inserters only drop Barrels or Vrauks): a filter with an item that never comes, the Deconstruction planner, sent to the side without a belt. Both leave nothing there while the chain flows; with the output belt backed up the priority sends 4 items to the dead side, the filter none. Where an inserter picks from the dead half, the 4 items are that inserter's buffer. | Engine, `tools/belt-lab`; `tools/vrauk-probe` ([chapter 8](../chapters/08-vrauks.md)) |
| To put items onto the far lane of a belt that already runs (a loop), use inserters: they drop on the far lane. A Splitter keeps the lanes, and side-loading reaches only the near lane. The author's Ash loop jammed with its outer lane full while the incoming Ash ran on that same lane; five Mechanical inserters onto the inner lane fixed it. | The author's game (chapter 7); `tools/belt-lab` |

**Lane filtering with an underground belt.** A belt that runs into the *side* of an underground
belt tile lets only one of its lanes through:

| Target tile (belt arriving from the south, flowing north) | Lane that passes |
|---|---|
| Entrance whose tunnel goes east | West |
| Entrance whose tunnel goes west | East |
| Exit pointing east (belt enters its back side) | East |
| Exit pointing west | West |

Rule of thumb: an entrance passes the lane *away from* its tunnel; an exit passes the lane on the
side it points to. (Engine, `tools/belt-lab`.)

## Inserters

| Fact | Source |
|---|---|
| The Mechanical inserter (Py's burner inserter) needs no fuel and no power at all. | Data (`void` energy), engine |
| It has 1 filter slot. | Data |
| Throughput: see the table below. Belt → belt: 0.83/s from a moving full belt, 0.86/s from a standing one. | Engine, `tools/inserter-probe`, `tools/design-lab` |
| The Py encyclopedia's 0.78/s for the Mechanical inserter matches one full turn at its rotation speed (0.013 turn per tick = 77 ticks); the engine moves 0.789/s (76 ticks a swing) from a chest and more from a belt, where the hand meets the items. | Data, engine (`tools/inserter-rate-probe`) |

Items per second without inserter capacity bonus (Iron plates, basic belt, 60 s per case,
`tools/inserter-probe`; the Mechanical inserter row to three decimals from `tools/inserter-rate-probe`,
10 minutes per case with every drop timed).

| Inserter | Chest → chest | Chest → moving belt | Moving full belt → chest | Standing full belt → chest |
|---|---|---|---|---|
| Mechanical inserter | 0.789 | 0.789 | 0.833 | 0.857 |
| Inserter (electric) | 1.25 | 1.25 | 1.25 | 1.27 |
| Long-handed inserter | 1.25 | 1.25 | 1.20 | 1.20 |
| Fast inserter | 2.50 | 2.50 | 2.82 | 2.73 |

The Mechanical inserter in detail (`tools/inserter-rate-probe`): every case takes a whole number of
ticks per item, and the target does not matter (a chest, a belt, a Burner assembling machine and a
Stone furnace took the same ticks); only the pick-up does:

| Picks up from | Ticks per item | Items/s |
|---|---|---|
| A chest or a machine | 76 | 0.789 |
| A moving full belt (both lanes, or only the near lane) | 72 | 0.833 |
| A moving belt, only the far lane full | 73.6 | 0.815 |
| A standing full belt (both lanes, or only the near lane) | 70 | 0.857 |
| A standing belt, only the far lane full | 74 | 0.811 |
| A thin belt: 1.95 items on the tile on average (blueprint bench, chapter 4) | 75 | 0.798 |

For planning: 0.789/s from a chest or a machine, 0.833/s from a moving belt, 0.857/s from the end
of a belt. An ingredient needed at 0.8/s plus the machine's fuel takes two inserters (chapter 4's
red science ran at 98 % with one).

**A machine is no faster than the inserters that fit around it** (the author). A Stone furnace with
one input inserter: Iron or Copper plate (0.8 ore/s) runs at full speed, Aluminium plate (1.667
ore/s) at 50 %, Iron oxide (5.714/s) at 15 %. Bench (chapter 4): the smelting column on a full
Aluminium ore lane feeds nine furnaces at 0.833 each, 0.75 plates/s; the Iron oxide pair takes
1.717 Iron oxide/s.

## Machines with an output port

| Fact | Source |
|---|---|
| Some machines drop their products themselves, like a mining drill, so they need no output inserter (inserters can add throughput): Soil extractor, Sap extractor, Wood processing unit, Sand extractor, Classifier, Ground borer, Clay pit, Casting unit (prototype field `vector_to_place_result`). | Data |
| A circuit that starts a supplier below a threshold must cover two batches when the supplier is slower than the consumer: a Soil extractor (8 Limestone per 20 s) feeding an Advanced foundry (5 per 15 s) gives 0.435 Steel/s for 8 pairs at < 5, 0.493 at < 8 and the full 0.533 from < 10 up. | Engine, `tools/save-probe.ps1` + `tools/steel-probe`; a tick model agrees (chapter 3) |
| A Soil extractor facing north drops 3.8 tiles below its centre, on the tile just past its bottom edge. A Foundry standing there gets the Limestone directly (24 Limestone in 60 s, all inside the Foundry); a belt there gets it on one lane only, the lane nearer the extractor. | Engine, `tools/inserter-probe` |
| The author's steel site stacks one Soil extractor on each Foundry this way. Output that lands on one lane can be spread over both with the author's lane balancer (Splitter and two-sided merge, above). | Author's save; `tools/belt-lab` |
| Taking from a Stone furnace or Boiler, an inserter takes the product **and** the Ash, never the fuel. | Engine, `tools/ch1-probe` |
| Taking from a Burner mining drill, an **unfiltered** inserter also pulls the fuel out and starves the drill; filtered to Ash it takes only Ash. | Engine, `tools/ch1-probe` |

## Burner machines, fuel and Ash

| Fact | Source |
|---|---|
| Stone furnace: 8 ore → 1 plate in 10 s (0.1 plate/s), 200 kW, 1 fuel slot. | Data, engine |
| Burner mining drill: mining speed 1, 500 kW, 1 fuel slot: 1 ore/s, 2 Raw coal/s, burns 0.167 Raw coal/s. | Data, engine |
| Coal-type fuels (Raw coal, Coal, Coke, …) leave 1 Ash per item; Logs and Wood leave nothing. | Data |
| A Log burns for 4 MJ; made into Wood (4 Logs → 40 Wood with Selective cutting heads) it gives 10 Wood of 2 MJ, 20 MJ. A Burner assembling machine (75 kW) burns 0.0375 Wood/s. | Data ([chapter 5](../chapters/05-tin-zinc-smelting.md)) |
| The burnt-result slot holds 1000 Ash; when full the machine stops. At full load on Raw coal: Boiler 13.5 min, Burner mining drill 100 min, Stone furnace ~4 h. | Data, engine |
| A Basic oxygen furnace MK 01 burns 5 MW: on Raw coal 1.67 Ash a second while it works, twice what one Mechanical inserter takes out of a machine (0.789). Its burnt-result slot (1,000 Ash) then fills in about 19 minutes of work, after which the furnace works 47 % of the time. The author's four made 0.39 Antimony oxide a second until their slots filled, 0.19 after; with a second Ash inserter on three of them 0.26 to 0.30. Coke (5 MJ) makes 1.0 Ash a second, Crushed coal (6 MJ) 0.83; biomass fuels none. | Data; recorder; `tools/rate-probe` on the save of 32:40 ([chapter 13](../chapters/13-geothermal-antimony-oxide.md)) |
| Mining productivity is free output: +10 % gives 2.17 Raw coal/s per drill with unchanged fuel use. | Engine (one-off probe) |
| A Burner mining drill that cannot drop its ore ("waiting for space") burns nothing: 0.01 MJ in a minute, against 14.5 MJ for a working one. | Engine, `tools/drill-probe` |
| An inserter never takes fuel out of a furnace, so one filtered to everything *but* Ash (blacklist) takes only the product. | Engine (`tools/ch1-probe`), seen in the author's run |
| Ash separation (a red technology) is the early way to get rid of Ash: a Solid separator MK 01 (electric, 1.5 MW) turns 10 Ash per second into Coal dust (50 %), Soot (20 %) and Iron oxide (5 %). | Data (`data-raw-dump.json`) |
| Ash separation returns half the fuel it costs: 10 Ash take 1.5 MJ of electricity (3 MJ of Boiler fuel) and give 0.5 Coal dust (1.5 MJ). Separating all Ash costs about 5 % more Raw coal. Coal dust is a 3 MJ fuel like Raw coal, stacks to 100 and burns to Ash again. | Data ([chapter 3](../chapters/03-ash-separation-raw-coal-power.md)) |
| Soot separation: 2 Soot → Iron ore and Copper ore 20 % each, Ash 30 %, Aluminium, Zinc and Lead ore 10 % each, 1 s. Iron oxide smelts 20 → 10 Iron plates in 3.5 s in a Stone furnace (5.7 Iron oxide/s per furnace, but one input inserter brings 0.857: 15 %). | Data; the author's game (chapter 3); bench (chapter 4) |
| A Solid separator at full speed needs 13 Mechanical inserters on Ash (13 × 0.833 = 10.8/s from a moving belt). | Data, inserter measurement; the author's design |
| The Ash separation and the Soot separation form a loop when the Soot separator puts its Ash (30 % of its output) back on an Ash belt: if that belt is full, the Soot separator stops, the Ash separators' Soot cannot leave, they stop too, the Ash backs up into the Boilers ("burnt result full") and the Steam engines run dry. Nothing restarts it, since the separators run on electricity. In the author's base a new line that doubled the Raw coal burnt (37 → 72–79 a second) blacked the base out 60 minutes after it started; 6 of the 12 Ash separators stood short of Ash at the save while others backed up. The Burner (first pY science pack 1 technology) burns Ash or Soot at 3.3 a second, but gives back 1 Ash in 5: on Ash it removes 2.7 a second. The author's first fix, the Soot separator's Ash dropped onto the loop's other lane, did not help: the Ash loop was full on both lanes, its only way off fed three of the twelve separators, and the base blacked out within an hour again. | `tools/rate-probe` (Boilers and Steam engines by row), save of 23:31, data ([chapter 9](../chapters/09-py-science-pack-1.md#7-two-hours-after-the-save)) |

## Steam power

| Fact | Source |
|---|---|
| Boiler: 3.7 MW, 7.5 Steam/s at 250 °C, 1.23 Raw coal/s at full load. | Data, engine |
| Steam engine: 15 Steam/s → 3.7 MW. **Two boilers per engine.** | Data, engine |
| Offshore pump needs no power; with `pump-anywhere-fork` it works on land. | Data, engine |
| The electric network loads every Steam engine that has steam by the same share of what it can deliver. Two engines behind two Coal dust Boilers (one engine's steam) take two shares, so those Boilers run twice as hard as the rest and burn the Coal dust first (the author's trick). In the author's save the computed share, 2.0 Coal dust/s, matched the 2.03/s burnt. | Data; the author's save (chapter 3) |
| Boilers pass water along their row. The author's 24-Boiler station had its Offshore pump at one end and a three-tile gap between its halves, so only 12 Boilers had water (22.2 of 44.4 MW); three pipes per row closed it (all engines running afterwards). | The author's saves (chapter 3) |
| A Boiler's Steam carries 493.5 kJ a unit (2.1 kJ per degree, 15 → 250 °C), so 10 Steam (one Tin ore's mining fluid) cost 1.65 Raw coal. | Data ([chapter 5](../chapters/05-tin-zinc-smelting.md)) |
| Crushing Raw coal before burning it: a Secondary crusher MK 01 (3 s, 450 kW, 465 kW measured while working) turns 3 Raw coal (9 MJ) into 1 Crushed coal (6 MJ), 2 Coal (8 MJ) and Coal dust at 30 % (0.9 MJ): 4.67 MJ a Raw coal without the Coal dust, 1.56 times burning it raw. Two belts (30 Raw coal/s, 30 crushers, 60 Boilers) give 140 MW of fuel and 283.7 Steam/s: 19 Steam engines (18.9). Measured 70.0 MW, of which the crushers take 13.95 MW and the 3 Ash separators 4.6 MW; burnt raw, the same two belts give 44.4 MW. Each crusher feeds one Boiler Crushed coal (54 % of its 3.7 MW) and one Coal (72 %). | Data; `tools/power-probe` on the author's block (x 108–213, y 151–197) in a copy of the save of 2026-10-18 00:34, finished by script (19 Steam engines, poles, water, the missing inserter) |
| Every crusher's fuel burns to 1 Ash a second, so a row of 15 crushers puts 15 Ash/s on its Ash belt: a full Transport belt. Inserters drop on the far lane only (7.5/s a lane); in the author's block one lane of each row got 7.67/s, the last Boiler on it kept 0.17 Ash/s and was full (1,000 Ash) after 95 minutes. Then the block ran at 29.6 Raw coal/s and 69.1 MW, steady to 3 hours. The author's lane switch halfway along each row (a Splitter and a side-loaded Underground belt at x 160–163, one Boiler with an inserter on each side) is in the right place: counted item by item, both lanes carried 7.333/s just before the last Boiler, so it alone (0.333/s, one inserter at the belt's corner) overflows. A second Ash inserter on it, onto a belt that side-loads the other lane (the author's idea), filled both lanes to 7.500/s; then all 30 Ash/s reached the 3 separators, whose 13 Burner inserters each took 29.85/s, and the other row backed up instead. A seventh inserter under the third separator (or a fourth separator): 30.0 Raw coal/s, 70.0 MW and no Ash building up over 3 hours. Fast belts (Logistics 2) need pY science pack 2 and Logistic science. | `tools/power-probe` on the author's block (x 108–213, y 151–197) in a copy of the save of 2026-10-18 00:34, finished by script (19 Steam engines, poles, water, the missing inserter) |
| A block whose crushers run on its own power cannot start itself: with empty Boilers it stood still (crushers without power, Boilers without fuel). 20 Coal in each Boiler started it; on the base's network the base's power would. | `tools/power-probe` on the author's block (x 108–213, y 151–197) in a copy of the save of 2026-10-18 00:34, finished by script (19 Steam engines, poles, water, the missing inserter) |
| The author's finished crushed-coal block (x −60 to 46, y 142 to 186), measured alone: 70.3 MW for an hour (engines full, helped by the starting Coal and stored Steam), then 66.5 MW at 28.5 Raw coal/s, 48.8 MW net. One crusher never ran: its Coal Boiler's Steam went into a Pipe to ground facing the same way as its partner, so the two did not connect; the Boiler stood "output full", the crusher filled with Coal and its Crushed coal Boiler got nothing. Turned round: all 30 crushers, 29.7 to 30.0 Raw coal/s. Each row's 15 Ash/s is exactly one Transport belt, so the lane the west end's Boilers drop onto is about 98 % full there: the second Boiler from the west end (0.67 Ash/s) got only 0.52/s out and filled with Ash within an hour. With the westmost crusher's two fuel filters also swapped (Coal to the westmost Boiler, which has two Ash inserters), the lower row kept no Ash for three hours, but the upper row's westmost Boiler still kept 0.17 Ash/s and was full after about 100 minutes: 29.8 Raw coal/s after that, fuel for 69.4 MW (66.5 as built). Taking the Ash off at the corner or at the separator belts' dead ends changed nothing (624 and 627 Ash in that Boiler after 30 minutes): the limit is the one drop. A second Ash inserter on that Boiler, on the free tile west of the first (same lane, one tile on), and the block runs full: 30 Raw coal/s, the 3 separators at 100 %, 70.3 MW, 51.7 MW net, the Boilers' Ash unchanged over two hours (the swap with it makes the westmost Boiler fill again). Why (the author's explanation, which the runs support): a Mechanical inserter's round trip takes 76 ticks, at most 0.789 items/s (measured above), and a Coal Boiler's 0.67 Ash/s is 85 % of that, so it can wait for a gap only 15 % of the time; the upstream Boilers' drops leave gaps in a fixed pattern set by their phases, so whether it finds enough depends on the pattern (the lower row, unchanged, filled at 583, 138 or 0 Ash a half hour in different runs; the draft never). A belt side-loading the lane takes any gap and buffers a few items: the general fix for a Boiler on a nearly full lane (the author's proposal). Tested with random start phases (crushers started in a random order 0–4 s apart, `stagger=`, 90 minutes): as built 1 of 3 starts jam, pipe turned 1 of 3, with the second inserter 0 of 3; the author's update of 2026-10-19 (the westmost Boiler's Ash merged by a short belt and a Splitter) 3 of 6, all at the second Boiler from the west, and 0 of 6 with a second inserter on it. | `tools/power-probe` with `isolate=1` (the block cut off from the base), `each=boiler`, `lanes=`, `turn=` and `filter=` in a copy of the save of 2026-10-18 20:35 ([chapter 10](../chapters/10-crushed-coal-power.md)) |
| Coal dust at full load: with every Boiler of the base burning, the base made 8.26 Coal dust/s (5.84 from Ash separation, 2.42 from the crushers) and its six Coal dust Boilers burn at most 7.40 (1.23 each). The surplus backed up along the by-product belt; the crushed-coal block's lower row, whose Coal dust belt joins it last, then stood "output full" 30 to 82 % of the time in its western half. As saved (6.4 made, 7.5 burnt) nothing backs up. | `tools/power-probe` load test (whole base, `each=secondary-crusher-mk01`, `lanes=`) in a copy of the save of 2026-10-18 20:35 |
| Oil burner (Oil industry machinery - Stage 1): 29.6 MW of Steam (60/s at 250 °C, four Steam engines) from 14.8 MW of fluid fuel. It burns any fluid with a fuel value at 200 %, a Boiler burns at 100 %, and Steam engines turn Steam into power at 50 %: a fluid fuel gives its whole fuel value as power, a solid fuel in a Boiler half. Measured: 37.01 Syngas/s (0.4 MJ) → 14.805 MW, steady over 6 minutes. | Data; `tools/power-probe` with `fill=` (an Oil burner, four Steam engines and a Storage tank of Syngas placed beside the author's base in a copy of the save of 2026-10-18 20:35) |
| Geothermal power (Geothermal Power - Stage 1; the exchanger from Hot air - Stage 1): a Geothermal plant (an 11×11 mining drill, 1 MW) on a Geothermal fissure makes 100 Geothermal water at 3000 °C a cycle from 10 Pressurized water, 2.5 cycles a second; a Regenerative heat exchanger (300 kW) turns 600 of it into 300 Steam at 500 °C in 2.5 s. A Steam engine takes Steam up to 500 °C, and Py's Steam holds 2.1 kJ a degree: 15 Steam/s at 500 °C give 7.639 MW, a Boiler's 250 °C Steam 3.701 MW. Measured: the plant 250.00 water/s (300.00 with +20 % mining productivity, without more Pressurized water or fissure used), 25.00 Pressurized water/s, 1.000 MW; the exchanger 240 → 120/s, 0.310 MW. One fissure: 1.25 exchangers and 10 engines, 76.4 MW, about 75 MW net, no fuel. A fissure holds 2^16 × its distance from the start × the richness setting: 225 M to 379 M on the author's map, used 2.5 a second. | Data; `tools/geo-probe` (a lab map, each stage on its own network, 60 s each); the save of 29:51 ([geothermal](geothermal.md)) |
| A crafting machine draws a thirtieth of its power while idle (Py's data sets no drain, so the engine's default holds): the Regenerative heat exchanger measured 300 kW + 10 kW; so an Electrolyzer MK 01 (10 MW) draws 333 kW standing idle. Mining drills and burner machines draw nothing idle. | `tools/geo-probe`; data |
| The author's three geothermal sites (each a Geothermal plant, a Pressure pump MK 01, two Regenerative heat exchangers, ten Steam engines): 76.39 MW a site, 74.86 MW net, measured alone with a load; the whole base 231.0 MW, of which it used 84. With them the coal power (two Raw coal stations, the crushed-coal block) was taken up, and Raw coal mined fell from 78 to 89 a second to 12 to 21. | `tools/power-probe` on the save of 32:40 ([chapter 13](../chapters/13-geothermal-antimony-oxide.md)) |

## Pipes, Pumps and Check valves

| Fact | Source |
|---|---|
| A fluid segment (pipes that touch) may span at most 320 tiles: Py's Pipe and Pipe to ground have `max_pipeline_extent` 320 (other fluid boxes 1280). Longer, it fills and delivers nothing: 310 tiles of Pipe to ground 4,800 Steam/s, 330 and 625 tiles 0. The span is the segment's box on the map, not its length: an L of 200 + 200 tiles delivers 4,800. The author's widest segment covers exactly 320 tiles (an Aromatics pipe) and flows. | Data; `tools/valve-probe` ([chapter 5](../chapters/05-tin-zinc-smelting.md)) |
| A Pump or a Check valve ends a segment: 625 tiles with one at tile 310 deliver 3,880 (Pump) and 4,781 (Check valve) Steam/s; with a Pump at tile 205 the 420 tiles behind it deliver 0. | `tools/valve-probe` |
| Pump: 1 × 2, 29 kW, 200 per tick, pushes until the far side is full or the near side empty (20 % → 80 %: the near side emptied into the far one). Check valve (Fluid handling): 1 × 1, no power, one-way, 200 per tick, lets fluid run only from the fuller side to the emptier one and stops when they are level (20 % → 80 %: nothing; 80 % → 20 %: levelled at 50 %). A supply line drained at its far end works with either. | Data; `tools/valve-probe` |
| A Pipe holds 100 and a Pipe to ground 100, so an underground pair (11 tiles) holds 200: a 100-tile line of them only 1,900. | Data; `tools/valve-probe` |
| A Pipe to ground reaches 10 tiles (`max_underground_distance` 10). A pair further apart simply does not join, with no warning: the two ends are separate segments. The author moved a row of 20 Coke Boilers eight tiles with robots and left their Steam pipe's last Pipe to ground 17 tiles from its partner: the Boilers stopped burning Coke, the Tar line jammed on its Coke within minutes and its Aromatics fell from 17.2 to 3 a second. A second pair in the gap put it right. | Data; `tools/rate-probe` on the save of 32:40 ([chapter 13](../chapters/13-geothermal-antimony-oxide.md)) |
| Overflow valve: lets a fluid through only while its input side is over 80 % full; Underflow valve: only while its output side is under 80 %. Both Fluid handling, each made with one Simple circuit board. The author's uses: the aluminium drills get Coal gas first and the rest passes an Overflow valve to a Gasifier (Syngas into an Exhaust pipe); Treated wood gets Creosote first and the rest passes an Overflow valve into a Sinkhole; the steam block's Steam enters the long steam pipe through an Underflow valve; the lead drills get Acetylene first and the rest passes an Overflow valve to the titanium drills (chapter 7). | Data; the author's saves of 16:40 ([chapter 6](../chapters/06-simple-circuit-boards.md)) and 17:48 ([chapter 7](../chapters/07-copper-screening-titanium-duralumin.md)) |

## Distillation byproducts

| Fact | Source |
|---|---|
| Exhaust pipe: no power; its venting recipe takes 20,000 Coal gas per craft at speed 2. One pipe vented about 88 Coal gas/s, the whole output of five distillation columns. | Data; the author's game ([chapter 2](../chapters/02-coke-steel-crushed-iron.md)) |
| Tailings pond: 18×18, holds 1,000,000 of one fluid. The author's held 160,300 Tar after about 75 minutes of coke making. | Data; the author's save |
| A column stops as soon as one output has no way out: with the Exhaust pipe removed, the author's five columns filled their Coal gas pipes within minutes and stopped Coke, and with it Steel. A Tailings pond is no store for gas: pycoalprocessing's script empties every gas that enters a pond (counting 15 % of it as pollution), so on the Coal gas pipe it is just another vent. Tanks (Storage tanks: 10,000–30,000) hold minutes of it. | The author's save, the author; `pycoalprocessing/scripts/tailings-pond.lua`; data (chapter 3) |
| Aluminium ore can only be mined with Coal gas as the mining fluid (Fluid mining drill, Mining with fluid). A Fluid mining drill MK 01 mines 0.5 ore/s with 10 Coal gas per ore and burns fuel (400 kW): the author's seven took 35.3 Coal gas/s for 3.52 ore/s. | Data; the author's recorder ([chapter 4](../chapters/04-aluminium-glass-logs.md)) |
| Coal gas comes only with Coke: three Raw coal → Coal columns feeding two Coal → Coal gas columns make 240 Coal gas and 150 Tar per 6 Coke, so every Coke taken lets them make 40 Coal gas and 25 Tar (4 Aluminium ore). With no Coke user the columns stop and the aluminium drills run dry. The author's windows: 0.88 Coke/s (steel) → 35 Coal gas/s → 3.5 ore/s; 0.3 Coke/s (a High pressure furnace) → 12 → 1.2; none → 0. | Data; the author's recorder (chapter 4) |
| Glassworks MK 01 burn a fluid fuel, 10 MW each. On Tar (0.2 MJ) a busy one takes 50 Tar/s; the author's melter and caster made 0.2 Glass/s on 56 Tar/s, 280 Tar per Glass. | Data; the author's recorder (chapter 4) |
| Distillation gives Iron oxide by chance, 20 % of the Coal crafts and 30 % of the Coal gas crafts: the author's 1,338 Coal and 690 Coke came with 119 Iron oxide, 124 expected. | Data; the author's save |
| Aromatics from Tar (Tar processing): Tar refining bottoms (100 Tar + 100 Steam → 30 Middle oil, 24 Creosote, 75 Anthracene oil, 140 Pitch, 5 s), tops (100 Middle oil + 100 Steam → 50 Light oil, 50 Carbolic oil, 100 Naphthalene oil, 4 s), Coke from Pitch in a column (100 Pitch + 100 Steam → 10 Hydrogen, 20 Light oil, 20 Naphthalene oil, 30 Anthracene oil, 10 Coke, 5 s), Aromatics (50 Light oil → 50 Aromatics + 25 Gasoline, 2 s). Per 100 Tar: 43 Aromatics, with 117 Anthracene oil, 58 Naphthalene oil, 24 Creosote, 15 Carbolic oil, 14 Hydrogen, 21.5 Gasoline, 14 Coke, and 270 Steam in. One column refines 20 Pitch/s against the 28 of one refining unit. | Data ([chapter 5](../chapters/05-tin-zinc-smelting.md)) |
| Gasoline from Anthracene oil (Tar processing; the recipe is named after its product): 50 Anthracene oil → 20 Gasoline + 5 Coke, 4 s, in a Destructive distillation column (12.5 oil a second). With all its Anthracene oil cracked, 100 Tar give 25.7 Coke (14 from the Pitch) besides the 43 Aromatics, and 68 Gasoline. The author's line, measured at 13.3 Tar/s: 5.75 Aromatics, 3.58 Coke, 9.8 Gasoline, 7.5 Naphthalene oil, 3.2 Creosote, 1.9 Carbolic oil, 1.85 Hydrogen and about 36 Steam a second. | Data; `tools/rate-probe` (chapter 5) |
| A Tar line stops when any byproduct pipe fills: the author's dead-end pipes filled with Anthracene oil (3,200) and Pitch (2,900) after 850 Aromatics. The oils become Creosote (Creosote technology), Anthracene oil Gasoline and Coke, and most burn (Gasoline 1.2 MJ, Carbolic oil 0.35, Naphthalene oil 0.3, Anthracene oil 0.25, Hydrogen 0.1). | The author's save; data (chapter 5) |
| Ways out for byproducts: a Tailings pond stores 1,000,000 of one liquid (the author's four Tar liquids would fill theirs in 35 to 158 hours of play, at the rates of 13:28), an Exhaust pipe vents a gas (Hydrogen, the Lime furnace's Carbon dioxide), a Sinkhole takes a liquid away (Saline water). | Data; the author's save; `tools/rate-probe` (chapter 5) |
| A store is not a source: from 11:03, when the coke columns came down, no machine made Tar, and the author's Tar line lived on the pond's stock (82,094 at 13:05, 73,764 at 13:28: 1.8 hours at 11.2 a second). Coke distillation (chapter 2) makes 67.5 Tar a second from 15 Raw coal; the author rebuilt it at 13:22 and cut its power, to use the stock first. | The author's saves; `tools/rate-probe`; data (chapter 5) |
| Surplus Coke back to Tar by circuit: Coal gas (from Coke, Coal processing 1), 20 Coke → 20 Coal gas + 20 Tar + 1 Ash, 5 s, in a Destructive distillation column. The author's new coke block reads the last tile of its Coke belt (hold) and runs its sixth column's four input inserters while the tile holds 4 Coke or more. Bench: Coke not taken → all 2.70 Coke/s into Tar (70.2 Tar/s), the other five columns at 100 %; Coal gas taken at only 20/s (four aluminium drills) → 18 % (0.5 Coke, 12.5 Tar/s), Coke taken or not; Coal gas not taken → everything stops. | Data; `tools/bp-bench.ps1 -Bench coke-distillation` (chapter 5) |
| A line runs at the pace of its slowest way out. The author's Tar line hands its Coke only to the acetylene block, which takes only the six lead drills' 2.8 Coke/s once their pipe is full: Tar 13.3 → 11.2/s, Aromatics 5.75 → 4.92 (ten minutes from 13:05 and from 13:28). The Lead plates gather only in the 13 furnaces (100 each), full about 20 minutes after 13:28; 25 to 35 minutes after it the lead drills, the acetylene block, the Tar line and the zinc drills all stand. Expected while nothing uses the plates (principle 23). | `tools/rate-probe` on the saves of 13:05 and 13:28 (chapter 5) |
| A byproduct with one user runs its line at that user's pace, and if the user needs the line, a stop does not clear: the author's Creosote pipe joins the Tar refining unit and two new Creosote units (Carbolic, Naphthalene oil) to one Treated wood unit. Filled in 10 minutes, the refining unit waited with Creosote in its output box: Tar 14.3 → 4–5 a second, Aromatics 6.2 → 2.0, Coke 3.7 → 1.3. When the boards stopped for want of Zinc, the Treated wood stopped and the Tar line stood, with the Zinc waiting on it. Creosote's only use at this stage is Treated wood; a Tailings pond or a Sinkhole (Void Creosote) takes the rest. | `tools/rate-probe` with the machines' fluid boxes read every 5 minutes; data (chapter 6) |
| Coal gas and Syngas share the Tar's limit. The author's Coal gas (Destructive distillation columns) goes to the aluminium drills first and past an Overflow valve to the Gasifiers (Syngas); columns and Gasifiers put their Tar into one pipe whose only user, two Tar refining units, takes 40 a second, and a machine with nowhere for its Tar stops. With the drills mining 7 Aluminium ore a second (70 Coal gas) the Syngas fell from 45 to 3 a second, and with it the plastic, the Antimony oxide and the Intermetallics. With a Tailings pond on the Tar pipe: Coal gas 96, Syngas 61, Tar 87 a second (47 into the pond, full in about six hours), and the Intermetallics line held its 0.167 a second for the hour. | Data; recorder; `tools/rate-probe` on the save of 34:59 ([chapter 14](../chapters/14-intermetallics-trains.md)) |

## Farms, logs and red science

| Fact | Source |
|---|---|
| Moss farms and Fastwood forestries have a base effect of −100 % speed, limited to −99.99 %: empty they run at a ten-thousandth of their speed, which is nearly nothing but not quite (see Vrauks below: an empty machine still takes one craft's ingredients in and holds them). Their slots take only their own module (Moss, Tree), +100 % each; full they run at speed 1 (15 × 0.0667 and 10 × 0.1). | Data; blueprint bench (chapter 4) |
| A balanced log block: 10 Moss farms : 8 Botanical nurseries : 16 Fastwood forestries make 2.0 Moss, 1.2 Tree seedlings and 2.4 Logs a second, 2.348 net after the Wood for the Tree seeds; they take Ash 12, Stone bricks 1.25, Coke 0.31 and about 316 Water a second, and about 13 MW. The chain needs a few Logs to start. | Data; bench `log-production`: 2.336 Logs/s |
| Fastwood forestry upgrade (a TURD technology) offers Dry storage (Fiber), Selective cutting heads (Wood processing unit: 4 Logs → 40 Wood in 1 s instead of 20 in 4 s) and Internal burner (forestries −50 % energy, +50 % speed and productivity, twice the Ash). | pyalienlife `prototypes/upgrades/fwf.lua` |
| Red science at 0.2/s is one Burner assembling machine; it needs 0.4 Planter boxes/s, that is 2.0 Soil/s (one Soil extractor running all the time), 0.8 Wood/s plus fuel and 1.6 Stone bricks/s into the Empty planter box machine (two Mechanical inserters each at their limit), and 2 Native flora/s (two Flora collectors MK 01). | Data; bench `red-science`: 0.196/s with one Wood inserter, 0.200 with two |
| A Solid separator block with Ash belts above and below the row needs both fed: one basic belt brings 15 Ash/s, half of what three separators take. | Bench `ash-separation`: 50 % with one belt, 100 % with both |
| Moondrop upgrade (TURD) offers Copper (Moondrop recipes take 10 Copper ore, twice the Moondrop in half the time), Moon (+35 % productivity, −50 % speed, a Methane recipe with a Lamp) and Carbon capture (+50 % speed, three times the power, a greenhouse recipe making 200 Carbon dioxide every 5 s from nothing). A Moondrop greenhouse MK 01 (9 × 9) runs at speed 1 with its 16 Moondrop modules. Carbon capture adds a hidden beacon with a +800 % speed module (T.U.R.D. script; `carbon-capture-module-mk01`): speed 0.0625 × (8 + Moondrop), 0.5 empty, 1.5 full (the author's, read in the save of 16:08). | pyalienlife `prototypes/upgrades/moondrop.lua`; data; `tools/inspect-save.ps1` ([chapter 6](../chapters/06-simple-circuit-boards.md)) |
| With Carbon capture the greenhouse draws 3 × 450 kW (the module's consumption +200 %): 22,500 J a tick against an electric buffer of 24,267 J, barely more than one tick. On the first tick after a save loads, 4 of the author's 6 greenhouses read "low power" with the buffer at 34 %; on every one of the next 3,599 ticks none did and the buffers were full on average. The status is an artefact of that one tick, not a shortage (the save inspector now snapshots one second after loading). | `tools/status-probe` on the save of 2026-10-18 20:35 |
| Starting Moondrop: a greenhouse has a base effect of −100 % speed and takes only Moondrop as modules (+100 % each), so the first come from a Botanical nursery: 1 Moondrop codex (2 Glass + 50 Air-core inductors + 20 Tinned cables, handcrafted) + 2 Petri dishes (Empty petri dish + Agar; Agar = 5 Seaweed + 100 Steam in a High pressure furnace) + 1 Planter box + 1,000 Water → 4 Moondrop, 200 s. Then the nursery turns 5 Moondrop into 2 back and 7 seeds (+10 % chance of 1–3 Moondrop, +25 % of 1–3 seeds: 2.8 Moondrop → 7.5 seeds), a greenhouse 4 seeds into 4 Moondrop in 140 s. At speed 1.5 two greenhouses and one nursery leave 0.14 seeds a second spare; Methane takes 0.1. Measured: 0.165 seeds made, 0.164 used, an hour. | Data; the author's note "月落草需要一点海藻启动"; `tools/rate-probe` (chapter 6) |
| Sap extractor MK 01: base effect −100 %, two Sap tree modules make speed 1; Sap (4 every 80 s) 0.05 a second each. The author's 14: 0.7 Sap a second. | Data; `tools/inspect-save.ps1` (chapter 6) |

## Tin, zinc and lead

| Fact | Source |
|---|---|
| Tin ore is mined with Steam (10 per ore), Zinc ore with Aromatics (4 per ore), both by Fluid mining drills. Tin plate (Mining with fluid) and Zinc plate (Electronics - Stage 1) are 40 ore → 4 plates in 60 s in a Stone furnace: 0.667 ore/s a furnace, twelve for half a belt. The author's tin column: 7.50 ore and 0.75 plates a second in the windows from 10:20 to 11:30 (one dipped to 4.95). | Data; the author's recorder ([chapter 5](../chapters/05-tin-zinc-smelting.md)) |
| A Simple circuit board takes 3.11 Tin plates (Solder, Ceramic capacitors, High-power resistors) and 3.33 Zinc plates (the CuZn Battery). Zinc has no other use before them. | Data |
| Steam-mined Tin costs about 1.9 Raw coal an ore: 1.65 for its Steam in the Boilers, 0.27 for the drill (400 kW at 0.5 ore/s). Half a belt of Tin ore burns 14 Raw coal a second. | Data |
| Lead ore is mined with Acetylene (10 per ore). Lead plate (Solder - Stage 1): 6 ore → 1 plate in 10 s, 0.6 ore/s a Stone furnace. A Simple circuit board takes 2.67 Lead plates (Solder: 2 Tin + 4 Lead → 1); Lead also makes tanks (the PyTank (40 kL) 30, without Duralumin). The author's six drills: 3.02 ore and 0.50 plates a second. | Data; `tools/rate-probe` (chapter 5) |
| Ore a plate on the screener routes. Lead (Lead processing - Stage 1): 5 ore → 1 Lead grade 1 (Automated screener, 3 s), 4 → 10 plates (40 s): 2 ore a plate instead of 6. Tin (Tin processing - Stage 1): 5 ore → 1 grade 1 + 0.5 grade 2 (screener), grade 2 → 0.5 grade 1 + Stone (crusher), 15 grade 1 → 10 plates (50 s): 6 ore a plate instead of 10. Zinc (Zinc processing - Stage 1, after Mining machines - Stage 1): 5 ore + 3 Iron sticks → 1 grade 1 (Ball mill, 4 s), 2 → 2 grade 2 (Impact crusher, 2 s), 20 → 30 plates (40 s): 3.33 ore and 2 Iron sticks a plate instead of 10. | Data |
| Acetylene (Acetylene technology): Limestone (Soil extractor, 0.4/s) → Lime (High pressure furnace, 15 Coke + 10 Limestone → 10 Lime + 100 Carbon dioxide, 5 s) → Calcium carbide (7 Coke + 2 Lime → 10, 4 s) → Acetylene (Gasifier, 300 Water + 10 carbide → 100 Acetylene + 25 Slaked lime, 8 s); an Evaporator dries the Slaked lime back (60 → 1 Lime + 1 Gravel, 2 s). Per Lead ore 0.94 Coke and 0.16 Limestone. Balanced: 2 extractors, 1 Lime furnace, 2 carbide furnaces, 4 Gasifiers for 50 Acetylene/s. | Data; bench `acetylene`: 49.5/s once every inserter reaches the belt (chapter 5); the author's corrected block 49.75/s (chapter 6) |

## Copper screening, titanium and duralumin

| Fact | Source |
|---|---|
| Copper processing - Stage 1 (red science): Automated screener MK 01 (7 × 7, 300 kW) 5 Copper ore → 2 Copper (grade 2) + 1 Copper (grade 1), 3 s; Jaw crusher MK 01 (1 MW) 2 grade 1 → 1 grade 2 + 2 Stone, 3 s; a furnace 5 grade 2 → 2 Copper plates, 2 s. So 5 ore and a Stone per plate, against 8 ore in 10 s with the plain recipe. One belt of ore (15 a second): nine screeners, five crushers, three furnaces for the plates and five for Stone bricks; 3 plates and 1.5 bricks a second, 7.7 MW. The author's block: 3.01 plates a second measured. | Data; `tools/rate-probe`, the save of 17:48 ([chapter 7](../chapters/07-copper-screening-titanium-duralumin.md)) |
| A resource's `fluid_amount` is per 10 ore: Titanium ore takes 4 Acetylene an ore (40), Lead ore 10 (100). Measured: 2.75 Titanium ore and 1.25 Lead ore a second used 23.0 Acetylene (23.5 from the data). | Data; `tools/rate-probe` (chapter 7) |
| Titanium plate (Alloy smelting - Stage 1): 40 Titanium ore → 4 plates in 60 s in a furnace, 0.667 ore a second a Stone furnace. A Fluid mining drill MK 01 mines 0.25 Titanium ore a second (speed 0.5, mining time 2). The author's eleven drills: 2.75 ore and 0.275 plates a second, the work of four furnaces. | Data; `tools/rate-probe` (chapter 7) |
| Duralumin (Alloy smelting - Stage 1): 4 Aluminium plates + 2 Copper plates → 1 in 4 s, only in a Smelter MK 01 (10 MW of fluid fuel), whose recipe takes 15 Titanium plates, 40 Steel plates, 50 Ceramic and 5 Simple circuit boards among others. On the way to pY science pack 1, Titanium plates also go into the Slaughterhouse MK 01 (40) and the Reproductive complex MK 01 (100), for the Formic acid of the Glassware's Rubber stoppers. | Data; the author's Factory Planner plan (chapter 7) |
| Before pY science pack 1, Duralumin is needed once: about 345 for the machines that start the Vrauks. The first Vrauks come only from a Creature chamber MK 01 (400 s each), since the Vrauk paddock and the Reproductive complex have base speed −100 % and run only with Vrauks as modules. Creature chamber 130 (with the Gene lab, Biofactory and PyTanks it uses up), Gene lab MK 01 for Moss gene samples 100, Data array 50, Incubator MK 01 15, Biofactory MK 01 for Plastic bars 50; also 295 Titanium plates and 60 Plastic bars. The author needed **245**: the Creature chamber's recipe takes a whole Gene lab, so they used the lab for the Moss gene samples first and crafted it into the chamber afterwards (also 40 Plastic bars). Steady use comes later (Burner assembling machine MK 02, trains, Intermetallics). | Data (chapter 7); save statistics ([chapter 8](../chapters/08-vrauks.md)) |
| One Smelter MK 01 fed from chests, one Mechanical inserter per chest: 0.197 Duralumin a second, 79 % of full speed, because the recipe takes 1 Aluminium plate a second and the inserter brings 0.789. It burns Naphthalene oil (0.3 MJ): 26.3 a second at that speed, 33.3 at full; the Tar line's 16.5 a second keep one Smelter at half speed. | `tools/rate-probe`, the save of 18:03 (chapter 7) |
| One Duralumin Smelter at full speed (0.25 a second) takes a whole Aluminium plate a second: 10 Aluminium ore, and so 100 Coal gas, in Stone furnaces. The author's Intermetallics line (four Smelters on Gasoline, 8.3 a second each at work) at its full 0.167 a second made the base use 66 Gasoline a second against 27 made. | Data; `tools/rate-probe` on the save of 34:59 ([chapter 14](../chapters/14-intermetallics-trains.md)) |

## Lead, titanium and tin screening

| Fact | Source |
|---|---|
| Lead processing - Stage 1: Automated screener MK 01 5 Lead ore → 1 Lead (grade 1), 3 s; a furnace 4 grade 1 → 10 Lead plates, 40 s. So 2 ore a plate instead of 6 (6 ore → 1 plate, 10 s), 0.25 plates a second a Stone furnace instead of 0.1. One belt of ore (15 a second): nine screeners, 30 furnaces, 7.5 plates a second. The author's block (nine screeners, 30 furnaces, six Fluid mining drills MK 02): 2.9 plates a second, limited by its Acetylene. | Data; `tools/rate-probe`, the save of 27:39 ([chapter 11](../chapters/11-lead-titanium-tin-smelting.md)) |
| Titanium processing - Stage 1: screener 5 Titanium ore → 1 grade 1 + 0.5 grade 2; Jaw crusher 1 grade 2 → 1 Stone + 0.5 grade 1; screener 3 grade 1 → 1 grade 3 + 0.5 rejects; Secondary crusher 1 rejects → 1 Gravel + 0.3 grade 3 (all 3 s); a furnace 5 grade 3 → 10 plates, 25 s. So 5.2 ore a plate instead of 10, 0.4 plates a second a furnace instead of 0.067. One belt of ore (15 a second): nine + four screeners, 4.5 Jaw crushers, 1.9 Secondary crushers, 7.2 furnaces, 2.9 plates a second, 3 Stone and 0.6 Gravel a second to place (the author: three brick furnaces, a Burner). Measured with 6 ore a second: 1.10 to 1.18 plates. | Data; `tools/rate-probe` (chapter 11) |
| Fluid mining drill MK 02 (Electric mining drill technology): mining speed 1, 900 kW electric, against 0.5 and 400 kW of fuel for the MK 01. A drill takes its mining fluid per cycle, so Mining productivity is free ore: lead drills at +10 % mined 6.56 ore a second with 59.0 Acetylene, 10 per cycle of 1.1 ore. | Data; recorder (chapter 11) |
| Add up every drill on one mining-fluid source. The author's acetylene block makes 49.75 a second; six lead drills MK 02 want 60, ten titanium drills 20. With an Overflow valve giving lead first call, the titanium drills stop ("missing required fluid") once the lead plates are all used; they keep their 20 while lead takes at most 29.75, about 1.8 plates a second. | `tools/rate-probe` with the plates taken away (chapter 11) |
| Tin processing - Stage 1: screener 5 Tin ore → 1 Tin (grade 1) + 1 grade 2 at 50 %, 3 s; Jaw crusher 1 grade 2 → 1 grade 1 at 50 % + 1 Stone, 4 s; a furnace 15 grade 1 → 10 Tin plates, 50 s. So 6 ore a plate instead of 10, 0.2 plates a second a furnace instead of 0.067. One belt of ore (15 a second): nine screeners, six crushers exactly, 12.5 furnaces, 2.5 plates a second, 1.5 Stone a second to place. The author's block (13 Fluid mining drills MK 02): 13.48 ore and 2.23 plates a second, 50 Steam a plate instead of 100. | Data; `tools/rate-probe`, the save of 28:02 ([chapter 11](../chapters/11-lead-titanium-tin-smelting.md)) |
| A filter Splitter whose filter side has no belt holds that item back: the author's tin block sends Tin (grade 2) there, so it never reaches the furnace belt and waits on the Splitter for the last Jaw crusher's inserter. In an hour with the plates taken away no grade 2 got past it. | The save of 28:02; `tools/rate-probe` (chapter 11) |
| Drills on both sides of one belt each fill their own lane, 7.5 a second at most. The author's tin mine has five drills MK 02 on one side (6 ore a second) and eight on the other (9.6): 13.48 ore a second, not 15.6; the last drills of the eight-drill side wait for space while the other side always works. The author keeps such extra drills as a reserve for when the first ones mine out (principle 8); waiting, they draw no power: the base's MK 02 drills used 15.9 MW in that hour, just what the working ones need. | `tools/rate-probe` watch points, one-minute steps (chapter 11) |
| Nickel processing - Stage 1: Jaw crusher MK 01 5 Nickel ore → 1 Nickel (grade 1) + 0.5 Stone, 3 s; a furnace 1 grade 1 → 1 Nickel plate, 10 s: 5 ore a plate. One belt of ore (15 a second): nine crushers, 30 furnaces, 3 plates a second, 1.5 Stone. Nickel ore takes Syngas, 4 an ore, and mines in 2 s: an MK 02 drill 0.5 ore a second, 0.6 with Mining productivity 2. The author's block, built for a full belt, has eight drills: 4.80 ore and 0.96 plates a second. | Data; `tools/rate-probe`, the save of 29:51 ([chapter 12](../chapters/12-nexelit-nickel.md)) |
| Antimony processing - Stage 1: screener 10 Antimony ore → 5 grade 1 + 3 grade 2 (+ 2 Stone, 0.3 Iron oxide), 5 s; Jaw crusher 5 grade 1 → 10 grade 2, 5 s; screener 10 grade 2 → 5 grade 4 + 0.8 grade 3 (+ 3 Gravel), 10 s; Secondary crusher 5 grade 3 → 4 grade 4, 5 s; Basic oxygen furnace (burner, 5 MW) 10 grade 4 + 50 Oxygen + 1 Plastic bar → 1 Antimony oxide, 10 s. So 13.64 ore an oxide. The Oxygen comes from an Electrolyzer MK 01 (300 Water → 200 Hydrogen + 100 Oxygen, 10 s, 10 MW): 50 MJ of electricity an oxide, three quarters of the block's power; its 100 Hydrogen (10 MJ) nearly fuel the Antimony drills (any fluid fuel, 1 MW, 1.2 ore a second with Mining productivity 2). | Data ([antimony oxide](antimony-oxide.md)) |
| Every Antimony oxide takes a Plastic bar (Biofactory MK 01: 50 Aromatics + 100 Syngas, 1.5 s): 20 Aromatics a second at 0.4 oxide. The author's Tar line makes 17.2, which the zinc drills had used up (Aromatics as mining fluid, 4 an ore); with Overflow valves putting the plastic first, Zinc ore fell from 5.2 a second to almost nothing. The Electrolyzers' Hydrogen needs a way out as well: above about 0.3 oxide a second the author's only outlet (fluid-fuel machines at y 348) held them back. | Data; recorder; `tools/rate-probe` on the save of 32:40 ([chapter 13](../chapters/13-geothermal-antimony-oxide.md)) |

## Vrauks

| Fact | Source |
|---|---|
| Vrauk paddock MK 01 (12 × 12, 250 kW, speed 0.05, 10 slots): 10 Vrauk cocoons + 15 Native flora + 5 Moss + 3 Water barrels → 2 Vrauks + 3 Barrels, 160 s. Reproductive complex MK 01 (21 × 21, 500 kW, speed 0.5, 2 slots): 10 Moss + 3 Sap + 5 Native flora + 4 Water barrels → 4 to 6 cocoons (5 on average) + 4 Barrels, 40 s. Both take Vrauks as modules (+1 speed each) on a base effect of −1. Full (84 Vrauks in 8 paddocks and 2 complexes): 3 Vrauks and 15 cocoons a minute, the author's plan; measured 28 to 32 Vrauks every 10 minutes. | Data; `tools/vrauk-probe` ([chapter 8](../chapters/08-vrauks.md)) |
| A machine on a base effect of −100 % is limited to −99.99 %: without modules it runs at a ten-thousandth of its speed (a paddock 0.000005). It starts a craft as soon as its ingredients are in, shows "working", and holds them for good (a paddock's craft would take 370 days); its inserters then fill its input again. An empty Vrauk paddock holds 9 Water barrels and 30 cocoons this way. | Engine, a copy of the author's save (chapter 8) |
| Inserters fill a machine's input with two crafts' worth while it works on a third: a paddock holds 9 Water barrels, a complex 12, whether they have Vrauks or not. Eight paddocks and two complexes hold 96; at full output the author's line had 128 barrels in it, 32 in crafts. With 64 it stopped within half an hour; with 96 or 100 it started as fast (all slots in 100 minutes) but at full output the paddocks waited a quarter of the time. | `tools/vrauk-probe` (chapter 8) |
| The first Vrauks: Creature chamber MK 01, 400 s each, from Moss gene samples (Gene lab), Generic earth DNA samples (Data array, 15 red science packs each) and Biosamples (Incubator). The chamber's recipe takes a whole Gene lab: use the lab first, then craft it in. The author's five Vrauks took 245 Duralumin, 680 Titanium plates with the complexes and the Slaughterhouse, and 33 minutes of the chamber. | Data; save statistics (chapter 8) |
| Growth: a Vrauk in a paddock makes 1/1600 of a Vrauk a second, so the paddocks double at best every 18.5 minutes (3 → 80 in 88 minutes); one Vrauk in a complex makes the cocoons for 20 in paddocks. Measured, every new Vrauk put back within a minute: five Vrauks to all 84 slots in 110 minutes. | Data; `tools/vrauk-probe` (chapter 8) |
| The game's production statistics leave barrels out (`ignored_by_stats` on the barrel results of the filling recipes and the Vrauk recipes): count Water barrels by the Barreling machine's finished crafts. | Data; `tools/vrauk-probe` |
| pY science pack 1 (Research center MK 01): 18 Basic substrate + 3 Glassware → 3, 15 s. Per pack 1 Glassware = 2 Rubber stoppers = 1 Latex = 1 Latex slab = 100 Formic acid = half a Caged vrauk (a Slaughterhouse renders one into 200 Formic acid in 10 s). 0.1 packs a second therefore take 3 Vrauks a minute, the whole output of a full line of 8 paddocks and 2 complexes, and keep one Latex furnace (1 Latex per 10 s) busy all the time. | Data; the author's plan; `tools/rate-probe` ([chapter 9](../chapters/09-py-science-pack-1.md)) |
| The Slaughterhouse gives the Cage back with the products: one Cage between the caging assembler and the Slaughterhouse renders 0.05 Vrauks a second (measured for 40 minutes). Per Vrauk it also gives 2 Meat, 2 Guts, 1 Chitin and 1 Brain (stack 100: a Wooden chest holds 1,600, the Meat one full in 4.3 hours at 3 Vrauks a minute). The Burner (first pY science pack 1 technology) burns each of them at 3.3 a second and gives back 1 Ash in 5 (every void recipe has Ash at 20 %). | Data; save of 23:31; `tools/rate-probe` ([chapter 9](../chapters/09-py-science-pack-1.md)) |

## Circuit boards

| Fact | Source |
|---|---|
| Simple circuit board (Electronics - Stage 1, Chipshooter machine): 1 Printed circuit substrate (tier 1) + 3 Vacuum tubes + 3 Air-core inductors + 5 Ceramic capacitors + 6 High-power resistors + 2 Solder + 1 CuZn Battery → 3, 4 s. The substrate needs Formica, Formica Formaldehyde, Formaldehyde Methane (60 → 50), and the only Methane at this stage is a Moondrop greenhouse's (100 Water + 100 Carbon dioxide + 1 seed → 40, 15 s): one greenhouse at speed 1.5 is 4 Methane, 0.033 substrates, 0.1 boards a second. | Data; the author's block, Methane greenhouse busy 100 % for an hour ([chapter 6](../chapters/06-simple-circuit-boards.md)) |
| 0.1 Simple circuit boards a second take from outside: Copper plates 1.13, Iron plates 0.25, Tin plates 0.31, Lead plates 0.27, Zinc plates 0.33, Coke 0.40, Stone bricks 0.83 (Saline water), Logs 0.29, Molten glass 1.67 (Glass 0.17), Creosote 6.7 (Treated wood), Steam 6.4 (Clay). Their Zinc is 13.3 Aromatics: 31 Tar a second through the author's Tar line, more than one Tar refining unit takes (20). | Data (chapter 6) |
| The author's chain after the tidy-up of 16:40 (chapter 6): its pace is the Tar, and the Tar is what the coke block makes for the Coal gas it can hand on (aluminium drills first, then one Gasifier at 16.7 a second, its Syngas into an Exhaust pipe). Measured: 27 Coal gas, 26.7 Tar, 12 Aromatics, 0.30 Zinc plates and 0.1 boards a second while the drills mine; 16.7, 20.4, 8.75, 0.22 and 0.07 once their ore is gone (about 2.5 hours after the save). Nothing stops in either. With a second Gasifier (17:18) the block hands on 23.4 Coal gas a second without the aluminium drills: 28.5 Tar, 12.3 Aromatics, 0.31 Zinc plates, 0.1 boards. | `tools/rate-probe`, two hours and a half hour from 2.5 hours after the save of 16:40 (chapter 6); half an hour from two hours after the save of 17:48 (chapter 7) |
| A stock buys time, not rate: 724 Zinc plates on the bus ran the author's block at 0.120 boards a second for 35 minutes, while the zinc column made 0.15 plates a second against 0.40 used; at 40 minutes the boards fell to 0.01–0.04. | `tools/rate-probe`, an hour after the save of 16:08 (chapter 6) |

## Research

| Fact | Source |
|---|---|
| Steam power and the Automation science pack technology are triggers: make 10 Iron plates / 10 Copper plates. Furnace output counts, from all furnaces together. | Data, engine |
| Plates made before the prerequisite is researched still count. | Engine, `tools/ch1-probe` |
| Mining productivity 1 (+10 %) costs 90 × (red + pY science pack 1) and needs Mining machines - Stage 1. | Data |
| The first pY science pack 1 technologies (Burner, Quartz processing - Stage 1, Electric mining drill, crusher-2, Titanium processing - Stage 1, Raw coal - Stage 1) cost 50 to 55 units of 1 pY science pack 1 + 2 red, 45 s. Five Labs take 0.111 units a second; at 0.1 packs a second each takes 8 to 9 minutes and 0.2 red science a second. | Data ([chapter 9](../chapters/09-py-science-pack-1.md)) |

## Design principles (the author's)

1. **Two belts, one input and one output each.** Each belt beside a machine column carries its
   input on the lane next to the machines and collects an output on the outer lane (inserters
   drop there anyway). Every output inserter is filtered.
2. **Input inserter downstream, separator right after the last machine.** Then nothing is left
   stranded on a belt when supply stops: after draining, 0 ore remained with this placement and 4
   with the opposite one; throughput is the same (engine, `tools/design-lab`).
3. **Separate lanes at the end with an underground belt** and collect into chests.
4. **One dedicated fuel drill per raw coal module.** It feeds a service belt that passes every
   drill and tunnels under the output belt; 9 drills give exactly one full belt. With 8 drills
   the best possible is 14.67/s, because the drills burn 1.33 Raw coal/s themselves; 8 become
   possible only after Mining productivity 1, and then need tapping from the output belt, which
   costs more parts than the drill it saves.
5. **Fuel lines.** A drill row whose output belt U-turns behind it becomes its own service belt
   (coal lands on the inner lane) and can continue as a fuel line (Raw coal + Ash) for other burner
   rows. Raw-coal-filtered inserters take pure coal off such a line.
6. **One fuel tap per smelting column.** A column of 10 furnaces burns 0.667 Raw coal/s; one
   inserter moves 0.83/s from a passing Raw coal belt onto the start of the fuel belt, dropping
   onto its inner lane. A full Raw coal belt fuels about 22 columns.
7. **Opening order.** Handcraft all red science until Wood is mass-produced; automate Iron plates
   (and Raw coal) first. In their second game the author puts drills before belts: early belts
   and inserters are dear, so the first plates become Burner mining drills dropping straight into
   Stone furnaces. From data: a Basic transport belt costs 11 Iron ore + 3 Copper ore per tile
   (1.375 Iron plates + 0.375 Copper plates); a Burner inserter 68 Iron ore + 12 Copper ore, more
   than a Burner mining drill (66 Iron ore + 18 Copper ore + 5 Stone), which mines its iron back
   in 66 seconds on an iron patch.
8. **Smelting unit.** Ore drill rows and a 10-furnace column on one fuel loop; the drill rows cover
   the whole ore strip and hold more drills than needed, because downstream drills take over when
   upstream ones mine out and blocked drills burn nothing. Uneven rows are mined-out spots. A unit
   burns about 2.0 Raw coal/s and takes it with three taps (3 × 0.83/s). The same holds for
   electric drills: a mining drill has no idle drain, so a blocked Fluid mining drill MK 02 draws
   no power ([chapter 11](../chapters/11-lead-titanium-tin-smelting.md#6-tin)).
9. **One column blueprint for every plate.** Plate-side output inserters filtered to everything
   but Ash (blacklist), so the same blueprint smelts iron or copper.
10. **Mall.** Once handcrafting holds you up (in the author's first run: 48 minutes of recipe time
   in 77 minutes, 28.5 of them behind Small parts), assemblers make the building materials into
   chests. Not balanced — every machine just produces; the items needed in very large numbers
   (Transport belts, Mechanical inserters) come first and their bottlenecks are raised later.
11. **Make on the spot what needs nothing or only Water** (Soil, Limestone, Seaweed, Sap, CO2 from
   Moondrop greenhouses, Vacuum, Methane ...): each block that uses one runs its own machines for
   it, so every block balances itself and these items stay off the bus. `rate-plan.js` finds them
   (plan option `local: 'free'`); see [first-save-review](first-save-review.md#5-the-bus-to-trains).
12. **Every byproduct gets a buffer**, so that a consumer that stops cannot jam its producer.
   **Stone travels as Stone bricks**: they stack to 1,000 against Stone's 50 (an iron chest holds
   32,000 bricks, i.e. 64,000 Stone, against 1,600 Stone), and a Jaw crusher turns 4 bricks back
   into 8 Stone where Stone is needed, for some fuel (smelting) and power (crushing). The bus then
   carries half as many items. Plan option `carry` in `rate-plan.js`.
13. **Ash on belts to Solid separators, not into chests.** Every fuel loop and furnace row passes its
   Ash lane on to one Ash belt ending at the separators; their Coal dust goes back into Boilers and
   furnaces, their Soot into Soot separation, their Iron oxide into furnaces, each through a buffer
   chest. Size the separators for the Ash already piled up, not only for what the base makes.
14. **Burn byproduct fuel first** by giving its Boilers one Steam engine more than their steam needs
   (see Steam power). For fluid fuel, by circuit: the author's seven Glassworks get one fuel pipe fed
   by three pumps, each switched by a condition read from the pipes: Hydrogen while there is any,
   Syngas while there is no Hydrogen, stored Gasoline only while there is neither. The two gases had
   been vented before (chapter 8). A pipe holds one fluid, so the fuel changes once the pipe is empty.
15. **Product before disposal.** An Ash loop passes the blocks that need Ash for a product (logs,
   planter boxes) before it reaches the separators, which get what is left.
16. **Priority by circuit.** Where one machine feeds two users, let the second user's inserter run
   only while the first holds enough: the author's forestry passes Logs to the belt only while the
   Wood processing unit next to it holds 2 or more.
17. **A machine is no faster than its inserters.** Before choosing a fast recipe for a machine with
   room for one input inserter, divide: a Stone furnace on Aluminium ore runs at 50 %, on Iron
   oxide at 15 %. Plan the furnaces by inserters, not by recipe time.
18. **Cut long pipelines into segments under 320 tiles.** A Pump or a Check valve at least every
   320 tiles (the span on the map); the author's long Steam, Tar, Aromatics and Acetylene lines
   keep every segment within 320 tiles. A Check valve does it without power wherever the line runs
   from a full source to a consumer. The Acetylene line to the titanium drills (chapter 7): about
   890 tiles past an Overflow valve, cut by two Check valves into segments spanning 254, 311 and 88
   tiles.
19. **Wood for burner buildings that should make no Ash.** The author's third mall burns Wood made
   on the spot from Logs: no Ash to take away, and a Log made into Wood gives five times the heat.
20. **One line's byproduct is the next line's input.** The author's Tar line turns its Pitch and
   Anthracene oil into Coke, and the Coke into the Acetylene the lead drills mine with. What has no
   use yet is stored (liquids in Tailings ponds, a day of play or more) or vented (gases), until
   the circuit boards need it.
21. **Every inserter of a block reaches something.** One input inserter that reached for a pole
   tile where a belt ended early held the author's acetylene block at 86 %; on the bench, one belt
   tile instead made 99 %. Check the end tiles of every belt that feeds inserters.
22. **Overflow by circuit.** Where a product may not be taken, let a belt tile read it and switch
   on a machine that turns the surplus into something stored: the author's coke block turns Coke
   into Tar while 4 or more wait at the belt end. Every other output still needs its own way out:
   with its Coal gas drawn only by four aluminium drills the block runs at 18 % on the bench.
23. **Self-sufficient once a main product is in steady demand.** Build for one main product at a
   time (after red science: circuit boards, planned at 0.1 a second). A line that jams on a
   product nobody uses yet is normal, not a fault. Once the main product's line is complete, the
   whole chain must keep running: no byproduct may jam it, and every product needed steadily is
   decoupled from the others (the author's lead and zinc both hang on the Tar line, in a ratio
   unlike the circuit board's: to be dealt with then). Example: after the Ash processing of
   chapter 3 the map took raw ores and gave Iron and Copper plates and steady red science. The
   board line was complete at 16:08 (chapter 6); an hour of it measured: 40 minutes on the Zinc
   stock, then the boards and, through its Creosote, the Tar line stopped together. After the
   author's tidy-up (16:40: every byproduct a way out, Naphthalene oil and Gasoline stored for
   later technologies) nothing stopped in three hours measured. Chapter 7: while the copper was
   rebuilt (old mine out at 16:45, the screened copper from 17:25) the bus ran out of Copper plates
   and the boards lost about a quarter of an hour, so build the new supply of a main product's
   ingredient before taking the old one away. The screened copper's surplus (3 plates a second,
   1.1 used) filled the bus and chests within two hours, after which the block makes what is
   used: the expected jam on a surplus. Chapter 8: with its Exhaust pipe taken away,
   the Syngas could leave only through Glassworks that stood full; within an hour of the save the
   Syngas Gasifiers filled, and the Tar line, the zinc and the boards ran down to 0.005 a second (an
   Exhaust pipe put back: 0.1).
24. **A one-off need is a batch, not a line.** Before building a line for a new material, look at
   what it is needed for now. Before pY science pack 1 Duralumin is needed once, for the machines
   that start the Vrauks (about 345), so the author made it in one Smelter fed from chests by hand,
   from the Aluminium plates in store, with the Naphthalene oil the Tar line had stored as fuel:
   about 400 in half an hour (chapter 7). The full line, with a new aluminium mine, waits until
   Duralumin is needed steadily.
25. **Items that circulate run on a loop belt** (the author's note: "循环物品形成环带避免堵塞"). The
   author's Water barrels go round one closed belt past the complexes, the paddocks and the
   Barreling machine, so a full machine never stops the belt. Count the containers for every place
   where they wait, not for the recipes alone: two crafts' worth in each machine's input and one in
   work, also in machines that do not run yet; 4 on every Splitter output without a belt; and the
   belts. The author's estimate, twice the barrels of the recipes running at once, gave 64; the line
   starts with 96 but needs 128 to run at full output (chapter 8). And keep the other chains of
   such a block free of dead ends: give a Splitter used as a drop point a filter with the
   Deconstruction planner on its side without a belt.
26. **A line is done when a copy of the save runs it without the player.** The author's pY science
   pack 1 line looked finished and made packs, but its Research center took the Basic substrate from
   a chest filled by hand: the substrate belt ended one tile short. Run without the player, it
   stopped after 6 packs; with one inserter it made 0.1 a second. And let it run long enough to
   reach the rest of the base: what a new line adds to the load (here twice the Ash) shows only
   after the buffers fill, 40 minutes later (chapter 9).

## Fish and nexelit

| Fact | Source |
|---|---|
| Fish in water are map entities: picked by hand (5 Fish each) they do not come back. A lasting supply needs Fish - Stage 1 (Fish farm MK 01, 1 MW): Fish eggs (12 Fish + 50 Phytoplankton + 100 Saline water → 25, 80 s), then Fish (10 eggs + 60 Oxygen + 3 Small lamps + 10 Biomass + 100 Saline water → 10, 150 s): 13 Fish more a round than it takes. The farm's speed comes from Fish as modules: base −100 %, +100 % a Fish, 7 slots (speed 1 when full). Fish oil: 8 Fish → 100 (Slaughterhouse, Water animals - Stage 1). | Data; the author (fish are finite) |
| The author's fish block (save of 34:59) stood for two reasons, one behind the other. Its Electrolyzer's Hydrogen ended at a Pipe to ground with nothing beyond, so it made no Oxygen for the Fish farm. And its Composter, a furnace that works one recipe at a time and takes nothing else until that input is used up, got Wood through an inserter wired to run while the Composter held Biomass = 0, besides the Slaughterhouse's Skin and Bones: the inserter overshot a Wood batch (5 → 30 Biomass), 2 Wood were left over, the Composter waited for 3 more and took no Skin or Bones, the Slaughterhouse's output filled and the Fish farm's after it. With an Exhaust pipe on the Hydrogen, no Wood and a Sinkhole for the Fish oil: 0.067 Fish and 0.42 Fish oil a second (one breeding Fish farm with 7 Fish modules), the plan's rate; Skin and Bones alone gave 0.063 of the 0.067 Biomass a second it used, about 95 % (24.4 of 25 a round by the data). The author's own fix (Hydrogen into the bus's Hydrogen pipe, a second Composter for the Wood alone) measured the same in the save of 35:07. | Data; `tools/wire-probe`; `tools/rate-probe` on the save of 34:59 ([chapter 14](../chapters/14-intermetallics-trains.md)) |
| Raw nexelit before Nexelit processing - Stage 2: Stage 1 unlocks the Dig-o-saurus and its Dig site (7×7, 4 Dig-o-saurus slots, 400 kW drain). A script runs the mining (pyalienlife 3.1.8; the data's 10 s Dig site recipes are only for calculators): every 61 ticks a site sends out at most one waiting Dig-o-saurus, which eats one food, walks to a random Natural nexelit tile in the 25×25 area 16 tiles in front of the site, digs (15 hits, 0.5 s each) and walks back with 2 ore for a Meat, 1 for Guts or Dried meat, 8 for Worker's food. Dig-o-sauruses don't block each other, and a site holding more than 1,000 ore stops. Measured at the author's site (save of 28:53, one Dig-o-saurus of the faster T.U.R.D. version, 0.1026 tiles a tick instead of 0.076, see [T.U.R.D. choices](turd-choices.md); an hour): a trip takes 13.8 s, so each Dig-o-saurus eats 0.072 food a second. Which food it eats depends on what its slots hold: at 28:53 only Guts, at 29:51 (three Dig-o-sauruses) Meat for 20 minutes, then Guts, then Meat again ([chapter 12](../chapters/12-nexelit-nickel.md)). With unlimited food (`tools/dig-probe`, an hour each): four T.U.R.D. Dig-o-sauruses 13.9 s a trip each, one or four ordinary ones 15.8 s, so four in one site make four times the trips of one. A waiting Dig-o-saurus costs nothing (the site's 400 kW is drawn either way). Otherwise Tar quenching (500 Tar → 500 Tailings) and an Evaporator (500 Tailings → 1 Raw nexelit): 1,500 Tar a Nexelit plate. A Dig-o-saurus (Creature chamber, 120 s; the T.U.R.D. version 480 s): 30 Moss gene samples, 10 Generic earth DNA samples (15 red science each), 10 Petri dishes, 50 Titanium plates, 1,000 Saline water. | Data, pyalienlife's script; `tools/rate-probe`, the save of 28:53; the author (biological mining) |
| The author's nexelit line (save of 29:51): three T.U.R.D. Dig-o-sauruses ate 0.215 meals a second in an hour (0.217 possible); a Washer MK 01 turns 3 Raw nexelit + 100 Water into 1 Clean nexelit + 100 Muddy sludge (3 s), a Stone furnace 18 Clean nexelit into 18 Nexelit plates (60 s): 3 Raw nexelit a plate. Food sets the rate: the slaughterhouse's 0.093 Meat and 0.093 Guts a second give about 0.09 plates a second once the stock on the belt is eaten (0.145 on Meat alone). A Dig-o-saurus's 10 Generic earth DNA samples take 100 Biosamples (Incubator MK 01: 1 Bio container + 15 Native flora, 10 s) and 150 red science. | `tools/rate-probe`, the save of 29:51; recorder; data ([chapter 12](../chapters/12-nexelit-nickel.md)) |

## Trains

First plan for trains and robots in quantity: [Trains and robots](trains-and-robots.md).
See [Railways under Pyanodons](py-railway.md): no speed cap in Py (measured top speeds and
braking distances), Ash and empty containers from locomotive fuel, 3.5-tile MK 02/MK 04 wagons,
and one platform layout that serves both 7-tile and 3.5-tile wagons.

| Fact | Source |
|---|---|
| A Locomotive (5 Intermetallics, 25 Duralumin, 4 Brakes MK 01, 4 Shafts MK 01, a Gearbox MK 01, 30 Steel, 2 Steam engines and more) and two Cargo wagons (5 Intermetallics, 10 Duralumin, 2 Brakes, 2 Shafts, 50 Titanium plates each): 15 Intermetallics, 209 Duralumin (160 of it in the 8 Brakes), 10 Shafts (50 s each by hand) and 20 Fish oil. The author handcrafted that set at 34:55. Rails (1 Stone, 4 Bolts, 2 Treated wood, 1 Steel, 5 Solder → 3): two Thermal assemblers MK 02 of Solder (0.33 a second each) make 0.4 rails a second, measured. | Data; recorder; `tools/rate-probe` on the save of 34:59 ([chapter 14](../chapters/14-intermetallics-trains.md)) |
