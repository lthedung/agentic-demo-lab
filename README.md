# GitLab CI/CD Session 4 Demo

## Purpose
This repository supports a 2-hour workshop on environment management and deployment strategies.

## Demo Flow
- `feature/*` runs validation only
- `develop` deploys to `dev`
- `main` deploys to `staging`
- tag `v1.0.0` exposes manual production deployment and rollback
- release tag pipelines also expose manual production strategy demos for rolling update, blue/green, and blue/green rollback

## Runner
Use GitLab Runner tag `runner_01` so students can see the runner pick up jobs and execute the pipeline.

## Key Commands
```bash
sh scripts/test.sh
sh scripts/build.sh
CI_COMMIT_SHORT_SHA=demo123 sh scripts/deploy-dev.sh
CI_COMMIT_SHORT_SHA=demo456 sh scripts/deploy-staging.sh
CI_COMMIT_TAG=v1.0.0 sh scripts/deploy-production.sh
sh scripts/rollback-production.sh
sh scripts/simulate-rolling.sh
sh scripts/simulate-blue-green.sh
sh scripts/rollback-blue-green.sh
```

## Teaching Notes
- Show the Pipeline view after each branch/tag scenario.
- Open the Environments page to explain deployment history.
- Pause at the manual production gate before clicking deploy.
- After production deploy, trigger rollback once so students see recovery as a real GitLab action.
- Use the strategy logs to explain rolling update and blue/green trade-offs.
- Trigger blue/green rollback to show traffic switching back to the previous active color.

## Verification Checklist
- [ ] `sh scripts/test.sh` passes locally
- [ ] Feature branch pipeline shows validation without deployment
- [ ] `develop` branch deploys to `dev`
- [ ] `main` branch deploys to `staging`
- [ ] Tag `v1.0.0` exposes manual production deployment and rollback
- [ ] `rollback_production` restores the previous production version
- [ ] `simulate_rolling_update` prints instance-by-instance rollout logs
- [ ] `simulate_blue_green` switches active color to green
- [ ] `rollback_blue_green` switches active color back to blue
- [ ] GitLab Environments page shows `dev`, `staging`, and `production`
