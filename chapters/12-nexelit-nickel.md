# Chapter 12 — Nexelit mining and nickel smelting

[中文版](12-nexelit-nickel.zh-CN.md) · [Index](../README.md) · Previous:
[chapter 11](11-lead-titanium-tin-smelting.md)

This chapter follows the same recorded run from the save of 28:02 to the save of 29:51. Its
subject is the author's, **nexelit mining and nickel smelting** (蓝坷垃开采与镍矿冶炼): two of the
new materials trains need ([trains and robots](../research/trains-and-robots.md)). Nexelit comes
from a Dig site where Dig-o-sauruses dig it up for food (sections 2 and 3); nickel from a field
of Fluid mining drills MK 02 running on Syngas, crushed and smelted like lead and tin in
[chapter 11](11-lead-titanium-tin-smelting.md) (section 4). Times are game time. Numbers come from
the game's data, from the recorder's 10-minute production windows, from the save of 29:51
(`tools/inspect-save.ps1`) and from an hour of that save, as it stands and with both new plates
taken away (`tools/rate-probe`). The author has not exported blueprints of the new blocks.

The result: **three Dig-o-sauruses make about 0.1 Nexelit plates a second**, as many as the
Vrauk slaughterhouse feeds them: 0.1 Meat and 0.1 Guts a second give 0.3 Raw nexelit, three of
which wash and smelt into one plate. They can eat more (0.217 meals a second), and while the
belt from the slaughterhouse still holds a stock of Meat they make up to 0.145 plates a second.
**The nickel block makes 0.96 Nickel plates a second** from 4.8 ore: its eight drills are the
limit, since its nine Jaw crushers and thirty Stone furnaces have room for a full belt of 15 ore
(3 plates a second). Both blocks keep their plates on a belt that ends in a dead end; nothing
uses either yet.

## The run at a glance

| Game time | What happened |
|---|---|
| 28:02 | Water animals - Stage 1 researched, Assembly 2 next; the save of chapter 11 |
| 28:04–28:10 | A Dig site tried at (14, −188) and at (−170, −222), both taken up again |
| 28:10–28:20 | The belt for Meat and Guts begun along x −98, south from the slaughterhouse (y −379). Robots take up 14 Burner mining drills near the centre (section 6); the author replaces two Electric mining drills on copper at (51.5, 38.5) and (55.5, 38.5) |
| 28:15 | Assembly 2 researched; Creature chamber upgrade next |
| 28:16–28:37 | **Samples for the first Dig-o-saurus**: a Flora collector MK 01 and Incubators MK 01 make Biosamples, a Data array makes Generic earth DNA samples, a Gene lab MK 01 Moss gene samples (around (−14 to 45, 77 to 88)); taken up when ten DNA samples are done |
| 28:24 | Creature chamber upgrade researched (the T.U.R.D. pick Planetary adaptation: the Dig-o-saurus takes four times as long in the chamber, digs 35 % faster); Microbiology - Stage 1 next |
| 28:38–28:48 | A Creature chamber MK 01 at (6.5, −254.5) makes the first Dig-o-saurus (480 s), then is taken up |
| 28:41–28:48 | **The Dig site** at (−102.5, 537.5), the Meat belt finished down to it (916 tiles from y −379 to 538); a Washer MK 01, its Offshore pump and a Sinkhole at (−132, 516); one Stone furnace for Nexelit plates at (−130, 509); belts for the plates (x −89) and the Ash (x −93) north |
| 28:47 | Microbiology - Stage 1 researched; Separation next |
| 28:53 | The save of [trains and robots](../research/trains-and-robots.md) and [T.U.R.D. choices](../research/turd-choices.md): one Dig-o-saurus at work |
| 28:54–29:01 | Samples again for two more Dig-o-sauruses (a second Flora collector, Incubators and Data arrays) |
| 29:00 | Separation researched; Fish - Stage 1 next |
| 29:00–29:20 | **The nickel block** at x −230 to −130, y 13 to 32: nine Jaw crushers MK 01 at y 21.5 and 33 Stone furnaces, handcrafted on the spot, half of them placed by robots, and rearranged by robots at 29:20 |
| 29:25–29:51 | The Creature chamber back at (6.5, −254.5): the second and third Dig-o-saurus |
| 29:26–29:27 | **The nickel mine**: eight Fluid mining drills MK 02 (crafted on the spot) on the Nickel field at (−256, 96) |
| 29:30–29:38 | A Syngas pipe from the fluid bus at x −107.5 to the drills; at (−107.5, 179.5) the bus's Check valve replaced by an Overflow valve |
| 29:43 | Fish - Stage 1 researched; Casting - Stage 1 next. The sample machines taken up |
| 29:45–29:47 | Five Antimony drills MK 01 crafted (25 Electric mining drills and 10 Engine units go into them) |
| 29:51 | The Creature chamber taken up; the save |

Production per second (10-minute windows from the recorder):

| Window ending | Raw nexelit made / used | Clean nexelit | Nexelit plates | Meat made / used | Guts made / used | Nickel ore | Nickel (grade 1) | Nickel plates |
|---|---|---|---|---|---|---|---|---|
| 28:50 | 0.023 / 0.015 | 0.005 | 0 | 0.100 / 0.008 | 0.100 / 0.010 | 0 | 0 | 0 |
| 29:00 | 0.087 / 0.090 | 0.030 | 0.030 | 0.100 / 0.013 | 0.100 / 0.058 | 0 | 0 | 0 |
| 29:10 | 0.070 / 0.070 | 0.023 | 0 | 0.057 / 0 | 0.057 / 0.070 | 0 | 0 | 0 |
| 29:20 | 0.070 / 0.070 | 0.023 | 0.030 | 0 / 0 | 0 / 0.070 | 0 | 0 | 0 |
| 29:30 | 0.072 / 0.075 | 0.025 | 0.030 | 0 / 0 | 0 / 0.072 | 0.027 | 0 | 0 |
| 29:40 | 0.110 / 0.105 | 0.035 | 0.030 | 0.063 / 0.002 | 0.063 / 0.108 | 4.80 | 0.877 | 0.777 |
| 29:50 | 0.143 / 0.145 | 0.048 | 0.060 | 0.100 / 0 | 0.100 / 0.143 | 4.80 | 0.960 | 0.958 |

The furnace smelts Clean nexelit 18 at a time (one craft a minute), so its plates come in steps
of 18 a window. In the windows ending 29:20 and 29:30 no Caged vrauks were made (Cages 0), so the
slaughterhouse made no Meat, Guts or Formic acid, and with no Formic acid no pY science pack 1
either; the dig site lived on the Guts already on its belt. The cause was not traced.

Between the saves of 28:02 and 29:51 the base gained 9 Jaw crushers MK 01 (36 to 45), 34 Stone
furnaces (152 to 186), 8 Fluid mining drills MK 02 (35 to 43), a Dig site, 3 Dig-o-sauruses, a
Washer, a Sinkhole and an Offshore pump; 20 Burner mining drills fewer (145 to 125).

## 1. Technology

Nexelit processing - Stage 1 (24:43, Dig-o-saurus and Dig site, Washer recipe for Clean nexelit,
Nexelit plates) and Nickel processing - Stage 1 (25:12, Nickel (grade 1) and Nickel plates) were
researched long before; see [chapter 11](11-lead-titanium-tin-smelting.md#1-technology). In this
chapter:

| Researched | Technology | What it gives here |
|---|---|---|
| 28:15 | Assembly 2 | Shaft MK01, Brakes MK01, Gearbox MK01 (for the trains) |
| 28:24 | Creature chamber upgrade | The T.U.R.D. pick Planetary adaptation ([T.U.R.D. choices](../research/turd-choices.md)) |
| 28:47 | Microbiology - Stage 1 | on the way to the Fish farm |
| 29:00 | Separation | on the way to the Fish farm |
| 29:43 | Fish - Stage 1 | the Fish farm |

Queue at the save: Casting - Stage 1 (59 %), Coke processing - Stage 1, Hot air - Stage 1, Boron,
Iron processing - Stage 1, Geothermal Power - Stage 1 ([geothermal](../research/geothermal.md)).
Research ran at about 0.1 units a second (0.093 pY science pack 1 a second in the hour after the
save).

## 2. Dig-o-sauruses

A Dig-o-saurus is made in a Creature chamber MK 01: 30 Moss gene samples, 10 Generic earth DNA
samples, 10 Petri dishes, 50 Titanium plates and 1,000 Saline water. With the author's T.U.R.D.
pick (Planetary adaptation) it takes 480 s instead of 120, and digs 35 % faster
([T.U.R.D. choices](../research/turd-choices.md)). The samples are the long part:

| Sample | Machine | Recipe |
|---|---|---|
| Biosample | Incubator MK 01 | 1 Bio container + 15 Native flora, 10 s |
| Generic earth DNA samples | Data array | 1 Iron chest + 15 Automation science packs + 10 Biosamples, 25 s |
| Moss gene sample | Gene lab MK 01 | 2 Petri dishes + 20 Moss, 10 s |

A Bio container is 1 Lead plate, 1 Steel, 1 Glass and 2 Titanium plates; Native flora comes from
a Flora collector MK 01. So one Dig-o-saurus takes 100 Biosamples (1,500 Native flora, 100 Bio
containers) and 150 red science packs for its ten DNA samples. The author built these machines
for the job and took them up afterwards: 30 DNA samples were made and 30 used (ten in each of the
windows ending 28:40, 29:30 and 29:50), and the Bio containers were handcrafted (100 at 28:07,
201 at 28:53). The Creature chamber stood only while it worked, at (6.5, −254.5).

## 3. The dig site and the Nexelit plates

<!-- ![The dig site: the Dig site at the bottom right with its three Dig-o-sauruses, the Meat and Guts belt coming down from the north, the Washer and the Nexelit furnace on the left](../images/ch12-dig-site.jpg) -->

- **Food.** The belt along x −98 brings Meat and Guts from the slaughterhouse at (−31.5, −354.5),
  916 tiles. Two filter inserters, one for Meat and one for Guts, put them into the Dig site at
  (−102.5, 537.5). A Dig-o-saurus walks out, digs and comes back with Raw nexelit: a trip takes
  13.8 s (measured with one, [trains and robots](../research/trains-and-robots.md)), so three make
  0.217 trips a second. By the data each trip eats one meal: a Meat gives 2 Raw nexelit, Guts 1.
- **Washing.** The site drops Raw nexelit on a belt west to a Washer MK 01 at (−132, 516): 3 Raw
  nexelit + 100 Water → 1 Clean nexelit + 100 Muddy sludge, 3 s. Its own Offshore pump gives the
  Water, a Sinkhole takes the sludge. One Washer handles 1 Raw nexelit a second.
- **Smelting.** One Stone furnace at (−130, 509): 18 Clean nexelit → 18 Nexelit plates in 60 s, so
  up to 0.3 plates a second, on Raw coal from a belt from the west. Its Ash goes north on x −93
  into the base's Ash belt; its plates north on x −89 to (−88.5, 188.5), where the belt ends: 324
  tiles that keep about 1,300 plates on their one lane.

So 3 Raw nexelit make a plate, as [trains and robots](../research/trains-and-robots.md) assumed.
The site is limited by food, not by Dig-o-sauruses: the slaughterhouse makes 0.1 Meat and 0.1
Guts a second at most (eight paddocks; and only while pY science pack 1 takes its Formic acid,
[trains and robots](../research/trains-and-robots.md)), that is 0.3 Raw nexelit and **0.1 Nexelit
plates a second**. Three Dig-o-sauruses could eat 0.217 meals: all Meat would be 0.43 Raw nexelit
and 0.145 plates. What they get beyond 0.2 comes out of the stock on the 916-tile belt.

## 4. Nickel

<!-- ![The nickel mine: two rows of four Fluid mining drills MK 02 with the ore belt between them](../images/ch12-nickel-mine.jpg) -->

<!-- ![Nickel crushing: nine Jaw crushers in a row, the ore belt below them and the belt for Stone and Nickel (grade 1) above](../images/ch12-nickel-crushing.jpg) -->

<!-- ![Nickel smelting: two rows of fifteen Stone furnaces, three brick furnaces below, the plate belts ending on the right](../images/ch12-nickel-smelting.jpg) -->

- **Mine.** Eight Fluid mining drills MK 02 in two rows of four at x −270.5 to −255.5, y 75.5 and
  81.5, on the Nickel field at (−256, 96) (30.4 M; 13.7 M under the drills). Nickel ore takes
  Syngas as mining fluid, 4 an ore (the data's 40 per ten). An MK 02 mines 0.5 Nickel ore a second
  (speed 1, mining time 2), 0.6 with Mining productivity 2: **4.8 ore a second** from the eight,
  19.2 Syngas. The Syngas comes from the fluid bus at x −107.5 through about 160 tiles of
  underground pipe; at (−107.5, 179.5) on the bus the author replaced a Check valve with an
  Overflow valve (it passes fluid on only once its input side is 80 % full).
- **Ore belt.** The drills drop on a belt at y 78 that turns north at x −252 and east at y 26,
  under the crushers.
- **Crushing.** Nine Jaw crushers MK 01 at y 21.5, x −229.5 to −173.5, three inserters each from
  the ore belt: 5 Nickel ore → 1 Nickel (grade 1) + 0.5 Stone, 3 s. Nine crushers take 15 ore a
  second, a full belt. Two filter inserters per crusher put Stone and Nickel (grade 1) out, and
  they travel east on one belt.
- **Smelting.** Two rows of fifteen Stone furnaces at y 18 and 24 (x −163 to −135), each row
  between two belts in the author's column layout ([chapter 1](01-landing-to-red-science.md)):
  above it one belt brings Nickel (grade 1) on one lane and takes the plates on the other, below
  it one belt brings Raw coal and takes the Ash. Nickel plate: 1 Nickel (grade 1) → 1 plate, 10
  s: thirty furnaces make 3 plates a second. Three more Stone furnaces at y 30 turn the Stone into
  Stone bricks (2 Stone a brick).
- **Where it all goes.** Plates, Ash and bricks each end on a belt with nothing after it, at
  (−129.5, 23.5), (−129.5, 18.5) and (−129.5, 29.5).

So **5 Nickel ore make a plate**, and the block, built for 15 ore a second, gets 4.8: about ten of
the thirty furnaces and a third of the crushers' time are used. Seventeen more drills would fill
it. Each plate also takes 0.5 Stone (0.25 bricks) and 2 MJ of Raw coal (a Stone furnace burns
200 kW), that is 0.67 Raw coal and 0.67 Ash.

## 5. The hour after the save

An hour of the save of 29:51 (`tools/rate-probe`), once as saved and once with the Nickel plates
taken off the end of their belt (−129.5, 23.5) and the Nexelit plates off theirs (−88.5, 188.5):

| | As saved | Plates taken |
|---|---|---|
| Nickel ore | 4.80/s until minute 50, then the drills wait | 4.80/s all hour |
| Nickel plates | 0.92–0.94/s for 30 minutes, 0.73 in minutes 30–40, 0.07, then 0 | 0.96/s all hour (1.11 taken, the belt's stock included) |
| Nickel furnaces | full output 76 % of the time | working 96 % |
| Raw nexelit | 0.343/s | 0.343/s |
| Meat / Guts eaten by the dig site | 0.128 / 0.087 a second | same |
| Nexelit plates | 0.115/s | 0.115/s made, 0.105 taken |
| Slaughterhouse | Meat and Guts 0.093/s each; full output 49 % | same |
| Power | 108 MW in the first ten minutes, 59 MW in the last (87.4 MW on average); always met | 108 MW to 70 MW (89.1 MW) |

- **Nickel**: as saved, the plate belt and the furnaces' output slots fill in about 40 minutes and
  the block stops: nothing uses Nickel plates yet. With the plates taken it makes 0.96 a second
  all hour; the crushers wait for ore 68 % of the time.
- **Nexelit**: the dig site ate 0.215 meals a second, its three Dig-o-sauruses' 0.217: in the first
  20 minutes Meat (0.217 a second, the stock on the belt), from minute 30 to 50 Guts, at the end
  Meat again. The slaughterhouse made 0.093 Meat and 0.093 Guts a second meanwhile, so the stock
  on the belt goes down; after it, the site gets what the slaughterhouse makes, about 0.09 plates
  a second.
- **Power** falls all hour in both runs, as stores fill (the base's demand, not a shortage).
  The nickel block adds about 10 MW while it runs: 7.2 MW for its eight MK 02 drills (900 kW
  each) and 2.9 MW for its Jaw crushers (1 MW each while crushing, a third of the time).

Things that will stop the nickel block later, while nothing uses its products (the author's
rule: a jam on a product nothing uses yet is normal, [techniques](../research/techniques.md)
principle 23):

- **Ash has no way out.** The Ash lanes of both fuel belts were full at the save; since then each
  working furnace keeps its own Ash (36 to 52 in them at the save). A Stone furnace's burnt slot
  holds 1,000, and a busy one makes an Ash every 15 s: about four hours of work.
- **Stone bricks** likewise: their belt is full and the first brick furnace held 117 bricks. A
  brick furnace's output slot holds 1,000; at the 0.24 bricks a second of the present ore the
  three hold about three hours, then the Stone backs up into the crushers and they stop.

## 6. Other changes

- **Burner drills taken up**: robots took up 14 Burner mining drills at 28:18–28:19 and 6 more at
  29:34, with their inserters: 15 on the iron field near the centre (x 39 to 57, y −16 and −13)
  and 5 on the copper field at (53 to 57, 27 to 30). Their ore was running out: of the 35 iron
  drills left, 2 had less than 1,000 under them at the save.
- **Two Electric mining drills** replaced on copper at (51.5, 38.5) and (55.5, 38.5) (28:19).
- **Antimony drills**: five Antimony drills MK 01 crafted at 29:45–29:47 (each takes five Electric
  mining drills and two Engine units), for the next block: [Antimony oxide](../research/antimony-oxide.md).

## 7. Checklist

- Nexelit without a mine: a Dig site, Dig-o-sauruses and food. 3 Raw nexelit (a Meat and a half,
  or three Guts) make a plate through a Washer and a Stone furnace.
- The food decides the rate, not the number of Dig-o-sauruses: three eat 0.217 meals a second, the
  slaughterhouse gives 0.2.
- A Dig-o-saurus costs ten Generic earth DNA samples: 100 Biosamples and 150 red science. Build the
  sample machines for the batch and take them up again.
- Nickel: Fluid mining drills MK 02 on Syngas (4 an ore), 5 ore → 1 Nickel (grade 1) in a Jaw
  crusher, 1 → 1 plate in a Stone furnace. Like lead and tin, every stage built for 15 ore; more
  drills later.
- Fuel by-products need a way out too: Ash and bricks collect in the furnaces' own slots for a few
  hours, then the furnaces stop.

## 8. How these facts were checked

- Recording: the companion's recorder (run `2652821414-0`, last line 29:51), read with
  `tools/recorder-phases.js` (10-minute slices), `tools/recorder-summary.js` and
  `tools/recorder-log.js` (production windows, minute lines for where machines went); no chat
  notes in this part.
- Save of 29:51 (`Py-Exploration`, copied to `C:\tmp\ch12` first; consistency check passed):
  `tools/inspect-save.ps1 -Ticks 3700`, `tools/summarize-save.js`, `tools/trace-layout.js` (belts,
  what each machine takes and gives, fluid segments), `tools/render-area.js`; the snapshot's
  furnace slots for the Ash and brick counts.
- Data: recipes, machines, mining times and fluids (`tools/q.js`, data export of 2026-10-18).
- The hour after the save: `tools/save-probe.ps1 -Probe rate-probe -Ticks 219700 -Variant
  '60,3600,600,<items>'`, once as saved and once with `+sink@-129.5:23.5;sink@-88.5:188.5`
  (both plate belts emptied every tick).
- Pictures: not taken yet; the areas are planned with `node tools/shots.js plan`.

Next: chapter 13 (to come).
