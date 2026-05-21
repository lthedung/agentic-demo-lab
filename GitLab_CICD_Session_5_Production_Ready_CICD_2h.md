# GitLab CI/CD Session 5 — Production-Ready CI/CD

**Thời lượng:** 2 tiếng  
**Đối tượng:** Học viên đã học xong 4 session GitLab CI/CD nền tảng và đã thực hành lab/demo cơ bản  
**Format:** Slide title tiếng Anh, nội dung trình bày tiếng Việt  
**Mục tiêu chính:** Giúp học viên chuyển từ mức “viết pipeline chạy được” sang “thiết kế pipeline ổn định, dễ debug, tối ưu, bảo mật và dễ scale trong project thật”.

---

## Tổng thời lượng đề xuất

| Phần | Slide | Thời lượng |
|---|---:|---:|
| Opening & Context | 1–3 | 10 phút |
| Pipeline Troubleshooting & Debugging | 4–9 | 35 phút |
| Pipeline Optimization | 10–15 | 35 phút |
| Reusable CI/CD Templates | 16–18 | 20 phút |
| Security & Governance in CI/CD | 19 | 10 phút |
| Production-Ready Checklist & Wrap-up | 20 | 10 phút |
| Q&A / Discussion | — | 10 phút |
| **Tổng** | **20 slides** | **120 phút** |

---

# Slide 1 — Session Overview

## Nội dung trình bày

Trong 4 session trước, học viên đã nắm được các phần nền tảng của GitLab CI/CD:

- Hiểu CI/CD là gì và vai trò của GitLab trong quy trình DevOps.
- Biết cách tạo pipeline bằng `.gitlab-ci.yml`.
- Hiểu `stages`, `jobs`, `script`, `artifacts`, `variables`.
- Biết GitLab Runner nhận và thực thi job như thế nào.
- Đã thực hành build, test, coverage, SonarQube, environment và deployment cơ bản.

Session 5 không tập trung dạy lại syntax cơ bản.  
Buổi này đi vào tư duy vận hành CI/CD trong project thật.

Một pipeline chạy được chưa chắc là pipeline tốt.  
Pipeline tốt phải trả lời được các câu hỏi:

- Khi pipeline lỗi, team có biết debug không?
- Khi project lớn lên, pipeline có bị chậm không?
- Khi nhiều project dùng chung logic, có phải copy-paste YAML không?
- Khi deploy production, secrets và quyền deploy có được kiểm soát không?
- Khi người mới join team, họ có đọc hiểu pipeline không?

## Key message

**Pipeline chạy được là nền tảng. Pipeline production-ready mới là năng lực thực chiến.**

## Speaker notes

Mở đầu bằng cách nhắc lại hành trình 4 session trước.  
Không cần đi sâu lại lý thuyết cũ. Trọng tâm là nói rõ: buổi này giúp học viên nâng cấp tư duy từ “làm được” sang “làm tốt, làm an toàn, làm bền”.

---

# Slide 2 — Agenda

## Nội dung trình bày

Session này có 4 phần chính:

1. **Pipeline Troubleshooting & Debugging**  
   Cách nhận diện lỗi pipeline, đọc log, kiểm tra runner, variables, artifacts và deployment issues.

2. **Pipeline Optimization**  
   Cách làm pipeline chạy nhanh hơn, gọn hơn và tránh lãng phí runner bằng `cache`, `artifacts`, `needs`, `rules`, parallel jobs và interruptible pipelines.

3. **Reusable CI/CD Templates**  
   Cách giảm copy-paste YAML bằng hidden jobs, `extends`, `include` và template structure.

4. **Security & Governance in CI/CD**  
   Cách bảo vệ secrets, branch, runner, production deployment và kiểm soát quyền trong pipeline.

## Key message

**Session này tập trung vào cách làm GitLab CI/CD ổn định hơn, nhanh hơn, bảo mật hơn và dễ scale hơn trong project thật.**

## Speaker notes

Nói rõ agenda chỉ có 4 mục, không mở rộng thêm quá nhiều.  
Nếu học viên hỏi có lab không, có thể nói phần này có thể demo hoặc thảo luận case nhanh trong từng slide, nhưng trọng tâm là tư duy vận hành và checklist.

---

# Slide 3 — From Working Pipeline to Production-Ready Pipeline

## Nội dung trình bày

Một pipeline cơ bản thường chỉ trả lời câu hỏi:

> Code có build, test và deploy được không?

Nhưng trong project thật, câu hỏi này chưa đủ.

Pipeline production-ready cần trả lời thêm:

- Pipeline có dễ debug khi lỗi không?
- Pipeline có chạy nhanh và tiết kiệm runner resource không?
- Pipeline có kiểm soát đúng branch, tag và environment không?
- Secrets có được bảo vệ đúng cách không?
- YAML có dễ bảo trì khi project lớn lên không?
- Pipeline có dễ reuse cho nhiều project hoặc nhiều service không?
- Khi deploy production, có approval gate và audit trail không?

## So sánh nhanh

| Working Pipeline | Production-Ready Pipeline |
|---|---|
| Chạy được | Chạy ổn định |
| Có build/test/deploy | Có kiểm soát build/test/scan/deploy |
| YAML viết được | YAML dễ đọc, dễ maintain |
| Deploy đơn giản | Deploy có environment, rule, approval |
| Có variable | Secret được masked/protected |
| Có log | Log đủ rõ để debug |
| Chạy mọi job | Chỉ chạy job cần thiết |

## Key message

**CI/CD không chỉ là automation. CI/CD là automation có kiểm soát.**

## Speaker notes

Đây là slide chuyển mạch. Nhấn mạnh học viên không còn ở level “Hello World pipeline”.  
Sau session này, họ cần biết nhìn pipeline như một hệ thống vận hành.

---

# Slide 4 — Common Pipeline Failure Points

## Nội dung trình bày

Một GitLab CI/CD pipeline có thể lỗi ở nhiều tầng khác nhau.  
Khi debug, không nên nhìn lỗi như một khối chung, mà cần tách theo từng lớp.

| Failure Point | Vấn đề thường gặp | Dấu hiệu nhận biết |
|---|---|---|
| YAML syntax | Sai indentation, sai keyword, sai structure | Pipeline không được tạo |
| Pipeline creation | File `.gitlab-ci.yml` không hợp lệ | Không thấy pipeline mới |
| Stage/job definition | Stage chưa khai báo, job thiếu `script` | Pipeline invalid hoặc job không chạy |
| Runner selection | Runner offline, tag không match | Job pending |
| Script execution | Command fail, thiếu dependency | Job failed |
| Variables/secrets | Variable sai tên, thiếu scope, protected sai | Job fail ở bước build/deploy |
| Cache/artifacts | Sai path, file không tồn tại | Job sau không lấy được output |
| Rules/conditions | Job bị skipped ngoài ý muốn | Job không xuất hiện hoặc bị skip |
| Deployment | Sai branch, sai environment, thiếu approval | Deploy fail hoặc không trigger được |

## Cách tư duy

Khi pipeline lỗi, cần hỏi:

1. Lỗi xảy ra trước khi pipeline được tạo hay sau khi pipeline được tạo?
2. Lỗi xảy ra ở job nào?
3. Job đó có được runner nhận không?
4. Lỗi nằm ở script, variable, artifact hay deploy target?
5. Đây là lỗi config hay lỗi application code?

## Key message

**Muốn debug nhanh, phải xác định lỗi nằm ở tầng nào trước. Đừng sửa YAML theo cảm giác.**

## Speaker notes

Có thể hỏi học viên: “Job pending thì có phải do script sai không?”  
Đáp án: thường không. Pending thường do runner matching. Đây là cách kéo học viên vào tư duy phân tầng lỗi.

---

# Slide 5 — Pipeline Debugging Mindset

## Nội dung trình bày

Debug CI/CD không phải là “thử sửa đại vài dòng YAML”.  
Cách làm đúng là đi theo logic từ trên xuống.

## Tư duy debug đúng

### 1. Xác định pipeline có được tạo không

Nếu pipeline không xuất hiện, lỗi thường nằm ở:

- YAML syntax.
- `workflow`.
- File `.gitlab-ci.yml` đặt sai vị trí.
- Điều kiện branch/tag không cho pipeline chạy.

### 2. Xác định job có được tạo không

Nếu pipeline có nhưng thiếu job, kiểm tra:

- `rules`.
- `only/except`.
- Stage.
- Job syntax.
- Điều kiện branch, merge request hoặc tag.

### 3. Xác định job có được runner nhận không

Nếu job pending, lỗi thường nằm ở:

- Runner tag.
- Runner scope.
- Protected runner.
- Runner offline.
- Executor lỗi.

### 4. Xác định command nào fail

Nếu job chạy rồi fail, log là nguồn dữ liệu chính.  
Không nên đoán. Cần đọc job log từ trên xuống và tìm command đầu tiên bị lỗi.

### 5. Xác định lỗi đến từ code, environment hay CI config

Không phải lỗi nào cũng do GitLab CI/CD. Có thể lỗi đến từ:

- Dependency.
- Test case.
- Permission.
- Secret.
- Deploy target.
- Application code.

## Nguyên tắc

- Không đoán khi chưa đọc log.
- Không sửa nhiều thứ cùng lúc.
- Sửa một lỗi, chạy lại, xác nhận kết quả.
- Ghi lại root cause để lần sau không lặp lại.
- Tách lỗi CI config khỏi lỗi application code.

## Key message

**Engineer tốt debug bằng checklist. Engineer yếu debug bằng cảm giác.**

## Speaker notes

Nói thẳng: debug bằng cảm giác làm mất thời gian team.  
CI/CD debugging cần giống điều tra lỗi hệ thống: xác định symptom, isolate layer, xác nhận root cause.

---

# Slide 6 — Debugging Checklist

## Nội dung trình bày

Khi pipeline lỗi, dùng checklist này để kiểm tra theo thứ tự.

## 1. Pipeline có được tạo không?

Kiểm tra:

- File `.gitlab-ci.yml` có nằm đúng root project không?
- YAML có lỗi indentation không?
- Có dùng keyword sai không?
- Có `workflow: rules` làm pipeline không tạo không?
- Branch hiện tại có bị giới hạn điều kiện chạy không?
- Commit có thật sự trigger pipeline không?

## 2. Job có xuất hiện không?

Kiểm tra:

- Job có stage hợp lệ không?
- Stage đó có được khai báo trong `stages` không?
- Job có `script` không?
- `rules` có làm job bị skip không?
- Job có bị giới hạn theo branch, tag hoặc merge request không?

## 3. Job có bị pending không?

Kiểm tra:

- Runner có online không?
- Runner có tag đúng không?
- Job có khai báo `tags` mà không runner nào match không?
- Runner có được enable cho project không?
- Runner có protected trong khi branch không protected không?
- Runner có bị locked cho project khác không?

## 4. Job chạy rồi fail ở đâu?

Kiểm tra:

- Command đầu tiên bị fail là command nào?
- Exit code là gì?
- Dependency đã được cài chưa?
- File/folder cần dùng có tồn tại không?
- Environment variable có được inject không?
- Version tool trên runner có giống local không?

## 5. Deploy có đúng điều kiện không?

Kiểm tra:

- Deploy job có chỉ chạy trên branch phù hợp không?
- Production deploy có manual gate không?
- Secret production có protected không?
- Environment name có đúng không?
- Runner dùng cho deploy có quyền phù hợp không?
- Có ai đủ quyền để trigger manual deploy không?

## Key message

**Checklist giúp giảm thời gian debug và tránh sửa sai chỗ.**

## Speaker notes

Có thể nhấn mạnh: “Đừng nhảy thẳng vào sửa script nếu job còn pending.”  
Pending nghĩa là script chưa chạy. Vậy sửa script lúc đó gần như vô nghĩa.

---

# Slide 7 — YAML Error Troubleshooting

## Nội dung trình bày

YAML là nguyên nhân gây lỗi rất phổ biến trong GitLab CI/CD vì nó nhạy với indentation và structure.

## Ví dụ lỗi

```yaml
stages:
  - build
  - test

build_app:
 stage: build
 script:
  - echo "Build app"

test_app:
  stage: testing
  script:
    - echo "Run test"
```

## Lỗi 1 — Indentation không nhất quán

```yaml
build_app:
 stage: build
 script:
```

YAML không dùng `{}` để xác định block. Nó dựa vào khoảng trắng.  
Indentation không đều có thể làm GitLab hiểu sai cấu trúc file hoặc làm file khó maintain.

## Lỗi 2 — Stage chưa được khai báo

```yaml
test_app:
  stage: testing
```

Trong phần `stages`, chỉ có:

```yaml
stages:
  - build
  - test
```

Như vậy `testing` là stage không tồn tại.

## Bản sửa

```yaml
stages:
  - build
  - test

build_app:
  stage: build
  script:
    - echo "Build app"

test_app:
  stage: test
  script:
    - echo "Run test"
```

## Checklist khi lỗi YAML

- Kiểm tra indentation.
- Kiểm tra dấu `:`.
- Kiểm tra stage name.
- Kiểm tra job có `script` không.
- Kiểm tra keyword có đúng GitLab CI/CD syntax không.
- Dùng CI Lint để validate file trước khi commit.
- Tránh copy YAML từ nhiều nguồn khác nhau mà không kiểm tra spacing.

## Key message

**Nhiều lỗi pipeline không phức tạp. Chỉ là YAML sai nhỏ nhưng làm cả pipeline không chạy.**

## Speaker notes

Có thể demo nhanh bằng cách hỏi học viên tìm lỗi trong YAML trước khi reveal bản sửa.  
Đây là cách giữ tương tác tốt.

---

# Slide 8 — Runner and Job Pending Issues

## Nội dung trình bày

Job pending là một trong những lỗi phổ biến nhất khi làm việc với GitLab Runner.

## Job pending nghĩa là gì?

Job đã được tạo, nhưng GitLab chưa tìm được runner phù hợp để thực thi job đó.

## Ví dụ

```yaml
test_app:
  stage: test
  tags:
    - docker
  script:
    - echo "Run test"
```

Nếu project không có runner nào mang tag `docker`, job sẽ bị pending.

## Nguyên nhân phổ biến

| Nguyên nhân | Giải thích |
|---|---|
| Runner offline | Runner không hoạt động hoặc mất kết nối |
| Tag không match | Job cần tag `docker`, runner không có tag này |
| Runner chưa enable | Runner chưa được gán cho project |
| Protected runner | Runner chỉ nhận job từ protected branch/tag |
| Branch không protected | Job từ feature branch không được protected runner nhận |
| Runner bị locked | Runner chỉ dùng cho project khác |
| Executor lỗi | Shell/Docker/Kubernetes executor cấu hình sai |

## Cách kiểm tra

1. Vào **Settings > CI/CD > Runners**.
2. Kiểm tra runner đang online hay offline.
3. Kiểm tra runner tag.
4. Kiểm tra job có khai báo `tags` không.
5. Kiểm tra branch hiện tại có protected không.
6. Kiểm tra runner scope: project, group hay instance.
7. Kiểm tra executor đang dùng: shell, docker hay kubernetes.
8. Kiểm tra runner có giới hạn concurrency hoặc resource không.

## Key message

**Job pending thường là lỗi matching giữa job và runner, không phải lỗi command trong script.**

## Speaker notes

Nhấn mạnh: job pending = script chưa chạy.  
Vì vậy đừng debug command trước. Hãy debug runner trước.

---

# Slide 9 — Variable and Secret Issues

## Nội dung trình bày

Variable và secret là phần rất dễ gây lỗi vì chúng liên quan đến quyền, branch, environment và bảo mật.

## Ví dụ lỗi

```yaml
deploy_production:
  stage: deploy
  script:
    - npm run deploy -- --token=$PROD_TOKEN
```

Job fail vì `$PROD_TOKEN` rỗng hoặc không được inject vào job.

## Nguyên nhân phổ biến

| Nguyên nhân | Mô tả |
|---|---|
| Variable chưa được tạo | GitLab không có biến tương ứng |
| Sai tên variable | `PROD_TOKEN` khác `PRODUCTION_TOKEN` |
| Protected variable | Chỉ chạy trên protected branch/tag |
| Environment scope sai | Variable chỉ áp dụng cho environment khác |
| Masked variable không hợp lệ | Format không thỏa điều kiện masked |
| Group variable không inherit | Project không nhận variable từ group |
| Runner/context không phù hợp | Job chạy trong context không được quyền dùng secret |

## Cách kiểm tra an toàn

Không in secret ra log.

Sai:

```yaml
script:
  - echo $PROD_TOKEN
```

Đúng hơn:

```yaml
script:
  - test -n "$PROD_TOKEN" || (echo "PROD_TOKEN is missing" && exit 1)
  - npm run deploy
```

## Best practices

- Không commit `.env` lên repository.
- Không hard-code password/token trong YAML.
- Dùng GitLab CI/CD Variables.
- Bật `masked` cho secret nếu có thể.
- Bật `protected` cho production secrets.
- Tách variable theo environment: dev, staging, production.
- Chỉ cho production secret xuất hiện trên protected branch/tag.
- Không truyền secret vào artifacts, cache hoặc log file.

## Key message

**Secret chỉ nên được sử dụng bởi pipeline, không nên được nhìn thấy trong log.**

## Speaker notes

Đây là slide quan trọng. Nhắc học viên rằng lỗi secret không chỉ làm pipeline fail mà còn có thể gây security incident.

---

# Slide 10 — Why Pipeline Optimization Matters

## Nội dung trình bày

Một pipeline chạy được nhưng quá chậm sẽ tạo ra chi phí vận hành rất lớn.

## Vấn đề của pipeline chậm

- Developer phải chờ feedback lâu.
- Merge request bị delay.
- Runner resource bị lãng phí.
- Team dễ bỏ qua CI/CD vì thấy mất thời gian.
- Hotfix production bị chậm.
- Nhiều pipeline chạy dư khi chỉ thay đổi nhỏ.
- Chi phí hạ tầng tăng nếu dùng runner/cloud resource trả phí.
- Team có xu hướng tắt bớt kiểm tra quan trọng để chạy nhanh hơn.

## Pipeline tối ưu cần đạt điều gì?

| Mục tiêu | Ý nghĩa |
|---|---|
| Feedback nhanh hơn | Developer biết lỗi sớm |
| Ít việc lặp lại hơn | Không install/build lại vô ích |
| Job chạy đúng điều kiện | Không chạy deploy/test nặng khi không cần |
| Resource hiệu quả hơn | Runner không bị nghẽn |
| Output rõ ràng hơn | Artifacts/report dễ truy vết |
| Dễ mở rộng | Project lớn lên không làm pipeline rối |

## Các kỹ thuật chính

- `cache`
- `artifacts`
- `needs`
- `rules`
- parallel jobs
- `interruptible`
- smaller images
- dependency lock files

## Key message

**Pipeline chậm thì sớm muộn cũng bị team né. Pipeline tốt phải nhanh nhưng vẫn kiểm soát được chất lượng.**

## Speaker notes

Nói rõ: optimize không có nghĩa là bỏ test để chạy nhanh.  
Optimize đúng là bỏ việc thừa, giữ việc quan trọng.

---

# Slide 11 — Cache Strategy

## Nội dung trình bày

`cache` dùng để lưu lại các file có thể tái sử dụng nhằm giảm thời gian chạy job.

## Cache phù hợp cho gì?

- Dependencies.
- Package manager cache.
- Build cache tạm.
- Framework/tooling cache.
- Files có thể tái tạo lại nếu cache mất.

## Ví dụ Node.js

```yaml
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/

install:
  stage: build
  script:
    - npm install
```

## Ví dụ cache theo lock file

```yaml
cache:
  key:
    files:
      - package-lock.json
  paths:
    - node_modules/
```

Cách này tốt hơn vì cache sẽ thay đổi khi dependency lock file thay đổi.

## Khi nào nên dùng cache?

| Trường hợp | Có nên cache? |
|---|---|
| Cài dependencies mất nhiều thời gian | Nên |
| Build output cần dùng ở job sau | Không, dùng artifacts |
| File release quan trọng | Không |
| Tool cache tạm | Có thể |
| Secret hoặc credential | Không bao giờ |

## Lỗi cache thường gặp

- Cache key quá chung, dễ dùng nhầm cache cũ.
- Cache path sai.
- Cache quá nặng làm upload/download lâu hơn build mới.
- Dùng cache thay cho artifact.
- Cache dependency nhưng không kiểm soát lock file.
- Cache chứa file nhạy cảm.

## Key message

**Cache dùng để tăng tốc, không dùng để lưu output quan trọng hoặc dữ liệu nhạy cảm.**

## Speaker notes

Giải thích rõ khác biệt cache và artifact ở đây, rồi slide sau sẽ đi sâu artifacts.  
Cache có thể mất, artifact là output có chủ đích.

---

# Slide 12 — Artifacts Strategy

## Nội dung trình bày

`artifacts` là file được job tạo ra và GitLab lưu lại như kết quả của job.

## Artifacts dùng cho gì?

- Build output.
- Test report.
- Coverage report.
- Logs.
- Package.
- File deploy.
- File cần truyền sang job sau.

## Ví dụ build artifact

```yaml
build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week
```

## Ví dụ test report artifact

```yaml
test:
  stage: test
  script:
    - npm test
  artifacts:
    reports:
      junit: junit.xml
    paths:
      - coverage/
```

## Cache vs Artifacts

| Tiêu chí | Cache | Artifacts |
|---|---|---|
| Mục đích | Tăng tốc | Lưu output |
| Độ tin cậy | Không nên xem là kết quả chính thức | Là kết quả của job |
| Dùng cho | Dependencies, package cache | Build output, reports |
| Gắn với job | Không chặt | Có |
| Dùng cho audit | Không phù hợp | Phù hợp hơn |

## Best practices

- Chỉ lưu file thật sự cần.
- Đặt `expire_in` hợp lý.
- Không lưu secret trong artifacts.
- Tách rõ artifact cho build, test report, coverage.
- Kiểm tra path trước khi upload artifact.
- Không lưu artifact quá lớn nếu không cần thiết.

## Key message

**Artifacts giúp pipeline có output rõ ràng, có thể kiểm tra, có thể truyền sang bước tiếp theo.**

## Speaker notes

Có thể hỏi: “dist/ nên cache hay artifact?”  
Đáp án: artifact, vì nó là build output cần truyền hoặc kiểm tra.

---

# Slide 13 — Needs and Faster Job Execution

## Nội dung trình bày

Mặc định, GitLab chạy pipeline theo stage.  
Job ở stage sau phải chờ toàn bộ job ở stage trước hoàn thành.

Điều này dễ làm pipeline chậm nếu chỉ một số job thật sự phụ thuộc nhau.

## Ví dụ không dùng `needs`

```yaml
stages:
  - build
  - test

build_frontend:
  stage: build
  script:
    - npm run build:frontend

build_backend:
  stage: build
  script:
    - npm run build:backend

test_frontend:
  stage: test
  script:
    - npm run test:frontend
```

Trong trường hợp này, `test_frontend` phải chờ cả `build_backend`, dù nó chỉ cần `build_frontend`.

## Dùng `needs`

```yaml
test_frontend:
  stage: test
  needs:
    - build_frontend
  script:
    - npm run test:frontend
```

## Lợi ích

- Job chạy sớm hơn.
- Feedback nhanh hơn.
- Pipeline graph rõ dependency hơn.
- Giảm thời gian chờ không cần thiết.
- Phù hợp với monorepo hoặc project nhiều module.

## Khi nào nên dùng?

- Job chỉ phụ thuộc vào một vài job trước.
- Test frontend không cần chờ build backend.
- Deploy service A không cần chờ service B.
- Scan/report có thể chạy song song với test khác.
- Project có nhiều module độc lập.

## Lưu ý

- Không dùng `needs` bừa nếu dependency chưa rõ.
- Phải đảm bảo job sau có đủ artifact/output cần thiết.
- Pipeline graph có thể phức tạp hơn nếu lạm dụng.

## Key message

**`needs` giúp pipeline chạy theo dependency thật, không bị kẹt bởi stage tổng quát.**

## Speaker notes

Đây là slide kỹ thuật quan trọng. Nên giải thích bằng ví dụ frontend/backend vì dễ hiểu.

---

# Slide 14 — Rules and Conditional Jobs

## Nội dung trình bày

`rules` giúp kiểm soát khi nào job được tạo và chạy.

Pipeline production-ready không nên chạy mọi job trong mọi tình huống.

## Ví dụ: chỉ deploy production từ `main`

```yaml
deploy_production:
  stage: deploy
  script:
    - npm run deploy
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual
```

## Ví dụ: chỉ chạy test khi file frontend thay đổi

```yaml
frontend_test:
  stage: test
  script:
    - npm test
  rules:
    - changes:
        - frontend/**/*
```

## Ví dụ: chạy security scan cho merge request

```yaml
security_scan:
  stage: test
  script:
    - npm run scan
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

## Use cases phổ biến

| Use case | Rule logic |
|---|---|
| Deploy production | Chỉ `main`, manual |
| Deploy staging | Branch develop hoặc merge request |
| Build docs | Chỉ khi folder docs thay đổi |
| Run heavy test | Chỉ khi source code thay đổi |
| Release job | Chỉ khi có tag |
| Security scan | Chỉ MR hoặc scheduled pipeline |

## Lưu ý

- `rules` có thứ tự từ trên xuống.
- Rule đầu tiên match sẽ được áp dụng.
- Tránh viết rules quá phức tạp làm người khác không hiểu.
- Cần test kỹ để tránh job bị skip ngoài ý muốn.
- Nên document rule quan trọng, nhất là deploy production.

## Key message

**Pipeline tốt không chạy mọi thứ mọi lúc. Pipeline tốt chạy đúng job, đúng branch, đúng thời điểm.**

## Speaker notes

Nói rõ `rules` là nơi pipeline bắt đầu có “logic vận hành”.  
Sai rules có thể khiến job quan trọng không chạy hoặc deploy sai lúc.

---

# Slide 15 — Parallel Jobs and Interruptible Pipelines

## Nội dung trình bày

Pipeline có thể được tối ưu thêm bằng cách chạy song song và hủy pipeline cũ không còn cần thiết.

## Parallel jobs

Parallel jobs giúp chia công việc lớn thành nhiều job nhỏ chạy cùng lúc.

```yaml
test:
  stage: test
  parallel: 3
  script:
    - echo "Running test group $CI_NODE_INDEX of $CI_NODE_TOTAL"
```

## Khi nào nên dùng parallel?

- Test suite lớn.
- Nhiều module độc lập.
- Nhiều version cần test.
- Nhiều target build.
- Cần rút ngắn feedback loop.

## Rủi ro khi dùng parallel

- Nếu test không chia được rõ, kết quả có thể thiếu tin cậy.
- Nếu runner ít, parallel quá nhiều sẽ gây nghẽn.
- Nếu job setup nặng, parallel có thể làm tổng resource tăng mạnh.
- Nếu test phụ thuộc thứ tự chạy, parallel có thể gây lỗi khó đoán.

## Interruptible pipelines

Khi developer push nhiều commit liên tục, pipeline cũ có thể không còn giá trị.

```yaml
test:
  stage: test
  interruptible: true
  script:
    - npm test
```

## Nên dùng `interruptible` cho

- Lint.
- Test trên feature branch.
- Build preview.
- Non-production jobs.
- Jobs không ghi dữ liệu quan trọng.

## Không nên dùng cho

- Production deployment.
- Database migration.
- Release job.
- Job ghi dữ liệu quan trọng.
- Job đang publish package chính thức.

## Key message

**Parallel giúp tăng tốc. Interruptible giúp tránh lãng phí. Nhưng cả hai phải dùng có kiểm soát.**

## Speaker notes

Nhấn mạnh: không phải cứ parallel là tốt. Nếu runner ít, parallel quá nhiều chỉ chuyển bottleneck từ pipeline sang runner.

---

# Slide 16 — Why Reusable CI/CD Templates Matter

## Nội dung trình bày

Khi project còn nhỏ, một file `.gitlab-ci.yml` viết tay có thể đủ dùng.

Nhưng khi team lớn hơn, nhiều project hơn, nhiều service hơn, copy-paste YAML sẽ trở thành technical debt.

## Vấn đề của copy-paste YAML

- Mỗi project một kiểu pipeline.
- Sửa security rule ở một project, quên sửa project khác.
- Deploy logic không đồng nhất.
- Version image/tooling lệch nhau.
- Debug khó vì cấu trúc không chuẩn.
- Onboarding người mới mất thời gian.
- CI/CD file ngày càng dài và khó đọc.
- Một bug trong template copy-paste có thể lặp lại ở nhiều project.

## Template giúp gì?

| Lợi ích | Ý nghĩa |
|---|---|
| Chuẩn hóa | Nhiều project dùng chung logic |
| Dễ maintain | Sửa một nơi, dùng nhiều nơi |
| Giảm lỗi | Ít copy-paste sai |
| Tăng governance | Security/deploy rule nhất quán |
| Dễ scale | Thêm project mới nhanh hơn |

## Khi nào nên tạo template?

- Từ 3 project trở lên có logic giống nhau.
- Nhiều job lặp lại cùng image, cache, script.
- Team muốn chuẩn hóa build/test/deploy.
- Pipeline dài quá khó đọc.
- Có security/deploy rule cần áp dụng thống nhất.
- Có nhiều service dùng cùng tech stack.

## Key message

**Pipeline scale tốt không phải bằng copy-paste. Pipeline scale tốt bằng template hóa.**

## Speaker notes

Có thể lấy ví dụ: 5 project Node.js cùng build/test/deploy.  
Nếu mỗi project tự viết YAML, sau vài tháng sẽ lệch version, lệch cache, lệch security.

---

# Slide 17 — Hidden Jobs and Extends

## Nội dung trình bày

Hidden job là job có tên bắt đầu bằng dấu chấm `.`.  
Hidden job không tự chạy, thường được dùng làm template để job khác kế thừa.

## Ví dụ hidden job

```yaml
.default_node_job:
  image: node:20
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/
  before_script:
    - npm install
```

Job `.default_node_job` không tự xuất hiện như một job chạy trong pipeline.

## Dùng `extends`

```yaml
build:
  extends: .default_node_job
  stage: build
  script:
    - npm run build

test:
  extends: .default_node_job
  stage: test
  script:
    - npm test
```

## Lợi ích

- Không cần lặp lại `image`.
- Không cần lặp lại `cache`.
- Không cần lặp lại `before_script`.
- Dễ thay đổi version Node ở một nơi.
- Giữ cấu trúc build/test nhất quán.
- Dễ áp dụng convention cho nhiều job.

## Nên dùng cho

- Default image.
- Before script.
- Cache config.
- Common variables.
- Common retry/timeout.
- Common setup command.
- Common service dependencies.

## Lưu ý

- Đừng lạm dụng quá nhiều tầng `extends`.
- Template quá phức tạp sẽ khó debug.
- Tên hidden job nên rõ nghĩa: `.default_node_job`, `.deploy_template`, `.docker_build_template`.
- Template nên giải quyết phần lặp thật, không nên template hóa mọi thứ quá sớm.

## Key message

**`extends` giúp giảm lặp và tăng tính maintainable, nhưng template phải đủ rõ để người khác đọc được.**

## Speaker notes

Nhấn mạnh “template hóa” không đồng nghĩa làm YAML thành mê cung.  
Nếu một người mới không hiểu job kế thừa từ đâu, template đang quá phức tạp.

---

# Slide 18 — Include and Template Structure

## Nội dung trình bày

`include` cho phép tách CI/CD config ra nhiều file hoặc tái sử dụng template từ nơi khác.

## Ví dụ include file local

```yaml
include:
  - local: 'ci/node-template.yml'
```

## Cấu trúc gợi ý

```text
ci/
├── templates/
│   ├── node.yml
│   ├── docker.yml
│   └── deploy.yml
├── jobs/
│   ├── build.yml
│   ├── test.yml
│   └── scan.yml
└── environments/
    ├── staging.yml
    └── production.yml
```

## File `.gitlab-ci.yml` chính

```yaml
include:
  - local: 'ci/templates/node.yml'
  - local: 'ci/jobs/build.yml'
  - local: 'ci/jobs/test.yml'
  - local: 'ci/environments/production.yml'

stages:
  - build
  - test
  - deploy
```

## Khi nào nên tách file?

- `.gitlab-ci.yml` quá dài.
- Có nhiều nhóm job: build, test, scan, deploy.
- Có nhiều environment.
- Nhiều project dùng chung template.
- Cần phân quyền hoặc review từng phần rõ hơn.
- Cần tái sử dụng template cho nhiều service.

## Nguyên tắc đặt cấu trúc

| Nguyên tắc | Ý nghĩa |
|---|---|
| Tách theo mục đích | build/test/deploy/security |
| Tên file rõ nghĩa | Đọc tên biết file làm gì |
| Không tách quá vụn | Quá nhiều file sẽ khó theo dõi |
| Template phải có convention | Team dùng chung dễ hiểu |
| Document cách dùng | Người mới không phải đoán |

## Key message

**Một file CI/CD quá dài là dấu hiệu cần refactor. Nhưng tách file cũng phải có cấu trúc, không tách bừa.**

## Speaker notes

Có thể đưa rule thực tế: nếu `.gitlab-ci.yml` quá dài, nhiều job lặp lại, hoặc nhiều project copy nhau, bắt đầu nghĩ đến `include`.

---

# Slide 19 — CI/CD Security and Governance

## Nội dung trình bày

CI/CD không chỉ là công cụ tự động hóa.  
Nó có quyền tác động trực tiếp đến source code, build, secret, server và production.

## Vì sao CI/CD cần governance?

Pipeline có thể:

- Đọc source code.
- Dùng secrets.
- Build package.
- Push image lên registry.
- Deploy lên server.
- Chạy migration.
- Gọi API bên ngoài.
- Tác động trực tiếp đến production.

Nếu pipeline bị cấu hình sai, rủi ro không nhỏ.

## Các lớp kiểm soát chính

| Control Layer | Cần kiểm soát gì? |
|---|---|
| Branch | Ai được merge/push vào main |
| Variables | Secret nào được dùng ở đâu |
| Runner | Runner nào được chạy job nào |
| Deployment | Ai được deploy production |
| Environment | Dev/staging/prod tách biệt không |
| Approval | Bước nào cần manual gate |
| Audit | Có trace được ai làm gì không |

## Best practices

- Protect `main` hoặc release branches.
- Dùng protected variables cho production secrets.
- Dùng masked variables để tránh lộ secret trong log.
- Không echo secret.
- Không dùng production secret trên feature branch.
- Tách runner cho job nhạy cảm.
- Production deploy nên có manual gate.
- Giới hạn quyền deploy theo role.
- Review pipeline changes như review code.
- Không cấp quyền dư cho runner/token.

## Anti-pattern nguy hiểm

```yaml
script:
  - echo $PRODUCTION_PASSWORD
```

Hoặc:

```yaml
deploy:
  stage: deploy
  script:
    - npm run deploy
```

Mà không có branch rule, không environment, không manual gate.

## Key message

**CI/CD càng tự động hóa nhiều, governance càng phải chặt. Automation không kiểm soát là rủi ro.**

## Speaker notes

Phần này nên nói thẳng: CI/CD là đường vào production.  
Nếu pipeline không kiểm soát, team đang mở cửa cho lỗi vận hành hoặc leak secret.

---

# Slide 20 — Production-Ready CI/CD Checklist

## Nội dung trình bày

Trước khi gọi một pipeline là production-ready, cần kiểm tra theo 4 nhóm.

---

## 1. Debuggability

Pipeline có dễ debug không?

- Log có rõ không?
- Job name có dễ hiểu không?
- Stage có được đặt hợp lý không?
- Lỗi có trace được từ job log không?
- Có phân biệt lỗi build, test, scan, deploy không?
- Có checklist debug cho team không?

---

## 2. Optimization

Pipeline có chạy hiệu quả không?

- Có dùng cache cho dependencies không?
- Cache key có hợp lý không?
- Có dùng artifacts cho build/report output không?
- Có dùng `needs` để giảm thời gian chờ không?
- Có dùng `rules` để tránh job chạy dư không?
- Có dùng parallel cho test suite lớn không?
- Có dùng `interruptible` cho non-production jobs không?

---

## 3. Reusability

Pipeline có dễ maintain không?

- YAML có bị copy-paste nhiều không?
- Có dùng hidden jobs cho cấu hình chung không?
- Có dùng `extends` để reuse job template không?
- Có tách file bằng `include` khi pipeline quá dài không?
- Template có tên rõ nghĩa không?
- Người mới có đọc hiểu được cấu trúc không?

---

## 4. Security & Governance

Pipeline có đủ kiểm soát không?

- Main branch có protected không?
- Production variables có masked/protected không?
- Production deploy có manual gate không?
- Production deploy có chỉ chạy từ branch/tag phù hợp không?
- Runner production có được kiểm soát không?
- Secret có bị in ra log không?
- Có trace được ai trigger deployment không?
- Pipeline changes có được review không?

## Final Key Message

Production-ready CI/CD không chỉ là pipeline chạy xanh.

Production-ready CI/CD là pipeline:

- **Dễ debug**
- **Chạy hiệu quả**
- **Dễ tái sử dụng**
- **Bảo mật**
- **Có governance**
- **Sẵn sàng cho project thật**

## Câu chốt

**Build được pipeline là nền tảng. Vận hành được pipeline ổn định mới là năng lực thực chiến.**

## Speaker notes

Dùng slide này để recap toàn buổi.  
Có thể yêu cầu học viên tự chọn một pipeline từng làm và đánh giá theo 4 nhóm: Debuggability, Optimization, Reusability, Security & Governance.

---

# Gợi ý phân bổ thời gian nói chi tiết

| Mốc thời gian | Nội dung |
|---|---|
| 00:00–00:05 | Mở đầu, mục tiêu session |
| 00:05–00:10 | Agenda và chuyển từ working pipeline sang production-ready |
| 00:10–00:45 | Troubleshooting & Debugging |
| 00:45–01:20 | Pipeline Optimization |
| 01:20–01:40 | Reusable CI/CD Templates |
| 01:40–01:50 | Security & Governance |
| 01:50–02:00 | Checklist, recap, Q&A |

---

# Câu hỏi gợi mở cho trainer

## Troubleshooting

- Nếu job pending, bạn kiểm tra script trước hay runner trước?
- Nếu pipeline không xuất hiện, bạn kiểm tra file nào đầu tiên?
- Nếu secret bị rỗng, có nên `echo` ra log không?

## Optimization

- Cache và artifacts khác nhau như thế nào?
- Khi nào nên dùng `needs`?
- Có nên chạy toàn bộ pipeline cho mọi commit không?

## Reusability

- Khi nào copy-paste YAML trở thành technical debt?
- Hidden job có tự chạy không?
- `extends` giúp giải quyết vấn đề gì?

## Security & Governance

- Vì sao production variable nên protected?
- Manual gate có làm pipeline kém hiện đại không?
- Vì sao pipeline changes cũng cần review như code?

---

# Checklist chuẩn bị trước buổi dạy

- Mở sẵn một GitLab project demo.
- Có sẵn một pipeline lỗi YAML để minh họa.
- Có sẵn một job pending do tag mismatch.
- Có sẵn ví dụ variable bị thiếu hoặc protected sai branch.
- Có sẵn pipeline chậm để minh họa cache/artifacts/needs/rules.
- Có sẵn ví dụ hidden job + extends.
- Có sẵn ví dụ include file.
- Chuẩn bị 5–10 phút Q&A cuối buổi.

---

# Kết luận buổi học

Sau 4 session đầu, học viên đã biết cách xây dựng pipeline.  
Sau Session 5, học viên cần biết cách **vận hành pipeline như một hệ thống thật**.

Điểm khác biệt nằm ở tư duy:

- Không chỉ viết YAML.
- Không chỉ chạy job.
- Không chỉ deploy.
- Mà phải biết debug, optimize, template hóa, bảo mật và kiểm soát.

**Thông điệp cuối:**  
GitLab CI/CD không khó ở cú pháp. Nó khó ở thiết kế pipeline đủ tốt để team thật dùng lâu dài.
