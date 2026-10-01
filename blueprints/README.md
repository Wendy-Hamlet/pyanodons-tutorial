# Blueprints

[中文版](README.zh-CN.md)

The pictures are in-game screenshots of the designs running in `tools/design-lab`
(`tools/take-screenshots.ps1`; the infinity chests and loaders at the edges are the lab's
sources and sinks, not part of the blueprints). Import a file's content with the in-game
"Import string" button; `book.txt` holds all of them as one blueprint book (order and label in
`book.json`). Every design was built and run in the engine by `tools/design-lab` (5 minutes of
game time, rates measured after the first minute); the numbers are from those runs. Explanations: [chapter 1](../chapters/01-landing-to-red-science.md).

| File | In game | What it is | Measured |
|---|---|---|---|
| `raw-coal-module.txt` | 15 [Raw coal] | The author's raw coal module: 9 Burner mining drills filling one belt | 15.00 Raw coal/s, 1.40 Ash/s into chests |
| `smelting-column.txt` | 0.94 [Iron plate][Copper plate] | The author's smelting column: 10 Stone furnaces on half a belt of ore, for iron or copper | Iron and copper each: 0.91 plates/s, 0.60 Ash/s, no mixed items, 0 ore left after the supply stops |

## How the blueprints are labelled

- **Name:** the theoretical output per second (from the recipe and belt numbers, not the
  measurement) followed by the main product's icon, written as rich text, e.g.
  `15 [item=raw-coal]`.
- **Icons:** chosen by what the design does (the product, or the products it can make).
- **Description:** what goes in and comes out, how to start it, and the measured numbers, in
  English and Chinese. The game keeps only the first **500 bytes** of a blueprint description
  (Chinese characters take 3 bytes each), so `tools/bp-sync.js push` refuses longer ones.

## Raw coal module

![Raw coal module running in the design lab](../images/raw-coal-module.jpg)

- Two drill rows face one output belt; each row fills one lane.
- One drill feeds only the service belt, which runs behind both rows and tunnels under the
  output belt. Fuel travels on the inner lane; Ash-filtered inserters put Ash on the outer lane;
  at the end an underground belt lets only the Ash lane through into two chests.
- To start it, put a few Raw coal into the fuel drill. Needs Raw coal under every drill. Near the
  edge of a field the full module may not fit; the author's run used a 7-drill cut of it there.

## Smelting column

![Smelting column running in the design lab](../images/smelting-column.jpg)

- Ten Stone furnaces in a row between two belts flowing the same way. Top belt: ore on the lane
  next to the furnaces, plates come back on the outer lane. Bottom belt: Raw coal next to the
  furnaces, Ash on the outer lane.
- Plate-side inserters take **everything but Ash** (blacklist filter): nothing else can come out
  of a furnace on that side, so the same blueprint smelts iron or copper. Ash-side inserters are
  filtered to Ash.
- Feed ore by side-loading onto the top belt's furnace-side lane (half a belt, 7.5 ore/s) and
  Raw coal the same way onto the bottom belt (0.67/s; one tap from a passing Raw coal belt is
  enough).
- At the end, a pair of underground belts on each belt lets only the outer lane through: plates
  into the three top chests, Ash into the three bottom ones (one Mechanical inserter moves only
  0.82 items/s into a chest).

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

`tools/check-companion.ps1` checks the round trip in the engine: the book imports cleanly (both
blueprints with their labels, entity counts and full descriptions), an unchanged export pulls as
"unchanged", and an edited one shows exactly the edits (one changed, one relabelled as new plus
missing).
