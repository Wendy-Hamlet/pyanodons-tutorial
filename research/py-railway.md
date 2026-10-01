# Railways under Pyanodons (Factorio 2.1.20, Py 3.1.x, elevated-rails on)

Facts below come from `tools/dump-data.ps1` (data.raw of the player's exact mod set) and from
`tools/train-probe` (measured in the engine), not from wikis.

## Unlock order

| Technology | Science | Unlocks |
|---|---|---|
| railway (after automation-2) | red + py1 | rail, locomotive, cargo-wagon |
| automated-rail-transportation | red + py1 | train-stop, rail-signal, rail-chain-signal |
| fluid-wagon | red + py1 | fluid-wagon |
| cybersyn-train-network (+ circuit-network) | red | cybersyn-combinator |
| elevated-rail | red + py1 + green | rail-ramp (4x16), rail-support (3x3, range 11) |
| railway-mk02 | + py2 | mk02 locomotive / wagons, `rail-2` (12 rails per craft) |
| railway-mk03 | + chemical, py3 | ht locomotive / wagons |
| railway-mk04 | + production, py4, military | mk04 locomotive / wagons |

## Rolling stock

| Tier | Locomotive | Fuel (burnt result) | Wagon | Tiles per car | Cargo |
|---|---|---|---|---|---|
| mk01 | 600 kW, 2000 kg, braking 10, 3 fuel + 3 burnt slots | chemical / biomass (ash), nuclear fuel | cargo-wagon | 7 | 20 slots / 25k fluid |
| mk02 | 900 kW, 1600 kg, braking 18, 5 slots | fluid canisters (empty canister), nuclear fuel | mk02-wagon | **3.5** | 20 slots / 25k |
| mk03 | 1.6 MW, 1200 kg, braking 45, 1 slot | nexelit battery (used battery) | ht-generic-wagon | 7 | 80 slots / 75k |
| mk04 | 2.4 MW, 1000 kg, braking 81, 1 slot | quantum battery (used battery) | mk04-wagon | **3.5** | 80 slots / 75k |

Locomotives are 7 tiles per car in every tier. Station geometry for 7-tile wagons (mk01, mk03)
does not fit 3.5-tile wagons (mk02, mk04), and a locomotive followed by a 3.5-tile wagon is
5.25 tiles apart.

Py gives the mk01 locomotive a burnt-result inventory (`pycoalprocessing` entity-updates), so
every tier returns something to collect at refuelling: ash, empty canisters or used batteries.

## No speed cap

`pycoalprocessing` sets `max_speed = nil` on the vanilla locomotive and wagons, and Py's own
stock never sets it, so top speed is limited only by power, weight and air resistance
(air resistance is divided by train weight: longer trains with the same power/weight run faster).

Measured on straight track, empty wagons (`tools/train-probe`):

| Composition | Top speed | Braking from top speed |
|---|---|---|
| mk01 1-2, coal | 245 km/h (90% after ~20 s) | 145 tiles |
| mk01 1-4, coal | 216 km/h | 122 tiles |
| mk01 2-4, coal | 486 km/h | 576 tiles |
| mk01 1-2, nuclear fuel | 676 km/h | 1112 tiles |
| mk02 1-4, fuel canister | 330 km/h | 97 tiles |
| mk03 1-2, nexelit battery | 918 km/h | 436 tiles |
| mk04 1-4, quantum battery | >= 1907 km/h (track ended) | 799 tiles |

Re-run: copy `tools/train-probe` into the dump environment's mods folder (`C:\tmp\cf-dump\mods`
after `tools/dump-data.ps1`), then run factorio with that `--config`/`--mod-directory`:
`--create probe.zip`, then `--benchmark probe.zip --benchmark-ticks 20000`; results are the
`CF-PROBE` log lines.

## One platform for 7-tile and 3.5-tile wagons

1 locomotive + 2 cargo-wagons and 1 locomotive + 4 mk02-wagons are both 21 tiles long. Measured
with `tools/station-probe` (an inserter on every tile beside the platform; offsets are tiles
relative to the train stop tile, trains running towards +x):

```
offset           -21 ............ -14 ............ -7 ..... -1
1+2 cargo-wagon     .222222.111111.LLLLLL
1+4 mk02-wagon      444433332221111LLLLLL
```

- The vanilla pattern (6 inserters per wagon, 1-tile gaps at -14 and -7) still gives every
  mk02-wagon 3 inserters per side.
- A continuous row from -21 to -7 (15 per side) serves both: mk02 wagons get 3-4 each, and the 3
  extra tiles idle for 7-tile wagons.
- The tiles-to-wagon grouping differs between the two, so a platform must not rely on fixed
  per-wagon inserter groups (e.g. one item per wagon via fixed filters).
- Locomotive tiles are -6..-1 (refuelling inserters go there).
- Py's burner-inserter has a void energy source: it needs neither fuel nor power.

## Cybersyn 2.1.2

Station, depot, refueler modes; depot bypass; fuel threshold (share of the fuel inventory that
must be full to skip the refueler).
