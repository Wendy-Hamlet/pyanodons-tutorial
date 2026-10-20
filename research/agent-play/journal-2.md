# Agent play journal, game 2

Claude playing on in a copy of the author's Py-Exploration save (seed 2652821414), from game
time 26:13 (the author's save of 2026-10-19 13:20), with [tools/agent](../../tools/agent/README.md)
(`setup.ps1 -Mirror`: the author's exact mods; the agent takes over the author's place and
inventory, 15,054 items moved, checked against the save snapshot). Times are game time.
Game 1 (own map): [journal.md](journal.md).

## Rules

Everything through the character's inventory, nothing created, `eval` only reads. Belts and
black boxes; one finished block per technology; no research rush (the author's advice after game 1).

## Goals

- **Long-term: the railway's parts** — Locomotive, Cargo wagon, rails, then stops and signals
  (Trains & railway - Stage 1 needs Assembly 2 and Water animals - Stage 1, both queued).
- **Short-term, in order:**
  1. **Intermetallics** (researched by the author, never made): 1 Vitreloy + 1 Iron nexelit
     antimony special alloy, Advanced foundry, 15 s. They need three new materials:
     - Antimony oxide: Antimony drill MK 01 on the field at x 320..351, y 0..31 (7.1M), Automated
       screener -> Jaw crusher -> Automated screener -> Secondary crusher to Grade 4, then a Basic
       oxygen furnace (10 Grade 4 + 50 Oxygen + 1 Plastic): 13.6 ore an oxide (data).
     - Nickel plates: Fluid mining drill with Syngas (4 a ore) on x -288..-257, y 64..127 (28.6M),
       Jaw crusher (5 ore -> 1 Grade 1), Stone furnace (1 -> 1 plate).
     - Nexelit plates: Dig site + Dig-o-saurus on the Natural nexelit field at x -160..-97,
       y 512..607 (a script: each trip brings 2 ores for a Meat, 1 for Guts; the Vrauk
       slaughterhouse's Meat and Guts are burnt today), Washer (3 ore -> 1 clean), Stone furnace.
  2. Assembly 2 parts: Brakes MK 01 (2 Vitreloy), Shaft MK 01 (5 alloy, 5 Solder), Gearbox MK 01
     (Fish oil).
  3. Locomotive and wagons once Trains & railway - Stage 1 is in.
- The outposts are black boxes into buffer chests; until trains exist their products are carried
  to an alloy cell by the character (the first trains are what replaces that carrying).

## Timeline

| Game time | What I did |
|---|---|
| 26:13 | Took over. Labs on Mining productivity 1 (38 %); queue as the author left it. 100 Construction pynobots MK 04, power armor MK 2 with 4 personal roboports. |
| 26:14–26:24 | Research reordered: Water animals - Stage 1, Assembly 2, Trains & railway - Stage 1 first. Took 150 Aluminium, 300 Steel, 500 Small parts, 200 boards from the author's stores; handcrafted the antimony machines. |
| 26:24–26:40 | **Antimony outpost** (`designs/sb-outpost.js`): 42 small poles from (65.5,35.5) to the field; Antimony drill MK 01 (331.5,9.5) drops into Automated screener A (Grade 1), Jaw crusher, screener B (Grade 3), Secondary crusher; filtered inserters, Grade 4 into chests, Stone/Gravel/Iron oxide into chests. The drill burns Hydrogen from an Electrolyzer beside it (water from an Offshore pump on land; its Oxygen vented for now). Working at 26:40; 63 Grade 4 after a few minutes. |
| 26:40–26:55 | **Nickel outpost** (`designs/ni-outpost.js`): 28 poles along y 92.5 across the base; the Syngas line at x -107.5 opened (its pipe-to-ground pair at y 91.5/101.5 replaced by pipes) with a Check valve at (-108.5,98.5) and 13 pipe-to-ground pairs west along y 98.5. Two Fluid mining drills MK 02 drop into one Jaw crusher; two Stone furnaces make Nickel plates into chests. The Syngas line holds only ~5 of 100 (the Glassworks burn it), but the drills got enough to run. |
| 26:55–27:10 | Syngas for the nickel drills: the base's Syngas reaches x -107.5 only through an Overflow valve at (-107.5,-74.5) and all of it went to the Glassworks fuel pumps (H2 > Syngas > Gasoline by circuit), while Gasoline is in surplus (27.4/s made, 6.5 used; 321k stored). Set the Syngas pump (-107.5,347) never to run and the second Gasoline pump (-111.5,347) to run whenever there is no Hydrogen: the Glassworks burn Gasoline, the overflowing Syngas goes to the nickel drills. New agent ops `set_condition`, `set_filters`. |
| 27:10–27:30 | **Antimony oxide** (`designs/sb-bof.js`): Refined concrete in a burner Assembling machine with an Offshore pump (one craft), Gas furnace, Basic oxygen furnace at the antimony outpost under screener B; its Oxygen from the Electrolyzer, the vent now behind an Overflow valve. Fuel (Raw coal, 5 MW at full) needs two inserters; its Ash goes to its own chest. 7 oxide in the first minute. |
| 27:30–28:10 | **Nexelit from Tar** (`designs/nexelit-tar.js`): the Dig-o-saurus (the intended source) needs 30 Moss gene samples and 10 Generic earth DNA samples, i.e. ~300 Glass, 1,500 Native flora, 600 Moss and 150 red packs, all used by the base today; so first the brute-force route: 1,500 Tar a plate (500 Tar -> 500 Tailings -> 1 Raw nexelit; 3 -> 1 clean; 18 -> 18 plates). On the free middle of the raw coal field at x 25..52, y -101..-70: two Electric mining drills drop straight into a Destructive distillation column (Raw coal: 30 Tar, 60 Coal gas, 3 Coal); Coal gas vented; its Coal burnt by two Boilers and a Steam engine on the base grid; Quenching tower, Evaporator, Washer, Stone furnace, two sinkholes. Running at 28:10, about 36 plates an hour. |
