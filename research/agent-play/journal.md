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
