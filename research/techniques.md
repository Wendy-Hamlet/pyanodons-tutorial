# Techniques and mechanics

[中文版](techniques.zh-CN.md) · [Index](../README.md)

Everything here was measured in the engine or read from the prototype data of the setup in the
[README](../README.md); the source is given for each entry. Chapter 1 explains the early ones in
context.

## Belts

| Fact | Source |
|---|---|
| A Transport belt carries 15 items/s, 7.5 per lane. | Data |
| An Underground belt spans at most 9 tiles. | Data |
| A mining drill drops onto the belt lane **nearest** to it. | Engine, `tools/belt-lab` |
| An inserter drops onto the belt lane **farthest** from it. | Engine, `tools/belt-lab` |
| Side-loading puts everything from the feeding belt onto the lane of the target belt nearest the feeding belt. | Engine (all designs below) |

**Lane filtering with an underground belt.** A belt that runs into the *side* of an underground
belt tile lets only one of its lanes through:

| Target tile (belt arriving from the south, flowing north) | Lane that passes |
|---|---|
| Entrance whose tunnel goes east | West |
| Entrance whose tunnel goes west | East |
| Exit pointing east (belt enters its back side) | East |
| Exit pointing west | West |

Rule of thumb: an entrance passes the lane *away from* its tunnel; an exit passes the lane on the
side it points to. (Engine, `tools/belt-lab`.)

## Inserters

| Fact | Source |
|---|---|
| The Mechanical inserter (Py's burner inserter) needs no fuel and no power at all. | Data (`void` energy), engine |
| It has 1 filter slot. | Data |
| Belt → chest: 0.82 items/s. Belt → belt: 0.83/s from a moving full belt, 0.86/s from a standing one. | Engine, `tools/belt-lab`, `tools/design-lab` |
| Taking from a Stone furnace or Boiler, an inserter takes the product **and** the Ash, never the fuel. | Engine, `tools/ch1-probe` |
| Taking from a Burner mining drill, an **unfiltered** inserter also pulls the fuel out and starves the drill; filtered to Ash it takes only Ash. | Engine, `tools/ch1-probe` |

## Burner machines, fuel and Ash

| Fact | Source |
|---|---|
| Stone furnace: 8 ore → 1 plate in 10 s (0.1 plate/s), 200 kW, 1 fuel slot. | Data, engine |
| Burner mining drill: mining speed 1, 500 kW, 1 fuel slot: 1 ore/s, 2 Raw coal/s, burns 0.167 Raw coal/s. | Data, engine |
| Coal-type fuels (Raw coal, Coal, Coke, …) leave 1 Ash per item; Logs and Wood leave nothing. | Data |
| The burnt-result slot holds 1000 Ash; when full the machine stops. At full load on Raw coal: Boiler 13.5 min, Burner mining drill 100 min, Stone furnace ~4 h. | Data, engine |
| Mining productivity is free output: +10 % gives 2.17 Raw coal/s per drill with unchanged fuel use. | Engine (one-off probe) |

## Steam power

| Fact | Source |
|---|---|
| Boiler: 3.7 MW, 7.5 Steam/s at 250 °C, 1.23 Raw coal/s at full load. | Data, engine |
| Steam engine: 15 Steam/s → 3.7 MW. **Two boilers per engine.** | Data, engine |
| Offshore pump needs no power; with `pump-anywhere-fork` it works on land. | Data, engine |

## Research

| Fact | Source |
|---|---|
| Steam power and the Automation science pack technology are triggers: make 10 Iron plates / 10 Copper plates. Furnace output counts, from all furnaces together. | Data, engine |
| Plates made before the prerequisite is researched still count. | Engine, `tools/ch1-probe` |
| Mining productivity 1 (+10 %) costs 90 × (red + pY science pack 1) and needs Mining machines - Stage 1. | Data |

## Design principles (the author's)

1. **Two belts, one input and one output each.** Each belt beside a machine column carries its
   input on the lane next to the machines and collects an output on the outer lane (inserters
   drop there anyway). Every output inserter is filtered.
2. **Input inserter downstream, separator right after the last machine.** Then nothing is left
   stranded on a belt when supply stops: after draining, 0 ore remained with this placement and 4
   with the opposite one; throughput is the same (engine, `tools/design-lab`).
3. **Separate lanes at the end with an underground belt** and collect into chests.
4. **One dedicated fuel drill per raw coal module.** It feeds a service belt that passes every
   drill and tunnels under the output belt; 9 drills give exactly one full belt. With 8 drills
   the best possible is 14.67/s, because the drills burn 1.33 Raw coal/s themselves; 8 become
   possible only after Mining productivity 1, and then need tapping from the output belt, which
   costs more parts than the drill it saves.
5. **Fuel lines.** A drill row whose output belt U-turns behind it becomes its own service belt
   (coal lands on the inner lane) and can continue as a fuel line (Raw coal + Ash) for other burner
   rows. Raw-coal-filtered inserters take pure coal off such a line.
6. **One fuel tap per smelting column.** A column of 10 furnaces burns 0.667 Raw coal/s; one
   inserter moves 0.83/s from a passing Raw coal belt onto the start of the fuel belt, dropping
   onto its inner lane. A full Raw coal belt fuels about 22 columns.
7. **Opening order.** Handcraft all red science until Wood is mass-produced; automate Iron plates
   (and Raw coal) first.

## Trains

See [Railways under Pyanodons](py-railway.md): no speed cap in Py (measured top speeds and
braking distances), Ash and empty containers from locomotive fuel, 3.5-tile MK 02/MK 04 wagons,
and one platform layout that serves both 7-tile and 3.5-tile wagons.
