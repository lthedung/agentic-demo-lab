# GitLab CI/CD Session 4 Demo Design

## Goal
Prepare a 2-hour workshop-friendly demo that supports the speaker notes in [gitlab_cicd_session_4_speaker_notes_vi.md](../../gitlab_cicd_session_4_speaker_notes_vi.md). The demo should emphasize environment flow, GitLab Environments, manual production approval, and deployment strategy concepts without relying on fragile production-like infrastructure.

## Audience and Teaching Intent
The audience already knows basic GitLab CI/CD concepts, can read a `.gitlab-ci.yml`, and has seen tests, coverage, and SonarQube in earlier sessions. The demo should focus on release control, not on debugging infrastructure. It should be visual enough for a workshop, but stable enough to run repeatedly in class.

## Scope
The demo will cover three core teaching points:

1. Environment flow from branch and tag rules
   - `feature/*` runs validation only
   - `develop` deploys to `dev`
   - `main` deploys to `staging`
   - tag `v*` exposes manual production deployment
2. GitLab Environments and deployment history
   - environment names
   - environment URLs
   - deployment history and latest deployment visibility
   - manual production approval
3. Deployment strategy concepts
   - rolling update as a sequential instance update simulation
   - blue/green as a traffic switch simulation

The demo will not include Kubernetes, real server deployment, real secrets management, or a real multi-service application.

## Demo Approach
Use a minimal repository with a tiny static app and mock deployment scripts.

The pipeline will be real from GitLab’s perspective: jobs will be executed by the GitLab Runner container `runner_01`, environments will be declared in `.gitlab-ci.yml`, and manual production approval will be demonstrated with a real manual job.

The deployment target will be simulated locally using generated files and state files instead of external infrastructure. This preserves the teaching value while minimizing demo failure risk.

## Recommended Repository Structure

```text
app/
  index.html
scripts/
  build.sh
  test.sh
  deploy-dev.sh
  deploy-staging.sh
  deploy-production.sh
  simulate-rolling.sh
  simulate-blue-green.sh
state/
  dev.json
  staging.json
  production.json
  blue-green.json
  rolling.log
.gitlab-ci.yml
README.md
```

## Static App Design
The static app should be intentionally small and readable. A single HTML page is enough.

The page should display:
- app name
- app version
- current environment
- deploy time
- deployment mode or strategy label
- active color for blue/green simulation

The page exists to make deployment state visible to learners. It does not need JavaScript-heavy behavior or a build framework.

## Pipeline Design
The pipeline should remain short enough to explain during class. It should include build, test, and deploy stages, plus optional strategy demonstration jobs.

### Branch and tag flow
- `feature/*`
  - run build and test
  - do not deploy
- `develop`
  - run build and test
  - auto deploy to `dev`
- `main`
  - run build and test
  - auto deploy to `staging`
- tag `v*`
  - run build and test
  - expose `deploy_production` as a manual job

### Strategy jobs
Two additional jobs should exist for explicit demonstration during the strategy section:
- `simulate_rolling_update`
- `simulate_blue_green`

These jobs are teaching jobs, not part of the normal release promotion flow.

## Environment Design
Three core GitLab environments should be declared:
- `dev`
- `staging`
- `production`

Each deployment job should define:
- `environment.name`
- `environment.url`

The URLs can point to mock or local-friendly targets if available. If no reliable local serving setup is available, the environment URLs may point to simple placeholder pages or stable local outputs, but the pipeline must still declare them so the UI clearly shows environment tracking.

## Deployment Simulation Design
Each deploy job should update a small state file and regenerate the static page content for the target environment.

### Dev deploy
`deploy-dev.sh` should:
- record commit or version metadata
- mark environment as `dev`
- write deploy time
- update the dev state artifact

### Staging deploy
`deploy-staging.sh` should:
- record commit or version metadata
- mark environment as `staging`
- write deploy time
- update the staging state artifact

### Production deploy
`deploy-production.sh` should:
- record tag or release metadata
- mark environment as `production`
- write deploy time
- update the production state artifact
- be invoked only from a manual job

## Rolling Update Simulation
The rolling update script should simulate a multi-instance deployment in logs rather than relying on orchestration software.

The script should emit clear learner-facing steps such as:
- updating instance 1 of 4
- health check passed
- updating instance 2 of 4
- health check passed
- rollout complete

The purpose is to illustrate:
- sequential replacement
- reduced downtime
- mixed-version risk during rollout

The script output should be simple enough to narrate live.

## Blue/Green Simulation
The blue/green script should simulate two production targets:
- blue
- green

The script should:
- deploy the new version to the inactive color
- simulate a smoke test
- switch active color in a state file
- preserve the previous color as rollback candidate

The page or state output should make the active color obvious so learners can immediately understand what changed.

## Role of GitLab Runner `runner_01`
The demo should make the runner visible as an execution actor.

`runner_01` is responsible for:
- receiving jobs from GitLab
- running job steps inside the configured container environment
- printing logs for build, test, deploy, and strategy simulations
- producing artifacts or updated state outputs

The demo should not require the runner to reach real servers. Its value is showing that GitLab coordinates pipelines while the runner executes work.

## Classroom Demo Timeline

### Part 1: Framing
Explain the shift from CI to CD and define the three themes:
- environment flow
- manual release control
- deployment strategies

### Part 2: Environment flow
Show the repository structure and `.gitlab-ci.yml`, then demonstrate:
- feature branch pipeline with no deploy
- `develop` to `dev`
- `main` to `staging`

Open GitLab pipeline views and Environments UI during this section.

### Part 3: Manual production gate
Create or use tag `v1.0.0`, show that production deployment appears as manual, explain why the job does not auto-run, then trigger it.

### Part 4: Strategy demo
Run:
- rolling update simulation
- blue/green simulation

Use the logs and state changes to explain trade-offs.

### Part 5: Wrap-up
Summarize the relationship between:
- release flow
- environment control
- deployment safety
- rollback thinking

## Failure Reduction Strategy
The demo should be optimized for stability.

### Avoid
- Kubernetes or Docker orchestration dependencies in the teaching path
- real remote servers
- real secrets handling
- database migrations
- many moving services

### Prepare in advance
- one working feature branch example
- one working `develop` example
- one working `main` example
- one working release tag such as `v1.0.0`
- at least one previously successful pipeline to fall back to in the UI

### If a live action fails
The session should still be teachable from:
- GitLab pipeline history
- GitLab Environments page
- job logs from a prior successful run
- generated state files and artifacts

## Acceptance Criteria
The demo design is successful if it enables the presenter to show all of the following during class:
- a feature branch pipeline that validates but does not deploy
- a `develop` pipeline that deploys to `dev`
- a `main` pipeline that deploys to `staging`
- a tagged release that exposes a manual production deployment
- GitLab Environments with visible deployment history
- a rolling update simulation with sequential instance logs
- a blue/green simulation with visible active color switching
- job execution visibly handled by `runner_01`

## Non-Goals
This demo is not intended to prove:
- production-grade infrastructure automation
- real zero-downtime deployment guarantees
- real cluster rollout behavior
- real rollback automation
- real secret management discipline

It is intended to teach the mental model and GitLab workflow safely.

## Testing and Verification Expectations
Before the workshop, the demo should be validated by running each intended branch or tag path at least once.

Minimum verification:
- feature branch build and test pass
- `develop` deploy path updates `dev`
- `main` deploy path updates `staging`
- release tag path exposes manual production job and completes when triggered
- rolling update simulation prints the expected sequence
- blue/green simulation switches active state clearly
- environment names and URLs appear correctly in GitLab UI

## Open Implementation Notes
The implementation should prefer very small shell scripts and static files over frameworks or abstractions. If a local preview server is needed for the static page, it should be lightweight and optional rather than central to the workshop flow.

The implementation should also preserve readability for teaching: learners should be able to understand the pipeline and scripts without reading large amounts of code.
