# Session 5 demo runbook — Production-Ready CI/CD

Runbook này dùng để xen kẽ demo GitLab UI với slide trong file [GitLab_CICD_Session_5_Production_Ready_CICD_2h.md](../GitLab_CICD_Session_5_Production_Ready_CICD_2h.md). Tất cả job dùng GitLab Runner tag `runner_01` và chỉ mô phỏng deploy bằng file text.

## Demo map theo 4 agenda chính

| Agenda | Slide | Demo | Thời lượng | File chính |
|---|---:|---|---:|---|
| Pipeline Troubleshooting & Debugging | 4–9 | Job visibility, rules, runner `runner_01`, log debug | 8–10 phút | [.gitlab-ci.yml](../.gitlab-ci.yml), [scripts/test.sh](../scripts/test.sh) |
| Pipeline Optimization | 10–15 | `needs`, artifacts, conditional jobs, rolling/blue-green manual jobs | 8–10 phút | [.gitlab-ci.yml](../.gitlab-ci.yml), [scripts/build.sh](../scripts/build.sh) |
| Reusable CI/CD Templates | 16–18 | `include`, hidden jobs, `extends` | 8–10 phút | [.gitlab/ci/](../.gitlab/ci/) |
| Security & Governance in CI/CD | 19–20 | protected/manual production deploy, rollback, variable scope | 8–10 phút | [.gitlab-ci.yml](../.gitlab-ci.yml), [scripts/deploy-production.sh](../scripts/deploy-production.sh) |

## Chuẩn bị trước buổi học

1. Kiểm tra runner `runner_01` đang online trong GitLab project.
2. Đảm bảo branch `develop` tồn tại nếu muốn demo deploy dev.
3. Đảm bảo branch `main` là protected nếu muốn nói về governance.
4. Tạo sẵn hoặc chuẩn bị tạo tag dạng `v1.0.0` cho demo production manual gate.
5. Nếu muốn demo rollback có previous release ngay trong tag pipeline đầu tiên, set CI/CD variable `PREVIOUS_PRODUCTION_RELEASE=v0.9.0` khi chạy job hoặc trong project demo.
6. Mở sẵn các trang GitLab:
   - CI/CD > Pipelines
   - CI/CD > Jobs
   - Settings > CI/CD > Runners
   - Operate/Deploy > Environments

## Demo 1 — Pipeline Troubleshooting & Debugging

- Thời điểm: sau slide 4–9.
- Mục tiêu: học viên thấy cách debug theo thứ tự pipeline → job → runner → script → variable/artifact.

### Kịch bản A — Job visibility và `rules`

1. Push branch `feature/session5-demo`.
2. Mở pipeline mới trong GitLab.
3. Chỉ ra `test` và `build` chạy.
4. Chỉ ra `deploy_dev`, `deploy_staging`, `deploy_production` không chạy vì `rules` không match.
5. Mở [.gitlab-ci.yml](../.gitlab-ci.yml), chỉ vào rule của `deploy_dev`, `deploy_staging`, `deploy_production`.

Câu chốt: nếu job không xuất hiện, hãy kiểm tra `rules` trước khi kiểm tra script.

### Kịch bản B — Runner `runner_01` và pending job

1. Mở job `test` hoặc `build`.
2. Chỉ ra job kế thừa `.runner_01_job` từ [.gitlab/ci/common.yml](../.gitlab/ci/common.yml).
3. Mở Settings > CI/CD > Runners để thấy runner `runner_01` online.
4. Giải thích: nếu tag trong template đổi thành tag không tồn tại, job sẽ pending.

Câu chốt: khi job pending, kiểm tra runner online, tag, protected runner và branch protection.

### Kịch bản C — Script log debug

1. Mở log job `test`.
2. Chỉ ra log `Version file found`, `Lint simulation passed`, `Unit test simulation passed`.
3. Mở [scripts/test.sh](../scripts/test.sh), chỉ ra lệnh fail sớm nếu thiếu [app/version.txt](../app/version.txt).

Câu chốt: log tốt giúp tìm command đầu tiên fail, không đoán mò.

## Demo 2 — Pipeline Optimization

- Thời điểm: sau slide 10–15.
- Mục tiêu: học viên thấy pipeline không chỉ chạy được mà còn chạy đúng thứ tự, đúng điều kiện và giữ output cần thiết.

### Kịch bản A — `needs` giúp job chạy sớm hơn

1. Mở graph pipeline.
2. Chỉ ra `build` dùng `needs: [test]`, deploy jobs dùng `needs: [build]`.
3. Giải thích `needs` mô tả dependency trực tiếp thay vì chỉ chờ toàn bộ stage.

Câu chốt: `needs` làm pipeline rõ dependency và giảm thời gian chờ không cần thiết.

### Kịch bản B — Artifact build output

1. Mở job `build`.
2. Tải hoặc xem artifact `preview/release.txt`.
3. Mở [scripts/build.sh](../scripts/build.sh) để chỉ ra artifact được tạo từ version và SHA.

Câu chốt: cache dùng để tăng tốc, artifact dùng để truyền output chính thức giữa job.

### Kịch bản C — Conditional jobs và strategy jobs

1. Trên branch `main` hoặc tag pipeline, chỉ ra `simulate_rolling_update` và `simulate_blue_green` là manual.
2. Chạy `simulate_rolling_update`, xem log từng instance và health check.
3. Chạy `simulate_blue_green`, xem artifact `state/blue-green.env`.
4. Chạy `rollback_blue_green`.

Câu chốt: job nặng hoặc job chiến lược nên chạy có điều kiện/manual, không chạy mọi pipeline.

## Demo 3 — Reusable CI/CD Templates

- Thời điểm: sau slide 16–18.
- Mục tiêu: học viên thấy template thật thay vì chỉ nghe khái niệm.

### Kịch bản A — `include`

1. Mở đầu file [.gitlab-ci.yml](../.gitlab-ci.yml).
2. Chỉ ra 3 include local:
   - [.gitlab/ci/common.yml](../.gitlab/ci/common.yml)
   - [.gitlab/ci/deploy.yml](../.gitlab/ci/deploy.yml)
   - [.gitlab/ci/strategy.yml](../.gitlab/ci/strategy.yml)
3. Giải thích file chính chỉ còn orchestration, logic dùng chung được tách ra.

Câu chốt: `include` giúp project lớn không biến `.gitlab-ci.yml` thành một file quá dài.

### Kịch bản B — Hidden jobs

1. Mở [.gitlab/ci/common.yml](../.gitlab/ci/common.yml).
2. Chỉ ra `.runner_01_job` và `.artifact_1_week` bắt đầu bằng dấu chấm.
3. Giải thích hidden job không tự chạy; nó là template để job thật kế thừa.

Câu chốt: hidden job là nơi chuẩn hoá runner, before_script, artifact policy.

### Kịch bản C — `extends`

1. Mở job `deploy_production` trong [.gitlab-ci.yml](../.gitlab-ci.yml).
2. Chỉ ra job này extends `.deploy_template` và `.production_state_artifact`.
3. Mở [.gitlab/ci/deploy.yml](../.gitlab/ci/deploy.yml) để xem logic dùng chung.
4. So sánh với `deploy_dev` và `deploy_staging` để thấy không copy-paste stage/needs/runner.

Câu chốt: `extends` giảm copy-paste nhưng vẫn giữ job chính đọc được.

## Demo 4 — Security & Governance in CI/CD

- Thời điểm: slide 19–20.
- Mục tiêu: học viên thấy production không nên deploy tự động như dev/staging.

### Kịch bản A — Manual production gate

1. Tạo tag `v1.0.0`.
2. Mở tag pipeline.
3. Chỉ ra `deploy_production` xuất hiện dạng manual.
4. Mở [.gitlab-ci.yml](../.gitlab-ci.yml), chỉ ra rule chỉ match tag semver `vX.Y.Z`.
5. Bấm chạy `deploy_production`.

Câu chốt: production deploy nên có điều kiện rõ ràng và manual gate.

### Kịch bản B — Production state và rollback

1. Sau production deploy, mở artifact `state/production.env`.
2. Chỉ ra `CURRENT_RELEASE` và `PREVIOUS_RELEASE`.
3. Bấm chạy `rollback_production`. Nếu chạy rollback độc lập, truyền `PREVIOUS_PRODUCTION_RELEASE=v0.9.0`.
4. Mở log rollback để thấy production chuyển về previous release.
5. Nếu `PREVIOUS_RELEASE=none`, giải thích đây là first deploy nên không có bản trước đó.

Câu chốt: rollback phải là một flow có thể chạy và audit được, không phải thao tác thủ công ngoài pipeline.

### Kịch bản C — Variable và protected scope

1. Nhắc variable demo `PREVIOUS_PRODUCTION_RELEASE=v0.9.0`.
2. Mở Settings > CI/CD > Variables nếu có quyền.
3. Giải thích production secret thật nên là masked/protected và chỉ dùng trên protected branch/tag.
4. Nhấn mạnh demo này không dùng secret thật.

Câu chốt: governance nằm ở branch protection, protected variables, runner scope, manual job và audit trail.

## Lệnh kiểm tra local

Các lệnh dưới đây sẽ tạo hoặc cập nhật file trong [preview/](../preview/) và [state/](../state/). Nếu muốn chạy lại từ đầu, xoá các file sinh ra bằng `rm -f preview/*.txt state/*.env`.

```bash
sh scripts/test.sh
sh scripts/build.sh
CI_COMMIT_SHORT_SHA=demo123 sh scripts/deploy-dev.sh
CI_COMMIT_SHORT_SHA=demo456 sh scripts/deploy-staging.sh
PREVIOUS_PRODUCTION_RELEASE=v0.9.0 CI_COMMIT_TAG=v1.0.0 CI_COMMIT_SHORT_SHA=demo789 sh scripts/deploy-production.sh
sh scripts/rollback-production.sh
sh scripts/simulate-rolling.sh
sh scripts/simulate-blue-green.sh
sh scripts/rollback-blue-green.sh
```

## Checklist khi demo lỗi

- Pipeline không tạo: kiểm tra YAML syntax và `include` path.
- Job không xuất hiện: kiểm tra `rules`.
- Job pending: kiểm tra runner `runner_01`, tag, protected runner và branch protection.
- Job fail ở script: mở log, tìm command đầu tiên fail.
- Rollback không có state: kiểm tra artifact của job trước đó hoặc truyền biến demo `PREVIOUS_PRODUCTION_RELEASE`.
- Template không apply: kiểm tra hidden job name trong `extends` có đúng dấu chấm ở đầu không.
