#!/bin/bash
# One play round: one RCON batch of chores. Usage: round.sh [plates per small-parts chest]
cd /d/factorio-explore/py-tutorial/tools/agent
node quota.js guard >/dev/null || { node quota.js; exit 2; }
P=${1:-50}
W="names=wooden-chest"
ops=(
  "upkeep @C:/tmp/cf-agent/upkeep.json" "restock @C:/tmp/cf-agent/stash.json"
  # power
  "fuel item=raw-coal count=50 names=boiler r=160" "fuel item=raw-coal count=10 r=160"
  "feed item=kerogen count=800 $W x=-30 y=12.5 r=1" "feed item=kerogen count=800 $W x=-47 y=3.5 r=1"
  # bricks, wood
  "feed item=stone count=50 names=stone-furnace x=-35 y=-8 r=6" "craft recipe=log-wood count=5"
  # red science cell ports (Native flora and half the Soil arrive by belt)
  "feed item=stone-brick count=500 $W x=12.5 y=12 r=2.6" "feed item=wood count=400 $W x=9.5 y=12.5 r=0.6"
  "feed item=soil count=800 $W x=17.5 y=10.5 r=0.6" "feed item=ash count=2000 $W x=15.5 y=13.5 r=1.1"
  "feed item=iron-plate count=300 $W x=11.5 y=27.5 r=0.6" "feed item=raw-coal count=300 $W x=19.5 y=29.5 r=0.6"
  "feed item=small-parts-01 count=200 $W x=19.5 y=27.5 r=0.6" "feed item=raw-coal count=300 $W x=21.5 y=25.5 r=0.6"
  # small parts block
  "insert x=-0.5 y=-4.5 item=iron-plate count=$P" "insert x=10.5 y=-11.5 item=iron-plate count=$P" "insert x=10.5 y=2.5 item=copper-plate count=$P"
  # coal block, steel, aluminium
  "feed item=coal count=100 names=distilator x=-18 y=-11 r=1" "feed item=raw-coal count=100 names=distilator x=-46 y=56 r=1"
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
  | grep -vE '"inserted"|^== (insert|fuel|feed|craft|stash_all|restock)|"fed"|"started"|"stored"|"restocked"'
