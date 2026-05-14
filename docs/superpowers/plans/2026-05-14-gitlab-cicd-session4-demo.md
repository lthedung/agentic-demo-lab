# GitLab CI/CD Session 4 Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a small GitLab CI/CD workshop repo that demonstrates branch-based environment promotion, GitLab Environments, manual production approval, and mock rolling/blue-green deployment strategies using runner `runner_01`.

**Architecture:** The repo stays intentionally small: a static HTML demo app, shell scripts for build/test/deploy simulation, JSON state files for environment outputs, and a short `.gitlab-ci.yml` that maps feature/develop/main/tag flows into GitLab jobs and environments. All deployment behavior is simulated through generated files and learner-friendly logs so the workshop teaches release flow without depending on external infrastructure.

**Tech Stack:** Static HTML, POSIX shell scripts, JSON state files, GitLab CI/CD YAML, GitLab Runner container `runner_01`

---

## File Structure

- Create: `app/index.html` — base static page template for the workshop demo
- Create: `scripts/build.sh` — builds the distributable demo files into `dist/`
- Create: `scripts/test.sh` — validates required demo files and output markers
- Create: `scripts/render-env.sh` — shared renderer for generating environment-specific HTML and JSON state
- Create: `scripts/deploy-dev.sh` — writes `dev` deployment state and rendered output
- Create: `scripts/deploy-staging.sh` — writes `staging` deployment state and rendered output
- Create: `scripts/deploy-production.sh` — writes `production` deployment state and rendered output from a tag/manual flow
- Create: `scripts/simulate-rolling.sh` — prints sequential rolling-update logs and writes `state/rolling.log`
- Create: `scripts/simulate-blue-green.sh` — switches active color in `state/blue-green.json` and renders a production strategy view
- Create: `state/.gitkeep` — keeps the state directory in git before first run
- Create: `.gitlab-ci.yml` — GitLab pipeline for build, test, deploy, and strategy jobs
- Create: `README.md` — presenter cheat sheet for the workshop setup and live-demo steps

### Task 1: Create the static app template

**Files:**
- Create: `app/index.html`
- Test: `scripts/test.sh`

- [ ] **Step 1: Write the failing test**

Create `scripts/test.sh` with this initial check so the repo fails until `app/index.html` exists:

```sh
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `sh scripts/test.sh`
Expected: FAIL with `Missing app/index.html`

- [ ] **Step 3: Write minimal implementation**

Create `app/index.html` with this exact content:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>GitLab CI/CD Session 4 Demo</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 32px;
        background: #0f172a;
        color: #e2e8f0;
      }
      .card {
        max-width: 760px;
        margin: 0 auto;
        background: #1e293b;
        border-radius: 16px;
        padding: 24px;
        box-shadow: 0 20px 45px rgba(15, 23, 42, 0.35);
      }
      .badge {
        display: inline-block;
        margin: 4px 8px 4px 0;
        padding: 6px 10px;
        border-radius: 999px;
        background: #334155;
      }
      .value {
        color: #38bdf8;
        font-weight: bold;
      }
    </style>
  </head>
  <body>
    <main class="card">
      <h1>__APP_NAME__</h1>
      <p>Workshop demo for GitLab CI/CD Session 4.</p>
      <p class="badge">Version: <span class="value">__VERSION__</span></p>
      <p class="badge">Environment: <span class="value">__ENVIRONMENT__</span></p>
      <p class="badge">Deploy time: <span class="value">__DEPLOY_TIME__</span></p>
      <p class="badge">Strategy: <span class="value">__STRATEGY__</span></p>
      <p class="badge">Active color: <span class="value">__ACTIVE_COLOR__</span></p>
    </main>
  </body>
</html>
```

- [ ] **Step 4: Run test to verify it passes**

Run: `sh scripts/test.sh`
Expected: PASS with `Static app template checks passed`

- [ ] **Step 5: Commit**

```bash
git add app/index.html scripts/test.sh
git commit -m "feat: add workshop demo app template"
```

### Task 2: Add build and render scripts

**Files:**
- Create: `scripts/build.sh`
- Create: `scripts/render-env.sh`
- Modify: `scripts/test.sh`

- [ ] **Step 1: Write the failing test**

Append these checks to `scripts/test.sh`:

```sh
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `sh scripts/test.sh`
Expected: FAIL with `scripts/build.sh is not executable`

- [ ] **Step 3: Write minimal implementation**

Create `scripts/build.sh`:

```sh
#!/bin/sh
set -eu

mkdir -p dist
cp app/index.html dist/index.html
```

Create `scripts/render-env.sh`:

```sh
#!/bin/sh
set -eu

environment="$1"
version="$2"
deploy_time="$3"
strategy="$4"
active_color="$5"
out_dir="$6"
state_file="$7"

mkdir -p "$out_dir"
mkdir -p "$(dirname "$state_file")"

sed \
  -e "s#__APP_NAME__#GitLab CI/CD Session 4 Demo#g" \
  -e "s#__VERSION__#$version#g" \
  -e "s#__ENVIRONMENT__#$environment#g" \
  -e "s#__DEPLOY_TIME__#$deploy_time#g" \
  -e "s#__STRATEGY__#$strategy#g" \
  -e "s#__ACTIVE_COLOR__#$active_color#g" \
  app/index.html > "$out_dir/index.html"

cat > "$state_file" <<EOF
{
  "version": "$version",
  "environment": "$environment",
  "deployTime": "$deploy_time",
  "strategy": "$strategy",
  "activeColor": "$active_color"
}
EOF
```

Make both scripts executable:

```bash
chmod +x scripts/build.sh scripts/render-env.sh
```

- [ ] **Step 4: Run test to verify it passes**

Run: `sh scripts/test.sh`
Expected: PASS with `Static app template checks passed`

- [ ] **Step 5: Commit**

```bash
git add scripts/build.sh scripts/render-env.sh scripts/test.sh
git commit -m "feat: add build and render scripts"
```

### Task 3: Implement dev, staging, and production deploy scripts

**Files:**
- Create: `scripts/deploy-dev.sh`
- Create: `scripts/deploy-staging.sh`
- Create: `scripts/deploy-production.sh`
- Create: `state/.gitkeep`
- Modify: `scripts/test.sh`

- [ ] **Step 1: Write the failing test**

Append these checks to `scripts/test.sh`:

```sh
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
[ -f state/production.json ] || {
  echo "Missing state/production.json" >&2
  exit 1
}
grep -q '"environment": "production"' state/production.json || {
  echo "Production state missing environment" >&2
  exit 1
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `sh scripts/test.sh`
Expected: FAIL with `scripts/deploy-dev.sh is not executable`

- [ ] **Step 3: Write minimal implementation**

Create `scripts/deploy-dev.sh`:

```sh
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
```

Create `scripts/deploy-staging.sh`:

```sh
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
```

Create `scripts/deploy-production.sh`:

```sh
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
```

Create `state/.gitkeep` as an empty file, then make the deploy scripts executable:

```bash
touch state/.gitkeep
chmod +x scripts/deploy-dev.sh scripts/deploy-staging.sh scripts/deploy-production.sh
```

- [ ] **Step 4: Run test to verify it passes**

Run: `sh scripts/test.sh`
Expected: PASS and see deploy log lines for dev, staging, and production

- [ ] **Step 5: Commit**

```bash
git add scripts/deploy-dev.sh scripts/deploy-staging.sh scripts/deploy-production.sh state/.gitkeep scripts/test.sh
git commit -m "feat: add mock deploy scripts"
```

### Task 4: Add rolling and blue-green strategy simulations

**Files:**
- Create: `scripts/simulate-rolling.sh`
- Create: `scripts/simulate-blue-green.sh`
- Modify: `scripts/test.sh`

- [ ] **Step 1: Write the failing test**

Append these checks to `scripts/test.sh`:

```sh
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `sh scripts/test.sh`
Expected: FAIL with `scripts/simulate-rolling.sh is not executable`

- [ ] **Step 3: Write minimal implementation**

Create `scripts/simulate-rolling.sh`:

```sh
#!/bin/sh
set -eu

mkdir -p state
: > state/rolling.log

for instance in 1 2 3 4; do
  line_1="updating instance ${instance} of 4"
  line_2="health check passed for instance ${instance}"
  echo "$line_1" | tee -a state/rolling.log
  echo "$line_2" | tee -a state/rolling.log
done

echo "rollout complete" | tee -a state/rolling.log
```

Create `scripts/simulate-blue-green.sh`:

```sh
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
```

Make both scripts executable:

```bash
chmod +x scripts/simulate-rolling.sh scripts/simulate-blue-green.sh
```

- [ ] **Step 4: Run test to verify it passes**

Run: `sh scripts/test.sh`
Expected: PASS and see rolling output plus blue/green switch log lines

- [ ] **Step 5: Commit**

```bash
git add scripts/simulate-rolling.sh scripts/simulate-blue-green.sh scripts/test.sh
git commit -m "feat: add deployment strategy simulations"
```

### Task 5: Add the GitLab CI/CD pipeline

**Files:**
- Create: `.gitlab-ci.yml`
- Modify: `scripts/test.sh`

- [ ] **Step 1: Write the failing test**

Append these checks to `scripts/test.sh`:

```sh
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `sh scripts/test.sh`
Expected: FAIL with `Missing .gitlab-ci.yml`

- [ ] **Step 3: Write minimal implementation**

Create `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - deploy
  - strategy

default:
  tags:
    - runner_01

build_demo:
  stage: build
  script:
    - sh scripts/build.sh
  artifacts:
    paths:
      - dist/

validate_demo:
  stage: test
  script:
    - sh scripts/test.sh

.deploy_template: &deploy_template
  stage: deploy
  artifacts:
    paths:
      - preview/
      - state/

.deploy_strategy_template: &deploy_strategy_template
  stage: strategy
  artifacts:
    paths:
      - preview/
      - state/

feature_validation:
  stage: test
  script:
    - echo "Feature branch validation only"
  rules:
    - if: '$CI_COMMIT_BRANCH =~ /^feature\//'

deploy_dev:
  <<: *deploy_template
  script:
    - sh scripts/deploy-dev.sh
  environment:
    name: dev
    url: https://example.invalid/dev
  rules:
    - if: '$CI_COMMIT_BRANCH == "develop"'

deploy_staging:
  <<: *deploy_template
  script:
    - sh scripts/deploy-staging.sh
  environment:
    name: staging
    url: https://example.invalid/staging
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

deploy_production:
  <<: *deploy_template
  script:
    - sh scripts/deploy-production.sh
  environment:
    name: production
    url: https://example.invalid/production
  when: manual
  rules:
    - if: '$CI_COMMIT_TAG =~ /^v.*/'

simulate_rolling_update:
  <<: *deploy_strategy_template
  script:
    - sh scripts/simulate-rolling.sh
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual

simulate_blue_green:
  <<: *deploy_strategy_template
  script:
    - sh scripts/simulate-blue-green.sh
  environment:
    name: production
    url: https://example.invalid/production-green
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual
```

- [ ] **Step 4: Run test to verify it passes**

Run: `sh scripts/test.sh`
Expected: PASS with pipeline checks succeeding

- [ ] **Step 5: Commit**

```bash
git add .gitlab-ci.yml scripts/test.sh
git commit -m "feat: add session 4 gitlab pipeline"
```

### Task 6: Add presenter documentation

**Files:**
- Create: `README.md`
- Modify: `scripts/test.sh`

- [ ] **Step 1: Write the failing test**

Append these checks to `scripts/test.sh`:

```sh
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `sh scripts/test.sh`
Expected: FAIL with `Missing README.md`

- [ ] **Step 3: Write minimal implementation**

Create `README.md`:

```md
# GitLab CI/CD Session 4 Demo

## Purpose
This repository supports a 2-hour workshop on environment management and deployment strategies.

## Demo Flow
- `feature/*` runs validation only
- `develop` deploys to `dev`
- `main` deploys to `staging`
- tag `v1.0.0` exposes a manual production deployment

## Runner
Use GitLab Runner tag `runner_01` so students can see the runner pick up jobs and execute the pipeline.

## Key Commands
```bash
sh scripts/test.sh
sh scripts/build.sh
CI_COMMIT_SHORT_SHA=demo123 sh scripts/deploy-dev.sh
CI_COMMIT_SHORT_SHA=demo456 sh scripts/deploy-staging.sh
CI_COMMIT_TAG=v1.0.0 sh scripts/deploy-production.sh
sh scripts/simulate-rolling.sh
sh scripts/simulate-blue-green.sh
```

## Teaching Notes
- Show the Pipeline view after each branch/tag scenario.
- Open the Environments page to explain deployment history.
- Pause at the manual production gate before clicking deploy.
- Use the strategy logs to explain rolling update and blue/green trade-offs.
```

- [ ] **Step 4: Run test to verify it passes**

Run: `sh scripts/test.sh`
Expected: PASS with README checks succeeding

- [ ] **Step 5: Commit**

```bash
git add README.md scripts/test.sh
git commit -m "docs: add workshop demo guide"
```

### Task 7: End-to-end verification of the workshop repo

**Files:**
- Modify: `README.md`
- Test: `scripts/test.sh`
- Test: `.gitlab-ci.yml`

- [ ] **Step 1: Write the failing verification checklist**

Add this checklist section to the end of `README.md`:

```md
## Verification Checklist
- [ ] `sh scripts/test.sh` passes locally
- [ ] Feature branch pipeline shows validation without deployment
- [ ] `develop` branch deploys to `dev`
- [ ] `main` branch deploys to `staging`
- [ ] Tag `v1.0.0` exposes manual production deployment
- [ ] `simulate_rolling_update` prints instance-by-instance rollout logs
- [ ] `simulate_blue_green` switches active color to green
- [ ] GitLab Environments page shows `dev`, `staging`, and `production`
```

- [ ] **Step 2: Run the local verification suite**

Run: `sh scripts/test.sh`
Expected: PASS

- [ ] **Step 3: Run the strategy scripts manually**

Run:

```bash
sh scripts/simulate-rolling.sh
sh scripts/simulate-blue-green.sh
```

Expected output includes:
- `updating instance 1 of 4`
- `rollout complete`
- `switching active environment: blue -> green`

- [ ] **Step 4: Validate branch and tag flows in GitLab**

Run these git commands one at a time from a clean branch workflow:

```bash
git checkout -b feature/session4-demo
git commit --allow-empty -m "test: trigger feature pipeline"
git push -u origin feature/session4-demo
```

Expected in GitLab: validation jobs run, no deploy environment update.

```bash
git checkout -b develop-demo
git commit --allow-empty -m "test: trigger develop deploy"
git push -u origin develop-demo:develop
```

Expected in GitLab: `deploy_dev` runs and `dev` environment updates.

```bash
git checkout main
git commit --allow-empty -m "test: trigger staging deploy"
git push origin main
```

Expected in GitLab: `deploy_staging` runs and `staging` environment updates.

```bash
git tag v1.0.0-demo
git push origin v1.0.0-demo
```

Expected in GitLab: `deploy_production` appears as manual.

- [ ] **Step 5: Commit the verification checklist**

```bash
git add README.md
git commit -m "docs: add session 4 verification checklist"
```

## Self-Review

### Spec coverage
- Environment flow is implemented in Task 5 and verified in Task 7.
- GitLab Environments and manual production approval are implemented in Task 5 and verified in Task 7.
- Rolling update and blue/green simulations are implemented in Task 4 and demonstrated again in Task 7.
- Presenter guidance and workshop timeline support are covered by Task 6 and Task 7.

### Placeholder scan
- No `TODO`, `TBD`, or deferred instructions remain.
- Each code-changing step includes exact file content or exact appended content.
- Each validation step includes exact commands and expected outcomes.

### Type consistency
- The state JSON keys are consistently `version`, `environment`, `deployTime`, `strategy`, and `activeColor`.
- The script names used across tasks and `.gitlab-ci.yml` match exactly.
- The branch and tag flows stay consistent with the approved spec.
