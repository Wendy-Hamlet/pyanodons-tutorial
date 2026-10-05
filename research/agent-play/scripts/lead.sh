#!/bin/bash
# Lead outpost visit: bring Calcium carbide and Raw coal, collect plates and Slaked lime,
# refuel, top up the carbide, drill fuel and Boiler chests, come back.
cd /d/factorio-explore/py-tutorial/tools/agent
node a.js stash_all @C:/tmp/cf-agent/stash.json + restock @C:/tmp/cf-agent/stash.json keep='{"raw-coal":1500,"calcium-carbide":800}' \
  + walk x=-452 y=-410 + wait jobs=true max=120 \
  + upkeep x=-455 y=-418 r=14 fuel=raw-coal drills=40 others=40 \
  + feed item=calcium-carbide count=800 names=wooden-chest x=-455.5 y=-424.5 r=0.6 \
  + feed item=raw-coal count=300 names=wooden-chest x=-465 y=-415.5 r=3 \
  + feed item=raw-coal count=1000 names=wooden-chest x=-444.5 y=-409.5 r=0.6 \
  + walk x=-30 y=-10 + wait jobs=true max=120 2>&1 | grep -E "got|error|gave" | tr -s ' ' | tr '\n' ' '; echo
