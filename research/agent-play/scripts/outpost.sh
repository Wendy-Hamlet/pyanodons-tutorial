#!/bin/bash
# Visit an outpost: take fuel from the warehouse, collect outputs, refuel (Raw coal, then
# Kerogen), top up its fuel chests, come back. Usage: outpost.sh [x y r]  (default: iron outpost)
cd /d/factorio-explore/py-tutorial/tools/agent
X=${1:-130}; Y=${2:--437}; R=${3:-20}
node a.js restock @C:/tmp/cf-agent/stash.json keep='{"raw-coal":4000,"kerogen":2000}' \
  + walk x=$X y=$((Y + 12)) + wait jobs=true max=40 \
  + upkeep x=$X y=$Y r=$R fuel=raw-coal drills=50 others=50 \
  + fuel item=kerogen count=50 x=$X y=$Y r=$R \
  + feed item=raw-coal count=1500 names=iron-chest x=$X y=$Y r=$((R + 12)) \
  + walk x=-30 y=-10 + wait jobs=true max=40 2>&1 | grep -E "got|error|fuel_left|fuelled" | tr -s ' ' | tr '\n' ' '; echo
