# Agent play journal

Claude playing Py on its own with [tools/agent](../../tools/agent/README.md), from 2026-10-04.
Times are game time (h:mm:ss) unless marked as wall-clock time.

## Setup

- Map: seed 943562787, the author's map generation settings (Py recommended, cliffs off, no enemy
  bases, water coverage 0: Pump Anywhere places offshore pumps on land), pollution off.
- Mods: all Py mods (pyalienlife 3.1.7, pyalternativeenergy 3.2.8, ...) plus the author's helpers.
- Start: Py freeplay items (10 Burner mining drills, 1 Stone furnace, 8 Iron plates, 1 Wood,
  400 magazines) and the Py Quick Start kit (power armor with 4 personal roboports, 100
  construction robots). Reach 160 (Far Reach).
- Near spawn (0,0): Raw coal (-33,-32), 28 M; Iron ore (-48,-29); Copper ore (-17,-44); Stone
  (-44,41); Aluminium ore (-42,57); Bioreserve (-16,41); Quartz (161,-94); Oil sand (-115,140).
  34 trees within 100 tiles; big sand rocks around (-63,-25).

## Timeline

| Game time | What I did |
|---|---|
| 0:00–0:01 | Looted the crashed ship (68 Iron plate, 23 Copper plate, 5 Iron chests); robots cleared 14 rocks and trees in reach (49 Stone, 12 Logs). |
| 0:01–0:03 | Four-drill Raw coal pinwheel (drills feed each other's fuel slots); hand-mined 70 Raw coal (1 s each). |
| 0:02–0:04 | Drill-into-furnace pairs: 5 on iron, 2 on copper; 4 drills on Stone into chests. Steam power done at 3:39 (10 Iron plates smelted), Automation science pack at 4:31 (10 Copper plates). |
| 0:07–0:09 | Fuel was the bottleneck: four Raw coal drills into chests, and one `upkeep` command per round that empties every output and chest in reach and tops up every burner. |
| 0:09–0:12 | 9 iron and 6 copper pairs; two Stone drills moved to iron because Stone piled up (500) while iron ran out. |
| 0:11–0:12 | Power: Offshore pump (facing south: its output is on the opposite side), pipe, Boiler, Steam engine above it, three small poles; worked at the first try. |
| 0:13–0:14 | Logs: only 34 trees within 100 tiles of spawn; ran 230 tiles south (exoskeletons: 45 tiles/s) and let the 100 robots clear two forest cells: 392 Logs in 90 s. |
| 0:14–0:16 | Two labs, Soil extractor (water passes through the Boiler into it), four Stone furnaces making bricks. |
| 0:16–0:22 | Flora collector MK 01 on the Bioreserve (it drops into a chest like a drill); first red packs by hand. |
| 0:26–0:30 | Automation done. A Small parts block: five burner assemblers (Iron stick → Bolts, Iron gear wheel, Copper cable → Small parts) joined by inserters, fed from three chests I fill, output into a chest. |
| 0:30–0:35 | A red science line: Empty planter box → Planter box → Automation science pack, the last inserter feeding a lab, labs passing packs on; I fill the input chests each round. |
| 0:35–0:45 | Coal processing 1, Soil washing, Steel processing done. Explored a 350-tile ring: the near Iron patch is only 257 k (big ones 450+ tiles away). 14 more iron pairs, 6 copper, 6 more Raw coal drills, second Flora collector, labs 3–4. |
| 0:45–0:48 | Raised fuel buffers (drills 30 Raw coal, others 15): plates per round doubled. Three input chests and inserters per red-line machine. |
| 0:48–1:00 | Labs 5–6, south feeders on the red line, storage chests; red science 8–9 packs/min. Glass and Botany done. |
| 1:00–1:12 | Coal block: a Destructive distillation column on the Raw coal patch fed directly by three drills (Raw coal → Coal + Coal gas + Tar), Coal gas to a gas vent, Tar to a Tailings pond; a second column makes Coke from that Coal. Second power unit. |
| 1:10–1:15 | Steel: Advanced foundry MK 01 (Coke + Limestone + Iron ore), Limestone from a second Soil extractor with its own Offshore pump; one iron drill now drops into a chest for ore. A warehouse row of 10 iron chests and `stash_all`. |
| 1:15–1:25 | Aluminium: a Fluid drill on the Aluminium patch, Coal gas from a third Distillation column right next to it (fed with stored Raw coal), its Tar into a second pond, the ore dropped into a Stone furnace. Power cut once: a Boiler holds only 50 Raw coal (40 s at full load), so each Boiler now has two chests and two inserters. |
| 1:25–1:35 | Moss block: Washer (Muddy sludge) and High pressure furnace (CO2 from Coke) piped into the north inputs of a Moss farm (Moss-2, with Stone). Farms run on Moss as modules: one Moss gives speed 0.067, so its output goes back into its module slots. |
| 1:35–1:40 | Third Flora collector, labs 7–8, three more feeders on the first red-line machine: red science 10/min. |
| 1:40–1:45 | A second red science line (three more assemblers, 18 feeders), its packs collected and spread over all eight labs; a third Soil extractor; four Raw coal drills back (coal use had overtaken production). |
| 1:45–2:00 | Wood ran out: the forests near spawn were cut. A survey of the charted map found 300–400 trees per 64×64 cell 400–500 tiles west and south-west; one trip there gave 980 Logs. |
| 2:00–2:18 | Kerogen (2 MJ, a Stone byproduct) now fuels the Boilers through their chests; a second warehouse row. **Red science 15/min**; research reached Electronics. |
| 2:25–2:48 | Iron ran short (red science alone takes ~82 Iron plate/min). Moved 10 copper pairs to the 4.1 M Iron patch 470 tiles north-east as an outpost; every 4th round the character runs there (10 s), collects ~250 plates and refuels with Kerogen. Iron 127/min. Warehouse rows 2–3. |
| 2:48–3:33 | Two self-made outages. Research queue ran empty (7 min lost). Then I switched all burners to Kerogen to use up the stock: Kerogen comes far slower than the burners need, so the red lines ran dry (1.3 packs/min) while their inputs piled up in my inventory. Also the warehouse only took items in: once the Logs in hand were used up, Wood stopped although 1,346 Logs sat in a chest. Fixed with `restock` (takes kept items back) and Raw coal as the fuel again. |
| 3:56 | **pY science pack 1 researched.** Then the red-only technologies that help (Logistics, Ash separation, Copper processing 1, Fluid handling, Kerogen...). |

## Plan from 2:48: belts and black boxes

The author pointed out that I hardly use belts and move everything between chests by hand: every
round is ~60 commands, and any missed item starves something (wood, a full inventory stopping
research). Linked chests would teleport items, so instead each module becomes a black box with
belts in and out: built, left alone for 10 minutes, checked with `factory`/`prod`, then removed
from the round script.

1. Fuel backbone: move tailings pond 1 off the coal patch, place the author's Raw coal module
   (15/s), run a Raw coal belt past the Boilers, brick furnaces, Small parts block and red lines,
   one fuel inserter per burner.
2. Bricks: Stone drills onto a belt into the author's smelting column; Kerogen filtered onto the
   fuel lane.
3. Red science: Soil, Ash, Native flora, bricks, Wood (Wood processing unit from a chest of Logs),
   Iron plate and Small parts arrive by belt; packs go to the labs by belt.
4. Smelting: iron outpost and home patches as smelting columns.

## Belts from 4:20

| Game time | What I did |
|---|---|
| 4:20–4:35 | Red science cell v1 (`tools/agent/designs/red-science-cell.js`, built from ghosts by the robots): Empty planter box → Planter box → pack, each machine on one belt segment above and one below; neighbouring segments flow in opposite directions so they never touch; each segment starts at a port (a belt tile with an inserter behind it, items on the right lane, and one on its right side, items on the left lane). Packs go by belt past eight labs. Only burner inserters exist (long-handed and electric inserters and splitters need circuits). |
| 4:35–4:45 | The three Flora collectors now drop straight onto a belt (78 tiles) into the cell; a Soil extractor of its own, south of the cell, puts Soil on the south belt of the Planter box machine. Old red lines removed. Ports widened where one inserter (0.83 items/s) was the limit: bricks and Ash three inserters each. ~10 packs/min, no chores for Flora and half the Soil. |
| 4:45 | Home iron is running out (13 drills on empty ore): those drills and furnaces moved to the iron outpost, now 29 pairs. |
| 4:50–5:00 | Glass, fully automatic: a Borax mine on the Quartz patch 200 tiles east (Quartz is "borax" category), a 223-tile belt to a Glassworks (Quartz → Molten glass) burning Tar from the tailings pond, a second Glassworks right below it (Molten glass → Glass; its recipe uses its second input box, so it sits where that box meets the first one's output). ~12 Glass/min. |
| 5:00–5:20 | Tin outpost 350 tiles west: Offshore pump → two chained Boilers → three Fluid drills side by side (Steam passes through them) → Stone furnaces (40 ore → 4 plates in 60 s). Copper pairs moved back to unmined ore. |
| 5:20–5:40 | Power station on the Raw coal patch (`designs/power-station.js`): the author's Raw coal module from the blueprint book, its belt past four Boilers with two inserters each, a Steam engine under each. An Offshore pump cannot face west there; its collision box reaches one tile behind it. |
| 5:40–6:20 | Fuel crisis: the Raw coal module only feeds the Boilers, so the old coal drills I had removed were missed by every other burner. Twelve inserters now tap the module belt into iron chests, and nine new drills drop Raw coal into chests (spots found by a script: all four tiles Raw coal, drop tile free). Tin outpost Boilers get iron chests with inserters (a Boiler slot lasts 40 s). |
| 6:00–6:35 | Components workshop (x 0..40, y -60..-34): HPF (graphite, ceramic), Clay pit with its own Boiler (it drops clay through an output port), Vacuum pump right under an Electronics factory (vacuum tubes, then resistors and capacitors), Seaweed crop (needs Seaweed as modules: the first 10 hand-picked from 5 plants in the lake), agar HPF sharing the Clay pit's Steam, Botanical nursery with the Moondrop codex for a Moondrop sample. 90 vacuum tubes, 150 resistors. |
| 6:40 | I switched the second Glassworks to Empty petri dishes and mirrored it to line up its other input: Molten glass got into the shared Tar fuel network just as the Tar ran out, the tailings pond filled with Molten glass, and both Distillation columns stopped (Tar could not leave). Fixed by removing and re-placing the pond, 20 pipes and both Glassworks. |
| 6:45–7:55 | Bootstrapping the circuit board chain. Components for 50 circuits done (capacitors 230, resistors 165, vacuum tubes 94). Saps multiply themselves: the nursery turns 5 Saps into 2 seeds and 5 seeds plus a Planter box into a Sap tree; four Sap extractors with two trees each make 12 Saps/min. Pre-crafted the PCB factory (it contains two Electronics factories and two Distillation columns: ~22 Steam engines in all), Tar processing unit, Pulp mill, Wood processing unit, Moondrop greenhouse, a third Glassworks and HPF. A copper outpost on the 824 k patch at (58,-316), visited with the iron outpost. |
| 7:55–8:15 | Tar stopped reaching the glass: Distillation column 1 stood on "output full" (its Coal, 1.5/s, was only taken by my rounds). It now has two filtered inserters putting Coal on a belt to column 2 and one putting Iron oxide into a chest; columns 2 and 3 got output chests. |
| 8:15–8:40 | Tar refinery at tailings pond 2 (`designs/tar-refinery.js`): Tar processing unit 1 (Tar + Steam from its own Boiler) → Middle oil, Anthracene oil and Pitch into three new ponds, Creosote straight into unit 2, which makes Treated wood from Wood. |
| 8:40–9:10 | Moondrop: Empty petri dishes from the second Glassworks (back on the shared Tar line, unmirrored, nothing contaminated this time), Petri dishes by hand and in an assembler, two Moondrop samples (8 Moondrop). |
| 9:10–9:40 | Methane block (`designs/methane-block.js`), all built by robots from one ghost list: greenhouse 1 grows Moondrop from seeds, a nursery turns Moondrop into seeds (seeds go back to greenhouse 1 and on to greenhouse 2; the Moondrop it returns ride a two-tile belt back into it), greenhouse 2 makes Methane from seeds, Water and CO2 (an HPF burning Coke right under it), an HPF makes Methanal, then Pulp mill (Formica, with Raw fiber from a Wood processing unit), PCB factory with its own Vacuum pump. |
| 9:40–10:30 | Both outposts had run out of fuel: their upkeep used Kerogen, which was gone, and Raw coal could not enter slots still holding a little Kerogen. Upkeep now swaps such fuel out. Greenhouse 1 has its 16 Moondrop modules, greenhouse 2 gets the surplus (7 so far). |
| 10:30–10:45 | Calcium carbide for Acetylene (`designs/carbide.js`): an HPF makes Lime (its CO2 into a gas vent) and hands it by inserter to the HPF below, which makes Calcium carbide. |
| 10:45–11:00 | Lead outpost 600 tiles north-west (`designs/lead-outpost.js`): a Gasifier turns carried Calcium carbide and Water into Acetylene, straight into two Fluid drills → Stone furnaces; a Boiler + Steam engine powers it. It stopped after two crafts: its Slacked lime is a liquid, now drained into a sinkhole. |
| 11:00–11:20 | Zinc, first try: a Distillation column at pond 2 (Tar → Aromatics, Flue gas and CO2 vented) and a 723-tile pipe to the zinc patch 580 tiles south-east, laid by robots in 100-pipe chunks. 5 100 Aromatics filled it to 7 %, the drills got 7 % of their box and never started, a pump in front of them did not help, and the column had drained pond 2. |
| 11:20–11:35 | Zinc, second try (`designs/zinc-local.js`): two columns at the patch, Raw coal → Tar → Aromatics, every pipe a few tiles long; Raw coal is carried there. Zinc plates from the first visit on. |
| 11:35–11:55 | Battery cell (`designs/battery-cell.js`): a Washer turned south feeds Saline water straight into a burner Assembling machine 1, an HPF hands it Cellulose. Treated wood was the next limit (Creosote): TPU 3 turns pond A's Anthracene oil into Creosote and TPU 4 above it makes Treated wood (`designs/creosote.js`). 7 batteries, 13 PCBs, 24 solder. |
| 12:00 | The copper outpost had 1 432 plates waiting in full furnaces: every visit came with 5 000 Raw coal (100 slots) and no room to collect. Outposts now carry what they burn. |
| 12:00–12:30 | Chipshooter (`designs/chip.js`, 20 PCBs + 2 Distillation columns): all seven circuit ingredients from one chest. **First electronic circuits.** Research center MK01 crafted (50 circuits, a micro mine, a column). |
| 12:30–13:00 | Inventory crises: rounds ran upkeep with a full inventory (Raw coal for outposts), so ore chests and coal taps were never emptied and outposts went unfuelled. Rounds now stash first, keep amounts are smaller, and restock refills below three quarters. The Methane greenhouse at 16 modules took every seed and the Moondrop loop died; a second seed greenhouse (`designs/methane-gh3.js`) and 12 modules fixed it. |
| 13:00–13:30 | Titanium outpost (`designs/titanium-outpost.js`, the lead layout moved; four drills). Steel ran out: Iron ore now comes from three home drills and four iron-outpost drills into chests, and a second Advanced foundry. Three output inserters on the Calcium carbide HPF (one moved only a third of its output). |
| 13:30–14:10 | rc-mk01 needs 100 Concrete: Jaw crusher (Stone → Gravel → Sand) and a burner assembler with Water (`designs/concrete.js`), Lime taken from the lime HPF. Poles from Treated wood (no Logs left nearby; the next forests are 600–700 tiles west). rc-mk01 and the Vrauks paddock placed with a Barrel machine (`designs/vrauks.js`): Cocoons are breeding. |
| 14:10–15:10 | Latex block (`designs/latex.js`: Creamy latex washer → latex-slab column, alginate HPF, latex HPF with its own Boiler) and science block (`designs/science.js`: micro mine for Petri dish bacteria, Research center) placed; the slaughterhouse waits for circuits. rc-mk01 and the paddock turned out to need a creature module to run at all. Electronics block (`designs/electronics.js`): Resistor and Capacitor factories and a graphite HPF. |
| 15:10–15:40 | Switching the second Glassworks back from Petri dishes to Glass contaminated the Tar fuel network with Molten glass again; rebuilt pond, pipes and both Glassworks (`designs/glass-fuel-rebuild.js`). Raw coal ran short (52 k/h made, 56 k/h used): nine more burner drills on Raw coal (each nets 0.8/s), iron outpost visited half as often. The warehouse was full (Ash: 558 stacks): 24 iron chests added (`designs/storage2.js`); py-burners for Ash need research. |
| 15:40–16:10 | Glass line 2 (`designs/glass2.js`) by the quartz belt: a Distillation column's Coal gas goes through a Gasifier (Syngas, 0.4 MJ) into two new Glassworks; the Gasifier's Tar into a sinkhole. The first line made 40 Glass an hour. |
| 16:10–16:40 | Duralumin smelter: it burns fluid fuel too (10 MW through one box), so it got its own Syngas plant (a Distillation column + Gasifier, `designs/duralumin.js`). New `boxes` op: each fluid box's recipe filter and connections, read before piping. Tar distiller D8 under D7 and a plastic Biofactory (`designs/plastic.js`): Aromatics + Syngas, 56 Plastic. |
| 16:40–17:00 | Creature block (`designs/creature.js`): Incubator → Data array made two Earth samples (Bio containers, Native flora, red packs taken off the lab belt into a new chest). Slaughterhouse placed. Power: 16 machines on low power, so power station 2 on the eastern Raw coal patch (`designs/power-station-2.js`, a shifted copy of the first, with a 20-pole line). |
| 17:00–17:15 | Jams everywhere: the Moondrop return belt deadlocked the seed nursery (now a chest); the WPU drops Raw fiber through an output position, not its output slot (now a chest); every round crafted 24 Lead into Solder that was not needed; the warehouse was full again (48 iron chests now); three of four Distillation columns stood on full outputs (D2's single input and output inserters, D3's chest left behind by full-inventory upkeeps). |

## Lessons

1. **Taking all fuel out of a pinwheel would stop it for good** (a drill without fuel cannot feed
   the next one). Refill right away; better, never take from a pinwheel's fuel slots.
2. **Fuel logistics come first.** Every burner drill burns 0.17 Raw coal/s; 15 of them plus
   furnaces need about 3/s. Drills into chests plus one upkeep round per minute or two keeps up.
3. **Iron, not copper, limits the start**: a drill costs 8.25 Iron plate and 2.25 Copper plate,
   a Steam engine 29 Iron. Put idle drills (Stone) on iron.
4. Air-core inductors are the item `inductor1`, made by the recipe `inductor1-2` (Iron stick +
   8 Copper cable); the recipe named `inductor1` needs Ceramic.
5. Trees are scarce near this spawn; forests are 200+ tiles away and robots clear them fast.
6. **Fuel buffers must outlast the round.** A Burner mining drill burns 0.167 Raw coal/s, a Stone
   furnace 0.067/s: 6 and 8 pieces lasted 36 s and 120 s, while my rounds took 60–120 s, so half
   the machines stood idle. With 30 and 15 the plates per round doubled.
7. **One inserter is a hard limit**: a burner inserter moves about 0.8 items/s and a red pack
   takes 12 items in its last step (10 Native flora + 2 Small parts), so one input inserter caps
   the line at 4 packs/min. A 3×3 machine takes three inserters per side.
8. A drill on Stone cannot drop into a furnace: Stone comes with Kerogen, which the furnace
   refuses, and the drill stops. Drop into a chest. Likewise a drill whose ore runs out over a
   Raw coal tile starts mining coal, which the full fuel slot refuses: check mixed patches.
9. Upkeep must never empty an assembler's output: the next machine's inserter takes it from
   there. Only furnaces and chests are emptied; input chests are marked so they are left alone.
10. Fluid outputs of a multi-box machine: read which box holds which fluid after it runs
    (`get_fluid` + `get_fluid_box_prototype`), then pipe; the Distillation column puts Coal gas in
    box 2 (north) and Tar in box 8 (east). Gas vents void Coal gas 20 000 at a time. Recipes take
    their fluid input from a fixed box too: the Glassworks' Molten glass → Glass uses box 2.
11. An assembler created without a recipe ignores the direction it is given; create it with
    the recipe or rotate it afterwards.
12. Aluminium ore needs a Fluid drill (Coal gas); Glassworks burn fluid fuel (10 MW), and Tar
    (0.2 MJ) from the tailings ponds is a fine fuel for them.
13. **A warehouse must work both ways**: `stash_all` keeps the inventory free, `restock` brings
    kept items back when they run low. Without the second, a full chest of Logs did not stop the
    Wood shortage.
14. Do not switch a whole factory to a fuel that is produced slower than it is burned; and keep
    the research queue full (a check for "research: none" belongs in every round).
15. **Belts make black boxes; chests make chores.** (The author's advice.) A module fed by belts
    from its producers needs no round at all; every chest port is a recurring task.
16. A Boiler at full load burns 1.23 Raw coal/s: its single fuel slot (50) lasts 40 s. Boilers
    need a belt (Raw coal module) or a chest with an inserter, never hand refills.
17. Mining Tin with Steam is fuel-hungry: the Boilers, not the Fluid drills, set the rate.
18. When a module takes over a resource (the Raw coal module feeding only Boilers), keep a supply
    for everything else: removing the old coal drills starved every other burner.
19. Never switch the recipe of a machine on a shared fluid network (here a Glassworks on the Tar
    fuel line): leftover fluid can end up in the shared boxes and lock every pipe, pond and
    machine on it to the wrong fluid; then only removing and re-placing all of them clears it.
20. Py farms need their own organisms as modules to run at all (Seaweed crop speed 0 without
    Seaweed); the first ones come from the map (Seaweed plants in lakes, picked by hand).
21. **The character is a poor hub.** Everything the rounds move passes through one inventory;
    when it is nearly full, upkeep collects whatever comes first and the rest (here Stone) stays
    behind, so machines downstream starve. Another reason for belts.
22. Only Moondrop makes Methane, and only a Moondrop sample (2 Petri dishes, a Planter box and a
    Codex in a nursery) starts Moondrop: the Petri dish chain (Seaweed → Agar, Glassworks →
    Empty petri dish) comes before Formica and therefore before circuits.
23. **Every by-product needs its own exit.** A Distillation column makes 1.5 Coal/s besides its
    Tar; left to the rounds it fills up and the Tar stops with it. Two burner inserters per
    1.5 items/s.
24. **Glass is a fuel problem.** A Glassworks burns 10 MW, 50 Tar/s at 0.2 MJ, while one
    Distillation column gives 15 Tar/s; an Empty petri dish (50 Molten glass = 25 s of Quartz →
    Molten glass) costs about 1 400 Tar.
25. Moondrop numbers: greenhouse speed 0.0625 × (1 + Moondrop modules); 4 seeds → 4 Moondrop in
    140 s; 5 Moondrop → 7 seeds (+1–3 at 25 %) and 2 Moondrop back (+1–3 at 10 %); seed + 100 Water
    + 100 CO2 → 40 Methane in 15 s. Feeding the returned Moondrop back makes the loop gain ~6.7
    seeds per greenhouse craft instead of 2. One full Moondrop greenhouse can only keep a Methane
    greenhouse at ~70 %.
26. A recipe's k-th fluid ingredient goes into the machine's k-th input box (greenhouse:
    Water west, CO2 south), checked by piping Water to box 1 first.
27. **A fuel slot holding another fuel refuses yours.** The outposts ran on Kerogen until it ran
    out, then starved with Raw coal in my hand; upkeep now swaps the old fuel out.
28. Ash piles up: after ten hours the warehouse held 343 000 of it. Voiding it needs a py-burner
    (titanium); until then, plan chests for waste. And `take all=true` on a burner machine also
    takes its fuel.
29. Check every product's form before building: the Gasifier's Slacked lime is a liquid, the
    Tar distillation's Rich clay an item that fills its output after 51 runs. Each needs its exit
    (sinkhole, gas vent, inserter).
30. **Long pipes do not carry small flows in 2.x.** A pipe segment shares its fluid evenly over
    all its boxes, so machines on it fill only to its level, and a pump slows down with the
    fullness of its input segment. A 723-tile pipe holds 72 700: it needs tens of thousands of
    units before anything arrives. Make fluids where they are used, or barrel them.
31. A Py gas vent's connection faces 90° clockwise from its direction (direction north connects
    to the east); check `fluidbox_neighbours` after placing one.
32. **Carry what an outpost burns, not more.** 5 000 Raw coal took 100 of 180 slots; the next
    outpost's plates (1 432 copper) stayed in full furnaces for an hour.
33. Reach is 161 tiles: a round standing at home cannot feed machines 165 tiles east. Walking is
    cheap (a few seconds), so rounds walk.
34. **The inventory is the round's working memory.** Start every round and every trip by
    stashing; carry only what the trip needs; a nearly full inventory silently skips collections
    and refuelling, and the damage shows up an hour later somewhere else.
35. A loop that feeds itself (Moondrop → seeds → Moondrop) dies when a consumer on the same
    output can take more than the surplus: burner inserters have no priority. Keep the consumer
    below the surplus (fewer modules) or add producers.
36. One burner inserter moves 0.83 items/s: check it against every machine's output, not only
    its inputs (the carbide HPF made 2.5/s).
37. Wood runs out near the base: Logs only come from trees; Treated wood makes poles too
    (`small-electric-pole-2`).
38. **Never switch the recipe of a machine whose spare input box touches a shared network.** It
    happened twice with the Glassworks: on a recipe change the engine moves the old recipe's
    leftover fluid into another unfiltered box of the same machine, here the one connected to
    the Tar fuel pipes, and one pond plus 20 pipes were locked to Molten glass. The only cure is
    to remove and re-place every pipe, pond and machine on that network
    (`designs/glass-fuel-rebuild.js`). Give each recipe its own machine.
39. Py creature buildings (reproduction complex, Vrauks paddock) have a base speed effect of
    -100 %: they do nothing until a creature module is inserted, and the first Vrauks can only
    come from the Creature chamber (genlab, plastic, duralumin, data array, bio samples).
40. **Glass is energy.** Glass-1 makes 10 Molten glass in 5 s at 10 MW and 50 Molten glass make
    5 Glass in another 3 s at 10 MW: about 56 MJ of fluid fuel per Glass, 280 Tar. A circuit
    needs about 1.7 Glass. Coal gas (0.2 MJ) was being vented at 29/s; through a Gasifier it
    becomes Syngas (0.4 MJ per unit, 70 per 50 Coal gas).
41. Read a machine's real fluid boxes before piping it: this Gasifier has two inputs and two
    outputs, one of each with two connections (`get_fluid_box_pipe_connections`), and its Syngas
    recipe also makes Tar. The Glassworks' fuel box shares its positions with a recipe box.
42. A full warehouse hides behind other symptoms: stash_all silently keeps the items, the next
    upkeep stops halfway, and fuel runs out somewhere far away.
43. Machines can have an item drop position like a drill's: the WPU drops Raw fiber on the ground
    below it and stops when that tile is taken. Check `drop_position` / `drop_target` on new
    machine types.
44. Rounds that also craft (Solder, Inductors) quietly eat the inputs another chain is waiting
    for. Craft one-offs by hand and stop.
45. A self-feeding loop with a return path deadlocks when the machine at its centre reports
    "output full": it stops accepting input, so the returned items have nowhere to go.
46. Every machine with more than one solid output needs one output inserter per 0.8 items/s it
    makes, counted over all products (D2: 6 Coke + 1 Iron oxide per 3 s needs three).
