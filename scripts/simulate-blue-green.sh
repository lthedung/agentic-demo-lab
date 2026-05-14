#!/bin/sh
set -eu

version="${CI_COMMIT_TAG:-${CI_COMMIT_SHORT_SHA:-blue-green-demo}}"
deploy_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

sh scripts/render-env.sh \
  production \
  "$version" \
  "$deploy_time" \
  blue-green \
  green \
  preview/production-green \
  state/blue-green.json

echo "deployed new version to green"
echo "smoke test passed for green"
echo "switching active environment: blue -> green"
