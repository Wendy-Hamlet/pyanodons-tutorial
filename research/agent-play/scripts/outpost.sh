#!/bin/bash
# Visit the iron outpost at (130,-437): take fuel from the warehouse, collect plates, refuel
# (Raw coal, then Kerogen), come back.
cd /d/factorio-explore/py-tutorial/tools/agent
node a.js restock @C:/tmp/cf-agent/stash.json keep={\"raw-coal\":4000,\"kerogen\":2000} \
  + walk x=130 y=-425 + wait jobs=true max=40 \
  + upkeep x=130 y=-437 r=20 fuel=raw-coal drills=50 others=50 \
  + fuel item=kerogen count=50 x=130 y=-437 r=20 \
  + walk x=-30 y=-10 + wait jobs=true max=40 2>&1 | grep -E "got|error|fuel_left|fuelled" | tr -s ' ' | tr '\n' ' '; echo
