#!/bin/bash
# One play round: one RCON batch of chores. Usage: round.sh [plates per small-parts chest]
cd /d/factorio-explore/py-tutorial/tools/agent
node quota.js guard >/dev/null || { node quota.js; exit 2; }
P=${1:-50}
CH="names=wooden-chest r=1.2"
ops=(
  "upkeep @C:/tmp/cf-agent/upkeep.json"
  # power
  "fuel item=raw-coal count=50 names=boiler r=160"
  "feed item=kerogen count=800 names=wooden-chest x=-30 y=12.5 r=1"
  "feed item=kerogen count=800 names=wooden-chest x=-47 y=3.5 r=1"
  # bricks, wood
  "feed item=stone count=50 names=stone-furnace x=-35 y=-8 r=6"
  "craft recipe=log-wood count=5"
)
# red science lines: line 1 feeders at y 7.5 and 13.5, line 2 at y 15.5 and 21.5
for y in 7.5 13.5 15.5 21.5; do
  ops+=("feed item=stone-brick count=60 $CH x=0.5 y=$y" "feed item=wood count=30 $CH x=0.5 y=$y" "feed item=iron-plate count=15 $CH x=0.5 y=$y")
  ops+=("feed item=soil count=80 $CH x=-3.5 y=$y" "feed item=ash count=50 $CH x=-3.5 y=$y")
  ops+=("feed item=native-flora count=100 $CH x=-7.5 y=$y" "feed item=small-parts-01 count=20 $CH x=-7.5 y=$y")
done
ops+=(
  "feed item=automation-science-pack count=10 names=lab r=60"
  # small parts block
  "insert x=-0.5 y=-4.5 item=iron-plate count=$P" "insert x=10.5 y=-11.5 item=iron-plate count=$P" "insert x=10.5 y=2.5 item=copper-plate count=$P"
  # coal block, steel, aluminium
  "feed item=coal count=100 names=distilator x=-18 y=-11 r=1"
  "feed item=raw-coal count=100 names=distilator x=-46 y=56 r=1"
  "feed item=coke count=30 names=advanced-foundry-mk01 x=-48 y=-8 r=1" "feed item=limestone count=30 names=advanced-foundry-mk01 x=-48 y=-8 r=1"
  "feed item=iron-ore count=100 names=advanced-foundry-mk01 x=-48 y=-8 r=1"
  # moss block
  "feed item=soil count=100 names=washer x=26 y=-6 r=1" "feed item=coke count=20 names=hpf x=18.5 y=-5.5 r=1"
  "feed item=stone count=60 names=moss-farm-mk01 x=24 y=2 r=8" "feed item=moss count=15 names=moss-farm-mk01 x=24 y=2 r=8"
  # storage and report
  "stash_all @C:/tmp/cf-agent/stash.json"
  "status"
)
args=()
for o in "${ops[@]}"; do [ ${#args[@]} -gt 0 ] && args+=("+"); args+=($o); done
node a.js "${args[@]}" 2>&1 | grep -vE "^\s+(py-construction-robot-mk04|firearm-magazine|wooden-chest|iron-chest|saps|moss|kerogen): " \
  | grep -vE '"inserted"|^== (insert|fuel|feed|craft|stash_all)|"fed"|"started"|"stored"'
