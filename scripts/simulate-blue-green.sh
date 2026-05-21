#!/bin/sh
set -eu

echo "== Blue/green deployment simulation =="

active=blue
standby=green

if [ -f state/blue-green.env ]; then
  active=$(grep '^ACTIVE_COLOR=' state/blue-green.env | cut -d= -f2- || true)
  standby=$(grep '^STANDBY_COLOR=' state/blue-green.env | cut -d= -f2- || true)
fi

if [ "$active" = "blue" ]; then
  new_active=green
  new_standby=blue
else
  new_active=blue
  new_standby=green
fi

mkdir -p state
cat > state/blue-green.env <<STATE
ACTIVE_COLOR=$new_active
STANDBY_COLOR=$new_standby
PREVIOUS_ACTIVE_COLOR=$active
STATE

echo "Traffic switched from $active to $new_active"
cat state/blue-green.env
