#!/bin/sh
set -eu

version="${CI_COMMIT_TAG:-local-production}"
deploy_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
history_file="state/production-history.json"
current_version=""
current_color="blue"

if [ -f state/production.json ]; then
  current_version="$(grep '"version"' state/production.json | cut -d '"' -f 4)"
  current_color="$(grep '"activeColor"' state/production.json | cut -d '"' -f 4)"
fi

sh scripts/render-env.sh \
  production \
  "$version" \
  "$deploy_time" \
  direct \
  blue \
  preview/production \
  state/production.json

mkdir -p state
cat > "$history_file" <<EOF
{
  "currentVersion": "$version",
  "previousVersion": "$current_version",
  "currentColor": "blue",
  "previousColor": "$current_color",
  "lastAction": "deploy",
  "rolledBackFrom": "",
  "rolledBackTo": "",
  "updatedAt": "$deploy_time"
}
EOF

echo "Deployed $version to production"
if [ -n "$current_version" ]; then
  echo "Previous production version saved: $current_version"
fi
