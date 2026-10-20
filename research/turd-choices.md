# T.U.R.D. choices

[中文](turd-choices.zh-CN.md)

A T.U.R.D. upgrade (pyalienlife) is a technology named "… upgrade". Once it is researched, the
force picks one of its options, usually three, on the T.U.R.D. page. The pick swaps recipes,
unlocks recipes, puts a hidden module into the buildings it names or replaces those buildings. A
pick stays: changing it takes a reselect, and each T.U.R.D. reselect technology (1 to 5) gives
one. The first needs Chemical science pack and the Fawogae upgrade, 119 technologies away in the
save of 28:53. This note records the author's picks, the upgrades discussed but not picked yet,
and the list of all the others.

Sources: the author's save of 28:53 (2026-10-21, tick 6,240,550), read with `tools/turd-probe`,
which asks pyalienlife's own interface for each researched upgrade and its pick; the companion's
recorder (research times, chat notes); pyalienlife 3.1.8 `prototypes/upgrades/*.lua` and the
data dump of the author's mods (recipes, modules, units).

## 1. The author's picks

In the save of 28:53 three upgrades are researched and all three are picked; none waits for a
pick.

| Upgrade | Cost | Researched | Pick | The author's note |
|---|---|---|---|---|
| Fastwood forestry upgrade | 65 × red | 7:37 | Selective cutting heads | 8:25: "turd选择“选择性切割”" ([chapter 4](../chapters/04-aluminium-glass-logs.md)) |
| Moondrop upgrade | 65 × red | 10:12 | Carbon capture | 10:14: "月落草升级选择碳捕集" ([chapter 5](../chapters/05-tin-zinc-smelting.md)) |
| Creature chamber upgrade | 50 × (1 pY1 + 2 red) | 28:24 | Planetary adaptation | none; read in the save |

### Fastwood forestry upgrade: Selective cutting heads

- **Picked, Selective cutting heads**: the Wood processing unit's Logs to Wood becomes 4 Logs →
  40 Wood in 1 s instead of 20 Wood in 4 s. The author's Wood processing units run it.
- Dry storage: Raw fiber from Wood becomes 10 Wood → 8 Raw fiber + 6 Biomass + 1 to 2 Fiber in
  20 s instead of 2 Raw fiber in 10 s.
- Internal burner: Fastwood forestries −50 % energy, +50 % speed and +50 % productivity (a hidden
  module, speed +5 against the 10 Tree modules of a full MK 01); the forestry's recipe takes a
  Stone furnace more, and the Log recipes log3 and log6 take twice the Ash (log3: 60 instead of 30).

### Moondrop upgrade: Carbon capture

- **Picked, Carbon capture**: a hidden module in every Moondrop greenhouse (MK 01: speed +8,
  consumption +200 %), so an MK 01 runs at 0.0625 × (8 + Moondrop modules): 0.5 empty, 1.5 with
  all 16; and a greenhouse recipe making 200 Carbon dioxide every 5 s from nothing
  ([techniques](techniques.md), [chapter 6](../chapters/06-simple-circuit-boards.md)).
- Copper addition: every Moondrop recipe takes 10 Copper ore more, makes twice the Moondrop in half
  the time and drops its Hydrogen, Biomass, Fertilizer, Urea, Pesticide and Gasoline (Moondrop 1:
  4 seeds + 100 Water → 8 Moondrop in 70 s instead of 4 in 140 s).
- Moon light: +35 % productivity, speed −8 (0.5 with 16 Moondrop modules), and a Methane recipe:
  1 Lamp + 100 Water → 60 Methane + 40 Oxygen in 2 s, the lamp back 95 % of the time.

### Creature chamber upgrade: Planetary adaptation

- **Picked, Planetary adaptation**: eight creatures get a T.U.R.D. version that moves 35 % faster
  and has 35 % more health: Dig-o-saurus, Thikat, Work-o-dile, Caravan, Aerial caravan,
  ☢ Caravan ☢, Fluid caravan and Aerial fluid caravan. The Creature chamber makes the new version
  from the same ingredients in four times the time (a Dig-o-saurus: 480 s instead of 120), and a
  crafting recipe turns an old one into a new one in 0.5 s. A Dig-o-saurus walks 0.1026 tiles a tick
  instead of 0.076 (405 health instead of 300). The author's Dig site holds one; its trip of
  13.8 s ([techniques](techniques.md)) was measured with it. Measured with unlimited food
  (`tools/dig-probe`): 13.9 s a trip against 15.8 s for an ordinary Dig-o-saurus, 14 % more trips.
- Knowledge transfer (呼吸生物放大器): Creature chambers −10 % speed, +300 % energy; every
  chamber recipe that takes 5 or more DNA samples of one kind takes a tenth of them (a
  Dig-o-saurus: 1 Generic earth DNA sample instead of 10), and one that takes fewer gives each back
  80 % of the time.
- Neural fusion: Creature chambers +1,000 % speed and +1,000 % energy; it unlocks the Arthurian
  codex recipe, and the Creature chamber's own recipe takes an Arthurian codex more.

## 2. Discussed, not picked yet

### Fish upgrade (discussed 2026-10-21)

Needs Fish - Stage 1 and Cooling tower 1: 275 × (1 pY1 + 2 red), 45 s each. At 28:53 Fish -
Stage 1 is second in the research queue, but 17 technologies still stand before the upgrade
(among them Separation, Boron, Coke processing, Hot air, Casting, Chromium processing, Rubber,
Laboratory Equipment, Genetics - Stage 2, Ralesia, Auogs, Melamine, Battery, Machine Components
and Energy generation 1).

- **Aggressive selection**: every Fish breeding recipe of stage i makes i Fish fewer and i Fish
  food more, 10 % faster (stage 1: 10 Eggs … → 9 Fish + 1 Fish food in 135 s instead of 10 Fish in
  150 s). A breeding farm makes as many Fish a second as before, but each Fish takes 11 % more Eggs,
  Oxygen, Lamps, Biomass and Saline water. From stage 2 on, Eggs and Fish recipes take Fish food,
  whose own recipe is 6 Plastic + 10 Fawogae + 10 Native flora + 4 Lard + 5 Seaweed + 5 Skin + 2 Fish
  + 5 Bones + 100 Steam → 3; with this pick the farms make more Fish food than they use.
- **Temperature control**: Fish hydrolysate becomes 10 Fish … → 300 instead of 50, in 10 s instead
  of 5, with a Cooling tower MK 01 that comes back 99.9 % of the time; and Cyanic acid from it (Reformer:
  100 Fish hydrolysate + 100 Ammonia + 15 Saline water → 100 Cyanic acid + 100 Wastewater). Fish
  hydrolysate itself needs Fertilizer - Stage 2, and Melamine (before Cooling tower 1) already
  unlocks two Cyanic acid recipes.
- **Dosing pumps**: every Fish farm becomes a T.U.R.D. version (MK 01 5 MW instead of 1 MW, six
  fluid connections instead of four), and every Fish egg recipe makes 20 % fewer Eggs, 10 %
  faster, with Pressurized water instead of Saline water (Pressure pump, from Water) and
  byproducts by stage: 15 Fish oil at stage 1; 20 Fish oil + 15 Fish hydrolysate at stage 2;
  + 5 Fishmeal at stage 3; + 20 Fish emulsion at stage 4.

One round of 12 Fish → Eggs → Fish (Temperature control does not change breeding):

| | Without | Aggressive selection | Dosing pumps |
|---|---|---|---|
| Stage 1 | 13 Fish | 10.5 Fish + 2.5 Fish food | 8 Fish + 15 Fish oil |
| Stage 2 | 48 Fish, 4 Fish food used | 42 Fish, 2 Fish food left over | 36 Fish + 20 Fish oil + 15 Fish hydrolysate, 3.4 Fish food used |

Rendering 8 Fish gives 100 Fish oil (Slaughterhouse, 30 s, also 2 Meat, 5 Guts, 3 Skin, 2 Bones),
so the 15 Fish oil of a Dosing round is worth about 1.2 Fish against the 5 Fish it costs.
Analysis (not the author's decision): Aggressive selection costs little at stage 1 and makes the
Fish food line unnecessary from stage 2 on; by these numbers Dosing pumps is the weakest;
Temperature control only pays once Fish hydrolysate is needed in quantity.

### Slaughterhouse upgrade (mentioned 2026-10-21)

Far off: 800 × (1 blue + 2 pY2 + 3 green + 6 pY1 + 10 red + 2 military), 120 s each, after Laser
turret and Biotechnology machines - Stage 2. Every rendering recipe (Vrauks, Fish and 23 others) gets one of:

- Laser cutting: twice the Blood, Lard, Sulfuric acid and Bones, a Brain more 5 % of the time;
  takes a Laser turret, back 99.9 % of the time.
- Mercy killing: twice the Skin, Phadai carapace, Dingrit pelt, Chitin, Shell, Fish oil and Photophore; takes a
  Programmable speaker, back 99 % of the time.
- Lard use: twice the Meat, Arthropod blood, Guts, Formic acid, Bone meal, Kmaut tendons and Keratin;
  takes 3 Grease.

Lard use would double the Meat and Guts that feed the Dig-o-sauruses (and the Formic acid with
them); Mercy killing would double the Fish oil from rendering Fish.

## 3. All the other upgrades

Not researched at 28:53, by the newest science pack they take (data).

| Upgrade | Cost | Needs |
|---|---|---|
| Vrauks upgrade | 110 × (1 pY1 + 2 red) | Vrauks - Stage 2 |
| Moss farm upgrade | 175 × (1 pY1 + 2 red) | Melamine |
| Fish upgrade | 275 × (1 pY1 + 2 red) | Cooling tower 1, Fish - Stage 1 (section 2) |

- Green (Logistic science pack): Compost (also military), Arqad, Incubator, Seaweed, Xyhiphoe,
  Data array.
- pY science pack 2: Fawogae, Sap, Zipir, Tuuphra, Auog, Ulric, Wood processing unit, Sponge,
  Yaedols.
- Blue (Chemical science pack): Grod, Rennea, Slaughterhouse (section 2), Phagnot, Ralesia,
  Research, Cottongut, Scrondrix, Cadaveric arum.
- pY science pack 3: Biofactory, Kicalk, Phadai, Cridren, Mukmoux, Guar, Korlex, Yotoi, Bhoddos,
  Navens; Intense transmutation - Stages 1 and 2.
- Production science pack: Arthurian, Gene lab, Bioprinting, Trits, Vonix; Intense
  transmutation - Stage 3.
- pY science pack 4: Kmauts, Numal, Xeno, Zungror; Intense transmutation - Stage 4.
- Utility science pack: Bioreactor, Dhilmos.
- Space science pack: Atomizer, Dingrits, Schrödinger antelope; Intense transmutation - Stages 5
  and 6.

## How it was checked

- `tools/save-probe.ps1 -Save <save> -Probe turd-probe -Ticks 10` on a copy of the save of 28:53:
  three upgrades researched with picks `selective-heads`, `carbon-capture` and `cc`, the hidden
  Carbon capture module in Moondrop greenhouses MK 01 to 04, no machine replacements, every other
  upgrade open.
- Research times and the author's notes: the recorder's timeline (run `2652821414-0`).
- Options and their effects: pyalienlife 3.1.8 `prototypes/upgrades/fwf.lua`, `moondrop.lua`,
  `creature.lua`, `fish.lua`, `slaughterhouse.lua`, the zh-CN and en locale files for the option
  names, and the data dump for every recipe, module and unit quoted here; the reselect rule:
  `scripts/turd/turd.lua`.
