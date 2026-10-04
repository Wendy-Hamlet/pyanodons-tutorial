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

## Lessons

(Numbered in the order they were learned.)

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
   refuses, and the drill stops. Drop into a chest.
10. Fluid outputs of a multi-box machine: read which box holds which fluid after it runs
   (`get_fluid` + `get_fluid_box_prototype`), then pipe; the Distillation column puts Coal gas in
   box 2 (north) and Tar in box 8 (east). Gas vents void Coal gas 20 000 at a time.
11. An assembler created without a recipe ignores the direction it is given; create it with
    the recipe or rotate it afterwards.
12. Aluminium ore needs a Fluid drill (Coal gas); Glassworks burn fluid fuel (10 MW).
9. Upkeep must never empty an assembler's output: the next machine's inserter takes it from
   there. Only furnaces and chests are emptied; input chests are marked so they are left alone.
