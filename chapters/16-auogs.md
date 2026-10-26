# Chapter 16: Auogs

[中文](16-auogs.zh-CN.md) · [Contents](../README.md) · Previous:
[Chapter 15](15-train-preparation-1.md)

This chapter follows the same recorded game from the save of 41:05 to the save of 43:42. The
author named its theme: **Auogs**. Batteries take Melamine and Cyanic acid; at this stage both
come only from Urea, Urea from the Manure of Auogs, and an Auog paddock works only with Auogs
inside it. So before the battery line the author built everything the first Auog needs, made one,
and bred more from it. On the way the base needed a little Rubber, Boron trioxide and Hot air, and
the Stone for research ran short. Times are game times. The numbers come from the game data, the
recorder's 10-minute production windows, the author's Factory Planner drafts, and the saves of
41:07 and 43:42 (`tools/inspect-save.ps1`, and `tools/rate-probe` for an hour of each); the
analysis behind the Rubber decision is in [Trains and robots](../research/trains-and-robots.md),
section 7.

Conclusions:

- **The first Auog is the hard one.** The Creature chamber makes it from 3 cDNA and samples; the
  three cDNA take 9 Laboratory instruments, and those take 45 Rubber and 4.5 Boron trioxide; its
  Retroviruses take 150 Hot air and its samples 145 red science packs. Every later Auog grows from
  pups, with no Rubber at all.
- **One Auog was enough.** The Creature chamber ran from 43:11 to 43:17; from its one Auog the
  Reproductive complex and the paddocks made 69 pups and 46 more Auogs by 43:42. 33 are in the
  author's inventory and 4 in the one paddock on the ground; the battery draft needs about 26.
- **Rubber in a small line.** The author cut the draft from 60 to 15 a minute after the analysis
  (one Rubber takes 100 Aromatics; the base makes about 17 a second). It made 69 Rubber; its Latex
  goes in by hand.
- **Boron trioxide** from Raw borax mined at the west end of the rail network and Electrolyzers set
  up for the purpose: 30 made, then the Electrolyzers were taken up again.
- **Hot air** from a new block: Raw coal into Coke in High pressure furnaces, their hot Coke oven
  gas heats bricks, the bricks heat Pressurized air. Measured with a taker: 9.3 Hot air a second,
  and 5 Coke a second more for the base. Only three Retroviruses needed it; it stands full now.
- **Stone**: research had run short of it. The author's fix at 41:10–41:30 also ended the run-down
  measured in chapter 15; the save of 43:42 runs the whole hour without the player.

## At a glance

| Game time | What happened |
|---|---|
| 41:05 | Save after chapter 15 |
| 41:05–41:07 | The Aromatics Overflow valve becomes a Check valve (chapter 15); save at 41:07 |
| 41:08 | Chat note: "发现缺石矿" (Stone is short) |
| 41:10–41:30 | **Stone for research**: 8 Electric mining drills on the Stone field at (14, 30), 12 Stone furnaces for bricks at (−46, 30); Burner mining drills on iron east of the base replaced by Electric mining drills |
| 41:20–41:30 | 4 Flora collectors on Native flora at (28, 75); a Data array placed; handcrafted 24 Bio containers, 5 Auog codices, Lamps and Tinned cable |
| 41:30–41:50 | Gene labs and an Incubator at (−57, −396); the Data array moved to (−56, −418) |
| 41:39 | Renewables - Stage 1 researched; next Advanced combinators |
| 41:50–42:00 | The Zogna bacteria line at (−40, −390): Seaweed crop facilities, a High pressure furnace for Agar, Glassworks for empty Petri dishes, a Pressure pump, an Incubator |
| 42:00–42:10 | Biofactory for Plasmids at (−33, −399) |
| 42:10–42:20 | **Boron trioxide**: a Crystal mine on Raw borax at (436, −40) with a Washer and a Sinkhole, Syngas piped 400 tiles east to it; Electrolyzers and a High pressure furnace at (−107, −101) |
| 42:17 | Advanced combinators; next Warehousing; 42:24 Warehousing; next Construction robotics |
| 42:25 | Chat note: "理清思路！还需要橡胶和热气，少量" (Thought it through: Rubber and Hot air are needed too, a little) |
| 42:20–42:40 | The Electrolyzers taken up (30 Boron trioxide made); **Hot air block** at (−50, 262) built from a blueprint |
| 42:40–43:00 | **Rubber line** at (−150, −244): Reformer, Pressure pump for Vacuum, Multi-purpose cracker, Heavy oil refinery |
| 42:50–43:10 | 12 Laboratory instruments handcrafted; Retroviruses in an Incubator beside the Hot air block, cDNA in Gene labs |
| 43:10 | Construction robotics researched; next Cooling tower 1 |
| 43:11–43:17 | **Creature chamber** at (−17, −399): the first Auog |
| 43:12–43:40 | Reproductive complex at (−49, −422), a Barreling Machine for Water barrels, Auog paddocks placed and moved |
| 43:20–43:40 | Handcrafted for the battery line: 4 Washers, 2 Mixers, 2 Bioreactors, 4 Storage tanks, a Tailings pond; 7 Moss farms |
| 43:40 | The 7 Moss farms placed at y −440 |
| 43:42 | Save (`Py-Exploration`, 43.7 hours) |

## 1. Why Auogs come before Batteries

The Battery (Battery - Stage 1; Chemical plant, 10 s) takes Glass, 2 Melamine, a Lead antimony
alloy, 3 Bolts, 3 Graphite, 3 Zinc plates and 30 Cyanic acid (data). At this research Ammonia and
Cyanic acid come from one recipe only, Urea decomposition (20 Urea → 30 Ammonia + 30 Cyanic acid),
and Melamine needs both. Urea comes from Liquid manure and Zogna bacteria in a Bioreactor, Liquid
manure from Manure, and Manure from Auog paddocks.

The author's Factory Planner draft for Batteries (43:11) makes 6 a minute and needs 6.46 Auog
paddocks with 4 Auogs each, about 26 Auogs. It leaves 180 Ammonia a minute that nothing uses: like
the gases of chapter 15 it needs an outlet, or Urea decomposition stops and the Batteries with it.

**A paddock runs only with Auogs inside.** The Auog paddock MK 01 has crafting speed 0.5, four
module slots that take only Auogs, and a base effect of −100 % speed (data): with no Auog it
stands, each Auog adds 0.5. The Reproductive complex MK 01, which breeds the pups, is the same with
two slots, and its pup recipe takes no other module. So the first Auog has to come from a Creature
chamber.

## 2. The first Auog

What one Auog takes (data; machines as the author used them):

| Product | Machine | Takes |
|---|---|---|
| Auog (300 s) | Creature chamber | 2 Generic earth DNA samples, 5 Biosamples, 3 cDNA, an Auog codex, Bear DNA samples, 1,000 Water |
| Bear DNA samples (300 s) | Data array | Generic earth DNA samples, 100 red packs, 5 Auog codices |
| Generic earth DNA samples (25 s) | Data array | an Iron chest, 15 red packs, 10 Biosamples |
| Biosample (10 s) | Incubator | a Bio container, 15 Native flora |
| cDNA (10 s) | Gene lab | a Retrovirus, Plasmids, a Laboratory instrument, 5 Biosamples, 5 Incubated petri dishes, 5 Moss gene samples, 3 Glassware, 4 Basic substrate |
| Retrovirus (5 s) | Incubator | 4 Vrauk cocoons, Steel, a Petri dish, Glassware, a Laboratory instrument, 50 Hot air |
| Plasmids (8 s) | Biofactory | 20 Zogna bacteria, an Incubated petri dish, Glassware, a Laboratory instrument |
| 2 Laboratory instruments (7 s) | by hand | 3 Optical sets, 2 Equipment chassis, 5 Small parts, 10 Rubber |
| 3 Optical sets (3 s) | Glassworks | Boron trioxide, 100 Molten glass |

Each cDNA holds three Laboratory instruments: its own, the Retrovirus' and the Plasmids'. **One
Auog: 9 Laboratory instruments, so 45 Rubber and 13.5 Optical sets, which take 4.5 Boron trioxide;
150 Hot air for its three Retroviruses; 50 Biosamples and 145 red science packs.** The author's
production counters between the two saves show exactly one Auog's worth: 3 cDNA, 3 Retroviruses,
3 Plasmids, 3 Generic earth DNA samples, 1 Bear DNA sample, 50 Biosamples, 6 Auog codices; 12
Laboratory instruments (three to spare), 45 Optical sets, 30 Boron trioxide and 69 Rubber.

The workshop for it was temporary. Gene labs, Incubators, the Data array, the Creature chamber and
the Reproductive complex stood around (−50, −400) and, for the Retroviruses, beside the Hot air
block at (−65, 256); at 43:42 they are all back in the inventory. The Zogna bacteria line stays: the
battery line needs it for Urea.

## 3. Rubber: a small line

![The Rubber line at 43:42: left the Heavy oil refinery; in the middle the Multi-purpose cracker with the chimney of its Exhaust pipe for Steam, and to its right the Pressure pump for Vacuum; right the Reformer, making Carbon black from Anthracene oil; the small chests hold Carbon black, Latex, Titanium plates and the Rubber. Above, the Coke boilers; below right, the Creosote unit of chapter 15](../images/ch16-rubber.jpg)

One Rubber (Heavy oil refinery, 4 s) takes 50 Polybutadiene, 2 Carbon black and a Latex;
Polybutadiene (Multi-purpose cracker, 2 s) is 200 Aromatics, 1,000 Water and a Titanium plate for
100, with 1,000 Steam besides; Carbon black (Reformer, 2 s) is 200 Anthracene oil and 100 Vacuum
for 4. So one Rubber costs 100 Aromatics, 100 Anthracene oil, 50 Vacuum, half a Titanium plate and
a Latex (data).

The author's first draft (42:23) made 60 a minute, which needs 100 Aromatics a second; the base
made 17.2 (recorder, 41:40–42:20). After the analysis in the research note the draft was cut to
15 a minute (42:45): one refinery, with the Reformer and the cracker working a quarter of the time.
Rubber is needed only a few times so far: 45 for the first Auog, and later about one per green
science pack.

It stands at (−150, −244), near the Anthracene oil: the refinery at (−160.5, −244.5), the cracker
at (−149.5, −242.5) with its own Offshore pump and an Exhaust pipe for its Steam, a Pressure pump
for Vacuum and the Reformer at (−136.5, −245.5). Titanium plates and Latex go into chests by hand.
It made 69 Rubber, 60 of them for the 12 Laboratory instruments; at 43:42 the Latex chest is empty
and 9 Rubber wait in the output chest.

## 4. Boron trioxide

![The Raw borax outpost at (436, −40), 43:42: the Crystal mine on the borax field (bottom) gets Syngas by the pipe from the west; its Raw borax goes up into the Washer, whose Borax waits in the chest above it and whose Muddy sludge flows into the Sinkhole on the right](../images/ch16-borax.jpg)

The chain (data): Raw borax (Crystal mine MK 01, with Syngas) → Borax (Washer, with Water; Muddy
sludge besides) → Diborane (Electrolyzer, Borax and Hydrogen) → Boric acid (Electrolyzer, Diborane
and Water) → Boron trioxide (High pressure furnace, 200 Boric acid and a Coke). By the author's
draft one Boron trioxide takes 2.67 Raw borax and 66.7 Hydrogen.

The nearest Raw borax lies at x 400–464, y −48 to −16 (about 19 million), at the west end of the
rail network. The author put one Crystal mine there at (435.5, −40.5), a Washer, an Offshore pump
and a Sinkhole for the sludge, and brought Syngas from the nickel drills' pipe 400 tiles east along
y −25.5. Three Electrolyzers and a High pressure furnace stood at (−107, −101), beside the bus.
The mine dug 493 Raw borax; 30 Boron trioxide came out, and at 42:20–42:30 the Electrolyzers and
the furnace were taken up again. 15 Boron trioxide are left in the inventory; the mine and the
Washer stay, full.

The Optical sets come from Glassworks: one Boron trioxide and 100 Molten glass make 3 (with Hot
air, 4); 45 were made.

## 5. The Hot air block

![The Hot air block at 43:42: four Electric mining drills on Raw coal (bottom right) feed three High pressure furnaces; their Coke leaves on the belt below, their hot Coke oven gas rises into three Regenerative heat exchangers that heat Stone bricks; the bricks go round the belt loop to the fourth exchanger at the top, which makes Hot air with the Pressure pump's air; the chimney is the Exhaust pipe for the spent gas](../images/ch16-hot-air.jpg)

The author's blueprint "11.25 hot air", with the note "启动后把木箱拆除" (take the wooden chest away
once it runs):

- 3 High pressure furnaces: 10 Raw coal → 4 Coke + 20 Coke oven gas at 250 °C (2 s), the Raw coal
  from 4 Electric mining drills at (−39, 281);
- 3 Regenerative heat exchangers: 5 Stone bricks and 100 Coke oven gas of at least 250 °C → Warm
  stone bricks (8 s), the gas leaving at 100 °C through an Exhaust pipe;
- one more: 20 Warm stone bricks + 150 Pressurized air → 150 Hot air + 20 Stone bricks (2 s), the
  bricks going round again; Pressurized air from a Pressure pump.

The wooden chest holds the bricks that start the round; the author adds: "需要50石砖来启动（全部机器配方的两倍）"
(it takes 50 Stone bricks to start, twice the machines' recipes). **Measured** (`tools/rate-probe` on the save
of 43:42, with an Exhaust pipe placed on the Hot air pipe as a taker): 9.25 to 9.5 Hot air a second
against 11.25 on the label, 25 Coke oven gas and 1.25 Warm stone bricks a second; the Coke the base
made rose from 9.7 to 14.7 a second. The Hot air exchanger waited for bricks 88 % of the time (it
takes 20 at once), the furnaces worked 83 %.

Only the three Retroviruses needed Hot air, 150 units in all, so at 43:42 the block stands full.
Hot air also improves two recipes the author already has (Hot air - Stage 1): 50 Molten glass with
50 Hot air make 7 Glass instead of 5, and an Optical set recipe gives 4 instead of 3.

## 6. Breeding

![The Auog corner north of the base, 43:42: at the top the seven new Moss farms, not yet powered; in the middle the Auog paddock with its four Auogs and, left of it, the Barreling Machine for Water barrels; at the bottom the Zogna bacteria line: Glassworks for Molten glass and empty Petri dishes, assemblers for cable, Lamps and Petri dishes, the Pressure pump, the Incubator, the High pressure furnace for Agar and two Seaweed crop facilities](../images/ch16-auog.jpg)

The Reproductive complex MK 01 (21 × 21 tiles) makes pups: 20 Native flora, 10 Moss and 5 Water
barrels → 2 to 5 Auog pups and the empty barrels (15 s). The paddock raises them: 4 pups with the
same food → 2 to 4 Auogs (160 s). With n Auogs inside, either machine runs at 0.5 × n: a paddock
with four turns 4 pups into about 3 Auogs every 80 seconds (data).

The Creature chamber stood from 43:11 to 43:17, long enough for one Auog (300 s). Then came the
Reproductive complex, a Barreling Machine for the Water barrels and the paddocks. The recorder
counts pups and Auogs made: 4 and 1 in the window to 43:20, 28 and 8 to 43:30, 37 and 38 to 43:40.
From one Auog to 47 took about 25 minutes.

At 43:42 one paddock stands at (−26, −419) with 4 Auogs, maturing, full: nothing takes its Auogs
out. 33 Auogs and 6 paddocks are in the inventory. The 7 Moss farms at y −440 are placed but not
yet powered: their Moss is for the paddocks' Manure (the draft has 6.46 Moss farms with 15 Moss
each).

## 7. Stone, research and the run-down of chapter 15

![Stone for research, 43:42: right, the eight Electric mining drills on the Stone field and rows of chests; the Stone runs west on the long belt to the twelve Stone furnaces (left), which make bricks of it. Above, the Jaw crushers and screeners of the copper screening; at the bottom the tops of the aluminium drills](../images/ch16-stone.jpg)

The author's note at 41:08 says Stone is short. The recorder shows what it did:

| A second, window to | 40:30 | 40:50 | 41:10 | 41:30 | 41:50 |
|---|---|---|---|---|---|
| Stone made | 8.4 | 6.3 | 4.7 | 16.7 | 17.8 |
| Red packs used | 0.185 | 0.137 | 0.010 | 0.080 | 0.213 |
| Molten glass made | 9.6 | 8.1 | 2.9 | 5.9 | 15.0 |
| Syngas used | 32.8 | 27.2 | 14.3 | 19.2 | 51.5 |

The author explains it: the Stone for research came from crushing, as a byproduct of the
circuit-board and Intermetallics lines, and both stood; research also takes Glass, and the
Glassworks that make its Molten glass burn Syngas and Hydrogen (chapter 8), the biggest Syngas
users. The fix: 8 Electric mining drills on the Stone field at x 0–28, y 18–41, and 12 Stone
furnaces at y 30 that make bricks of it.

This also ended the run-down of chapter 15. The save of 41:05 was taken while research stood, so a
copy run without the player stopped its coke block within 40 minutes. In the game the author found
the shortage three minutes after the save and fixed it by 41:30: the Glassworks burned Syngas again,
the Gasifiers took the Coal gas, and from the window to 41:20 on, Tar stayed at 34 to 50 a second up
to 43:40.

## 8. What stands at 43:42

- **Research**: 119 technologies; Cooling tower 1 at 72 %, then Domestication - Stage 1,
  Fiberboard, a tile technology, Mycology - Stage 1, Starch - Stage 1 and Cottongut - Stage 1: the
  way to the green science pack, which needs Solidified sarcorus (Cottongut) and Mycology.
  Construction robotics is done; the author still carries the 100 Construction pynobots MK 04.
- **The Auog corner** in the north (y −380 to −445): the paddock, the Zogna bacteria line and the
  new Moss farms.
- **For the battery line**, in the inventory: 4 Washers, 2 Mixers, 2 Bioreactors, 4 Storage tanks
  and a Tailings pond (handcrafted 43:20–43:40).
- **Zinc**: the 12 zinc furnaces at y 199 make plates since about 41:15; the base made 0.34 to 0.72
  Zinc plates a second in every window from 41:30, about 0.4 since 42:00 (recorder).
- **Unchanged**: the rail network as at 41:05, not joined to the base; the T.U.R.D. picks (the Moss
  farm upgrade is still not picked).

## 9. The hour after the save

The save of 43:42 run for an hour without the player (`tools/rate-probe`):

| A second (10-minute steps) | 10 min | 20 | 30 | 40 | 50 | 60 |
|---|---|---|---|---|---|---|
| Coal gas made | 39.4 | 38.4 | 26.8 | 27.6 | 27.7 | 27.2 |
| Tar made | 33.9 | 34.2 | 33.9 | 34.3 | 34.3 | 34.2 |
| Coke made | 9.7 | 9.8 | 9.4 | 9.5 | 9.5 | 9.5 |
| Syngas used | 13.3 | 23.8 | 37.6 | 37.8 | 37.8 | 37.5 |
| Power used (MW) | 91.6 | 86.5 | 84.0 | 79.8 | 78.0 | 77.2 |

It holds. The Gasifiers stop half the time (53 % "full output") on their Tar, the limit of the Tar
pipe found in chapter 14, not on Syngas. The zinc furnaces fill after 20 minutes (their plates have
no user yet), the paddock stays full and the Hot air block stands: blocks waiting for their users,
which is normal in this base.

## 10. The blueprints

- **New**: `hot-air` ("11.25 hot air"), the Hot air block of section 5, measured at 9.3 Hot air a
  second with a taker. The book now holds 46 blueprints.
- Still waiting: the author's supply station 固体供货站-1 (chapter 15), until Batteries make
  Cybersyn requests possible.

## 11. Key points

- In Py the first animal of a kind is expensive and the rest are cheap: one Auog takes 45 Rubber,
  4.5 Boron trioxide, 150 Hot air and 145 red packs; from it the Reproductive complex and the
  paddocks bred 46 more in 25 minutes.
- Paddocks and the Reproductive complex have −100 % speed of their own and run only with their
  animals inside; one animal is enough to start.
- An intermediate needed only a few times gets a small line (Rubber, 15 a minute) or a temporary
  one (the Electrolyzers for Boron trioxide, taken up again).
- Research can hold up the coke block: the Glassworks that make Glass for research burn the Syngas.
- Exhaust pipes and Sinkholes empty batches of 20,000; "no ingredients" there only means the next
  batch is filling.

## 12. How these facts were checked

- The saves of 41:07 and 43:42 (`Py-Exploration`, copied to `C:\tmp\ch15` and `C:\tmp\ch16`;
  consistency check passed): `tools/inspect-save.ps1 -Ticks 3700` and `tools/summarize-save.js`;
  their production counters compared for the Auog chain; T.U.R.D. picks with
  `tools/save-probe.ps1 -Probe turd-probe`.
- The recorder: `tools/recorder-phases.js` in 10- and 2-minute slices, and its windows of Stone,
  packs, Molten glass, Syngas, Auogs and pups.
- The author's Factory Planner drafts 电池 (43:11), 橡胶 (42:23 and 42:45), 热气 (42:25) and
  三氧化二硼 (42:13): `tools/planner-summary.js`.
- The Hot air block: `tools/rate-probe` on the save of 43:42 with `py-gas-vent@-61.5:253.5:north` as
  the taker (the other three directions do not connect).
- The hour after the save: `tools/save-probe.ps1 -Probe rate-probe -Ticks 219700`.
- Data facts: `tools/q.js`, `tools/recipe-tree.js battery-mk01 --techs save`, and the machines'
  effect receivers and module categories in the data dump.
- Screenshots: taken by the author with the companion (`/pt-shots`), areas planned with
  `node tools/shots.js plan`.

Next chapter: chapter 17 (to come): Batteries.

