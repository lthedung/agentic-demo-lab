# GitLab CI/CD Session 3 — Speaker Notes

**Topic:** Running Tests in Pipeline, Code Coverage, and Code Quality Integration with SonarQube  
**Duration:** Approximately 2 hours  
**Language:** Vietnamese  
**Audience:** Người mới hoặc đã có kiến thức cơ bản về GitLab CI/CD, `.gitlab-ci.yml`, stages, jobs, variables, artifacts, runner.

---

## Tổng quan thời lượng đề xuất

| Phần | Nội dung | Thời lượng |
|---|---|---:|
| 1 | Mở đầu, mục tiêu, agenda | 5 phút |
| 2 | Running test in pipeline | 40 phút |
| 3 | Code coverage | 30 phút |
| 4 | Code quality & SonarQube | 35 phút |
| 5 | Demo, recap, Q&A | 10 phút |
| **Tổng** |  | **120 phút** |

> Gợi ý trình bày:  
> Session này nên nói chậm, giải thích theo flow thực tế của pipeline.  
> Không cần đọc toàn bộ text trên slide.  
> Dùng slide để dẫn ý, còn phần dưới đây là script chi tiết để trình bày.

---

# Slide 1 — GitLab CI/CD Session 3

## Mục tiêu trình bày

Ở slide đầu tiên, chúng ta mở đầu session và kết nối với 2 session trước.

## Speaker Notes

Chào mọi người.

Hôm nay chúng ta sẽ tiếp tục với **GitLab CI/CD Session 3**.

Ở 2 session trước, chúng ta đã đi qua các phần nền tảng của CI/CD.

Chúng ta đã nói về CI/CD là gì, tại sao cần CI/CD, pipeline hoạt động như thế nào, các thành phần như stage, job, runner, variable, artifact, và đặc biệt là cách viết file `.gitlab-ci.yml`.

Session 1 thiên về kiến trúc tổng quan và mindset CI/CD.

Session 2 tập trung nhiều hơn vào GitLab Runner và cách viết pipeline YAML.

Sang session 3, chúng ta sẽ đi vào một phần rất quan trọng trong thực tế dự án: **làm sao để pipeline không chỉ build và deploy, mà còn giúp kiểm soát chất lượng phần mềm**.

Một pipeline tốt không chỉ chạy lệnh tự động.

Một pipeline tốt cần giúp team trả lời các câu hỏi như:

Code mới có làm hỏng chức năng cũ không?

Test có pass không?

Coverage có đủ không?

Code có bug tiềm ẩn không?

Code có vấn đề bảo mật không?

Code có đủ điều kiện để merge hoặc deploy không?

Vì vậy, nội dung hôm nay sẽ tập trung vào 3 nhóm chính:

**Running test in pipeline.**

**Code coverage.**

**Code Quality Integration with SonarQube.**

Sau session này, mục tiêu là mọi người hiểu được test stage nên đặt ở đâu trong pipeline, vì sao cần chạy test tự động, coverage có ý nghĩa gì, và SonarQube giúp chúng ta kiểm soát chất lượng code như thế nào.

---

# Slide 2 — Agenda

## Mục tiêu trình bày

Giới thiệu cấu trúc tổng thể của session.

## Speaker Notes

Agenda hôm nay gồm 3 phần chính.

Phần đầu tiên là **Running test in pipeline**.

Ở phần này, chúng ta sẽ nói về lý do tại sao test nên được đưa vào pipeline, test nên chạy ở giai đoạn nào, các loại test phổ biến, cách chia test stage thành nhiều job nhỏ, cách lưu test report và artifact.

Phần thứ hai là **Code coverage**.

Chúng ta sẽ tìm hiểu coverage là gì, coverage đo cái gì, tại sao coverage hữu ích nhưng không phải là bằng chứng tuyệt đối rằng code không có lỗi.

Chúng ta cũng sẽ nói về coverage threshold, coverage report và cách coverage report được sử dụng bởi các tool như SonarQube.

Phần thứ ba là **Code Quality Integration with SonarQube**.

Ở phần này, chúng ta sẽ nói về code quality, static analysis, SonarQube, Quality Gate, và flow tích hợp SonarQube vào pipeline.

Điểm quan trọng của session này là chúng ta không chỉ học thêm một vài command mới.

Chúng ta sẽ học cách biến pipeline thành một lớp bảo vệ chất lượng phần mềm.

Pipeline phải giúp team phát hiện lỗi sớm, giảm rủi ro khi merge code, và đảm bảo code được release an toàn hơn.

---

# Slide 3 — Running Test in Pipeline

## Mục tiêu trình bày

Chuyển sang phần đầu tiên của session: chạy test trong pipeline.

## Speaker Notes

Bây giờ chúng ta bắt đầu phần đầu tiên: **Running test in pipeline**.

Trước khi nói về command cụ thể, chúng ta cần hiểu lý do tại sao test lại quan trọng trong CI/CD.

Trong thực tế, developer thường test trên máy local trước khi push code.

Việc test local là cần thiết, nhưng không đủ.

Có nhiều vấn đề có thể xảy ra nếu team chỉ dựa vào test thủ công trên local.

Developer có thể quên chạy test.

Máy của mỗi developer có thể khác nhau về OS, version dependency, environment variable hoặc cấu hình runtime.

Có thể xảy ra tình trạng rất quen thuộc là: “máy tôi chạy được”, nhưng khi lên CI hoặc server thì fail.

Ngoài ra, khi team lớn hơn, số lượng merge request nhiều hơn, việc kiểm tra thủ công sẽ không còn scale tốt nữa.

Vì vậy, test cần được đưa vào pipeline để chạy tự động mỗi khi có code thay đổi.

Mỗi lần push code hoặc tạo merge request, pipeline sẽ tự động chạy test và đưa ra kết quả pass hoặc fail.

Nếu test pass, code có thể tiếp tục đi sang các bước sau.

Nếu test fail, pipeline nên dừng lại để developer sửa lỗi trước khi merge hoặc deploy.

Đây là một trong những nguyên tắc cốt lõi của CI: **detect problems early**.

Phát hiện lỗi càng sớm thì chi phí sửa lỗi càng thấp.

---

# Slide 4 — Pipeline Flow

## Mục tiêu trình bày

Giải thích vị trí của test trong pipeline và tại sao test nên chạy sớm.

## Nội dung chính trên slide

Pipeline flow thường gồm:

1. Checkout source code
2. Install dependencies
3. Build / compile
4. Run tests
5. Generate coverage
6. Run quality scan
7. Package artifact
8. Deploy

## Speaker Notes

Slide này mô tả một flow phổ biến trong CI/CD pipeline.

Ở phía trái slide, chúng ta thấy một cách hiểu đơn giản: pipeline chỉ gồm checkout, install, build và deploy.

Đây là cách nhiều người mới bắt đầu thường hình dung.

Nhưng trong thực tế, nếu pipeline chỉ có build và deploy thì vẫn còn thiếu một lớp rất quan trọng, đó là validation.

Validation ở đây có thể bao gồm chạy test, generate coverage report, scan code quality, kiểm tra security hoặc lint.

Một flow pipeline tốt thường đi theo thứ tự như sau.

Đầu tiên là **checkout source code**.

Runner lấy source code từ repository về workspace của job.

Tiếp theo là **install dependencies**.

Ví dụ với Node.js là `npm install` hoặc `npm ci`.

Với Java Maven là tải dependency trong quá trình `mvn test` hoặc `mvn package`.

Với Python là `pip install -r requirements.txt`.

Sau đó là **build hoặc compile**.

Một số project cần compile trước khi test, ví dụ Java, TypeScript, C#.

Một số project script có thể chạy test trực tiếp mà không cần build riêng.

Tiếp theo là **run tests**.

Đây là điểm rất quan trọng.

Test nên được chạy trước khi package hoặc deploy.

Nếu test fail, pipeline nên dừng lại.

Không nên tiếp tục build Docker image, upload artifact, hoặc deploy lên environment.

Sau test, pipeline có thể **generate coverage report**.

Coverage report cho biết phần nào của code đã được test chạy qua.

Sau đó là **run quality scan**.

Ví dụ SonarQube scanner sẽ đọc source code và coverage report, sau đó gửi kết quả lên SonarQube server.

Nếu tất cả validation đều pass, pipeline mới tiếp tục sang **package artifact** và **deploy**.

Thông điệp quan trọng của slide này là:

**Run tests as early as possible.**

Chạy test càng sớm càng tiết kiệm thời gian.

Nếu lỗi nằm ở unit test, chúng ta không cần tốn thêm runner resource để build image hoặc deploy.

Điều này giúp developer nhận feedback nhanh hơn và sửa lỗi nhanh hơn.

Trong nhiều dự án, test stage có thể được chia thành nhiều job chạy song song.

Ví dụ unit test, integration test và API test có thể chạy song song sau build.

Việc này giúp giảm tổng thời gian pipeline.

---

# Slide 5 — Test Automatic Flow

## Mục tiêu trình bày

So sánh manual testing và automated testing trong pipeline.

## Speaker Notes

Slide này giải thích vì sao team không nên chỉ dựa vào manual testing.

Nếu test chỉ chạy thủ công, team thường gặp một số vấn đề.

Thứ nhất, developer có thể quên chạy test trước khi push code.

Điều này rất bình thường trong thực tế, đặc biệt khi deadline gấp hoặc thay đổi code nhỏ.

Thứ hai, mỗi developer có thể có môi trường local khác nhau.

Một người dùng Node 18, người khác dùng Node 20.

Một người có package cache cũ, người khác vừa install lại dependency.

Một người có database local đã có dữ liệu, người khác thì không.

Kết quả là cùng một source code nhưng kết quả test có thể khác nhau.

Thứ ba, manual testing không scale tốt với dự án lớn.

Khi số lượng commit và merge request tăng lên, việc yêu cầu con người tự nhớ và tự chạy test sẽ không còn đáng tin cậy.

CI/CD giải quyết vấn đề này bằng cách tự động hóa validation.

Flow tự động thường như sau:

Developer push code.

Pipeline được trigger.

Pipeline chạy test.

Pipeline tạo test report.

Pipeline trả về kết quả pass hoặc fail.

Nếu pass, code có thể tiếp tục.

Nếu fail, developer nhận feedback và sửa lỗi.

Điểm quan trọng là pipeline áp dụng cùng một tiêu chuẩn cho mọi người.

Không quan trọng ai push code.

Không quan trọng code đến từ branch nào.

Nếu pipeline được cấu hình đúng, mọi thay đổi đều phải đi qua cùng một quá trình kiểm tra.

Lợi ích của automated testing trong pipeline là:

Test chạy tự động.

Kết quả nhất quán hơn.

Phát hiện lỗi sớm hơn.

Giảm lỗi do con người quên thao tác.

Reviewer có thêm thông tin khi review merge request.

Team tự tin hơn khi refactor hoặc thay đổi code.

Một câu có thể nhấn mạnh ở đây là:

**A good pipeline does not rely on people remembering to test. It makes testing automatic, consistent, and reliable.**

---

# Slide 6 — Test Types

## Mục tiêu trình bày

Giải thích các loại test thường gặp và khi nào nên chạy chúng.

## Speaker Notes

Không phải pipeline nào cũng cần chạy tất cả các loại test ở mọi thời điểm.

Một pipeline tốt cần chọn đúng loại test cho đúng giai đoạn.

Đầu tiên là **Unit Tests**.

Unit test kiểm tra các function, class hoặc module nhỏ.

Ví dụ một function tính giá tiền, một service xử lý logic nghiệp vụ, hoặc một method validate input.

Unit test thường nhanh, ít phụ thuộc external service và dễ chạy tự động.

Vì vậy, unit test nên chạy ở gần như mọi branch, mỗi lần push hoặc mỗi merge request.

Tiếp theo là **Integration Tests**.

Integration test kiểm tra nhiều thành phần làm việc cùng nhau.

Ví dụ API service kết nối database.

Hoặc backend gọi message queue.

Hoặc service A gọi service B.

Integration test thường chậm hơn unit test và cần nhiều setup hơn.

Vì vậy, integration test có thể chạy ở merge request, main branch hoặc môi trường staging.

Tiếp theo là **API Tests**.

API test kiểm tra endpoint, status code, request body, response body và contract giữa client với server.

Ví dụ gọi `GET /users`, `POST /orders`, kiểm tra response có đúng format không, status code có đúng không.

API test thường rất hữu ích khi backend được dùng bởi nhiều client khác nhau.

Tiếp theo là **UI / E2E Tests**.

Loại test này mô phỏng hành vi người dùng trên giao diện.

Ví dụ login, thêm sản phẩm vào giỏ hàng, checkout, tạo order.

E2E test thường chậm và dễ flaky hơn, vì phụ thuộc browser, network, data và environment.

Do đó, E2E test không nhất thiết phải chạy ở mọi commit.

Có thể chạy ở main branch, release branch, hoặc nightly pipeline.

Tiếp theo là **Lint Checks**.

Lint kiểm tra coding style, formatting, syntax rule hoặc convention.

Ví dụ ESLint cho JavaScript, flake8 hoặc pylint cho Python.

Lint thường chạy nhanh, nên có thể chạy ở mọi branch.

Cuối cùng là **Security Tests**.

Security test có thể kiểm tra dependency vulnerability, secret leak hoặc security issue trong source code.

Ví dụ dependency có CVE nghiêm trọng, hoặc developer vô tình commit token vào repository.

Security test có thể chạy ở merge request, scheduled pipeline hoặc release pipeline.

Thông điệp chính ở slide này là:

**A good pipeline does not run every test all the time. It runs the right tests at the right time.**

Nếu chạy quá ít test, pipeline không bảo vệ được chất lượng.

Nếu chạy quá nhiều test ở mọi commit, pipeline có thể quá chậm và làm developer mất thời gian chờ.

Vì vậy cần cân bằng giữa tốc độ feedback và mức độ kiểm tra.

---

# Slide 7 — Test Stage

## Mục tiêu trình bày

Giải thích cách thiết kế test stage hiệu quả và có cấu trúc rõ ràng.

## Speaker Notes

Slide này tập trung vào cách tổ chức test stage.

Một lỗi phổ biến khi mới viết pipeline là gom tất cả command vào một job rất lớn.

Ví dụ một job tên là `test` nhưng bên trong chạy lint, unit test, integration test, API test, coverage và security scan.

Cách này có thể chạy được, nhưng khi fail sẽ khó debug.

Developer sẽ phải đọc log rất dài để biết lỗi nằm ở đâu.

Ngoài ra, job lớn cũng khó tối ưu thời gian chạy vì mọi thứ chạy tuần tự trong cùng một job.

Một cách tốt hơn là chia test stage thành nhiều job nhỏ.

Ví dụ:

`unit-test`

`integration-test`

`api-test`

`lint-test`

`coverage`

Mỗi job nên có một trách nhiệm rõ ràng.

`unit-test` chỉ chạy unit test.

`lint-test` chỉ kiểm tra coding rule.

`coverage` chỉ generate hoặc publish coverage report.

Khi một job fail, developer có thể nhìn ngay tên job để biết nhóm lỗi nằm ở đâu.

Nếu `lint-test` fail, có thể là lỗi format hoặc coding style.

Nếu `unit-test` fail, có thể là logic code bị lỗi.

Nếu `coverage` fail, có thể coverage thấp hơn threshold hoặc report không được tạo đúng.

Một test stage tốt cần đảm bảo:

Test được chạy tự động.

Test fail thì job fail.

Job fail thì pipeline fail.

Có report rõ ràng.

Có artifact để xem lại sau khi job kết thúc.

Có log đủ thông tin để debug.

Slide cũng minh họa một ví dụ pipeline stage.

Pipeline có thể gồm các stage như:

`build`

`test`

`package`

Trong stage `test`, có nhiều job con cùng thuộc stage `test`.

Ví dụ trong `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - package

unit-test:
  stage: test
  script:
    - npm test

integration-test:
  stage: test
  script:
    - npm run test:integration

api-test:
  stage: test
  script:
    - npm run test:api

lint-test:
  stage: test
  script:
    - npm run lint

coverage:
  stage: test
  script:
    - npm run test:coverage
```

Điều quan trọng là các job trong cùng một stage có thể chạy song song nếu runner đủ khả năng xử lý.

Việc chia nhỏ giúp pipeline dễ quan sát hơn, dễ debug hơn và dễ tối ưu hơn.

Mục tiêu của test stage không chỉ là pass hoặc fail.

Mục tiêu là giúp developer hiểu nhanh lỗi nằm ở đâu và sửa lỗi ít đoán mò hơn.

---

# Slide 8 — Test Reports

## Mục tiêu trình bày

Giải thích vì sao test report quan trọng hơn việc chỉ nhìn pass/fail.

## Speaker Notes

Khi chạy test trong pipeline, nếu chúng ta chỉ nhìn job pass hoặc fail thì vẫn chưa đủ.

Developer cần biết chi tiết hơn.

Có bao nhiêu test đã chạy?

Bao nhiêu test pass?

Bao nhiêu test fail?

Test nào fail?

Fail ở file nào?

Fail ở dòng nào?

Lỗi cụ thể là gì?

Thời gian chạy test là bao lâu?

Đó là lý do cần test report.

Test report giúp biến output của test thành thông tin dễ đọc, dễ review và dễ debug.

Một format rất phổ biến là **JUnit XML**.

JUnit XML không chỉ dùng cho Java.

Nhiều framework khác cũng có thể export report theo format JUnit XML.

Ví dụ:

Jest có thể generate JUnit report cho JavaScript hoặc TypeScript.

Maven Surefire tạo report cho Java.

Pytest có thể export JUnit XML cho Python.

Nhiều CI/CD platform có thể đọc JUnit XML và hiển thị kết quả trực tiếp trên giao diện pipeline hoặc merge request.

Ví dụ thay vì chỉ thấy job fail, chúng ta có thể thấy:

Total tests: 128

Passed: 123

Failed: 5

Skipped: 0

Duration: 2 minutes 14 seconds

Sau đó bên dưới là danh sách failed tests.

Ví dụ:

`auth.service.spec.ts` fail vì expected status 401 but received 200.

`order.api.test.ts` fail vì timeout.

`PaymentControllerTest` fail vì refund object không được tạo đúng.

Những thông tin này giúp developer đi thẳng vào lỗi.

Không cần đọc toàn bộ log dài từ đầu đến cuối.

Trong thực tế, test report cũng rất hữu ích cho reviewer.

Reviewer có thể xem trong merge request rằng test đã chạy, test nào fail, coverage có thay đổi không.

Điều này làm quá trình review chuyên nghiệp hơn và ít phụ thuộc vào cảm tính hơn.

Ví dụ GitLab CI có thể cấu hình JUnit report như sau:

```yaml
unit-test:
  stage: test
  script:
    - npm ci
    - npm test -- --reporters=default --reporters=jest-junit
  artifacts:
    when: always
    reports:
      junit: junit.xml
```

Ở đây `artifacts.reports.junit` cho GitLab biết file nào là test report.

Ngay cả khi job fail, chúng ta vẫn muốn lưu report, vì vậy có thể dùng `when: always`.

---

# Slide 9 — Artifacts

## Mục tiêu trình bày

Giải thích artifact là gì và tại sao artifact quan trọng trong test stage.

## Speaker Notes

Slide này đang ghi là “Artifactory”, nhưng trong ngữ cảnh GitLab CI thì từ đúng thường là **Artifacts**.

Artifact là file hoặc folder được sinh ra trong quá trình chạy job và được lưu lại sau khi job kết thúc.

Ví dụ khi job chạy test, nó có thể sinh ra:

Test report.

Coverage report.

Log file.

HTML report.

XML report.

Các file này nếu không lưu lại thì sau khi job kết thúc, workspace của runner có thể bị xóa.

Developer sẽ mất dữ liệu để xem lại.

Artifact giải quyết vấn đề đó.

Nó cho phép pipeline upload các file quan trọng lên GitLab để người dùng download hoặc review sau.

Trong test stage, artifact rất hữu ích.

Ví dụ sau khi chạy coverage, project có thể sinh ra folder:

```text
coverage/
  index.html
  coverage.xml
  lcov.info
  jacoco.xml
```

`index.html` có thể là report dạng HTML để mở bằng browser.

`coverage.xml` có thể dùng cho Python hoặc một số tool khác.

`lcov.info` thường dùng cho JavaScript hoặc TypeScript.

`jacoco.xml` thường dùng cho Java.

Ngoài coverage, job có thể sinh ra `junit-report.xml` hoặc `test.log`.

Tất cả những file này nên được lưu lại thành artifact.

Ví dụ GitLab CI:

```yaml
unit-test:
  stage: test
  script:
    - npm ci
    - npm test
    - npm run test:coverage
  artifacts:
    when: always
    paths:
      - coverage/
      - test.log
    reports:
      junit: junit.xml
```

Ở đây `paths` dùng để lưu file hoặc folder bình thường.

`reports` dùng để GitLab hiểu file đó có format đặc biệt, ví dụ JUnit report.

Artifact đặc biệt hữu ích khi test fail.

Nếu không có artifact, developer chỉ có log terminal.

Nếu log quá dài, rất khó đọc.

Nếu có artifact, developer có thể mở report HTML hoặc XML để xem chi tiết.

Thông điệp chính là:

**Artifacts turn temporary job output into reusable evidence for debugging, review, and traceability.**

---

# Slide 10 — Artifacts

## Mục tiêu trình bày

Củng cố nội dung artifact và giải thích lại bằng flow cụ thể.

## Speaker Notes

Slide này lặp lại chủ đề artifact, nên có thể dùng để nhấn mạnh flow minh họa.

Một pipeline test có thể chạy như sau:

Đầu tiên job chạy test.

Sau đó job generate coverage.

Tiếp theo job tạo folder `coverage`.

Sau đó pipeline upload folder này thành artifact.

Cuối cùng developer hoặc reviewer có thể download và review.

Flow này rất thực tế.

Khi pipeline fail, người review không cần truy cập vào máy runner.

Không cần SSH vào server.

Không cần yêu cầu developer gửi file report thủ công.

Tất cả evidence đã được pipeline lưu lại.

Trong GitLab, artifact cũng có thể được truyền từ job này sang job khác.

Ví dụ job `test` tạo coverage report.

Job `sonar-scan` cần đọc coverage report đó.

Nếu 2 job khác nhau, chúng ta cần đảm bảo report được lưu hoặc được truyền đúng cách.

Ví dụ:

```yaml
test:
  stage: test
  script:
    - npm ci
    - npm run test:coverage
  artifacts:
    paths:
      - coverage/
    expire_in: 1 week

sonar-scan:
  stage: quality
  dependencies:
    - test
  script:
    - sonar-scanner
```

Ở đây `sonar-scan` có thể lấy artifact từ job `test`.

Lưu ý rằng artifact không nên lưu quá lâu nếu file lớn.

Có thể dùng `expire_in` để đặt thời gian hết hạn.

Ví dụ:

`expire_in: 1 week`

`expire_in: 3 days`

`expire_in: 1 month`

Tùy chính sách dự án.

Artifact giúp pipeline minh bạch hơn.

Mỗi lần pipeline chạy, chúng ta có bằng chứng rõ ràng về test result, coverage result và các file output liên quan.

---

# Slide 11 — Failure Fast

## Mục tiêu trình bày

Giải thích nguyên tắc fail fast trong CI/CD.

## Speaker Notes

Slide này nói về một nguyên tắc rất quan trọng trong pipeline: **fail fast**.

Fail fast nghĩa là nếu pipeline phát hiện lỗi ở bước sớm, pipeline nên dừng ngay thay vì tiếp tục chạy các bước không cần thiết.

Ví dụ pipeline có các bước:

Build.

Test.

Coverage.

Quality Gate.

Package.

Deploy.

Nếu unit test fail ở bước test, chúng ta không nên tiếp tục coverage, package hoặc deploy.

Vì code đã không đạt điều kiện cơ bản.

Tiếp tục chạy các bước sau sẽ chỉ tốn thời gian và tài nguyên runner.

Fail fast giúp tiết kiệm thời gian.

Fail fast giúp tiết kiệm tài nguyên.

Fail fast giúp developer nhận feedback nhanh.

Fail fast giúp ngăn code lỗi đi xa hơn trong flow release.

Slide có minh họa 2 trường hợp.

Trường hợp thứ nhất là **late stop**.

Pipeline vẫn chạy build, test, package, deploy rồi mới phát hiện lỗi.

Điều này là quá muộn.

Team đã lãng phí thời gian và có thể còn đưa lỗi tới môi trường phía sau.

Trường hợp thứ hai là **fail fast**.

Khi test fail, pipeline dừng ngay.

Developer nhận feedback sớm và sửa lỗi.

Pipeline nên fail trong các trường hợp như:

Build failure.

Unit test failure.

Integration test failure trong môi trường bắt buộc.

Coverage thấp hơn threshold.

SonarQube Quality Gate fail.

Critical vulnerability.

Severe lint error.

Tuy nhiên, có một điểm cần lưu ý.

Không phải mọi issue đều nên làm pipeline fail.

Team cần phân biệt **warning** và **error**.

Warning có thể là minor code smell, small style issue hoặc non-blocking recommendation.

Các vấn đề này có thể được report mà không làm pipeline fail ngay.

Error là các lỗi nghiêm trọng hơn.

Ví dụ broken build, failed required tests, critical security issue hoặc failed Quality Gate.

Những lỗi này nên fail pipeline.

Pipeline tốt cần đủ nghiêm để bảo vệ chất lượng, nhưng không nên quá cứng nhắc đến mức chặn mọi thay đổi nhỏ.

Ví dụ một code smell minor có thể là warning.

Nhưng vulnerability critical thì phải fail.

Đây là cách cân bằng giữa chất lượng và tốc độ development.

---

# Slide 12 — Code Coverage

## Mục tiêu trình bày

Chuyển sang phần Code Coverage.

## Speaker Notes

Bây giờ chúng ta chuyển sang phần thứ hai: **Code Coverage**.

Ở phần trước, chúng ta đã nói về việc chạy test trong pipeline.

Nhưng câu hỏi tiếp theo là:

Test đã chạy rồi, vậy làm sao biết test đang kiểm tra được bao nhiêu phần của source code?

Đó là lúc chúng ta cần code coverage.

Code coverage không thay thế test.

Code coverage là chỉ số giúp đo lường mức độ source code được thực thi khi test chạy.

Ví dụ project có 1.000 dòng code.

Khi chạy test, nếu test đi qua 750 dòng, thì line coverage có thể là 75%.

Coverage giúp team thấy vùng nào đã được test chạm tới và vùng nào chưa được test.

Tuy nhiên, chúng ta cần hiểu đúng.

Coverage không nói rằng test có tốt hay không.

Coverage chỉ nói rằng code đã được thực thi bởi test hay chưa.

Một dòng code được chạy qua không có nghĩa là logic đã được assert đúng.

Vì vậy coverage là một tín hiệu quan trọng, nhưng không phải là bằng chứng tuyệt đối về chất lượng.

---

# Slide 13 — Coverage Basics

## Mục tiêu trình bày

Giải thích coverage là gì, các loại coverage và ví dụ tính coverage.

## Speaker Notes

Slide này giải thích coverage cơ bản.

Code coverage đo phần trăm source code được thực thi khi chạy test.

Ví dụ:

Project có 1.000 dòng code.

Test chạy qua 750 dòng.

Có 250 dòng chưa được chạy.

Line coverage là 75%.

Cách tính đơn giản là:

```text
Coverage = Covered lines / Total lines * 100
Coverage = 750 / 1000 * 100 = 75%
```

Trên slide có minh họa các dòng màu xanh là dòng đã được executed bởi test.

Các dòng màu xám hoặc không được highlight là dòng chưa được test chạy qua.

Coverage có nhiều loại.

**Line Coverage** cho biết bao nhiêu dòng code đã được thực thi.

Đây là metric phổ biến nhất và dễ hiểu nhất.

**Branch Coverage** cho biết bao nhiêu nhánh điều kiện đã được thực thi.

Ví dụ một câu `if/else`.

Nếu test chỉ chạy nhánh `if` mà chưa chạy nhánh `else`, line coverage có thể cao nhưng branch coverage vẫn thấp.

Branch coverage rất quan trọng vì nhiều bug nằm trong các nhánh điều kiện.

**Function Coverage** cho biết bao nhiêu function đã được gọi bởi test.

Nếu một function chưa bao giờ được gọi trong test, đó có thể là vùng rủi ro.

**Statement Coverage** cho biết bao nhiêu statement được thực thi.

Tùy ngôn ngữ và tool, statement coverage có thể hơi khác line coverage.

Coverage giúp team trả lời các câu hỏi:

Codebase hiện tại được test chạm tới bao nhiêu?

Phần nào chưa được test?

Code mới có test chưa?

Coverage có bị giảm sau merge không?

Tuy nhiên, cần nhớ limitation.

Coverage cao vẫn có thể bỏ sót bug.

Coverage không thay thế assertion.

Coverage không thay thế code review.

Coverage là tín hiệu, không phải sự đảm bảo.

Ví dụ một test có thể chạy qua function `calculatePrice()` nhưng không kiểm tra kết quả trả về có đúng hay không.

Khi đó coverage tăng, nhưng chất lượng test không tốt.

---

# Slide 14 — Coverage Mindset

## Mục tiêu trình bày

Giải thích cách hiểu đúng về coverage và tránh chạy theo con số.

## Speaker Notes

Một hiểu nhầm phổ biến là coverage càng cao thì code càng tốt.

Điều này không hoàn toàn đúng.

Coverage cao là tín hiệu tốt, nhưng không tự động đảm bảo rằng test tốt hoặc code không có bug.

Ví dụ case A có 90% coverage.

Nghe có vẻ rất tốt.

Nhưng nếu test chỉ chạy qua code mà không có assertion mạnh, bug vẫn có thể lọt qua.

Ví dụ test chỉ gọi function nhưng không kiểm tra output.

Hoặc assertion quá yếu, chỉ kiểm tra object tồn tại nhưng không kiểm tra giá trị chính xác.

Trong trường hợp đó, coverage 90% vẫn chưa đủ tin cậy.

Case B có 60% coverage.

Con số thấp hơn.

Nhưng nếu 60% đó tập trung vào business logic quan trọng, logic payment, authorization, order processing, hoặc calculation rules, thì nó có thể đem lại giá trị cao hơn.

Điều này không có nghĩa là coverage thấp là tốt.

Ý chính là coverage cần được nhìn trong ngữ cảnh.

Coverage không thay thế:

Code review.

Test case design.

Strong assertions.

Static analysis.

Good unit tests.

Coverage cho biết test đã chạm vào đâu.

Coverage không nói test có kiểm tra đúng behavior không.

Vì vậy mindset tốt hơn là:

Dùng coverage để tìm vùng chưa được test.

Dùng coverage để highlight risky gaps.

Dùng coverage để theo dõi trend theo thời gian.

Dùng coverage để xem code mới có test hay không.

Dùng coverage cùng với review, unit test chất lượng và static analysis.

Mục tiêu không phải là có một con số đẹp.

Mục tiêu là giảm risk.

Câu có thể nhấn mạnh:

**The goal is not a pretty number. The goal is lower risk.**

---

# Slide 15 — Coverage Reports

## Mục tiêu trình bày

Giải thích coverage report, tool tạo report và flow sử dụng coverage report trong pipeline.

## Speaker Notes

Coverage report là file hoặc folder được tạo ra sau khi test chạy với coverage enabled.

Report này cho biết dòng nào được test chạy qua, dòng nào chưa được test, và tổng hợp các metric như line coverage, branch coverage, function coverage.

Mỗi ngôn ngữ hoặc framework có tool riêng để tạo coverage report.

Với JavaScript hoặc TypeScript, chúng ta có Jest, Vitest, Istanbul hoặc nyc.

Với Java, thường dùng JaCoCo, Maven Surefire hoặc Gradle test report.

Với Python, có pytest-cov hoặc coverage.py.

Với .NET, có coverlet hoặc dotnet test coverage.

Với PHP, có PHPUnit coverage.

Với Go, có `go test -cover`.

Một số format report phổ biến:

`lcov.info` thường dùng cho JavaScript hoặc TypeScript.

`jacoco.xml` thường dùng cho Java.

`coverage.xml` thường dùng cho Python.

`opencover.xml` thường dùng cho .NET.

Điều quan trọng là mỗi tool phía sau cần đúng format và đúng path.

Ví dụ SonarQube scanner muốn đọc coverage report.

Nếu report path cấu hình sai, SonarQube có thể hiển thị coverage là 0%, dù test đã chạy thành công.

Flow thường là:

Pipeline chạy unit test.

Coverage tool track các dòng code được executed.

Coverage tool generate report.

Pipeline lưu report thành artifact.

Sonar scanner đọc report.

SonarQube hiển thị coverage trên dashboard.

Quality Gate kiểm tra coverage có đạt threshold không.

Ví dụ với JavaScript:

```yaml
test-coverage:
  stage: test
  script:
    - npm ci
    - npm run test:coverage
  artifacts:
    paths:
      - coverage/
```

Và trong `sonar-project.properties` có thể có:

```properties
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

Nếu file thực tế nằm ở `coverage/lcov.info`, SonarQube sẽ đọc được.

Nếu file nằm ở path khác, coverage có thể không hiển thị đúng.

Thông điệp chính:

Coverage report kết nối test execution, artifact và quality control lại với nhau.

---

# Slide 16 — Code Quality

## Mục tiêu trình bày

Giải thích code quality là gì và vì sao cần tự động kiểm tra code quality.

## Speaker Notes

Bây giờ chúng ta chuyển sang phần thứ ba: **Code Quality**.

Code quality là mức độ source code dễ đọc, dễ bảo trì, ít lỗi, an toàn và có khả năng mở rộng.

Một điểm rất quan trọng là:

**Code chạy được chưa chắc là code tốt.**

Có những đoạn code chạy đúng trong hiện tại nhưng vẫn gây rủi ro lớn về sau.

Ví dụ function quá dài.

Một function xử lý quá nhiều logic, nhiều if/else, nhiều case đặc biệt.

Khi có bug, rất khó hiểu và khó sửa.

Ví dụ class làm quá nhiều nhiệm vụ.

Class vừa xử lý business logic, vừa gọi database, vừa format response, vừa gửi notification.

Điều này làm code khó test và khó maintain.

Ví dụ logic quá phức tạp.

Quá nhiều nested if, vòng lặp lồng nhau, hoặc điều kiện khó hiểu.

Ví dụ duplicated code.

Cùng một logic bị copy ở nhiều nơi.

Khi cần sửa, developer có thể sửa một chỗ nhưng quên chỗ khác.

Ví dụ tên biến không rõ nghĩa.

Các biến như `x`, `data2`, `temp`, `obj` làm người đọc khó hiểu intent của code.

Ví dụ không xử lý exception tốt.

Code có thể fail trong edge case nhưng không log rõ ràng hoặc không fallback.

Ví dụ hard-coded secret.

Token, password hoặc API key bị commit vào repo.

Đây là vấn đề nghiêm trọng về security.

Ví dụ bug tiềm ẩn hoặc vulnerability.

Những vấn đề này có thể không lộ ra ngay trong local test, nhưng có thể gây production incident.

Trong CI/CD hiện đại, code quality nên được kiểm tra tự động.

Không nên đợi đến manual review hoặc production incident mới phát hiện.

Một số tool phổ biến:

SonarQube cho tổng quan code quality, bug, security, duplication, coverage.

ESLint cho JavaScript hoặc TypeScript.

Checkstyle, PMD, SpotBugs cho Java.

Pylint hoặc flake8 cho Python.

StyleCop Analyzers cho .NET.

PHPStan hoặc Psalm cho PHP.

golangci-lint cho Go.

Flow quality thường là:

Commit code.

Run lint hoặc static analysis.

Generate quality report.

Review trên dashboard.

Quality Gate quyết định pass hoặc fail.

Slide này là phần dẫn vào SonarQube.

SonarQube là một platform phổ biến để gom nhiều tín hiệu chất lượng lại và enforce rule trong CI/CD.

---

# Slide 17 — Code Quality

## Mục tiêu trình bày

Củng cố code quality và chuẩn bị chuyển sang SonarQube integration.

## Speaker Notes

Slide này có thể được dùng để nhấn mạnh lại ý chính của code quality.

Code quality không chỉ là format code đẹp.

Code quality bao gồm nhiều khía cạnh.

Một là readability.

Code có dễ đọc không?

Tên biến, tên function, cấu trúc file có rõ ràng không?

Hai là maintainability.

Code có dễ sửa không?

Khi business requirement thay đổi, team có thể chỉnh code mà không sợ làm hỏng nhiều phần khác không?

Ba là reliability.

Code có ít bug không?

Có xử lý edge case tốt không?

Có test đủ cho logic quan trọng không?

Bốn là security.

Code có chứa hard-coded secret không?

Có dùng thư viện có vulnerability không?

Có xử lý input không an toàn không?

Một tool như SonarQube giúp team nhìn các vấn đề này ở mức project.

Nó không chỉ báo một lỗi riêng lẻ.

Nó cho dashboard tổng quan: bug, vulnerability, code smell, duplication, coverage, technical debt.

Vì vậy từ slide sau, chúng ta sẽ đi vào SonarQube cụ thể hơn.

---

# Slide 18 — Code Quality Integration with SonarQube

## Mục tiêu trình bày

Chuyển sang phần tích hợp SonarQube.

## Speaker Notes

Bây giờ chúng ta đi vào phần cuối: **Code Quality Integration with SonarQube**.

Ở phần trước, chúng ta đã nói code quality là gì.

Bây giờ câu hỏi là:

Làm sao đưa việc kiểm tra code quality vào pipeline một cách tự động?

Làm sao để mỗi merge request đều được kiểm tra theo cùng một bộ rule?

Làm sao để nếu code không đạt tiêu chuẩn thì pipeline fail?

Đây là vai trò của SonarQube trong CI/CD.

SonarQube giúp phân tích source code, đọc coverage report, phát hiện issue, và đánh giá Quality Gate.

Pipeline sẽ chạy Sonar Scanner.

Scanner gửi kết quả về SonarQube Server.

SonarQube Server phân tích và hiển thị kết quả trên dashboard.

Nếu Quality Gate pass, pipeline có thể tiếp tục.

Nếu Quality Gate fail, pipeline có thể dừng lại.

---

# Slide 19 — SonarQube

## Mục tiêu trình bày

Giải thích SonarQube là gì, SonarQube tracking những gì và các thành phần chính.

## Speaker Notes

SonarQube là một nền tảng phân tích chất lượng source code.

Nó giúp team có một góc nhìn tập trung về chất lượng và rủi ro của codebase.

SonarQube có thể track nhiều loại vấn đề.

Đầu tiên là **Bugs**.

Bug là lỗi logic hoặc pattern có khả năng gây behavior sai.

Ví dụ null pointer, unreachable code, condition luôn đúng hoặc luôn sai.

Thứ hai là **Vulnerabilities**.

Đây là vấn đề bảo mật có thể bị khai thác.

Ví dụ SQL injection, command injection, insecure crypto, hoặc dùng API không an toàn.

Thứ ba là **Security Hotspots**.

Security hotspot là đoạn code cần review bảo mật thủ công.

Không phải hotspot nào cũng là vulnerability, nhưng nó cần được người có kinh nghiệm kiểm tra.

Thứ tư là **Code Smells**.

Code smell là dấu hiệu code khó maintain.

Ví dụ function quá dài, duplicate logic, naming không rõ, complexity cao.

Thứ năm là **Duplications**.

Duplicated code làm tăng technical debt vì cùng một logic nằm ở nhiều nơi.

Thứ sáu là **Coverage**.

SonarQube có thể hiển thị coverage nếu scanner đọc được coverage report.

Thứ bảy là các rating như maintainability, reliability, security.

SonarQube cũng theo dõi technical debt.

Technical debt thể hiện chi phí ước lượng để sửa các vấn đề maintainability.

Các thành phần chính của SonarQube gồm:

**SonarQube Server.**

Đây là web UI và nơi quản lý kết quả phân tích.

**Database.**

Lưu project, metric, issue, rule và quality gate.

**Sonar Scanner.**

Đây là tool chạy trong pipeline hoặc local để scan source code.

**Quality Profile.**

Tập rule dùng để phân tích code.

Ví dụ rule cho JavaScript khác rule cho Java.

**Quality Gate.**

Bộ điều kiện pass/fail để quyết định project có đạt chuẩn không.

Flow CI/CD thường là:

Commit code.

Run tests.

Generate coverage report.

Run Sonar Scanner.

Send results to SonarQube Server.

Evaluate Quality Gate.

Trong ví dụ trên slide, kết quả project có:

Bugs: 2.

Vulnerabilities: 0.

Code smells: 14.

Coverage: 78%.

Duplications: 3.2%.

Quality Gate: Pass.

Đây là dạng dashboard summary giúp team xem nhanh trạng thái chất lượng code.

---

# Slide 20 — Quality Gate

## Mục tiêu trình bày

Giải thích Quality Gate và cách Quality Gate bảo vệ pipeline.

## Speaker Notes

Quality Gate là một bộ điều kiện để quyết định project có đạt chuẩn chất lượng hay không.

Có thể hiểu Quality Gate như một checkpoint trong pipeline.

Nếu code đạt các điều kiện, pipeline tiếp tục.

Nếu không đạt, pipeline fail hoặc dừng lại tùy cấu hình.

Ví dụ một Quality Gate có thể yêu cầu:

New bugs = 0.

New vulnerabilities = 0.

New code coverage >= 80%.

Duplicated lines on new code <= 3%.

Maintainability rating = A.

Reliability rating = A.

Security rating = A.

Trong ví dụ trên slide, project có:

New bugs = 0.

New vulnerabilities = 0.

New code coverage = 82%.

Duplicated lines on new code = 2.1%.

Maintainability rating A.

Reliability rating A.

Security rating A.

Vì tất cả điều kiện đều đạt, Quality Gate pass.

Nếu coverage chỉ là 74%, trong khi rule yêu cầu >= 80%, Quality Gate sẽ fail.

Điểm quan trọng là Quality Gate biến tiêu chuẩn chất lượng thành rule tự động.

Nếu không có Quality Gate, team có thể chỉ nói miệng rằng “code phải có coverage tốt”, “không được có bug nghiêm trọng”.

Nhưng nếu không có rule tự động, việc thực thi sẽ phụ thuộc vào con người.

Quality Gate giúp enforce tiêu chuẩn một cách nhất quán.

Trong pipeline, có thể cấu hình để nếu Quality Gate fail thì job fail.

Điều này giúp chặn code không đạt chuẩn trước khi merge hoặc deploy.

Ví dụ flow:

Commit code.

Run tests.

Generate coverage.

Run Sonar Scan.

Quality Gate check.

Nếu pass, pipeline tiếp tục.

Nếu fail, pipeline stop.

Quality Gate đặc biệt quan trọng cho protected branch như `main`, `master`, `release`.

Một best practice là áp dụng Quality Gate cho merge request.

Developer sẽ biết ngay merge request có đạt chất lượng hay không.

Reviewer cũng có dữ liệu rõ ràng để quyết định.

---

# Slide 21 — SonarQube Integration

## Mục tiêu trình bày

Giải thích flow tích hợp SonarQube vào pipeline, config cần thiết và ví dụ cấu hình.

## Speaker Notes

Slide này mô tả flow tích hợp SonarQube trong CI/CD pipeline.

Flow thường gồm các bước:

Developer push code hoặc mở merge request.

Pipeline install dependencies.

Pipeline chạy unit tests.

Pipeline generate coverage report.

Pipeline chạy Sonar Scanner.

Scanner gửi kết quả lên SonarQube Server.

SonarQube phân tích code và coverage.

SonarQube evaluate Quality Gate.

Pipeline nhận kết quả pass hoặc fail.

Nếu pass, pipeline tiếp tục build hoặc deploy.

Nếu fail, pipeline dừng lại và developer cần sửa issue.

Để tích hợp SonarQube, chúng ta thường cần một số thông tin cấu hình.

`SONAR_HOST_URL` là URL của SonarQube server.

Ví dụ:

```text
https://sonarqube.example.com
```

`SONAR_TOKEN` là token dùng để scanner xác thực với SonarQube server.

Token này là thông tin nhạy cảm.

Không nên hard-code token vào repository.

Nên lưu trong GitLab CI/CD Variables hoặc secret manager.

`sonar.projectKey` là key định danh project trên SonarQube.

`sonar.sources` là folder chứa source code.

`sonar.tests` là folder chứa test code.

`sonar.exclusions` là các file hoặc folder không cần scan.

Ví dụ `node_modules`, `dist`, `build`.

`sonar.coverage.exclusions` là file không cần tính coverage.

Ví dụ generated files, config files hoặc test files.

`coverage report path` là đường dẫn tới report coverage.

Ví dụ với JavaScript:

```properties
sonar.projectKey=my-app
sonar.sources=src
sonar.tests=tests
sonar.exclusions=dist/**,node_modules/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

Ví dụ GitLab CI job:

```yaml
sonar-scan:
  stage: quality
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - sonar-scanner
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.token=$SONAR_TOKEN
  dependencies:
    - test-coverage
  rules:
    - if: '$CI_COMMIT_BRANCH'
```

Trong một số setup, để pipeline chờ Quality Gate result, có thể cần cấu hình thêm property hoặc dùng scanner / plugin hỗ trợ wait quality gate.

Ví dụ concept:

```yaml
script:
  - sonar-scanner
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.token=$SONAR_TOKEN
      -Dsonar.qualitygate.wait=true
```

Khi Quality Gate fail, job có thể fail và pipeline dừng.

Điểm cần nhớ:

SonarQube không tự tạo coverage.

Pipeline phải chạy test và generate coverage report trước.

Sonar Scanner chỉ đọc coverage report và gửi kết quả lên server.

Nếu coverage path sai, coverage trên SonarQube có thể là 0%.

Nếu token sai hoặc thiếu quyền, scanner sẽ fail authentication.

Nếu projectKey sai, kết quả có thể gửi nhầm project hoặc tạo project mới không mong muốn.

Vì vậy khi debug SonarQube integration, nên kiểm tra:

Pipeline log.

Sonar scanner log.

Coverage report path.

CI/CD variables.

Token permission.

Project key.

Quality Gate configuration.

---

# Slide 22 — Demo

## Mục tiêu trình bày

Đề xuất flow demo để học viên thấy toàn bộ quá trình.

## Speaker Notes

Ở phần demo, chúng ta có thể đi theo flow từng bước.

Đầu tiên, mở repository đã có file `.gitlab-ci.yml`.

Giải thích nhanh pipeline hiện tại đang có những stage nào.

Ví dụ ban đầu pipeline chỉ có build.

Sau đó thêm job `unit-test`.

Ví dụ:

```yaml
stages:
  - test
  - quality
  - build

unit-test:
  stage: test
  image: node:20
  script:
    - npm ci
    - npm test
```

Sau khi thêm job, push code và quan sát pipeline chạy.

Giải thích rằng khi developer push code, GitLab tạo pipeline mới, runner pick job và chạy command trong script.

Tiếp theo, cố tình làm một test fail.

Ví dụ sửa expected value trong test.

Push code lại.

Cho học viên thấy pipeline fail ở job `unit-test`.

Nhấn mạnh fail fast: vì test fail nên pipeline không nên đi tiếp build hoặc deploy.

Sau đó sửa test và chạy lại pipeline.

Khi test pass, thêm coverage command.

Ví dụ:

```yaml
unit-test:
  stage: test
  image: node:20
  script:
    - npm ci
    - npm run test:coverage
  artifacts:
    when: always
    paths:
      - coverage/
```

Giải thích folder `coverage/` là artifact.

Mở artifact để xem report.

Sau đó thêm file `sonar-project.properties`.

Ví dụ:

```properties
sonar.projectKey=my-app
sonar.sources=src
sonar.tests=tests
sonar.exclusions=dist/**,node_modules/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

Tiếp theo thêm job SonarQube.

```yaml
sonar-scan:
  stage: quality
  image: sonarsource/sonar-scanner-cli:latest
  script:
    - sonar-scanner
      -Dsonar.host.url=$SONAR_HOST_URL
      -Dsonar.token=$SONAR_TOKEN
      -Dsonar.qualitygate.wait=true
  dependencies:
    - unit-test
```

Nhắc học viên rằng `SONAR_HOST_URL` và `SONAR_TOKEN` không nên ghi trực tiếp vào YAML.

Chúng nên được lưu trong GitLab CI/CD Variables.

Sau đó chạy pipeline và mở dashboard SonarQube.

Cho học viên xem bugs, vulnerabilities, code smells, coverage và Quality Gate.

Nếu Quality Gate pass, pipeline tiếp tục.

Nếu Quality Gate fail, developer phải sửa issue.

Demo này giúp học viên thấy toàn bộ flow:

Test.

Coverage.

Artifact.

Sonar scan.

Quality Gate.

Pipeline decision.

---

# Slide 23 — Thank You

## Mục tiêu trình bày

Tổng kết session và mở phần Q&A.

## Speaker Notes

Đến đây chúng ta tổng kết lại session 3.

Trong session này, chúng ta đã đi qua 3 nội dung chính.

Thứ nhất là **running tests in pipeline**.

Test nên được chạy tự động trong pipeline để phát hiện lỗi sớm và đảm bảo mọi developer đi qua cùng một tiêu chuẩn validation.

Test stage nên được thiết kế rõ ràng, chia thành nhiều job nhỏ như unit test, integration test, API test, lint và coverage để dễ debug và dễ tối ưu.

Thứ hai là **code coverage**.

Coverage giúp đo lường phần source code được test chạy qua.

Coverage giúp team biết vùng nào chưa được test, code mới có test chưa và coverage có bị giảm sau merge không.

Tuy nhiên coverage không phải là bằng chứng tuyệt đối rằng code không có bug.

Coverage cần được dùng cùng với test chất lượng, assertion tốt, code review và static analysis.

Thứ ba là **SonarQube integration**.

SonarQube giúp phân tích code quality, bugs, vulnerabilities, code smells, duplication, coverage và technical debt.

Quality Gate giúp biến tiêu chuẩn chất lượng thành rule tự động trong pipeline.

Khi Quality Gate fail, pipeline có thể dừng để ngăn code rủi ro đi tiếp.

Thông điệp cuối cùng là:

**CI/CD tốt không chỉ giúp deploy nhanh hơn. CI/CD tốt giúp release an toàn hơn.**

Pipeline không chỉ là tool automation.

Pipeline là một hệ thống bảo vệ chất lượng phần mềm.

Sau phần này, chúng ta có thể mở Q&A.

Một số câu hỏi có thể thảo luận:

Dự án hiện tại nên bắt đầu coverage threshold bao nhiêu?

Nên fail pipeline khi coverage giảm hay chỉ cảnh báo?

Unit test, integration test và E2E test nên chạy ở branch nào?

SonarQube issue nào nên ưu tiên xử lý trước?

Legacy project có coverage thấp thì nên áp dụng Quality Gate thế nào?

Làm sao xử lý flaky test trong pipeline?

---

# Appendix A — Suggested 2-hour delivery plan

## 0–5 phút: Introduction

Giới thiệu session, nhắc lại 2 session trước, nêu mục tiêu hôm nay.

## 5–45 phút: Running test in pipeline

Trình bày slide 3 đến slide 11.

Tập trung vào:

Pipeline flow.

Automated testing.

Test types.

Test stage structure.

Reports.

Artifacts.

Fail fast.

Có thể hỏi học viên:

“Hiện tại dự án của mọi người test đang chạy manual hay pipeline?”

“Có ai từng gặp lỗi local pass nhưng CI fail chưa?”

## 45–75 phút: Code coverage

Trình bày slide 12 đến slide 15.

Tập trung vào:

Coverage là gì.

Coverage mindset.

Threshold.

Coverage reports.

Có thể hỏi học viên:

“Nếu coverage 90% thì có chắc code không bug không?”

“Legacy project coverage 20% thì có nên đặt threshold 80% ngay không?”

## 75–110 phút: Code quality & SonarQube

Trình bày slide 16 đến slide 21.

Tập trung vào:

Code quality.

Static analysis.

SonarQube.

Quality Gate.

Integration flow.

Config.

Có thể hỏi học viên:

“Code chạy được nhưng function quá dài thì có vấn đề không?”

“Quality Gate fail thì nên block merge hay chỉ warning?”

## 110–120 phút: Demo recap & Q&A

Chạy demo hoặc recap demo flow.

Tổng kết lại 3 ý chính.

Mở Q&A.

---

# Appendix B — Short summary for opening

Hôm nay chúng ta sẽ học cách làm cho pipeline không chỉ build và deploy, mà còn kiểm soát chất lượng code.

Chúng ta sẽ đi qua cách chạy test tự động, cách đo coverage, và cách tích hợp SonarQube để phân tích code quality.

Mục tiêu cuối cùng là giúp pipeline phát hiện lỗi sớm, giảm rủi ro khi merge code, và đảm bảo release an toàn hơn.

---

# Appendix C — Short summary for closing

Session 3 có 3 ý chính.

Một là test nên được chạy tự động trong pipeline.

Hai là coverage giúp đo mức độ code được test, nhưng không thay thế test chất lượng.

Ba là SonarQube và Quality Gate giúp kiểm soát code quality tự động.

Khi kết hợp test, coverage và SonarQube, pipeline trở thành một hệ thống bảo vệ chất lượng phần mềm.

CI/CD tốt không chỉ giúp giao hàng nhanh hơn, mà còn giúp giao hàng an toàn hơn.
