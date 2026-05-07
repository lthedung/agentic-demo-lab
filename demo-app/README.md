# GitLab CI/CD Session 3 Demo App

This app supports the Session 3 demo for running tests in GitLab CI/CD, generating coverage, storing artifacts, and integrating with SonarQube.

## Local commands

```bash
npm install
npm test
npm run test:ci
npm run coverage
npm run build
```

## Demo scenarios

### Healthy pipeline

Keep the source and tests unchanged. The GitLab pipeline should run `unit-test`, `coverage-check`, optional `sonar-scan`, and `build-demo`.

### Failed unit test

Open `tests/grade.test.ts` and change this assertion:

```ts
expect(classifyGrade(95)).toBe('excellent');
```

Change it to:

```ts
expect(classifyGrade(95)).toBe('good');
```

Run:

```bash
npm test -- tests/grade.test.ts
```

The test should fail. Revert the assertion after the demo.

### Coverage threshold failure

Open `vitest.config.ts` and temporarily raise the line threshold above the current report:

```ts
lines: 101,
```

Run:

```bash
npm run coverage
```

Coverage should fail because coverage cannot exceed 100%. Revert the threshold after the demo.

## SonarQube variables

Configure these in GitLab CI/CD Variables instead of committing secrets:

- `SONAR_HOST_URL`
- `SONAR_TOKEN`
