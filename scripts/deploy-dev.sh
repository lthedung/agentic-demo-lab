#!/bin/sh
set -eu

version="${CI_COMMIT_SHORT_SHA:-local-dev}"
deploy_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

sh scripts/render-env.sh \
  dev \
  "$version" \
  "$deploy_time" \
  direct \
  blue \
  preview/dev \
  state/dev.json

echo "Deployed $version to dev"
