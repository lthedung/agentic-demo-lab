# GitLab CI/CD Session 3 Demo Design

## Goal

Create a complete workshop demo for GitLab CI/CD Session 3. The demo should support live presentation between slides and show tests, coverage, artifacts, SonarQube integration, Quality Gate behavior, and fail-fast pipeline behavior.

The GitLab runner tag for every pipeline job is `runner_01`.

## Audience and teaching style

The demo is for learners who are new to GitLab CI/CD or already understand basic concepts such as `.gitlab-ci.yml`, stages, jobs, variables, artifacts, and runners. The demo should be practical, simple to explain in Vietnamese, and easy to run during a two-hour session.

## Repository structure

The implementation will add a self-contained demo app instead of mixing code into the existing documentation files.

```text
demo-app/
  package.json
  tsconfig.json
  vitest.config.ts
  src/
    grade.ts
    order.ts
    auth.ts
  tests/
    grade.test.ts
    order.test.ts
    auth.test.ts
  sonar-project.properties
  README.md

.gitlab-ci.yml
docs/
  session3-demo-guide.md
```

`demo-app/` keeps the runnable code separate from the session notes and PDF. The root `.gitlab-ci.yml` makes the repository ready to push to GitLab and run with `runner_01`.

## Demo application

The demo app will be a small TypeScript project using Vitest.

The source modules are intentionally simple:

- `grade.ts`: classify a student score into a grade.
- `order.ts`: calculate order total, discount, and shipping.
- `auth.ts`: validate simple login input.

These examples are familiar enough for beginners and still useful for demonstrating unit tests, failed assertions, coverage, and static analysis.

## Test and coverage tooling

The project will use:

- TypeScript for source code.
- Vitest for unit tests.
- Vitest V8 coverage provider for coverage output.
- JUnit reporter output at `reports/junit.xml`.
- LCOV coverage output at `coverage/lcov.info` for SonarQube.

Local commands should include:

```bash
cd demo-app
npm install
npm test
npm run test:ci
npm run coverage
npm run build
```

## GitLab CI pipeline

The pipeline will have three stages:

```yaml
stages:
  - test
  - quality
  - build
```

All jobs will use the runner tag:

```yaml
default:
  tags:
    - runner_01
```

Planned jobs:

1. `unit-test`
   - Runs `npm run test:ci`.
   - Produces JUnit XML.
   - Saves `reports/` and `coverage/` as artifacts.
   - Uses `artifacts.when: always` so reports remain available even when tests fail.

2. `coverage-check`
   - Runs coverage with thresholds.
   - Saves coverage artifacts.
   - Demonstrates how coverage can fail a pipeline when threshold is not met.

3. `sonar-scan`
   - Uses `sonarsource/sonar-scanner-cli:latest`.
   - Reads `SONAR_HOST_URL` and `SONAR_TOKEN` from GitLab CI/CD Variables.
   - Uses `sonar.qualitygate.wait=true` so Quality Gate can fail the job.
   - Runs only when both Sonar variables exist.

4. `build-demo`
   - Runs TypeScript build after validation jobs.
   - Demonstrates that build/package steps should happen after quality checks pass.

## SonarQube configuration

`demo-app/sonar-project.properties` will define:

```properties
sonar.projectKey=gitlab-cicd-session3-demo
sonar.projectName=GitLab CI/CD Session 3 Demo
sonar.sources=src
sonar.tests=tests
sonar.exclusions=node_modules/**,dist/**,coverage/**,reports/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.testExecutionReportPaths=reports/junit.xml
```

`SONAR_HOST_URL` and `SONAR_TOKEN` must not be committed to the repository. The demo guide will instruct the presenter to configure them in GitLab CI/CD Variables.

## Slide-to-demo mapping

The implementation will add `docs/session3-demo-guide.md` in Vietnamese. It will map the live demo to the slide flow:

- Slides 1–2: introduce the repo, demo app, GitLab runner `runner_01`, and the session agenda.
- Slides 3–5: show automated test execution in pipeline.
- Slides 6–7: explain test types and show the `unit-test` job structure.
- Slides 8–10: show JUnit report and coverage artifacts.
- Slide 11: intentionally break a test or assertion to show fail-fast behavior.
- Slides 12–15: run coverage, inspect `coverage/lcov.info`, explain coverage limitations and threshold behavior.
- Slides 16–21: configure SonarQube variables, run scanner, explain Quality Gate pass/fail.
- Slides 22–23: recap the full flow and provide Q&A prompts.

## Demo scenarios

The demo should support these live scenarios:

1. Healthy pipeline
   - Tests pass.
   - Coverage report is generated.
   - Build runs after validation.

2. Failed unit test
   - Presenter changes one expected value or one simple implementation line.
   - `unit-test` fails.
   - JUnit report remains available.
   - Later stages do not proceed.

3. Coverage threshold failure
   - Presenter raises threshold or adds untested code.
   - Coverage job fails.
   - Coverage artifacts remain available.

4. SonarQube Quality Gate
   - When SonarQube variables are configured, scanner sends analysis to SonarQube.
   - If the Quality Gate fails, the `sonar-scan` job fails.

## Error handling and security

The pipeline should avoid hard-coded secrets. SonarQube token and URL are read only from GitLab CI/CD Variables.

The demo guide should call out common debugging checks:

- Runner tag mismatch with `runner_01`.
- Missing GitLab CI/CD Variables.
- Incorrect coverage report path.
- Missing artifacts after a failed job.
- SonarQube project key mismatch.

## Out of scope

The implementation will not set up a local SonarQube server with Docker by default. The session focuses on GitLab CI/CD integration flow, so SonarQube is treated as an existing service configured through `SONAR_HOST_URL` and `SONAR_TOKEN`.

The implementation will not create multiple Git branches for demo scenarios. Instead, the guide will describe small local edits that create pass/fail scenarios during the live presentation.

## Acceptance criteria

- `demo-app` can install dependencies and run tests locally.
- `npm run test:ci` produces a JUnit report.
- `npm run coverage` produces `coverage/lcov.info`.
- `.gitlab-ci.yml` uses `runner_01` for jobs.
- Pipeline has test, quality, and build stages.
- SonarQube configuration reads coverage from the generated LCOV path.
- Vietnamese demo guide maps practical demo steps to the Session 3 slide flow.
