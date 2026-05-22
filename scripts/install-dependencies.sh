#!/bin/sh
set -eu

echo "== Install dependency simulation =="

mkdir -p .demo-cache

if [ -f .demo-cache/dependency.txt ]; then
  echo "Cache hit: dependency already exists"
  cat .demo-cache/dependency.txt
else
  echo "Cache miss: installing dependency"
  echo "demo_dependency=installed" > .demo-cache/dependency.txt
fi
