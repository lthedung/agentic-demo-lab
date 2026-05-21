#!/bin/sh
set -eu

echo "== Roll back production environment =="

if [ -f state/production.env ]; then
  current=$(grep '^CURRENT_RELEASE=' state/production.env | cut -d= -f2-)
  previous=$(grep '^PREVIOUS_RELEASE=' state/production.env | cut -d= -f2-)
else
  current=${CI_COMMIT_TAG:-v$(cat app/version.txt)}
  previous=${PREVIOUS_PRODUCTION_RELEASE:-none}
fi

if [ "$previous" = "none" ] || [ -z "$previous" ]; then
  echo "No previous release recorded; nothing to roll back"
  exit 0
fi

cat > state/production.env <<STATE
CURRENT_RELEASE=$previous
PREVIOUS_RELEASE=$current
STATE

echo "Production rolled back from $current to $previous"
cat state/production.env
