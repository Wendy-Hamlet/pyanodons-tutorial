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
with the author's recipes (see [red-py1-factory](red-py1-factory.md) for each part). Items that
leave their block for several blocks:

| Item | From (/min) | To (/min) | Total |
|---|---|---|---|
| Stone | crushing iron 355 and copper 203, mined 1,162 | bricks 960, moss 443, battery 167, latex 150 | 1,720 (2 belts) |
| Ash | burners | wood (logs) 464, red 360; **8,504 left over** | 824 |
| Soil | soil and limestone | red 600, moss 222 | 822 |
| Native flora | mined | red 600, vrauks 188 | 788 |
| Wood | wood | cellulose 495, red 240, PCB 7 | 741 |
| Limestone | soil and limestone | cellulose 283, latex 180 | 463 |
| Iron plate | iron | small parts 210, red 120, components 25 | 355 |
| Moss | moss | vrauks 188, pY1 90, wood 77 | 355 |
| Seaweed | seaweed | petri dish 180, latex 150 | 330 |
| Copper plate | copper | small parts 110, moondrop 33, battery 33, PCB 17, components 10 | 203 |
| Sap | sap | PCB 67, latex 60, vrauks 45 | 172 |
| Cellulose | cellulose | pY1 54, battery 17 | 71 |
| Coke | tar refinery (Pitch) | components 13, ceramic 2 | 15 |

Pipes: Water 95,251/min (1,590/s), Steam 11,917, Tar 2,778 (750 from the plan's own Coal
distillation, the rest from the coke site or Tailings pond), CO2 2,217 (moondrop greenhouses to
moss farms), Creosote 667, Formaldehyde 333, Vacuum 250.

What changes against the first save:

1. **An Ash belt.** The plan burns 155 Raw coal/s (102 for electricity, 33 for process steam,
   21 in burners) and so leaves **9,328 Ash/min**; logs and red science use 824. The rest goes to
   Ash separation: about 14 Solid separators. Their yield is small: per minute 425 Coal dust,
   43 Iron oxide and 170 Soot, and the Soot gives 17 Iron, 17 Copper, 8.5 Aluminium, 8.5 Zinc and
   8.5 Lead ore. Ash separation disposes of Ash; it does not replace the zinc and lead mines
   (the circuits need 333 Zinc and 160 Lead ore per minute).
2. **A metals belt from the outposts.** The circuits need, per minute, 31 Tin, 27 Lead and 33 Zinc
   plate. Smelted at their fields (an outpost cell, like the steel site) that is 91 plates/min,
   a tenth of a belt; as ore it would be 804/min. One item per lane avoids a mixed lane jamming
   when one metal is not taken.
3. **Stone on the bus** instead of bricks in the inventory: 1,720/min, a third of it from
   crushing iron and copper ore.
4. **Every block takes its inputs from the bus or a neighbour**, including Coke and plates for the
   circuit components.
5. **A mall at the end of the bus**: Iron plate, Copper plate, Stone brick, Small parts, Glass and
   circuits are on it already; Steel comes from the steel outpost; Pipes, Steam engines and
   inductors are made in the mall itself ([key intermediates](red-py1-factory.md#7-other-key-intermediates-before-trains)).
   Its burners need a fuel belt, or electric Automated factories.

Power for this factory at full load: 152.9 MW electric, 62.6 MW burner fuel, 316 MW of fuel fluid
for 32 Glassworks.

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
