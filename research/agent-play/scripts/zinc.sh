#!/bin/bash
# Zinc outpost visit: bring Raw coal (Aromatics are distilled from it on the spot), collect Zinc
# plates and the distillers' by-products, refuel, top up the raw coal and fuel chests, come back.
cd /d/factorio-explore/py-tutorial/tools/agent
node a.js stash_all @C:/tmp/cf-agent/stash.json + restock @C:/tmp/cf-agent/stash.json keep='{"raw-coal":2500}' \
  + walk x=333 y=418 + wait jobs=true max=120 \
  + upkeep x=335 y=414 r=20 fuel=raw-coal drills=40 others=20 \
  + feed item=raw-coal count=800 names=wooden-chest x=325.5 y=407.5 r=2.5 \
  + feed item=raw-coal count=400 names=wooden-chest x=321.5 y=414.5 r=0.6 \
  + feed item=raw-coal count=300 names=wooden-chest x=348 y=423.5 r=3 \
  + walk x=-30 y=-10 + wait jobs=true max=120 2>&1 | grep -E "got|error|gave" | tr -s ' ' | tr '\n' ' '; echo
