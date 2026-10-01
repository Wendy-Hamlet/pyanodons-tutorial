# Py tutorial companion (mod)

[中文版](README.zh-CN.md)

A small mod for playing alongside the tutorial. It adds no game content: two shortcut buttons,
two console commands, three map settings and a script. Install it by copying (or linking) this
folder into your mods folder as `py-tutorial-companion`; it can be added to or removed from a
save at any time.

## Blueprint book

"Tutorial blueprint book" (`/pt-book`) puts the tutorial's blueprints into your cursor as one
book; "Export held blueprint" (`/pt-export`) writes the book or blueprint you hold to
`script-output/py-tutorial-companion/export.txt`. Both directions are driven by
`tools/bp-sync.js`; see [blueprints](../../blueprints/README.md#syncing-with-a-running-game).

## Play recorder

While you play, the mod writes a log to
`script-output/py-tutorial-companion/recorder/<map seed>-<tick it started>/` (in the game's
[user data directory](https://wiki.factorio.com/User_data_directory)). Nothing leaves your
computer; `node tools/recorder-summary.js` prints a summary of the latest game.

| File | Lines | Rotated |
|---|---|---|
| `timeline.jsonl` | research started, finished and cancelled; chat messages; console commands (first 200 characters); recording start and every mod or game version change with the full mod list | never (small) |
| `activity-NNNN.jsonl` | every minute: player positions and, per surface, what was built by hand or by robots, ghosts placed and removed, entities mined (trees counted together) or destroyed, tiles placed and removed, every machine placed with its position, and items crafted by hand; every 10 minutes: items and fluids produced and consumed since the previous line | yes |

Every line is one JSON object with the game tick `t` and a kind `k`. Loading an earlier save
rewinds the tick; the log simply continues, and readers drop the lines of the abandoned branch
(those with a tick at or after the rewound one) and any segment written before the segment in
front of it. `tools/recorder-summary.js` does both.

Map settings ("Mod settings" → "Map"):

- Record the game (on by default).
- Segment size, 4 MB by default: the activity log moves to a new file when the current one
  would grow past it.
- Segments kept, 16 by default: older activity files are deleted, so the activity log never
  takes more than segment size × segments kept (64 MB by default). The timeline is always kept.

### How big it gets

Measured on the author's 25-hour save (62,000 ticks, headless) and estimated from there:

| Part | Size | Per game hour |
|---|---|---|
| Minute line, nobody building | 73 bytes (measured) | 4.4 KB |
| Production line, 25-hour base (about 80 items and fluids moving) | 1.5–1.7 KB (measured), about 21 bytes per item | 10 KB |
| Building | about 0.5 KB per busy minute (estimated from the line format; the 25-hour base stands at 18,292 entities, about 730 per hour played) | up to 30 KB |
| Production line, late game (Py has 3,310 items and 475 fluids; assume about 3,000 produced or consumed) | about 63 KB (estimated) | about 380 KB |
| Timeline | 959 technologies make about 130 KB for a whole game; each mod change adds 1.2 KB (measured) | — |

So an opening of 25 hours writes at most about 1 MB, while a late Py base can write about
0.4 MB per hour and a whole playthrough well over 100 MB — hence the rotation. With the
defaults the activity log stays under 64 MB, which still holds the last ~150 game hours even at
the late-game rate (64 MB at 0.41 MB per hour); raise "Segments kept" to keep more. The
recorder's cost was not measurable: the same 62,000 ticks took 0.768 ms per tick without it and
0.732 ms with it.

### Checks

`tools/check-recorder.ps1` runs the recorder headlessly with 300-byte segments: after 60 game
minutes only the newest 3 segments are left, and replaying the same save for 20 minutes (what
loading an earlier save looks like) leaves a summary of exactly those 20 minutes, without the
abandoned branch's research line or its leftover segments.
