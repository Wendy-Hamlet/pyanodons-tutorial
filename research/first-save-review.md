# The author's first save: what moved by hand, and the bus that replaces it

[中文](first-save-review.zh-CN.md)

The author's first Py game ("Pyanodons", 27.1 hours, 2026-09-30) reached Simple circuit boards
and was about to mine titanium. It worked, but many items travelled in the author's inventory
from chest to chest. This note reads that save with `tools/inspect-save.ps1 -Save Pyanodons
-AllowModChanges` and `tools/manual-links.js`, and plans the bus that would carry those items
instead (`plans/bus-to-trains.js`, solved with `tools/rate-plan.js`).

## 1. The save

- 47 technologies, among them Electronics, Alloys 1, Crusher, Copper processing 1, Ash
  separation, Tar processing, Solder, Moondrop and the T.U.R.D. upgrades of Fastwood forestry
  and Moondrop. pY science pack 1 not yet researched.
- 18,292 entities: 10,828 belts, 2,584 Mechanical inserters, 390 machines with a recipe, 308
  chests. Base area 902 × 960 tiles.
- **124 chests are only ever filled** (someone empties them by hand) and **105 only ever emptied**
  (someone fills them by hand).
- The author carried 4,142 Iron plates, 1,049 Aluminium plates, 699 Stone bricks, 697 Logs and
  620 Glass: the inventory was the mall's supply line.

## 2. What already ran on belts

- A **four-belt spine** along x ≈ -250, from y ≈ 67 north to y ≈ -280: Glass (340 tiles),
  Copper plate (254), Coke (249), Iron plate with Processed iron ore (170). Branches go east to
  the circuit area at y ≈ -210 to -250 (Copper plate, Glass, inductors and capacitors).
- A 915-tile Raw coal trunk along x ≈ -530, plus Raw coal belts feeding the smelting columns.
- Red science, the wood farm, the moondrop greenhouses and the circuit components are fed by
  belts where their inputs come from the spine.

## 3. What moved by hand

| Item | Collected by hand | Topped up by hand | Why |
|---|---|---|---|
| **Ash** | 68 chests holding 349,961 (column ends, boilers) | 50 chests holding 98,395: 37 feed Ash separation, 8 the log farm (log3), 5 the Planter boxes | nothing carries the Ash a burner leaves |
| **Stone** | | 7 chests of Stone bricks (29,818) feed 7 Jaw crushers that turn 4 bricks back into 8 Stone, for 17 Saline-water washers and the moss farms | Stone stacks to 50, Stone brick to 1,000: carried as bricks, 40 times denser |
| **Tin plate** | 3 chests (6,618) at the tin field, 12 furnaces smelting on site | 3 chests (6,062) for capacitors, resistors and Solder | the tin field is about 580 tiles from the circuit area |
| **Lead plate** | 3 chests (1,481) at the lead field | Solder assemblers stocked by hand | about 420 tiles away |
| **Zinc plate** | 3 chests (800) at the zinc field | CuZn battery assemblers stocked by hand | about 630 tiles away |
| **Coke** | | 11 chests (15,236) for resistors, graphite and CO2 | the Coke belt of the spine has no branch to the circuit area |
| Copper and Iron plate | 10 chests of Iron plate at furnaces | 5 chests for the vacuum tubes; 2 Copper cable assemblers stocked by hand | same: no branch |
| Soot separation | its five ores in chests at 4 sites | Soot by hand at 2 of them | outputs not connected |
| Building materials | Aluminium plate 6,400, Small parts 1,000, Steel 500, circuits 355 in chests | | no mall belt |
| Fuel | | the 10 burner assemblers of the mall are fuelled by hand | no fuel belt there |

The effect shows in the machine states: the circuit assembler, both Solder and both battery
assemblers and both Small parts assemblers were waiting for ingredients, 3 of 4 red science
assemblers too, all 4 Soot separators; 10 of 13 lead furnaces were out of fuel.

## 4. Why it happened

1. **The circuit metals are far away.** Tin, lead and zinc fields lay 420 to 630 tiles from the
   base, and the amounts are small (section 5: about 30 plates/min each), so a belt felt
   wasteful; the plates were smelted at the field and carried.
2. **Ash appears everywhere and is wanted in two places.** Every smelting column ends in an Ash
   chest (chapter 1's design), every boiler leaves Ash, and red science, the log farm and Ash
   separation all eat it. No belt collected it.
3. **Branches missing from the spine.** Coke, Iron and Copper plate were on the spine, but the
   circuit area took them from chests.
4. **Stone without a belt.** Saline water (for batteries) and moss need Stone, which came as
   bricks in the inventory.

## 5. The bus to trains

`plans/bus-to-trains.js` joins red science 60/min, pY1 30/min and Simple circuit boards 10/min
with the author's recipes (see [red-py1-factory](red-py1-factory.md) for each part) and the
author's two rules for the bus:

**Rule 1: make on the spot what needs nothing or only Water.** An item qualifies when every input
of its recipe is Water or another such item (`rate-plan.js` finds them, loops included):

| Item | Made in (machines) |
|---|---|
| Soil | red 5 Soil extractors, moss 1.9 |
| Limestone | cellulose 11.8 Soil extractors, latex 7.5 |
| Seaweed | petri dish 13.6 Seaweed crops, latex 11.4 |
| Sap | PCB 14.8 Sap extractors, latex 13.3, vrauks 10 |
| CO2 | moss 0.9 Moondrop greenhouses, formaldehyde 0.4 |
| Methane, Moondrop, Moondrop seeds | formaldehyde (5.6 greenhouses, 0.2 nurseries) |
| Muddy sludge, Creamy latex, Vacuum | moss, latex, PCB and components |

Every block then balances itself and none of these items travels; only Water is piped to more
blocks. Small shares round up per block (two Pressure pumps instead of one).

**Rule 2: Stone travels as Stone bricks.** Every byproduct needs a buffer, so that a consumer that
stops cannot stop the producer, and bricks buffer well: they stack to 1,000, Stone to 50, so an
iron chest (32 slots) holds 32,000 bricks (64,000 Stone) against 1,600 Stone. The iron block's
crushing Stone fills a chest in 3 hours as bricks, in 4.5 minutes as Stone. The iron and copper
blocks smelt their Stone into bricks, the bricks block smelts the mined Stone, and the blocks
that need Stone (moss, battery, latex) crush bricks back, 4 into 8, in Jaw crushers. Cost: 20.3
more Stone furnaces (4.0 MW of fuel) and 7.9 Jaw crushers (7.9 MW), 6.6 more Raw coal/s in all.
In return the bus carries 860 bricks/min instead of 1,720 Stone: one belt instead of two.

Items that then leave their block for several blocks:

| Item | From (/min) | To (/min) | Total |
|---|---|---|---|
| Stone brick | bricks 581, iron 178, copper 102 | red 480, moss 222, battery 83, latex 75 | 860 (1 belt) |
| Ash | burners | wood (logs) 464, red 360; **8,902 left over** | 824 |
| Native flora | mined | red 600, vrauks 188 | 788 |
| Wood | wood | cellulose 495, red 240, PCB 7 | 741 |
| Iron plate | iron | small parts 210, red 120, components 25 | 355 |
| Moss | moss | vrauks 188, pY1 90, wood 77 | 355 |
| Copper plate | copper | small parts 110, formaldehyde 33, battery 33, PCB 17, components 10 | 203 |
| Cellulose | cellulose | pY1 54, battery 17 | 71 |
| Coke | tar refinery (Pitch) | components 13, ceramic 2 | 15 |

Pipes: Water 95,251/min to nine blocks (red 30,000 for its Soil, latex 18,000, cellulose 14,133,
moss 13,304, wood 9,273, ...), Steam 11,917, Tar 2,778 (750 from the plan's own Coal
distillation, the rest from the coke site or Tailings pond), Creosote 667, Formaldehyde 333.

Byproducts that need a buffer (per minute):

| Block | Byproducts |
|---|---|
| iron, copper | Stone 355 and 203, as bricks 178 and 102 |
| coal | Coal gas 1,500, Tar 750 (to the tar refinery), Iron oxide 5 |
| tar refinery | Pitch 3,486, Anthracene oil 2,204, Middle oil 833, Light oil 80, Naphthalene oil 80, Hydrogen 40 |
| latex | Meat 30, Guts 30, Chitin 15, Brain 15, Cages 15 (back to vrauks) |
| every burner | Ash, 9,726 in all |

What changes against the first save:

1. **An Ash belt.** The plan burns 162 Raw coal/s (107 for electricity, 33 for process steam,
   22 in burners) and so leaves **9,726 Ash/min**; logs and red science use 824. The rest goes to
   Ash separation: about 15 Solid separators. Their yield is small: per minute 445 Coal dust,
   45 Iron oxide and 178 Soot, and the Soot gives 18 Iron, 18 Copper, 9 Aluminium, 9 Zinc and
   9 Lead ore. Ash separation disposes of Ash; it does not replace the zinc and lead mines
   (the circuits need 333 Zinc and 160 Lead ore per minute).
2. **A metals belt from the outposts.** The circuits need, per minute, 31 Tin, 27 Lead and 33 Zinc
   plate. Smelted at their fields (an outpost cell, like the steel site) that is 91 plates/min,
   a tenth of a belt; as ore it would be 804/min. One item per lane avoids a mixed lane jamming
   when one metal is not taken.
3. **Stone bricks on the bus** instead of bricks in the inventory (rule 2).
4. **Every block takes its inputs from the bus, a neighbour or its own water-only machines**,
   including Coke and plates for the circuit components.
5. **A mall at the end of the bus**: Iron plate, Copper plate, Stone brick, Small parts, Glass and
   circuits are on it already; Steel comes from the steel outpost; Pipes, Steam engines and
   inductors are made in the mall itself ([key intermediates](red-py1-factory.md#7-other-key-intermediates-before-trains)).
   Its burners need a fuel belt, or electric Automated factories.

Power for this factory at full load: 160.8 MW electric, 66.6 MW burner fuel, 316 MW of fuel fluid
for 32 Glassworks.

**Option: Moss without Stone and Logs without Ash.** With the other Moss recipe (8 per 100 s, no
Stone) and Logs from water only (4 per 3 seedlings), Moss, Wood and Cellulose become water-only
too and leave the bus, which keeps only Copper plate, Stone brick (638/min), Iron plate, Native
flora and Coke; Ash goes to red science alone. The price: 80 Moss farms instead of 28 (1,200 Moss
as modules instead of 420), 23 Fastwood forestries instead of 10, 12 Botanical nurseries instead
of 7, 8 MW more electricity. Set `moss: 'Moss-1'` and `log: 'log2'` in the plan to see it.

## 6. The author's recipes

What the save runs, where an item has a choice (all now in the plans):

| Item | Recipe in the save | Note |
|---|---|---|
| Iron plate | Crusher: 5 Iron ore → 3 Processed + 1 Stone; 3 Processed → 1 plate | 35 furnaces, 12 crushers |
| Copper plate | Screener 5 ore → 1 grade-1 + 2 grade-2; Crusher 2 grade-1 → 1 grade-2 + 2 Stone; Foundry 5 grade-2 → 2 plates | |
| Wood | Logs with Ash (log3), Wood 40 per 4 logs (T.U.R.D.) | |
| CO2 | Moondrop greenhouse from nothing (T.U.R.D.), also Lime and Coke | |
| Coke | Pitch refining and Anthracene cracking (Tar processing), also Coal → Coke | |
| Creosote | Tar refining, plus the Carbolic, Naphthalene and Anthracene oil recipes | |
| Methane | Moondrop greenhouse (CO2 + Moondrop seeds) | 15 greenhouses on Methane |
| Acetylene | Lime → Calcium carbide → Acetylene | for lead and titanium mining |
| Stone | crushing Stone bricks | transport trick, see section 3 |

## Sources

- Save: "Pyanodons" of 2026-09-30 19:13, read with `tools/inspect-save.ps1 -Save Pyanodons
  -AllowModChanges` (it predates the companion mod and Cellforge, otherwise the same mods);
  `tools/manual-links.js` for chests and hand-fed machines, `tools/logistics.js` for belts.
- Plans and numbers: `tools/rate-plan.js` on `plans/bus-to-trains.js`; data from the prototype
  dump (stack sizes, recipes, product chances).
