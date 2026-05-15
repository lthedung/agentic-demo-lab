#!/bin/sh
set -eu

[ -f app/index.html ] || {
  echo "Missing app/index.html" >&2
  exit 1
}

grep -q '__APP_NAME__' app/index.html || {
  echo "Missing __APP_NAME__ placeholder" >&2
  exit 1
}

grep -q '__VERSION__' app/index.html || {
  echo "Missing __VERSION__ placeholder" >&2
  exit 1
}

grep -q '__ENVIRONMENT__' app/index.html || {
  echo "Missing __ENVIRONMENT__ placeholder" >&2
  exit 1
}

grep -q '__DEPLOY_TIME__' app/index.html || {
  echo "Missing __DEPLOY_TIME__ placeholder" >&2
  exit 1
}

grep -q '__STRATEGY__' app/index.html || {
  echo "Missing __STRATEGY__ placeholder" >&2
  exit 1
}

grep -q '__ACTIVE_COLOR__' app/index.html || {
  echo "Missing __ACTIVE_COLOR__ placeholder" >&2
  exit 1
}

echo "Static app template checks passed"

[ -x scripts/build.sh ] || {
  echo "scripts/build.sh is not executable" >&2
  exit 1
}

[ -x scripts/render-env.sh ] || {
  echo "scripts/render-env.sh is not executable" >&2
  exit 1
}

rm -rf dist
sh scripts/build.sh

[ -f dist/index.html ] || {
  echo "Missing dist/index.html" >&2
  exit 1
}

grep -q 'GitLab CI/CD Session 4 Demo' dist/index.html || {
  echo "Build output missing demo title" >&2
  exit 1
}

[ -x scripts/deploy-dev.sh ] || {
  echo "scripts/deploy-dev.sh is not executable" >&2
  exit 1
}

[ -x scripts/deploy-staging.sh ] || {
  echo "scripts/deploy-staging.sh is not executable" >&2
  exit 1
}

[ -x scripts/deploy-production.sh ] || {
  echo "scripts/deploy-production.sh is not executable" >&2
  exit 1
}

[ -x scripts/rollback-production.sh ] || {
  echo "scripts/rollback-production.sh is not executable" >&2
  exit 1
}

[ -x scripts/rollback-blue-green.sh ] || {
  echo "scripts/rollback-blue-green.sh is not executable" >&2
  exit 1
}

rm -rf preview
mkdir -p preview

CI_COMMIT_SHORT_SHA=abc1234 sh scripts/deploy-dev.sh
[ -f state/dev.json ] || {
  echo "Missing state/dev.json" >&2
  exit 1
}
grep -q '"environment": "dev"' state/dev.json || {
  echo "Dev state missing environment" >&2
  exit 1
}

CI_COMMIT_SHORT_SHA=def5678 sh scripts/deploy-staging.sh
[ -f state/staging.json ] || {
  echo "Missing state/staging.json" >&2
  exit 1
}
grep -q '"environment": "staging"' state/staging.json || {
  echo "Staging state missing environment" >&2
  exit 1
}

CI_COMMIT_TAG=v1.0.0 sh scripts/deploy-production.sh
CI_COMMIT_TAG=v1.0.1 sh scripts/deploy-production.sh
[ -f state/production.json ] || {
  echo "Missing state/production.json" >&2
  exit 1
}
grep -q '"environment": "production"' state/production.json || {
  echo "Production state missing environment" >&2
  exit 1
}
[ -f state/production-history.json ] || {
  echo "Missing state/production-history.json" >&2
  exit 1
}
grep -q '"currentVersion": "v1.0.1"' state/production-history.json || {
  echo "Production history missing current version" >&2
  exit 1
}
grep -q '"previousVersion": "v1.0.0"' state/production-history.json || {
  echo "Production history missing previous version" >&2
  exit 1
}
sh scripts/rollback-production.sh
grep -q '"version": "v1.0.0"' state/production.json || {
  echo "Production rollback did not restore previous version" >&2
  exit 1
}
grep -q '"lastAction": "rollback"' state/production-history.json || {
  echo "Production history missing rollback action" >&2
  exit 1
}
grep -q '"rolledBackTo": "v1.0.0"' state/production-history.json || {
  echo "Production history missing rollback target" >&2
  exit 1
}

[ -x scripts/simulate-rolling.sh ] || {
  echo "scripts/simulate-rolling.sh is not executable" >&2
  exit 1
}

[ -x scripts/simulate-blue-green.sh ] || {
  echo "scripts/simulate-blue-green.sh is not executable" >&2
  exit 1
}

sh scripts/simulate-rolling.sh > /tmp/rolling-output.txt
[ -f state/rolling.log ] || {
  echo "Missing state/rolling.log" >&2
  exit 1
}
grep -q 'updating instance 4 of 4' state/rolling.log || {
  echo "Rolling log missing final instance update" >&2
  exit 1
}

sh scripts/simulate-blue-green.sh
[ -f state/blue-green.json ] || {
  echo "Missing state/blue-green.json" >&2
  exit 1
}
grep -q '"activeColor": "green"' state/blue-green.json || {
  echo "Blue-green state missing active green color" >&2
  exit 1
}
sh scripts/rollback-blue-green.sh
grep -q '"activeColor": "blue"' state/blue-green.json || {
  echo "Blue-green rollback did not restore blue as active color" >&2
  exit 1
}

[ -f .gitlab-ci.yml ] || {
  echo "Missing .gitlab-ci.yml" >&2
  exit 1
}

grep -q '^stages:' .gitlab-ci.yml || {
  echo "Pipeline missing stages" >&2
  exit 1
}

grep -q 'deploy_production:' .gitlab-ci.yml || {
  echo "Pipeline missing deploy_production job" >&2
  exit 1
}

grep -q 'when: manual' .gitlab-ci.yml || {
  echo "Pipeline missing manual production gate" >&2
  exit 1
}

grep -q 'simulate_rolling_update:' .gitlab-ci.yml || {
  echo "Pipeline missing rolling simulation job" >&2
  exit 1
}

grep -q 'simulate_blue_green:' .gitlab-ci.yml || {
  echo "Pipeline missing blue-green simulation job" >&2
  exit 1
}

grep -q 'rollback_production:' .gitlab-ci.yml || {
  echo "Pipeline missing rollback_production job" >&2
  exit 1
}

grep -q 'rollback_blue_green:' .gitlab-ci.yml || {
  echo "Pipeline missing rollback_blue_green job" >&2
  exit 1
}

[ -f README.md ] || {
  echo "Missing README.md" >&2
  exit 1
}

grep -q 'runner_01' README.md || {
  echo "README missing runner_01 guidance" >&2
  exit 1
}

grep -q 'develop' README.md || {
  echo "README missing develop flow" >&2
  exit 1
}

grep -q 'v1.0.0' README.md || {
  echo "README missing production tag demo" >&2
  exit 1
}
