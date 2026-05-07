# GitLab CI/CD Session 3 Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete GitLab CI/CD Session 3 workshop demo with a TypeScript/Vitest app, GitLab pipeline using `runner_01`, coverage/JUnit artifacts, SonarQube config, and a Vietnamese slide-by-slide demo guide.

**Architecture:** Add a self-contained `demo-app/` TypeScript project so runnable demo code stays separate from session materials. The root `.gitlab-ci.yml` orchestrates test, quality, and build stages, while `docs/session3-demo-guide.md` maps live demo actions to the Session 3 slides.

**Tech Stack:** TypeScript, Node.js 20, Vitest, V8 coverage, GitLab CI/CD, SonarQube scanner.

---

## File Structure

- Create `demo-app/package.json`: npm scripts and dev dependencies for TypeScript, Vitest, coverage, and JUnit output.
- Create `demo-app/tsconfig.json`: TypeScript compiler settings for `src/` and `tests/`.
- Create `demo-app/vitest.config.ts`: test, coverage, threshold, reporter, and JUnit output configuration.
- Create `demo-app/src/grade.ts`: score-to-grade logic for simple unit test examples.
- Create `demo-app/src/order.ts`: order total logic for branch/coverage examples.
- Create `demo-app/src/auth.ts`: login input validation for simple validation examples.
- Create `demo-app/tests/grade.test.ts`: unit tests for grade classification.
- Create `demo-app/tests/order.test.ts`: unit tests for order totals and shipping/discount branches.
- Create `demo-app/tests/auth.test.ts`: unit tests for auth validation.
- Create `demo-app/sonar-project.properties`: SonarQube project, source, test, exclusion, and LCOV paths.
- Create `demo-app/README.md`: local run commands and demo scenario quick reference.
- Create `.gitlab-ci.yml`: GitLab pipeline with `runner_01`, test, quality, and build jobs.
- Create `docs/session3-demo-guide.md`: Vietnamese slide-to-demo guide.

## Task 1: Scaffold TypeScript/Vitest demo app

**Files:**
- Create: `demo-app/package.json`
- Create: `demo-app/tsconfig.json`
- Create: `demo-app/vitest.config.ts`

- [ ] **Step 1: Create `demo-app/package.json`**

```json
{
  "name": "gitlab-cicd-session3-demo",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "build": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:ci": "vitest run --coverage --reporter=default --reporter=junit --outputFile=reports/junit.xml",
    "coverage": "vitest run --coverage"
  },
  "devDependencies": {
    "@vitest/coverage-v8": "latest",
    "typescript": "latest",
    "vitest": "latest"
  }
}
```

- [ ] **Step 2: Create `demo-app/tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "types": ["vitest/globals"]
  },
  "include": ["src", "tests", "vitest.config.ts"]
}
```

- [ ] **Step 3: Create `demo-app/vitest.config.ts`**

```ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    include: ['tests/**/*.test.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      reportsDirectory: 'coverage',
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80
      }
    }
  }
});
```

- [ ] **Step 4: Verify package metadata parses**

Run: `node -e "JSON.parse(require('fs').readFileSync('demo-app/package.json','utf8')); console.log('package.json ok')"`

Expected: prints `package.json ok`.

- [ ] **Step 5: Commit scaffold**

```bash
git add demo-app/package.json demo-app/tsconfig.json demo-app/vitest.config.ts
git commit -m "chore: scaffold CI demo app"
```

## Task 2: Add grade module with tests

**Files:**
- Create: `demo-app/src/grade.ts`
- Create: `demo-app/tests/grade.test.ts`

- [ ] **Step 1: Write grade tests first**

Create `demo-app/tests/grade.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { classifyGrade } from '../src/grade';

describe('classifyGrade', () => {
  it('returns excellent for scores from 90 to 100', () => {
    expect(classifyGrade(95)).toBe('excellent');
  });

  it('returns good for scores from 75 to 89', () => {
    expect(classifyGrade(82)).toBe('good');
  });

  it('returns passed for scores from 50 to 74', () => {
    expect(classifyGrade(60)).toBe('passed');
  });

  it('returns failed for scores below 50', () => {
    expect(classifyGrade(42)).toBe('failed');
  });

  it('rejects scores outside the valid range', () => {
    expect(() => classifyGrade(120)).toThrow('Score must be between 0 and 100');
    expect(() => classifyGrade(-1)).toThrow('Score must be between 0 and 100');
  });
});
```

- [ ] **Step 2: Run grade tests and verify expected failure**

Run: `cd demo-app && npm test -- tests/grade.test.ts`

Expected: fails because `../src/grade` does not exist.

- [ ] **Step 3: Implement grade module**

Create `demo-app/src/grade.ts`:

```ts
export type Grade = 'excellent' | 'good' | 'passed' | 'failed';

export function classifyGrade(score: number): Grade {
  if (score < 0 || score > 100) {
    throw new Error('Score must be between 0 and 100');
  }

  if (score >= 90) {
    return 'excellent';
  }

  if (score >= 75) {
    return 'good';
  }

  if (score >= 50) {
    return 'passed';
  }

  return 'failed';
}
```

- [ ] **Step 4: Run grade tests and verify pass**

Run: `cd demo-app && npm test -- tests/grade.test.ts`

Expected: all tests in `grade.test.ts` pass.

- [ ] **Step 5: Commit grade module**

```bash
git add demo-app/src/grade.ts demo-app/tests/grade.test.ts
git commit -m "feat: add grade classification demo"
```

## Task 3: Add order module with branch coverage tests

**Files:**
- Create: `demo-app/src/order.ts`
- Create: `demo-app/tests/order.test.ts`

- [ ] **Step 1: Write order tests first**

Create `demo-app/tests/order.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { calculateOrderTotal } from '../src/order';

describe('calculateOrderTotal', () => {
  it('adds standard shipping for small orders', () => {
    expect(
      calculateOrderTotal({
        items: [
          { name: 'Book', quantity: 1, unitPrice: 20 },
          { name: 'Pen', quantity: 2, unitPrice: 5 }
        ]
      })
    ).toEqual({ subtotal: 30, discount: 0, shipping: 5, total: 35 });
  });

  it('applies free shipping for orders from 100', () => {
    expect(
      calculateOrderTotal({
        items: [{ name: 'Keyboard', quantity: 1, unitPrice: 120 }]
      })
    ).toEqual({ subtotal: 120, discount: 0, shipping: 0, total: 120 });
  });

  it('applies 10 percent discount before shipping when coupon is valid', () => {
    expect(
      calculateOrderTotal({
        items: [{ name: 'Monitor', quantity: 1, unitPrice: 200 }],
        couponCode: 'SESSION3'
      })
    ).toEqual({ subtotal: 200, discount: 20, shipping: 0, total: 180 });
  });

  it('rejects empty carts', () => {
    expect(() => calculateOrderTotal({ items: [] })).toThrow('Order must contain at least one item');
  });
});
```

- [ ] **Step 2: Run order tests and verify expected failure**

Run: `cd demo-app && npm test -- tests/order.test.ts`

Expected: fails because `../src/order` does not exist.

- [ ] **Step 3: Implement order module**

Create `demo-app/src/order.ts`:

```ts
export type OrderItem = {
  name: string;
  quantity: number;
  unitPrice: number;
};

export type OrderInput = {
  items: OrderItem[];
  couponCode?: string;
};

export type OrderTotal = {
  subtotal: number;
  discount: number;
  shipping: number;
  total: number;
};

export function calculateOrderTotal(order: OrderInput): OrderTotal {
  if (order.items.length === 0) {
    throw new Error('Order must contain at least one item');
  }

  const subtotal = order.items.reduce((sum, item) => sum + item.quantity * item.unitPrice, 0);
  const discount = order.couponCode === 'SESSION3' ? subtotal * 0.1 : 0;
  const shipping = subtotal >= 100 ? 0 : 5;
  const total = subtotal - discount + shipping;

  return { subtotal, discount, shipping, total };
}
```

- [ ] **Step 4: Run order tests and verify pass**

Run: `cd demo-app && npm test -- tests/order.test.ts`

Expected: all tests in `order.test.ts` pass.

- [ ] **Step 5: Commit order module**

```bash
git add demo-app/src/order.ts demo-app/tests/order.test.ts
git commit -m "feat: add order calculation demo"
```

## Task 4: Add auth module with validation tests

**Files:**
- Create: `demo-app/src/auth.ts`
- Create: `demo-app/tests/auth.test.ts`

- [ ] **Step 1: Write auth tests first**

Create `demo-app/tests/auth.test.ts`:

```ts
import { describe, expect, it } from 'vitest';
import { validateLoginInput } from '../src/auth';

describe('validateLoginInput', () => {
  it('accepts a valid email and password', () => {
    expect(validateLoginInput({ email: 'student@example.com', password: 'secret123' })).toEqual({
      valid: true,
      errors: []
    });
  });

  it('rejects invalid email addresses', () => {
    expect(validateLoginInput({ email: 'student', password: 'secret123' })).toEqual({
      valid: false,
      errors: ['Email is invalid']
    });
  });

  it('rejects short passwords', () => {
    expect(validateLoginInput({ email: 'student@example.com', password: '123' })).toEqual({
      valid: false,
      errors: ['Password must have at least 8 characters']
    });
  });

  it('returns all validation errors together', () => {
    expect(validateLoginInput({ email: 'student', password: '123' })).toEqual({
      valid: false,
      errors: ['Email is invalid', 'Password must have at least 8 characters']
    });
  });
});
```

- [ ] **Step 2: Run auth tests and verify expected failure**

Run: `cd demo-app && npm test -- tests/auth.test.ts`

Expected: fails because `../src/auth` does not exist.

- [ ] **Step 3: Implement auth module**

Create `demo-app/src/auth.ts`:

```ts
export type LoginInput = {
  email: string;
  password: string;
};

export type ValidationResult = {
  valid: boolean;
  errors: string[];
};

export function validateLoginInput(input: LoginInput): ValidationResult {
  const errors: string[] = [];

  if (!input.email.includes('@')) {
    errors.push('Email is invalid');
  }

  if (input.password.length < 8) {
    errors.push('Password must have at least 8 characters');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}
```

- [ ] **Step 4: Run auth tests and verify pass**

Run: `cd demo-app && npm test -- tests/auth.test.ts`

Expected: all tests in `auth.test.ts` pass.

- [ ] **Step 5: Commit auth module**

```bash
git add demo-app/src/auth.ts demo-app/tests/auth.test.ts
git commit -m "feat: add login validation demo"
```

## Task 5: Verify local test, coverage, and build commands

**Files:**
- Modify only if needed after command failures: `demo-app/package.json`, `demo-app/vitest.config.ts`, `demo-app/tsconfig.json`

- [ ] **Step 1: Install dependencies**

Run: `cd demo-app && npm install`

Expected: creates `demo-app/package-lock.json` and installs dependencies successfully.

- [ ] **Step 2: Run all tests**

Run: `cd demo-app && npm test`

Expected: all test files pass.

- [ ] **Step 3: Run CI test command**

Run: `cd demo-app && npm run test:ci`

Expected: tests pass, `demo-app/reports/junit.xml` exists, and `demo-app/coverage/lcov.info` exists.

- [ ] **Step 4: Run coverage command**

Run: `cd demo-app && npm run coverage`

Expected: coverage passes thresholds and `demo-app/coverage/` contains HTML and LCOV output.

- [ ] **Step 5: Run TypeScript build check**

Run: `cd demo-app && npm run build`

Expected: TypeScript exits successfully with no type errors.

- [ ] **Step 6: Commit lockfile and any config fixes**

```bash
git add demo-app/package-lock.json demo-app/package.json demo-app/vitest.config.ts demo-app/tsconfig.json
git commit -m "chore: verify demo app tooling"
```

## Task 6: Add SonarQube configuration

**Files:**
- Create: `demo-app/sonar-project.properties`

- [ ] **Step 1: Create SonarQube properties**

Create `demo-app/sonar-project.properties`:

```properties
sonar.projectKey=gitlab-cicd-session3-demo
sonar.projectName=GitLab CI/CD Session 3 Demo
sonar.sources=src
sonar.tests=tests
sonar.exclusions=node_modules/**,dist/**,coverage/**,reports/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.testExecutionReportPaths=reports/junit.xml
```

- [ ] **Step 2: Verify expected coverage path exists after CI test command**

Run: `test -f demo-app/coverage/lcov.info && test -f demo-app/reports/junit.xml && echo 'sonar inputs ok'`

Expected: prints `sonar inputs ok` after Task 5 has run `npm run test:ci`.

- [ ] **Step 3: Commit SonarQube config**

```bash
git add demo-app/sonar-project.properties
git commit -m "chore: add SonarQube demo config"
```

## Task 7: Add GitLab CI pipeline

**Files:**
- Create: `.gitlab-ci.yml`

- [ ] **Step 1: Create `.gitlab-ci.yml`**

```yaml
stages:
  - test
  - quality
  - build

default:
  tags:
    - runner_01

unit-test:
  stage: test
  image: node:20
  script:
    - cd demo-app
    - npm ci
    - npm run test:ci
  artifacts:
    when: always
    reports:
      junit: demo-app/reports/junit.xml
    paths:
      - demo-app/reports/
      - demo-app/coverage/
    expire_in: 1 week

coverage-check:
  stage: test
  image: node:20
  script:
    - cd demo-app
    - npm ci
    - npm run coverage
  artifacts:
    when: always
    paths:
      - demo-app/coverage/
    expire_in: 1 week

sonar-scan:
  stage: quality
  image: sonarsource/sonar-scanner-cli:latest
  dependencies:
    - unit-test
  script:
    - cd demo-app
    - >
      sonar-scanner
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.token=$SONAR_TOKEN
      -Dsonar.qualitygate.wait=true
  rules:
    - if: '$SONAR_HOST_URL && $SONAR_TOKEN'

build-demo:
  stage: build
  image: node:20
  script:
    - cd demo-app
    - npm ci
    - npm run build
```

- [ ] **Step 2: Verify runner tag appears in pipeline**

Run: `grep -n "runner_01" .gitlab-ci.yml`

Expected: prints the line containing `runner_01`.

- [ ] **Step 3: Verify pipeline contains required jobs**

Run: `grep -n "unit-test:\|coverage-check:\|sonar-scan:\|build-demo:" .gitlab-ci.yml`

Expected: prints all four job names.

- [ ] **Step 4: Commit GitLab CI pipeline**

```bash
git add .gitlab-ci.yml
git commit -m "ci: add Session 3 demo pipeline"
```

## Task 8: Add demo app README

**Files:**
- Create: `demo-app/README.md`

- [ ] **Step 1: Create README**

````markdown
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

Open `vitest.config.ts` and temporarily raise the line threshold:

```ts
lines: 100,
```

Run:

```bash
npm run coverage
```

Coverage should fail if the project does not reach 100%. Revert the threshold after the demo.

## SonarQube variables

Configure these in GitLab CI/CD Variables instead of committing secrets:

- `SONAR_HOST_URL`
- `SONAR_TOKEN`
````

- [ ] **Step 2: Commit README**

```bash
git add demo-app/README.md
git commit -m "docs: add demo app instructions"
```

## Task 9: Add Vietnamese slide-to-demo guide

**Files:**
- Create: `docs/session3-demo-guide.md`

- [ ] **Step 1: Create guide**

````markdown
# GitLab CI/CD Session 3 — Demo Guide

Tài liệu này dùng để trình bày demo xen kẽ với slide Session 3: Running Tests in Pipeline, Code Coverage, và Code Quality Integration with SonarQube.

## Chuẩn bị trước buổi học

1. Push repository này lên GitLab.
2. Đảm bảo GitLab Runner có tag `runner_01` đang online.
3. Nếu demo SonarQube, cấu hình GitLab CI/CD Variables:
   - `SONAR_HOST_URL`: URL SonarQube server.
   - `SONAR_TOKEN`: token dùng cho scanner.
4. Chạy thử local:

```bash
cd demo-app
npm install
npm test
npm run test:ci
npm run coverage
npm run build
```

## Slides 1–2: Introduction và agenda

Mở repository và giới thiệu nhanh:

- `demo-app/` là project TypeScript nhỏ dùng để demo test, coverage và SonarQube.
- `.gitlab-ci.yml` là pipeline chạy trên runner tag `runner_01`.
- Pipeline có ba stage chính: `test`, `quality`, `build`.

Thông điệp nói trên slide: pipeline tốt không chỉ build/deploy mà còn kiểm soát chất lượng code.

## Slides 3–5: Running test in pipeline

Mở `.gitlab-ci.yml` và chỉ job `unit-test`:

```yaml
unit-test:
  stage: test
  image: node:20
  script:
    - cd demo-app
    - npm ci
    - npm run test:ci
```

Giải thích flow:

1. Developer push code.
2. GitLab tạo pipeline.
3. Runner `runner_01` nhận job.
4. Job cài dependency và chạy test.
5. Test pass thì pipeline đi tiếp, test fail thì pipeline dừng.

Demo local trước khi push:

```bash
cd demo-app
npm test
```

## Slides 6–7: Test types và test stage

Mở thư mục `demo-app/tests/`:

- `grade.test.ts`: unit test cho logic xếp loại điểm.
- `order.test.ts`: test nhiều branch như discount và shipping.
- `auth.test.ts`: test validate input.

Nhấn mạnh: demo này dùng unit test vì nhanh, ổn định và phù hợp chạy ở mọi merge request.

Chỉ ra trong `.gitlab-ci.yml` rằng test stage được tách thành `unit-test` và `coverage-check`, thay vì gom tất cả vào một job lớn.

## Slides 8–10: Test reports và artifacts

Mở phần artifact của job `unit-test`:

```yaml
artifacts:
  when: always
  reports:
    junit: demo-app/reports/junit.xml
  paths:
    - demo-app/reports/
    - demo-app/coverage/
```

Giải thích:

- `reports.junit` giúp GitLab hiểu file JUnit XML và hiển thị test report.
- `paths` lưu lại file/folder để download sau khi job kết thúc.
- `when: always` giúp vẫn lưu report khi test fail.

Demo local:

```bash
npm run test:ci
```

Sau đó chỉ ra:

- `reports/junit.xml`
- `coverage/lcov.info`
- `coverage/index.html`

## Slide 11: Fail fast

Tạo lỗi có chủ đích trong `demo-app/tests/grade.test.ts`.

Đổi:

```ts
expect(classifyGrade(95)).toBe('excellent');
```

Thành:

```ts
expect(classifyGrade(95)).toBe('good');
```

Chạy:

```bash
npm test -- tests/grade.test.ts
```

Giải thích:

- Test fail thì job fail.
- Job fail thì pipeline fail.
- Pipeline không nên tiếp tục build hoặc deploy khi validation cơ bản đã fail.

Sau demo, revert lại assertion đúng.

## Slides 12–15: Code coverage

Chạy:

```bash
npm run coverage
```

Mở `coverage/index.html` hoặc xem output terminal.

Giải thích:

- Coverage cho biết code đã được test chạy qua bao nhiêu.
- Coverage không chứng minh test có assertion tốt.
- `coverage/lcov.info` là input cho SonarQube.

Demo coverage threshold fail:

Mở `vitest.config.ts`, đổi tạm:

```ts
lines: 100,
```

Chạy lại:

```bash
npm run coverage
```

Giải thích: coverage threshold có thể làm pipeline fail nếu team muốn enforce tiêu chuẩn chất lượng.

Sau demo, revert threshold về `80`.

## Slides 16–21: Code quality và SonarQube

Mở `demo-app/sonar-project.properties`:

```properties
sonar.sources=src
sonar.tests=tests
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

Giải thích:

- SonarQube scanner không tự tạo coverage.
- Pipeline phải chạy test và generate coverage trước.
- Scanner đọc `coverage/lcov.info` rồi gửi kết quả lên SonarQube server.

Mở job `sonar-scan`:

```yaml
sonar-scan:
  stage: quality
  image: sonarsource/sonar-scanner-cli:latest
  dependencies:
    - unit-test
```

Nhấn mạnh:

- `SONAR_HOST_URL` và `SONAR_TOKEN` phải nằm trong GitLab CI/CD Variables.
- Không hard-code token vào repository.
- `sonar.qualitygate.wait=true` cho phép Quality Gate fail thì job fail.

## Slides 22–23: Demo recap và Q&A

Tổng kết flow:

1. Push code.
2. Runner `runner_01` chạy pipeline.
3. `unit-test` chạy test và tạo JUnit report.
4. `coverage-check` tạo coverage artifact.
5. `sonar-scan` gửi kết quả lên SonarQube nếu có biến cấu hình.
6. `build-demo` chỉ chạy khi validation trước đó pass.

Câu hỏi gợi ý:

- Dự án thật nên bắt đầu coverage threshold bao nhiêu?
- Test nào nên chạy ở merge request, test nào nên chạy nightly?
- Quality Gate fail thì nên block merge hay chỉ warning?
- Legacy project coverage thấp thì áp dụng Quality Gate thế nào?
- Khi artifact không xuất hiện thì kiểm tra gì trước?
````

- [ ] **Step 2: Commit guide**

```bash
git add docs/session3-demo-guide.md
git commit -m "docs: add Session 3 demo guide"
```

## Task 10: Final verification

**Files:**
- Verify: all files created in previous tasks

- [ ] **Step 1: Run full local verification**

Run: `cd demo-app && npm test && npm run test:ci && npm run coverage && npm run build`

Expected: all commands pass.

- [ ] **Step 2: Verify generated report files**

Run: `test -f demo-app/reports/junit.xml && test -f demo-app/coverage/lcov.info && echo 'reports ok'`

Expected: prints `reports ok`.

- [ ] **Step 3: Verify GitLab runner tag**

Run: `grep -n "runner_01" .gitlab-ci.yml`

Expected: prints the `runner_01` tag line.

- [ ] **Step 4: Verify docs exist**

Run: `test -f docs/session3-demo-guide.md && test -f demo-app/README.md && echo 'docs ok'`

Expected: prints `docs ok`.

- [ ] **Step 5: Check git status**

Run: `git status --short`

Expected: only intended uncommitted files remain, or clean if all task commits were made.

## Self-Review

Spec coverage:

- Demo app structure: covered by Tasks 1–4.
- Local test/coverage/build commands: covered by Task 5 and Task 10.
- SonarQube config: covered by Task 6.
- GitLab CI with `runner_01`: covered by Task 7.
- Vietnamese slide-to-demo guide: covered by Task 9.
- README quick scenario guide: covered by Task 8.
- No local SonarQube Docker setup: respected by Task 6 and Task 9.
- No multi-branch demo flow: respected by README and guide instructions using small local edits.

Placeholder scan: no `TBD`, `TODO`, `implement later`, or vague implementation steps remain.

Type consistency: exported functions `classifyGrade`, `calculateOrderTotal`, and `validateLoginInput` match test imports and README examples.
