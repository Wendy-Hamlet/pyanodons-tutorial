# Agent player

Lets Claude (or any program) play a Py game on its own: a headless Factorio server with the
player's Py mods, a mod (`mod/`, name `pt-agent`) that gives the agent a character and commands,
and a command-line client (`a.js`) that talks to the server over RCON.

## Pieces

| File | What it does |
|---|---|
| `setup.ps1` | Builds `C:\tmp\cf-agent`: the player's Py mods and helper mods (zips hard-linked from `%APPDATA%\Factorio\mods`, never modified), the mod settings of their Py save, a junction to `mod/`, server settings. |
| `server.ps1 new\|start\|stop\|status` | Creates the map, starts the server detached (RCON on 127.0.0.1:27115), saves and quits. |
| `mapgen.json` | The player's map generation settings (Py recommended with cliffs off), without the seed. |
| `mod/` | The agent mod: `control.lua` (character, command dispatch, jobs, events), `lib/observe.lua`, `lib/act.lua`. |
| `a.js`, `rcon.js` | The client: `node a.js <op> key=value ... [+ <op> ...]`. |
| `statusline.js`, `quota.js` | Rate limit watch: Claude Code's status line saves the plan's limits; `quota.js` reads them. |

## The game

- Mods: every Py mod plus the player's helpers (Py Quick Start, Far Reach, Pump Anywhere, Doing
  Things By Hand, Factory Planner, Helmod...). Map: the player's settings (Py recommended preset,
  cliffs off, no enemy bases); `--preset` on the command line would override the settings file,
  so the mod applies the preset's advanced settings (pollution off...) in `on_init`.
- A headless server has no players, so the agent is a **character entity** created by the mod.
  It gets what a new player gets: Py's freeplay start items and the Py Quick Start kit (power
  armor MK2 with 4 personal roboports, 55 solar panels, 2 exoskeletons; 100 construction robots),
  and Far Reach's bonuses (reach and build distance 160).
- The game runs in real time while the agent thinks. `node a.js pause` / `pause value=false`
  stops and resumes it (`game.tick_paused`; commands still work while paused).

## Rules the agent plays by

Everything goes through the character, as for a player:

- Items come from its inventory and go back into it; nothing is created from nothing.
- Placing needs the item and build distance; opening, inserting and taking need reach.
- Hand mining (`mine`) takes the prototype's mining time at the character's mining speed, and
  walking (`walk`) takes distance / running speed; both are jobs that run one after another.
- Handcrafting goes through the character's crafting queue (`craft`).
- Ghosts (`ghost`, `blueprint`) are built by the construction robots from the inventory; `clear`
  marks trees and rocks for them. `build_ghosts` builds ghosts in reach from the inventory
  directly, like placing them by hand.
- `eval` runs a Lua expression for diagnostics only (reading the world, never changing it).

## Commands

Reading: `status` (time, position, inventory, crafting queue, research, jobs, events since the
last status), `inv`, `look x= y= w= h=` (ASCII map with legend), `scan r=` (resource patches,
rocks, trees), `entities x= y= r= name= type=`, `factory` (every machine by status, problem
positions), `prod window=ten_minutes fluids=true`, `recipe name=|product=|ingredient=`,
`tech [name=]`, `proto name=`, `boxes x= y=` (each fluid box of a machine: the recipe's filter,
what it holds, every pipe connection and what it faces; read it before piping a machine, box
numbers alone do not say which fluid goes where).

Acting: `place name= x= y= dir=N|E|S|W recipe=`, `ghost name= x= y= ...` or `ghost list=[...]
ox= oy=`, `blueprint string= x= y=`, `build_ghosts r=`, `clear x= y= w= h=`, `remove x= y=`,
`rotate`, `set_recipe x= y= recipe=`, `insert x= y= item= count=`, `take x= y= [item=]`,
`collect r= [chests=true] [ground=true]`, `fuel item= count= r=`, `feed item= count= r=
[names=]`, `craft recipe= count=`, `craft_cancel`, `walk x= y=`, `mine name=|type= count= [x= y=]
[r=]`, `stop`, `research add=a,b | set=a,b | cancel=true`, `speed value=`, `pause [value=false]`,
`note text=`, `respawn`, `upkeep` (one round of chores: empty every output, Ash slot and chest in
range except `keep=` items and input chests, top up every burner: `drills=`, `others=`),
`input_chest at=[[x,y],...]` (chests upkeep never empties).

Client-side: `wait seconds= jobs=true crafting=true max=` waits on the game (Bash may not start
with `sleep`). Git Bash rewrites a leading `/` in arguments, so `raw` takes commands without it.

Events (research finished, jobs done, entities destroyed) also go to
`C:\tmp\cf-agent\data\script-output\pt-agent\events.txt`; notes to `notes.txt` there.

## Rate limits

`D:\factorio-explore\.claude\settings.local.json` sets `statusline.js` as Claude Code's status line
(refreshed every 60 s). Claude Code passes it the plan's `rate_limits` (5-hour and 7-day
`used_percentage` and `resets_at`, refreshed after every API response); it writes them to
`C:\tmp\cf-agent\quota.json`.

- `node quota.js` prints the 5-hour use and exits 0 (ok), 2 (low: at least `PT_QUOTA_LOW`,
  default 90 %) or 3 (no data).
- `node quota.js guard` also pauses the game when the quota is low.
- `node quota.js wait 40` blocks until the window resets or 40 minutes pass. Run as a background
  task, it wakes the session every 40 minutes, which keeps the prompt cache (1 hour) warm until
  the window resets; with `/goal`, a turn that ends while background work runs is not evaluated.
