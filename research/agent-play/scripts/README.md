# My play scripts

The scripts I run each turn in my own game (seed 943562787), copied here as a record. They hold
my base's coordinates, so they only make sense for that save.

- `round.sh [plates]`: one RCON batch of chores (quota guard, `upkeep`, fuel for the Boilers,
  bricks, wood, both red science lines, labs, Small parts block, coal block, steel, aluminium,
  moss, `stash_all`, status).
- `loop.sh N W [plates]`: N rounds, W game seconds apart, one line per round.
- `logs.sh x y [x y ...]`: a logging trip; the robots clear an 80×80 box of trees at each point.
- `upkeep.json`, `stash.json`: arguments for `upkeep` and `stash_all`.
