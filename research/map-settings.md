# Map settings: Py's preset and the author's edits

[中文版](map-settings.zh-CN.md) · [Index](../README.md)

What Py's recommended map preset sets, how the author changed it in their first game
("Pyanodons", 2026-09-30) and again in their second ("Py-Exploration", 2026-10-07, Factorio
2.1.21), and what each change does to the map.

Sources: the preset is `pycoalprocessing/prototypes/map-gen-presets.lua` (identical in
pycoalprocessing 3.1.5 and 3.1.7); both saves were read with `tools/inspect-save.ps1`, which
records the full map generation and advanced settings; the effects were **measured** on three
maps created with the second game's seed (2652821414) and `--map-gen-settings`, observed by
`tools/newgame-observer` (resources and terrain within 320 tiles of spawn) and a one-off probe
counting water tiles out to 960 tiles. Consumption figures are the first game's cumulative
production (27.1 game hours).

To play the second game's map, paste [map-exchange-string.txt](map-exchange-string.txt) into
the new-game screen's map exchange string import (it carries the seed and every map and advanced
setting; mods are separate). It was read from the save with `game.get_map_exchange_string()`
and parsed back with `helpers.parse_map_exchange_string`: same seed, same autoplace controls,
same moisture bias.

## 1. The preset

- Starting area 4. Every ore: frequency 0.33, size 0.75, richness 4. Py's single deposits
  (`*-rock`, volcanic pipe, sulfur patch, geothermal crack and the like): frequency 0.33,
  richness 5. Water: frequency 0.75, size 0.75. Cliffs: interval 80, richness 3. Enemy bases:
  frequency 0. Trees are left at the defaults.
- Advanced: pollution off; enemy evolution time factor 2e-8, destroy factor 0.001, pollution
  factor 0; expansion on, at most 2 chunks, every 60 to 180 minutes.
- When a player is created Py warns if the enemy base size is above 0, or the stone richness is
  1 or less (`pycoalprocessing/control.lua`, `on_player_created`).

## 2. The author's edits

| Setting | Preset | First game | Second game |
|---|---|---|---|
| Enemy bases (frequency, size) | 0, default | 1/6, **none** | 1/6, none |
| Water coverage | 0.75 | **none** | none |
| Cliffs (size) | 0.75 | **none** | none |
| Iron ore, copper ore, stone (size) | 0.75 | 0.75 | **6** |
| Raw coal (size) | 0.75 | 0.75 | **1.5** |
| Trees (frequency, size) | 1, 1 | 1, 1 | **3, 1/3** |
| Rocks (frequency, size) | 0.33, 0.75 | 0.33, 0.75 | **3, 1/3** |
| Starting area moisture (frequency, size) | 0.33, 0.75 | 0.33, 0.75 | **6, 1/6** |
| Moisture bias | 0 | 0 | **−0.5** |

Everything else matches the preset, including all advanced settings of the second game (the
first game's report only kept expansion on and tech price 1). Both games also show the same
small offsets from the preset: frequency 1/3 instead of 0.33, deposit richness 4 instead of 5,
and richness 1 on controls that have no richness slider (bitumen seep, rocks, moisture). Being
identical in both games, they most likely come from how the map dialog loads the preset
(inferred, not verified).

## 3. What the edits do

Same seed, within 320 tiles of spawn (nearest = distance from spawn to the centre of the
nearest chunk holding it):

| | Py preset | First game's settings | Second game's settings |
|---|---|---|---|
| Iron ore | 0.55 M (389 tiles), nearest 23 | 0.55 M | **6.6 M** (2,134 tiles), 23 |
| Copper ore | 0.45 M (209 tiles), 51 | 0.45 M | **4.1 M** (926 tiles), 51 |
| Stone | 0.29 M (112 tiles), 51 | 0.29 M | **2.3 M** (510 tiles), 23 |
| Raw coal | 76.6 M (1,564 tiles), 51 | 76.8 M | **137.5 M** (2,666 tiles), 51 |
| Other ores | — | same | same (aluminium 7.7 M at 23, nickel, lead, molybdenum…) |
| Trees | 10,368, about 8,080 of them living | 10,371 | **227, all dead** |
| Rocks | 126 | 138 | 50, sand rocks only |
| Grass tiles | 1,958 | 1,958 | 0 (red desert and dirt) |
| Water tiles within 320 / 640 / 960 | 1,978 / 82,193 / 330,832 | 1,978 / 1,978 / 1,978 | 1,979 / 1,979 / 1,979 |
| Cliffs, enemies | 0, 0 | 0, 0 | 0, 0 |

Water coverage "none" leaves only the starting lake. Size 6 on an ore multiplies the amount
near spawn by 8 to 12, not just the area.

## 4. Why (inferred from the first game)

The author has not stated the reasons; each is matched to what the first game shows.

1. **Basic ores, size 6.** The first game used 1.1 M iron ore, 0.48 M copper ore and 0.22 M
   stone in 27 hours; under the preset all the iron and copper within 320 tiles of spawn
   (0.55 M, 0.45 M) is less than that, and the first game already had 9 drills on exhausted
   ground and only 0.45 M copper left under its 18 copper drills. Now the area holds 6, 8.5 and
   10 times the first game's whole use, within 51 tiles. The other ores were left alone: their
   use is small next to the preset's patches (aluminium: 89 k used, 7.7 M at 23 tiles).
2. **Raw coal, size 1.5.** Not for the amount (the preset's 76.6 M is 35 times the first game's
   2.2 M) but for room: 70 % more tiles means more drill spots, and the first game ran 103
   drills on raw coal.
3. **Fewer trees and rocks, a dry start.** Pollution is off in the preset, so trees absorb
   nothing; they only stand in the way of a base that reached 18,292 entities over 902 × 960
   tiles. The first game grew its Logs in a wood farm (8 Fastwood forestries) and made 45.8 k
   Wood in all. Rocks are obstacles too, and stone now has a large patch at 23 tiles.
4. **No lakes, cliffs or enemies** (kept from the first game). With `pump-anywhere-fork`
   offshore pumps work on land, so lakes are only obstacles; cliffs block building; with no
   enemy bases the evolution and expansion settings do nothing, and no defence is needed.

## 5. Consequences to plan for (from data)

- **Logs.** Dead trees give 1 Log each, living trees 2 Logs and 1 Sap: about 230 Logs are left
  within 320 tiles (109 Dead grey trunks, 118 desert dead trees), against about 18,400 under the
  preset. The wood farm (technology Wood processing) starts from Wood: 5 Wood → 4 Tree seeds;
  1 Tree seed + 5 Moss + 100 water → 3 Tree seedlings (Botanical nursery); 3 Tree seedlings → 3
  to 6 Logs (Fastwood forestry, recipes log1 to log3).
- **Moss.** Besides the moss farm itself, Moss only comes from mining rocks (big rock, huge rock,
  big sand rock: 1 Moss at 10 %). A Moss farm MK 01 runs at −100 % speed until a Moss module is
  inside; each one adds +100 %, up to 15. The 50 rocks within 320 tiles give about 5 Moss on
  average (the preset's 126 about 13), so every Moss from a rock counts: one starts a farm,
  whose output goes back in as modules.
- **Sap** comes from Sap extractors (and later from sap trees), not from cutting trees.
- **Tidal power plants** (pyalternativeenergy) need water tiles: only the starting lake has them.
