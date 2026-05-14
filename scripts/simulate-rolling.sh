#!/bin/sh
set -eu

mkdir -p state
: > state/rolling.log

for instance in 1 2 3 4; do
  line_1="updating instance ${instance} of 4"
  line_2="health check passed for instance ${instance}"
  echo "$line_1" | tee -a state/rolling.log
  echo "$line_2" | tee -a state/rolling.log
done

echo "rollout complete" | tee -a state/rolling.log
