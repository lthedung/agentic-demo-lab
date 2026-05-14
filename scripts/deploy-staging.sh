#!/bin/sh
set -eu

version="${CI_COMMIT_SHORT_SHA:-local-staging}"
deploy_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

sh scripts/render-env.sh \
  staging \
  "$version" \
  "$deploy_time" \
  direct \
  blue \
  preview/staging \
  state/staging.json

echo "Deployed $version to staging"
