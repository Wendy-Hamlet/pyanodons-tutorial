#!/bin/bash
# Logging trip: walk to x,y, let the robots clear an 80x80 box of trees, walk back. Usage: logs.sh x y [x y ...]
cd /d/factorio-explore/py-tutorial/tools/agent
while [ $# -ge 2 ]; do
  x=$1; y=$2; shift 2
  node a.js walk x=$x y=$y + wait jobs=true max=40 + clear x=$((x-40)) y=$((y-40)) w=80 h=80 type=tree + wait seconds=45 max=70 2>&1 | grep -E "marked"
done
node a.js walk x=-30 y=-10 + wait jobs=true max=40 + status events=false 2>&1 | grep -E "log:|pos"
