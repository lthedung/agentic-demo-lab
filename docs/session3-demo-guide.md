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

## Cách tạo SonarQube URL và token

### Trường hợp dùng SonarQube Server nội bộ

`SONAR_HOST_URL` là địa chỉ web UI của SonarQube Server mà GitLab Runner có thể truy cập được.

Ví dụ:

```text
http://sonarqube.company.local:9000
https://sonarqube.company.com
```

Cách lấy URL:

1. Mở SonarQube trên browser.
2. Copy phần origin của URL, gồm protocol, host và port nếu có.
3. Không copy thêm path như `/projects`, `/dashboard`, hoặc `/api`.

Ví dụ nếu browser đang mở:

```text
https://sonarqube.company.com/dashboard?id=gitlab-cicd-session3-demo
```

Thì GitLab variable cần đặt là:

```text
SONAR_HOST_URL=https://sonarqube.company.com
```

Cách tạo token:

1. Đăng nhập SonarQube bằng user có quyền phân tích project.
2. Vào avatar/user menu ở góc phải.
3. Chọn **My Account** hoặc **My Profile**.
4. Mở tab **Security**.
5. Ở phần token, tạo token mới cho CI/CD scanner.
6. Copy token ngay sau khi tạo vì thường token chỉ hiển thị một lần.
7. Lưu token vào GitLab CI/CD Variables với key `SONAR_TOKEN`.

### Trường hợp dùng SonarQube Cloud

Với SonarQube Cloud, URL thường dùng cho scanner là:

```text
SONAR_HOST_URL=https://sonarcloud.io
```

Cách tạo token tương tự:

1. Đăng nhập SonarQube Cloud.
2. Vào user/account menu.
3. Mở **Security**.
4. Generate token dùng cho CI analysis.
5. Copy token và lưu vào GitLab CI/CD Variables với key `SONAR_TOKEN`.

### Cấu hình trong GitLab

Trong GitLab project:

1. Vào **Settings** → **CI/CD**.
2. Mở rộng phần **Variables**.
3. Thêm variable `SONAR_HOST_URL`.
4. Thêm variable `SONAR_TOKEN`.
5. Với `SONAR_TOKEN`, bật **Masked** nếu GitLab cho phép.
6. Bật **Protected** nếu pipeline chỉ chạy trên protected branch như `main` hoặc `release`.

Không ghi trực tiếp token vào `.gitlab-ci.yml`, `sonar-project.properties`, README hoặc slide.

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

Mở `vitest.config.ts`, đổi tạm threshold cao hơn report hiện tại:

```ts
lines: 101,
```

Chạy lại:

```bash
npm run coverage
```

Giải thích: coverage threshold có thể làm pipeline fail nếu team muốn enforce tiêu chuẩn chất lượng. Ở demo này, `101` chắc chắn fail vì coverage không thể vượt quá 100%.

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

Trong demo này, `unit-test` chạy `npm run test:ci`, nên job này vừa tạo JUnit report vừa tạo `coverage/lcov.info` để `sonar-scan` đọc lại qua artifact dependency.

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
