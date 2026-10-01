# Blueprints

[中文版](README.zh-CN.md)

Import a file's content with the in-game "Import string" button; `book.txt` holds all of them as
one blueprint book (order and label in `book.json`). Every design was built and run in the
engine by `tools/design-lab` (5 minutes of game time, rates measured after the first minute); the
numbers are from those runs. Explanations: [chapter 1](../chapters/01-landing-to-red-science.md).

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

## Syncing with a running game

`tools/companion` is a small mod (no prototypes besides two shortcut buttons) that moves this
folder in and out of the game:

1. `node tools/bp-sync.js push` rebuilds `book.txt` and the mod's `book.lua` from these files.
2. In game, the "Tutorial blueprint book" shortcut (or `/pt-book`) puts the book into your
   cursor. In single player it first reloads the mod scripts from disk (`game.reload_mods()`),
   so a push made while the game runs is picked up without reloading the save.
3. Hold the book (from the inventory or the blueprint library) and press "Export held
   blueprint" (or `/pt-export`); it writes `script-output/py-tutorial-companion/export.txt`.
4. `node tools/bp-sync.js pull` matches the exported blueprints to these files by label,
   rewrites only those whose content changed, adds new ones, reports missing ones (never deletes)
   and pushes again. `--dry` only reports. A changed design has to be measured again before its
   numbers above are trusted.

`tools/check-companion.ps1` checks the round trip in the engine: the book imports cleanly (4
blueprints with their labels and entity counts), an unchanged export pulls as "unchanged", and an
edited one shows exactly the edits (one changed, one relabelled as new plus missing).
