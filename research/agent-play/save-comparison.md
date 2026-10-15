# Two Py games side by side: the author's "Pyanodons" and my agent game

[中文](save-comparison.zh-CN.md)

The author's first Py game (save "Pyanodons", 27.1 hours, see [first-save-review](../first-save-review.md))
and the game I played myself through `tools/agent` (2026-10-04 20:40 to 2026-10-05 20:06, 23.2
game hours, [journal](journal.md)). Both were read with the same save inspector and the same
summaries, so the numbers below compare like with like.

## 1. Same start, different maps

Both games use the Py quick start and the author's edit of Py's map preset: starting area 4, no
cliffs, no enemy bases (enemy base size set to none; expansion is switched on but has nothing to
expand), no lakes besides the starting lake (water coverage none), tech price 1; I copied the
author's map settings (see [map settings](../map-settings.md)). The seeds differ (1247658814 and 943562787), so the maps do
too: my base sat on a 27 M Raw coal patch 34 tiles from its centre, the author's nearest patches
were Iron (6 M, 72 tiles) and Raw coal (34 M, 176 tiles).

## 2. The numbers

| | The author | Me |
|---|---|---|
| Game time | 27.1 h | 23.2 h |
| Technologies researched | 47, none running | 64, Electric mining drill at 80 % |
| pY science pack 1 | not researched, 0 packs | 93 packs; first at 19:06, first pY1 technology (py-burner) at 22:10 |
| Entities | 18,292 | 2,754 |
| Machines with a recipe | 390 | 106 |
| Belts (+ underground) | 10,828 (+692) | 491 (+8) |
| Inserters | 2,584 | 257 |
| Chests filled only by machines (emptied by hand) | 124 | 97 |
| Chests emptied only by machines (filled by hand) | 105 | 82 |
| Hand-served chests per machine | 0.59 | 1.69 |
| Boilers / Steam engines | 89 / 27 | 19 / 13 |
| Steam per hour | 304 k | 117 k |
| Base extent | 902 × 960 | 823 × 867 |

Production per game hour (machine-made only):

| Item | The author | Me |
|---|---|---|
| Iron plate | 7,471 | 4,180 |
| Copper plate | 2,254 | 2,299 |
| Coke | 3,473 | 1,915 |
| Stone brick | 3,481 | 2,657 |
| Tin plate | 581 | 227 |
| Aluminium plate | 323 | 92 |
| Steel plate | 135 | 70 |
| Glass | 164 | 107 |
| Moondrop | 164 | 34 |
| Wood | 1,688 | (hand-crafted) |
| Native flora | 1,006 | 3,244 |
| Automation science pack | 87 | 259 |
| Simple circuit board | 21 (579 in all) | 17 (402 in all) |
| Titanium plate | 0 | 64 |
| pY science pack 1 | 0 | 4 (about 40 an hour at the end) |

My character has no player attached, so what it crafted by hand does not appear in the
statistics (Wood, belts and buildings read 0 there); those rows cannot be compared.

## 3. Two strategies

**The author built wide.** Many machines per product (35 iron furnaces, 20 Soil extractors, 20
Sap extractors, 38 Moondrop greenhouses, 8 Fastwood forestries), a four-belt spine and 10,800
belts. Raw material throughput is 1.8 to 3.5 times mine, and most drills stand on "waiting for
space": mining is ahead of use, so a busy chain does not starve the others. Ash goes through 11
Solid separators (Ash separation). Its weak spot, from the first-save review: the inventory was
the mall's supply line. The creature line had not started yet (Biotech, Genetics and Land animals
were available).

**I built a path.** One machine per step, chosen backwards from pY1: circuits at 12:20, the
Creature chamber at 18:40, the first Vrauks at 18:50, pY1 packs at 19:06. Everything not on a
belt was moved by a scripted round every one and a half game minutes (walk, stash, upkeep,
restock, about a hundred feed lines). That reached pY1 packs at 19 hours, which the author's
game had not reached at 27, but:

- throughput stayed small: most lines make a fraction of the author's (Iron plate 56 %, Steam
  38 %, Aluminium 28 %, Moondrop 21 %); only red science, Native flora and titanium are ahead;
- every shortage cascaded: copper, Wood, limestone, titanium, Raw coal each stopped something
  far away, and most fixes paused feeds in the round instead of adding producers;
- I researched technologies faster than I used them: Ash separation was done at 3:56, yet Ash
  went into chests for eighteen hours, waiting for py-burner;
- the factory is not a black box: it stops the moment the rounds stop.

## 4. What each game shows the other

For the author's next game, from mine:

- **The pY1 path is the Vrauks chain**: Creature chamber → first Vrauks → paddock with 10 Vrauks
  as modules → caged Vrauks → slaughterhouse → Formic acid → latex slab → Latex → Stoppers →
  Flasks. The chamber needs titanium, duralumin, plastic and 30 circuits, so titanium and the
  duralumin smelter come early.
- **Glass is fuel.** About 56 MJ of fluid fuel per Glass; Coal gas through a Gasifier becomes
  Syngas at twice the energy per unit (and some Tar).
- The red science cell fed by Flora collectors on a belt made three times the packs per hour.

For me, from the author's game:

- **Belts and parallel machines make black boxes.** 179 hand-served chests each need a line in
  a round; a belt from producer to consumer needs nothing.
- **A wood farm** (Fastwood forestries and Wood workshops, 1,688 Wood per hour) instead of
  logging trips; my Wood ran out twice, and each time the fix was a trip to a forest 400 to
  700 tiles away.
- **Overbuild the basics**: 20 Soil extractors kept the author in limestone; my three ran short at
  21:40 and stalled the latex step, the narrowest part of the pY1 chain.
- **Ash separation** disposes of Ash from the red-science age on: a Solid separator MK 01 takes
  10 Ash per second (three py-burners together take 10).

## 5. The author's advice for the next game

- Play with a long-term goal and short-term goals. The early long-term goals are three: red
  science, Simple circuit boards, pY1.
- Do not rush research. Each unlocked technology becomes one finished black box before the next
  is chased; labs standing idle for a long time are normal.
- Get rid of Ash with Ash separation.

## 6. My techniques and lessons

The 53 numbered lessons are in the [journal](journal.md#lessons); grouped:

1. **How the agent played.** One RCON batch per round worked well: walk, `stash_all`, `upkeep`
   (empty outputs, top up fuel, swap a blocking fuel out), `restock`, feeds. Designs as ghost lists
   that the 100 robots build (`tools/agent/designs/`) made every module repeatable. Reading the
   game paid off most where my guesses were wrong: the `boxes` op (each fluid box's recipe filter
   and connections) and a one-line status per batch. What did not work: chests as ports (each is
   a standing order) and the character as the hub (a nearly full inventory silently skips
   collections; stash first, carry only what the trip needs).
2. **Burner era.** Fuel comes first; fuel buffers must outlast a round (30 Raw coal per drill, 15
   per furnace doubled the plates); one burner inserter moves 0.83 items/s, which caps whole lines;
   every by-product needs its own exit (Coal from a distillation column, Rich clay, Slacked lime).
3. **Fluids in 2.x Py.** Read a machine's real fluid boxes before piping (merged boxes, filters,
   two-connection boxes); long pipes do not carry small flows (a segment shares its fluid evenly);
   never switch the recipe of a machine on a shared fluid network (it locked a fuel network to
   Molten glass twice; remove and re-place instead); a Py gas vent connects 90° clockwise from its
   direction.
4. **Py chain facts.** Creature buildings run at -100 % until a creature module is inside; the
   first Vrauks only comes from the Creature chamber; three pY1 packs cost two Vrauks at first, a
   paddock with ten Vrauks makes about 45 packs an hour downstream. Moondrop farms keep a loop only
   when no consumer takes more than the surplus.
5. **Management.** Use what is researched before researching more (see section 5); count stocks
   without feed chests; carry to an outpost what it burns;
   switch off chains that served a finished goal (paused circuits still ate Wood, idle HPFs still
   ate Coke).

## 7. At the same point: the author's second game at 23 hours

The author's second game ("Py-Exploration", seed 2652821414, recorded from the start; chapters 1
to 9 of the tutorial) reached pY science pack 1 at the same game time as mine. Both saves stand at
23 hours with 63 and 64 technologies and the first pY science pack 1 technology (Burner) under way
or just done. Read the same way as section 2:

| | The author's second game (23:31) | Me (23:03) |
|---|---|---|
| Game time | 23.5 h | 23.1 h |
| Technologies researched | 63, Burner at 75 % | 64 (Burner done at 22:10), Electric mining drill at 80 % |
| pY science pack 1 | 48 packs, the first in the window ending 23:30; a line built for 0.1 a second (360 an hour) | 93 packs, the first at 19:06; about 40 an hour at the end |
| Entities | 27,404 | 2,754 |
| Machines with a recipe | 343 | 106 |
| Belts (+ underground) | 19,889 (+979) | 491 (+8) |
| Inserters | 2,355 | 257 |
| Chests | 124 | 438 |
| One-way chests (filled or emptied only by hand) per machine | 0.17 (36 + 21) | 1.69 (97 + 82) |
| Boilers / Steam engines | 96 / 28 | 19 / 13 |
| Steam per hour | 530 k | 118 k |
| Labs | 5 | 16 |

Production per game hour (machine-made only; totals in brackets where they say more):

| Item | The author's second game | Me |
|---|---|---|
| Iron plate | 8,579 | 4,215 |
| Copper plate | 3,989 | 2,318 |
| Coke | 9,985 | 1,931 |
| Stone brick | 4,843 | 2,679 |
| Tin plate | 681 | 229 |
| Aluminium plate | 158 | 93 |
| Steel plate | 198 | 71 |
| Glass | 251 | 108 |
| Titanium plate | 239 | 64 |
| Moondrop | 74 | 34 |
| Moss | 852 | 273 |
| Wood | 4,586 | (hand-crafted) |
| Native flora | 2,053 | 3,271 |
| Automation science pack | 177 | 261 |
| Simple circuit board | 106 (2,499 in all) | 17 (402 in all) |
| Duralumin | (400 in all) | (433 in all) |
| Vrauks | (117 in all) | (61 in all) |
| Glassware | (50 in all) | (96 in all) |
| pY science pack 1 | (48 in all) | (93 in all) |

What the two show:

- **The same point by opposite routes.** I made my first packs four hours earlier, one machine per
  step and a scripted round to carry everything else; the author made them four hours later, with
  every step built as a belt-fed line sized for 0.1 packs a second. Their base is ten times mine in
  entities and makes 1.5 to 6 times as much per hour (Coke 5 times, boards 6, Titanium 3.7, Moss 3);
  I am ahead only in red science, Native flora and the count of packs so far.
- **The same chain and the same narrow step.** Both games found the path Creature chamber → Vrauks →
  Slaughterhouse → Formic acid → Latex → Rubber stoppers → Glassware, and in both the Vrauks set the
  pace: my one paddock made about 2 Vrauks every 320 s (about 40 packs an hour); the author's 8
  paddocks and 2 complexes make 3 a minute, exactly the 0.1 packs a second they planned.
- **Both had a hand in the loop at the end.** Mine everywhere (179 one-way chests, every one a line
  in the round); the author's in one place, the chest of Basic substrate at the Research center,
  because its belt ends one tile short (chapter 9).
- **Ash.** I let Ash go into chests for eighteen hours and voided it with three Burners at the end.
  The author separated it from the start, but once the pack line runs the base burns twice the Raw
  coal, and the loop of Ash separation and Soot separation stops the Boilers and the power within an
  hour (chapter 9); the Burner they are researching is the same way out I took.

## Sources

- The author's save "Pyanodons" of 2026-09-30 19:13 and my save `C:\tmp\cf-agent\saves\agent.zip`
  of 2026-10-05 20:09, each read with `tools/save-inspector` in its own mod setup (the author's
  loaded with exactly its mods and settings); summaries by `tools/summarize-save.js` and
  `tools/manual-links.js` (`PT_SAVE_SNAPSHOT` points them at a snapshot folder).
- Per-hour figures: the saves' cumulative item and fluid production divided by game time.
- Timeline and lessons: [journal](journal.md).
- Section 7: the author's save "Py-Exploration" of 2026-10-15 (game time 23:31), read the same way in its
  own mod setup (consistency check passed); events from the recorder and the tutorial's
  [chapter 9](../../chapters/09-py-science-pack-1.md).
