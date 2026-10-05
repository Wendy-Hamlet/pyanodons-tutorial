#!/bin/bash
# Titanium outpost visit (same layout as the lead outpost): bring Calcium carbide and Raw coal,
# collect plates, refuel, top up the carbide, drill fuel and Boiler chests, come back.
cd /d/factorio-explore/py-tutorial/tools/agent
node a.js stash_all @C:/tmp/cf-agent/stash.json + restock @C:/tmp/cf-agent/stash.json keep='{"raw-coal":1500,"calcium-carbide":400}' \
  + walk x=-262 y=50 + wait jobs=true max=120 \
  + upkeep x=-280 y=52 r=20 fuel=raw-coal drills=40 others=40 \
  + feed item=calcium-carbide count=400 names=wooden-chest x=-272.5 y=46.5 r=0.6 \
  + feed item=raw-coal count=300 names=wooden-chest x=-287 y=55.5 r=8 \
  + feed item=raw-coal count=1000 names=wooden-chest x=-261.5 y=61.5 r=0.6 \
  + walk x=-30 y=-10 + wait jobs=true max=120 2>&1 | grep -E "got|error|gave" | tr -s ' ' | tr '\n' ' '; echo
