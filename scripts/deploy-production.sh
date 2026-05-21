#!/bin/sh
set -eu

echo "== Deploy to production environment =="

release=${CI_COMMIT_TAG:-v$(cat app/version.txt)}
previous=${PREVIOUS_PRODUCTION_RELEASE:-none}

if [ -f state/production.env ]; then
  current_from_state=$(grep '^CURRENT_RELEASE=' state/production.env | cut -d= -f2- || true)
  if [ -n "$current_from_state" ]; then
    previous=$current_from_state
  fi
fi

mkdir -p state
cat > state/production.env <<STATE
CURRENT_RELEASE=$release
PREVIOUS_RELEASE=$previous
STATE

echo "Manual production gate accepted"
echo "Production deployment simulation completed"
cat state/production.env
