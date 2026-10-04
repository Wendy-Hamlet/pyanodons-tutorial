#!/bin/bash
# Runs round.sh N times (default 4), waiting W game seconds (default 60) between rounds; every
# 4th round also visits the iron outpost, every 8th the tin outpost.
cd /d/factorio-explore/py-tutorial/tools/agent
for i in $(seq 1 ${1:-4}); do
  out=$(bash /c/tmp/cf-agent/round.sh ${3:-50} 2>&1)
  if echo "$out" | grep -q "^5h used"; then echo "$out"; exit 2; fi
  echo "$out" | grep -E "error|time:|research:|finished|free_slots" | tr -s ' ' | tr '\n' ' '; echo
  [ $((i % 4)) -eq 0 ] && bash /c/tmp/cf-agent/outpost.sh 130 -437 20
  [ $((i % 4)) -eq 2 ] && bash /c/tmp/cf-agent/outpost.sh -347 -126 12
  [ $i -lt ${1:-4} ] && node a.js wait seconds=${2:-60} max=$(( ${2:-60} + 20 )) > /dev/null
done
node a.js prod window=ten_minutes 2>&1 | grep -E "automation-science|iron-plate|copper-plate|tin-plate|glass\"" | tr -s ' ' | tr '\n' ' '; echo
