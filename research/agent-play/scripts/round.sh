#!/bin/bash
# One play round: one RCON batch of chores. Usage: round.sh [plates per small-parts chest]
cd /d/factorio-explore/py-tutorial/tools/agent
node quota.js guard >/dev/null || { node quota.js; exit 2; }
P=${1:-50}
W="names=wooden-chest"
ops=(
  "walk x=-30 y=-10" "wait jobs=true max=60"
  "stash_all @C:/tmp/cf-agent/stash.json" "upkeep @C:/tmp/cf-agent/upkeep.json" "restock @C:/tmp/cf-agent/stash.json"
  # power
  "fuel item=raw-coal count=50 names=boiler r=160" "fuel item=raw-coal count=10 r=160"
  "feed item=kerogen count=800 $W x=-30 y=12.5 r=1" "feed item=kerogen count=800 $W x=-47 y=3.5 r=1"
  # bricks, wood
  "feed item=stone count=50 names=stone-furnace x=-35 y=-8 r=6" "craft recipe=log-wood count=5" "craft recipe=solder-0 count=6" "craft recipe=inductor1-2 count=20"
  # red science cell ports (Native flora and half the Soil arrive by belt)
  "feed item=stone-brick count=500 $W x=12.5 y=12 r=2.6" "feed item=wood count=400 $W x=9.5 y=12.5 r=0.6"
  "feed item=soil count=800 $W x=17.5 y=10.5 r=0.6" "feed item=ash count=2000 $W x=15.5 y=13.5 r=1.1"
  "feed item=iron-plate count=300 $W x=11.5 y=27.5 r=0.6" "feed item=raw-coal count=300 $W x=19.5 y=29.5 r=0.6"
  "feed item=small-parts-01 count=200 $W x=19.5 y=27.5 r=0.6" "feed item=raw-coal count=300 $W x=21.5 y=25.5 r=0.6"
  # small parts block
  "insert x=-0.5 y=-4.5 item=iron-plate count=$P" "insert x=10.5 y=-11.5 item=iron-plate count=$P" "insert x=10.5 y=2.5 item=copper-plate count=$P"
  # coal block, steel, aluminium
  "feed item=raw-coal count=500 $W x=-32.5 y=-27.5 r=1.2" "feed item=coal count=100 names=distilator x=-18 y=-11 r=1" "feed item=raw-coal count=100 names=distilator x=-46 y=56 r=1"
  "feed item=coke count=50 names=advanced-foundry-mk01 x=-48 y=-11.5 r=4" "feed item=limestone count=50 names=advanced-foundry-mk01 x=-48 y=-11.5 r=4"
  "feed item=iron-ore count=200 names=advanced-foundry-mk01 x=-48 y=-11.5 r=4"
  # moss block
  "feed item=soil count=100 names=washer x=26 y=-6 r=1" "feed item=coke count=20 names=hpf x=18.5 y=-5.5 r=1"
  "feed item=stone count=60 names=moss-farm-mk01 x=24 y=2 r=8" "feed item=moss count=15 names=moss-farm-mk01 x=24 y=2 r=8"
  # components workshop (bootstrap)
  "feed item=coke count=100 names=hpf x=5.5 y=-44.5 r=1" "feed item=raw-coal count=400 $W x=12.5 y=-48.5 r=0.6"
  "feed item=graphite count=20 names=electronics-factory-mk01 x=20.5 y=-44.5 r=1" "feed item=glass count=20 names=electronics-factory-mk01 x=20.5 y=-44.5 r=1" "feed item=copper-plate count=20 names=electronics-factory-mk01 x=20.5 y=-44.5 r=1" "feed item=iron-plate count=50 names=electronics-factory-mk01 x=20.5 y=-44.5 r=1" "feed item=coke count=200 $W x=5.5 y=-57.5 r=0.6" "feed item=limestone count=150 $W x=5.5 y=-57.5 r=0.6"
  "feed item=seaweed count=10 names=seaweed-crop-mk01 x=32.5 y=-52.5 r=1" "feed item=seaweed count=20 names=hpf x=19.5 y=-55.5 r=1"
  "feed item=agar count=10 names=assembling-machine-1 x=12.5 y=-38.5 r=1" "feed item=empty-petri-dish count=10 names=assembling-machine-1 x=12.5 y=-38.5 r=1"
  "feed item=moondrop count=16 names=moondrop-greenhouse-mk01 x=52.5 y=-64.5 r=1"
  "feed item=sap-tree count=2 names=sap-extractor-mk01 x=5 y=-34.5 r=10"
  # tar refinery (pond 2): wood for treated wood, Raw coal for its Boiler
  "feed item=wood count=100 names=tar-processing-unit x=-17.5 y=71.5 r=1" "feed item=raw-coal count=400 $W x=-39.5 y=82.5 r=0.6"
  "take x=-48.5 y=39.5 item=stone count=150"
  # concrete (one-off for rc-mk01): Stone into the Jaw crusher
  # east side (methane block, battery cell) is out of reach from home: walk there and back
  "walk x=40 y=-40" "wait jobs=true max=40"
  # methane block: coke (CO2), copper (methanal, PCB), wood (raw fiber), treated wood + saps (formica)
  "feed item=coke count=100 $W x=57.5 y=-38.5 r=0.6" "feed item=copper-plate count=150 $W x=61.5 y=-51.5 r=0.6" "feed item=copper-plate count=150 $W x=73.5 y=-40.5 r=0.6"
  "feed item=wood count=200 $W x=75.5 y=-52.5 r=0.6" "feed item=treated-wood count=60 $W x=68.5 y=-51.5 r=0.6" "feed item=saps count=150 $W x=68.5 y=-51.5 r=0.6"
  # battery cell: Stone (from the stone drills chest), Zinc + Copper, Wood + Limestone; east upkeep
  "feed item=stone count=300 $W x=84.5 y=-60.5 r=0.6"
  "feed item=zinc-plate count=100 $W x=85.5 y=-55.5 r=0.6" "feed item=copper-plate count=100 $W x=85.5 y=-55.5 r=0.6"
  "feed item=wood count=200 $W x=99.5 y=-53.5 r=0.6" "feed item=limestone count=120 $W x=99.5 y=-53.5 r=0.6"
  # chipshooter: all seven circuit ingredients into one chest; solder and inductors crafted by hand
  "feed item=battery-mk00 count=10 $W x=81.5 y=-44.5 r=0.6" "feed item=pcb1 count=10 $W x=81.5 y=-44.5 r=0.6" "feed item=solder count=20 $W x=81.5 y=-44.5 r=0.6"
  "feed item=capacitor1 count=50 $W x=81.5 y=-44.5 r=0.6" "feed item=resistor1 count=60 $W x=81.5 y=-44.5 r=0.6" "feed item=vacuum-tube count=30 $W x=81.5 y=-44.5 r=0.6"
  "feed item=inductor1 count=30 $W x=81.5 y=-44.5 r=0.6"
  "upkeep x=75 y=-50 r=30 drills=10 others=10 fuel=raw-coal" "take x=94.5 y=-53.5 item=cellulose count=10"
  # vrauk area: empty Barrels back to the Barrel machine, Water barrels, Flora, Saps and Moss to
  # rc-mk01 and the paddock; the rc's Barrels are taken by hand (its output inserter only takes Cocoons)
  "upkeep x=120 y=-55 r=26 drills=10 others=10 fuel=raw-coal" "take x=113 y=-62 item=barrel"
  "feed item=barrel count=20 $W x=106.5 y=-44.5 r=0.6"
  "feed item=water-barrel count=12 $W x=113.5 y=-74.5 r=0.6" "feed item=native-flora count=30 $W x=113.5 y=-74.5 r=0.6" "feed item=saps count=20 $W x=113.5 y=-74.5 r=0.6" "feed item=moss count=40 $W x=113.5 y=-74.5 r=0.6"
  "feed item=water-barrel count=9 $W x=133.5 y=-70.5 r=0.6" "feed item=native-flora count=45 $W x=133.5 y=-70.5 r=0.6" "feed item=moss count=15 $W x=133.5 y=-70.5 r=0.6"
  "walk x=-30 y=-10" "wait jobs=true max=40"
  # creosote: Wood for TPU 4 (pond A)
  "feed item=wood count=200 $W x=-11.5 y=40.5 r=0.6"
  # latex block (reachable from the east stop): washer, alginate HPF, Boiler fuel
  "walk x=40 y=-40" "wait jobs=true max=40"
  "feed item=limestone count=60 $W x=117.5 y=-47.5 r=0.6" "feed item=saps count=60 $W x=117.5 y=-47.5 r=0.6"
  "feed item=stone count=50 $W x=105.5 y=-43.5 r=0.6" "feed item=limestone count=40 $W x=105.5 y=-43.5 r=0.6" "feed item=seaweed count=50 $W x=105.5 y=-43.5 r=0.6"
  "feed item=raw-coal count=300 $W x=126.5 y=-41.5 r=0.6"
  "walk x=-30 y=-10" "wait jobs=true max=40"
  # science block: Petri dishes to the micro mine, substrate by hand, Flasks + substrate to the
  # research center (Cellulose is taken from the battery cell's HPF during the east stop)
  "feed item=petri-dish count=10 $W x=45.5 y=-20.5 r=0.6" "craft recipe=fawogae-substrate count=2"
  "feed item=flask count=30 $W x=55.5 y=-21.5 r=0.6" "feed item=fawogae-substrate count=180 $W x=55.5 y=-21.5 r=0.6"
  # electronics block: Resistors (Coke, Glass, Tin) and Capacitors (Ceramic, Tin)
  "feed item=coke count=60 $W x=65.5 y=-19.5 r=0.6" "feed item=glass count=30 $W x=65.5 y=-19.5 r=0.6" "feed item=tin-plate count=30 $W x=65.5 y=-19.5 r=0.6"
  "feed item=ceramic count=30 $W x=72.5 y=-19.5 r=0.6" "feed item=tin-plate count=60 $W x=72.5 y=-19.5 r=0.6" "feed item=coke count=150 $W x=79.5 y=-20.5 r=0.6"
  # storage and report
  "stash_all @C:/tmp/cf-agent/stash.json"
  "status"
)
args=()
for o in "${ops[@]}"; do [ ${#args[@]} -gt 0 ] && args+=("+"); args+=($o); done
node a.js "${args[@]}" 2>&1 | grep -vE "^\s+(py-construction-robot-mk04|firearm-magazine|wooden-chest|iron-chest|saps|moss|kerogen): " \
  | grep -vE '"inserted"|^== (insert|fuel|feed|craft|stash_all|restock)|"fed"|"started"|"stored"|"restocked"'
