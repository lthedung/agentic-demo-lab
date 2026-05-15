#!/bin/sh
set -eu

history_file="state/production-history.json"
production_state_file="state/production.json"

[ -f "$history_file" ] || {
  echo "Missing $history_file" >&2
  exit 1
}

current_version="$(grep '"currentVersion"' "$history_file" | cut -d '"' -f 4)"
previous_version="$(grep '"previousVersion"' "$history_file" | cut -d '"' -f 4)"
previous_color="$(grep '"previousColor"' "$history_file" | cut -d '"' -f 4)"
rollback_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

[ -n "$previous_version" ] || {
  echo "No previous production version available for rollback" >&2
  exit 1
}

sh scripts/render-env.sh \
  production \
  "$previous_version" \
  "$rollback_time" \
  direct \
  "$previous_color" \
  preview/production \
  "$production_state_file"

cat > "$history_file" <<EOF
{
  "currentVersion": "$previous_version",
  "previousVersion": "$current_version",
  "currentColor": "$previous_color",
  "previousColor": "blue",
  "lastAction": "rollback",
  "rolledBackFrom": "$current_version",
  "rolledBackTo": "$previous_version",
  "updatedAt": "$rollback_time"
}
EOF

echo "Current production version: $current_version"
echo "Rolling back to: $previous_version"
echo "Production rollback complete"
