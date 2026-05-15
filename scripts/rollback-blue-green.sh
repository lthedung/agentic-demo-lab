#!/bin/sh
set -eu

state_file="state/blue-green.json"
[ -f "$state_file" ] || {
  echo "Missing $state_file" >&2
  exit 1
}

version="$(grep '"version"' "$state_file" | cut -d '"' -f 4)"
current_color="$(grep '"activeColor"' "$state_file" | cut -d '"' -f 4)"
rollback_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

if [ "$current_color" = "green" ]; then
  rollback_color="blue"
  out_dir="preview/production-blue"
else
  rollback_color="green"
  out_dir="preview/production-green"
fi

sh scripts/render-env.sh \
  production \
  "$version" \
  "$rollback_time" \
  blue-green \
  "$rollback_color" \
  "$out_dir" \
  "$state_file"

echo "Current active environment: $current_color"
echo "Switching active environment: $current_color -> $rollback_color"
echo "Blue/green rollback complete"
