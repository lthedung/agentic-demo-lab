#!/bin/sh
set -eu

echo "== Blue/green rollback simulation =="

if [ -f state/blue-green.env ]; then
  active=$(grep '^ACTIVE_COLOR=' state/blue-green.env | cut -d= -f2-)
  standby=$(grep '^STANDBY_COLOR=' state/blue-green.env | cut -d= -f2-)
  previous=$(grep '^PREVIOUS_ACTIVE_COLOR=' state/blue-green.env | cut -d= -f2-)
else
  active=${ACTIVE_COLOR:-green}
  standby=${STANDBY_COLOR:-blue}
  previous=${PREVIOUS_ACTIVE_COLOR:-blue}
fi

cat > state/blue-green.env <<STATE
ACTIVE_COLOR=$previous
STANDBY_COLOR=$active
PREVIOUS_ACTIVE_COLOR=$standby
STATE

echo "Traffic rolled back from $active to $previous"
cat state/blue-green.env
