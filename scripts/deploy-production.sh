#!/bin/sh
set -eu

version="${CI_COMMIT_TAG:-local-production}"
deploy_time="${DEPLOY_TIME:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

sh scripts/render-env.sh \
  production \
  "$version" \
  "$deploy_time" \
  direct \
  blue \
  preview/production \
  state/production.json

echo "Deployed $version to production"
