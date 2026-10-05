#!/bin/bash
# Build the zinc pipeline and outpost chunk by chunk: for each chunk, place its ghosts, then
# stand at its first and third quarter so the robots (40-tile radius) reach every tile.
cd /d/factorio-explore/py-tutorial/tools/agent
for i in ${@:-0 1 2 3 4 5 6 7}; do
  f=C:/tmp/cf-agent/zinc-$i.json
  pts=$(node -e 'const l=require(process.argv[1]).list; const q=(k)=>l[Math.min(l.length-1,Math.floor(l.length*k))]; console.log([q(0.25),q(0.75)].map(e=>`${e.x} ${e.y}`).join(" "))' "$f")
  set -- $pts
  node a.js walk x=$1 y=$2 + wait jobs=true max=120 + ghost @$f + wait seconds=20 \
    + walk x=$3 y=$4 + wait jobs=true max=60 + wait seconds=20 + build_ghosts r=60 2>&1 | grep -E "ghosts|failed|missing|error" | tr -s ' ' | tr '\n' ' '
  echo "chunk $i"
done
