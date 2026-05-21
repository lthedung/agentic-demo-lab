#!/bin/sh
set -eu

echo "== Rolling update simulation =="

for instance in 1 2 3; do
  echo "Updating instance $instance"
  echo "Health check passed for instance $instance"
done

echo "Rolling update completed without downtime"
