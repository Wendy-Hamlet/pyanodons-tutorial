# Blueprints

[中文版](README.zh-CN.md)

Import a file's content with the in-game "Import string" button. Every design was built and run
in the engine by `tools/design-lab` (5 minutes of game time, rates measured after the first
minute); the numbers are from those runs. Explanations: [chapter 1](../chapters/01-landing-to-red-science.md).

| File | What it is | Measured |
|---|---|---|
| `raw-coal-module.txt` | The author's raw coal module: 9 Burner mining drills filling one belt | 15.0 Raw coal/s, 1.40 Ash/s into chests |
| `iron-smelting-column.txt` | 10 Stone furnaces on half a belt of Iron ore | 0.91 Iron plate/s, 0.60 Ash/s |
| `copper-smelting-column.txt` | The same column for Copper ore | 0.91 Copper plate/s, 0.60 Ash/s |
| `smelting-column-with-fuel-tap.txt` | The copper column plus the one inserter that takes its fuel from a Raw coal belt | 0.91 plates/s, no furnace ever out of fuel |

## Raw coal module

- Two drill rows face one output belt; each row fills one lane.
- One drill (at the upstream end of a row) feeds only the service belt, which runs behind both
  rows and tunnels under the output belt. Fuel travels on the inner lane; Ash-filtered inserters
  put Ash on the outer lane; at the end an underground belt lets only the Ash lane through into
  two chests.
- To start it, put a few Raw coal into the fuel drill. Needs Raw coal under all 36 drill tiles.

## Smelting columns

- West belt: ore on the lane next to the furnaces, plates on the outer lane. East belt: Raw coal
  next to the furnaces, Ash on the outer lane. Output inserters are filtered.
- Feed ore by side-loading it onto the west belt's first tile from the east; the fuel-tap version
  shows where one inserter takes Raw coal from a belt running past on the east.
- At the top, underground belts let only the outer lanes through; plates go to two chests (one
  Mechanical inserter moves 0.82 items/s into a chest, less than 0.91 plates/s), Ash to one.
