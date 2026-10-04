#!/bin/bash
# Visit the iron outpost at (130,-437): collect plates, refuel (Kerogen, then Raw coal), come back.
cd /d/factorio-explore/py-tutorial/tools/agent
node a.js walk x=130 y=-425 + wait jobs=true max=40 \
  + upkeep x=130 y=-437 r=20 fuel=kerogen drills=100 others=100 \
  + fuel item=raw-coal count=40 x=130 y=-437 r=20 \
  + walk x=-30 y=-10 + wait jobs=true max=40 2>&1 | grep -E "got|error|fuel_left" | tr -s ' ' | tr '\n' ' '; echo
