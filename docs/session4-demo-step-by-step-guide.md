# Session 4 Demo Step-by-Step Guide

## 1. Mục tiêu buổi demo
- Giải thích flow deploy theo môi trường trong GitLab CI/CD.
- Cho học viên thấy pipeline thay đổi theo branch và tag.
- Minh hoạ `dev`, `staging`, `production`, manual approval, rolling update, và blue/green.
- Dùng runner tag `runner_01` để học viên nhìn thấy job được pick up bởi đúng runner.

## 2. GitLab CI/CD cần những gì để demo được

### 2.1. Source code cần có trong repo
Push đầy đủ các phần này lên GitLab:
- `app/`
- `scripts/`
- `state/`
- `docs/`
- `.gitlab-ci.yml`
- `README.md`
- `.gitignore`

Không cần push output sinh ra trong lúc chạy demo:
- `dist/`
- `preview/`

### 2.2. GitLab project cần được setup trước
Trước buổi demo, đảm bảo project GitLab có đủ các điều kiện sau:
1. Đã tạo project mới trên GitLab.
2. Đã push branch `main` lên remote GitLab.
3. `main` đang là default branch của project.
4. Có ít nhất 1 runner khả dụng với tag `runner_01`.
5. Runner được phép chạy job cho project này.
6. Project cho phép tạo branch và push tag.
7. Bạn có quyền xem **Pipelines**, **Jobs**, **Environments**, và **Runners**.

### 2.3. Runner cần gì
Vì pipeline đang dùng tag `runner_01` trong [`.gitlab-ci.yml:7-10`](../.gitlab-ci.yml#L7-L10), bạn cần:
- một GitLab Runner online
- runner đó có tag `runner_01`
- runner shell hoặc container đều được, miễn là chạy được `sh`

Thông điệp nên nói khi demo:
> Ở đây chúng ta dùng tag `runner_01` để ép job chạy đúng runner mà mình muốn. Điều này giúp học viên thấy rõ cách GitLab route job theo tag.

### 2.4. Branch và tag cần chuẩn bị
Bạn nên chuẩn bị các branch/tag này để demo:
- `main`
- `develop`
- một branch theo pattern `feature/*`, ví dụ `feature/session4-validation-demo`
- một tag release theo pattern `v*`, ví dụ `v1.0.0`

### 2.5. Kiểm tra local trước buổi demo
Chạy local để chắc chắn code demo hoạt động:

```bash
sh scripts/test.sh
```

Expected:
- Script chạy thành công.
- Có tạo ra `dist/`, `preview/`, và các file trong `state/`.
- Không có lỗi missing file/script.

## 3. Setup project GitLab từ đầu

### 3.1. Tạo project GitLab
Trên GitLab UI:
1. Chọn **New project**.
2. Tạo một project trống.
3. Đặt tên project, ví dụ `gitlab-session4-demo`.
4. Tạo project xong thì copy URL remote.

### 3.2. Gắn remote từ máy local
Nếu repo local chưa trỏ tới GitLab này:

```bash
git remote add origin <gitlab-repo-url>
```

Nếu đã có remote nhưng cần đổi sang project demo mới:

```bash
git remote set-url origin <gitlab-repo-url>
```

### 3.3. Push branch chính

```bash
git checkout main
git push -u origin main
```

### 3.4. Đặt `main` làm default branch
Trên GitLab UI:
1. Vào **Settings > Repository**.
2. Tìm phần **Default branch**.
3. Chọn `main`.

Điều này quan trọng vì demo hiện tại map `main` -> `staging` theo [`.gitlab-ci.yml:55-63`](../.gitlab-ci.yml#L55-L63).

### 3.5. Kiểm tra runner
Trên GitLab UI:
1. Vào **Settings > CI/CD**.
2. Mở phần **Runners**.
3. Xác nhận có runner online.
4. Xác nhận runner có tag `runner_01`.

Nếu không có tag này, job sẽ bị pending và không chạy.

### 3.6. Trigger pipeline đầu tiên cho `main`
Ngay sau khi push `main`, GitLab thường sẽ tạo pipeline đầu tiên.
Bạn có thể tận dụng pipeline này để mở đầu phần giải thích về stages, jobs, và deploy `staging`.

## 4. Các màn hình GitLab cần mở sẵn
Trong lúc trình bày, nên ghim sẵn các màn hình sau trong tab browser:
1. **Build > Pipelines**
2. **Build > Jobs**
3. **Operate > Environments**
4. **Settings > CI/CD > Runners** hoặc trang runner tương đương của project/group
5. Repo source để mở `.gitlab-ci.yml`
6. Trang branch/tag của repo nếu muốn cho học viên thấy trigger đến từ đâu

## 5. Cách mở đầu buổi demo
Có thể nói ngắn gọn như sau:

> Trong session này, chúng ta không deploy lên hạ tầng thật. Thay vào đó, chúng ta mô phỏng flow CI/CD an toàn bằng static app, state file, và environment artifacts. Mục tiêu là hiểu cách GitLab điều phối pipeline, environment, approval, và deployment strategy.

Sau đó mở [README.md](../README.md) và giải thích nhanh phần:
- Demo Flow
- Runner
- Key Commands
- Teaching Notes

## 6. Giải thích pipeline trước khi chạy
Mở [`.gitlab-ci.yml`](../.gitlab-ci.yml) và đi qua các ý chính:

### 6.1. Stages
- `build`
- `test`
- `deploy`
- `strategy`

### 6.2. Runner tag
Chỉ vào đoạn [`.gitlab-ci.yml:7-10`](../.gitlab-ci.yml#L7-L10).

Thông điệp nên nói:
> Mọi job trong demo này đều yêu cầu runner có tag `runner_01`, nên học viên sẽ thấy rõ job được route đúng runner.

### 6.3. Mapping branch/tag sang môi trường
Giải thích theo đúng rules hiện tại:
- `feature/*` chỉ validation theo [`.gitlab-ci.yml:38-43`](../.gitlab-ci.yml#L38-L43)
- `develop` deploy `dev` theo [`.gitlab-ci.yml:45-53`](../.gitlab-ci.yml#L45-L53)
- `main` deploy `staging` theo [`.gitlab-ci.yml:55-63`](../.gitlab-ci.yml#L55-L63)
- tag `v*` mở manual production deploy theo [`.gitlab-ci.yml:65-74`](../.gitlab-ci.yml#L65-L74)
- release tag pipeline còn có 2 job manual cho production strategy demos theo [`.gitlab-ci.yml:76-93`](../.gitlab-ci.yml#L76-L93)

## 7. Thứ tự setup và demo end-to-end
Nếu bạn muốn trình bày từ đầu đến cuối theo đúng flow setup trước, demo sau, hãy đi theo thứ tự này:
1. Tạo project GitLab.
2. Push `main`.
3. Kiểm tra runner `runner_01`.
4. Mở pipeline của `main` để giải thích file CI.
5. Tạo feature branch để cho học viên thấy validation-only.
6. Tạo hoặc push `develop` để cho học viên thấy deploy `dev`.
7. Push thêm vào `main` để cho học viên thấy deploy `staging`.
8. Tạo tag `v1.0.0` để cho học viên thấy manual production gate.
9. Chạy `simulate_rolling_update` trên pipeline của release tag.
10. Chạy `simulate_blue_green` trên pipeline của release tag.

## 8. Demo 1 - Feature branch chỉ chạy validation

### 8.1. Tạo branch

```bash
git checkout main
git checkout -b feature/session4-validation-demo
```

### 8.2. Tạo commit để trigger pipeline

```bash
git commit --allow-empty -m "test: trigger feature validation pipeline"
```

### 8.3. Push branch lên GitLab

```bash
git push -u origin feature/session4-validation-demo
```

### 8.4. Trên GitLab UI
Vào **Build > Pipelines** rồi mở pipeline mới nhất của branch này.

### 8.5. Điều cần chỉ cho học viên
- Pipeline có `build_demo`, `validate_demo`, và `feature_validation`.
- Không có deploy sang `dev`, `staging`, hay `production`.
- Rule branch đang chặn deploy ở feature branch.

### 8.6. Câu nói gợi ý
> Đây là lớp bảo vệ đầu tiên. Developer có thể push feature branch liên tục để kiểm tra chất lượng mà không làm ảnh hưởng môi trường chia sẻ.

## 9. Demo 2 - Branch `develop` deploy lên `dev`

### 9.1. Tạo branch `develop` nếu project chưa có

```bash
git checkout main
git checkout -b develop
```

Nếu branch `develop` đã tồn tại local thì chỉ cần:

```bash
git checkout develop
```

### 9.2. Tạo commit để trigger pipeline

```bash
git commit --allow-empty -m "test: trigger develop deployment"
```

### 9.3. Push branch `develop`

```bash
git push -u origin develop
```

### 9.4. Trên GitLab UI
- Mở **Build > Pipelines**.
- Mở pipeline branch `develop`.
- Cho học viên thấy job `deploy_dev` chạy.

### 9.5. Mở trang environment
Vào **Operate > Environments**.

### 9.6. Điều cần chỉ cho học viên
- Environment `dev` xuất hiện.
- Có lịch sử deploy.
- Có thể bấm vào environment để xem artifact/output tương ứng nếu cần.

### 9.7. Câu nói gợi ý
> `dev` là môi trường tích hợp sớm. Chúng ta chấp nhận thay đổi thường xuyên ở đây để team kiểm tra nhanh sau khi merge hoặc push vào nhánh tích hợp.

## 10. Demo 3 - Branch `main` deploy lên `staging`

### 10.1. Quay lại `main`

```bash
git checkout main
```

### 10.2. Tạo commit để trigger pipeline mới

```bash
git commit --allow-empty -m "test: trigger staging deployment"
```

### 10.3. Push `main`

```bash
git push origin main
```

### 10.4. Trên GitLab UI
- Mở pipeline mới nhất của `main`.
- Chỉ cho học viên job `deploy_staging`.

### 10.5. Mở environment
Vào **Operate > Environments** và chỉ cho học viên thấy `staging`.

### 10.6. Điều cần nói
> `staging` gần production hơn `dev`. Thường đây là nơi QA, UAT, hoặc business review trước khi release.

### 10.7. Góc nhìn giảng giải
So sánh `develop -> dev` và `main -> staging` để học viên thấy:
- cùng một repo
- cùng pipeline engine
- nhưng khác rule theo branch
- dẫn tới khác môi trường đích

## 11. Demo 4 - Tag release và manual production deployment

### 11.1. Đảm bảo đang ở `main`

```bash
git checkout main
```

### 11.2. Tạo tag release

```bash
git tag v1.0.0
```

Nếu `v1.0.0` đã tồn tại, dùng tag mới hơn như:

```bash
git tag v1.0.1
```

### 11.3. Push tag lên GitLab

```bash
git push origin v1.0.0
```

Hoặc nếu dùng tag mới:

```bash
git push origin v1.0.1
```

### 11.4. Trên GitLab UI
- Vào **Build > Pipelines**.
- Mở pipeline của tag `v1.0.0` hoặc tag bạn vừa push.
- Chỉ cho học viên thấy job `deploy_production` ở trạng thái **manual**.

### 11.5. Trước khi bấm manual job
Dừng lại khoảng 15-30 giây để giải thích:
- Tại sao production không auto deploy.
- Manual approval là điểm kiểm soát rủi ro.
- Một release có thể đã build xong nhưng chưa được phép vào production ngay.

### 11.6. Thực hiện deploy manual
Bấm **Play** cho job `deploy_production`.

### 11.7. Sau khi job chạy xong
Mở **Operate > Environments** và chỉ cho học viên thấy `production`.

### 11.8. Demo rollback production thật trên GitLab UI
Ngay sau khi demo deploy production, bạn có thể demo rollback thật luôn:
1. Ở cùng pipeline tag release, chỉ cho học viên thấy job `rollback_production`.
2. Giải thích rằng job này sẽ đưa production về version trước đó đã được lưu trong state history.
3. Bấm **Play** cho job `rollback_production`.
4. Mở log job để học viên thấy các dòng như:
   - `Current production version: v1.0.1`
   - `Rolling back to: v1.0.0`
   - `Production rollback complete`
5. Mở lại **Operate > Environments** và giải thích rằng production đã quay về version trước.

### 11.9. Câu nói gợi ý
> Đây là mô hình thường gặp trong doanh nghiệp: build và kiểm thử có thể tự động, nhưng bước vào production vẫn cần approval để đáp ứng kiểm soát thay đổi. Và khi release có sự cố, rollback cũng phải là một thao tác thật, nhanh và rõ ràng trên pipeline.

## 12. Demo 5 - Rolling update simulation

### 12.1. Điều kiện chạy
Dùng pipeline của release tag vì job strategy hiện được bật manual trên cùng flow production release.

### 12.2. Trên GitLab UI
- Mở pipeline của tag release vừa push, ví dụ `v1.0.0`.
- Bấm manual job `simulate_rolling_update`.

### 12.3. Mở job log
Chỉ cho học viên log dạng:
- `updating instance 1 of 4`
- `health check passed for instance 1`
- ...
- `updating instance 4 of 4`

### 12.4. Thông điệp nên nói
> Rolling update thay từng instance một, giảm downtime và giảm blast radius. Nếu có lỗi, ta thường phát hiện trước khi toàn bộ hệ thống bị ảnh hưởng.

### 12.5. Điểm nhấn giảng dạy
Nhấn mạnh trade-off:
- Ưu điểm: an toàn hơn, ít gián đoạn hơn
- Nhược điểm: rollout chậm hơn, phức tạp hơn kiểu replace toàn bộ

## 13. Demo 6 - Blue/Green simulation

### 13.1. Trên GitLab UI
- Trong pipeline của tag release, bấm manual job `simulate_blue_green`.

### 13.2. Mở job log
Chỉ cho học viên các dòng:
- `deployed new version to green`
- `smoke test passed for green`
- `switching active environment: blue -> green`

### 13.3. Điều cần giải thích
> Blue/green nghĩa là ta giữ môi trường hiện tại đang phục vụ traffic và triển khai phiên bản mới ở môi trường song song. Chỉ khi kiểm tra xong mới chuyển traffic sang màu mới.

### 13.4. So sánh với rolling
- Rolling: đổi dần từng instance trong cùng một environment logic
- Blue/green: có hai phiên bản môi trường song song rồi chuyển active color

### 13.5. Cách nói ngắn gọn
> Rolling thì thay dần. Blue/green thì chuẩn bị sẵn môi trường mới rồi flip traffic.

## 14. Demo 7 - Rollback thật trên GitLab UI

### 14.1. Cách mở phần rollback
Sau khi demo xong production, rolling, và blue/green, bạn có thể chuyển ý như sau:

> Deploy xong chưa phải là hết việc. Điều quan trọng trong production là nếu bản mới có lỗi thì chúng ta phải rollback được thật, nhanh và rõ ràng ngay trên pipeline.

### 14.2. Demo rollback production thật
Đây là rollback theo version trước đó của production.

Các bước demo trên lớp:
1. Mở lại pipeline của tag release đã chạy `deploy_production`.
2. Chỉ cho học viên thấy job manual `rollback_production`.
3. Giải thích rằng job này dùng production history để quay về version trước đó.
4. Bấm **Play** cho `rollback_production`.
5. Mở log job và chỉ cho học viên các dòng:
   - `Current production version: ...`
   - `Rolling back to: ...`
   - `Production rollback complete`
6. Mở lại **Operate > Environments** hoặc artifact/state để cho học viên thấy production đã quay về version cũ.

### 14.3. Điều kiện để rollback production chạy được
Nói rõ với học viên:
1. Production phải đã được deploy ít nhất 2 lần thì mới có current version và previous version rõ ràng.
2. Nếu chưa có previous version, rollback sẽ không có đích để quay về.
3. Vì đây là workshop demo, previous version được lưu trong `state/production-history.json`.

### 14.4. Cách tập local trước buổi dạy cho rollback production
Nếu muốn tập local trước khi lên lớp, bạn có thể chạy:

```bash
CI_COMMIT_TAG=v1.0.0 sh scripts/deploy-production.sh
CI_COMMIT_TAG=v1.0.1 sh scripts/deploy-production.sh
sh scripts/rollback-production.sh
```

### 14.5. Câu nói gợi ý cho rollback production
> Rollback production ở đây không còn là giả định. Chúng ta có một manual job thật để đưa release hiện tại quay về release trước đó.

### 14.6. Demo rollback blue/green thật
Đây là rollback theo hướng chuyển active traffic về color trước đó.

Các bước demo trên lớp:
1. Ở pipeline của tag release, chạy `simulate_blue_green` trước.
2. Mở log để học viên thấy flow `blue -> green`.
3. Sau đó chỉ cho học viên thấy job manual `rollback_blue_green`.
4. Bấm **Play** cho `rollback_blue_green`.
5. Mở log job để học viên thấy dòng:
   - `Current active environment: green`
   - `Switching active environment: green -> blue`
   - `Blue/green rollback complete`
6. Giải thích rằng đây là rollback theo traffic switch, không nhất thiết phải build lại artifact mới.

### 14.7. Cách tập local trước buổi dạy cho rollback blue/green
Nếu muốn tập local trước khi lên lớp, bạn có thể chạy:

```bash
sh scripts/simulate-blue-green.sh
sh scripts/rollback-blue-green.sh
```

### 14.8. Câu nói gợi ý cho blue/green rollback
> Blue/green rollback nhanh vì mình không cần tạo release mới ngay. Việc đầu tiên là chuyển active traffic về màu cũ để khôi phục dịch vụ.

### 14.9. Rollback case 1 - Smoke test fail ngay sau deploy production
Đây là case dễ demo nhất vì xảy ra rất gần thời điểm release.

Flow bạn nên nói:
1. Deploy production xong.
2. Team chạy smoke test.
3. Smoke test fail.
4. Team bấm `rollback_production` ngay.

### 14.10. Rollback case 2 - Lỗi phát sinh sau vài phút do monitoring hoặc user report
Đây là case thực tế hơn vì nhiều lỗi không lộ ngay lúc smoke test.

Flow bạn nên nói:
1. Deploy production pass.
2. 5 đến 10 phút sau, monitoring tăng error rate hoặc user báo lỗi.
3. Team xác minh nhanh lỗi đi theo release mới.
4. Team bấm rollback.

### 14.11. Rollback case 3 - Bad config hoặc secret sai
Case này giúp nhấn mạnh rằng rollback không chỉ vì code lỗi.

Flow bạn nên nói:
1. Release mới không sai code.
2. Nhưng config production hoặc secret runtime sai.
3. Dịch vụ lỗi.
4. Team rollback để khôi phục dịch vụ trước, sửa config sau.

### 14.12. Rollback case 4 - Chỉ rollback traffic, chưa rollback artifact
Case này phù hợp cho blue/green.

Flow bạn nên nói:
1. Green đã deploy xong.
2. Team phát hiện lỗi.
3. Team bấm `rollback_blue_green` để chuyển traffic về blue.
4. Artifact ở green vẫn giữ lại để debug sau.

### 14.13. Rollback case 5 - Dừng rollout giữa chừng trong rolling update
Rolling rollback vẫn nên giải thích ở mức narrative, không cần job rollback thật trong repo này.

Flow bạn nên nói:
1. Rolling update đang update từng instance.
2. Health check fail giữa chừng.
3. Team dừng rollout.
4. Team redeploy version ổn định cho các instance đã update.

### 14.14. Flow quyết định rollback bạn có thể nói trên lớp
Khi học viên hỏi “khi nào thì rollback”, bạn có thể nói theo flow này:
1. Phát hiện tín hiệu lỗi.
2. Xác minh lỗi có liên quan tới release mới hay không.
3. Đánh giá mức độ ảnh hưởng.
4. Nếu ảnh hưởng production và chưa có fix nhanh, rollback.
5. Sau khi ổn định dịch vụ mới quay lại phân tích root cause.

Câu nói gợi ý:
> Trong production, ưu tiên đầu tiên là khôi phục dịch vụ. Root cause analysis là bước sau, không phải bước trước rollback.

### 14.15. Câu kết riêng cho phần rollback
Bạn có thể chốt phần này như sau:

> Một deployment strategy tốt không chỉ giúp mình đi tới phiên bản mới an toàn hơn, mà còn giúp mình quay về phiên bản cũ nhanh hơn khi production có sự cố.

### 14.16. Nếu muốn minh hoạ bằng version cũ
Bạn có thể dùng ví dụ nói trên lớp như sau:
- `v1.0.1` là bản đang chạy nhưng bị lỗi
- `v1.0.0` là bản ổn định trước đó

Luồng giải thích:
1. `deploy_production` đưa `v1.0.1` lên production
2. Team phát hiện lỗi
3. `rollback_production` đưa production về `v1.0.0`
4. Với blue/green, `rollback_blue_green` đưa active traffic về màu cũ

### 14.17. Thông điệp chốt cho học viên
> Trong demo này, rollback không phải phần nói miệng nữa. Nó là manual action thật trên GitLab UI mà team có thể bấm khi production gặp sự cố.

## 15. Cách giải thích file output để học viên dễ hình dung

Nếu muốn minh hoạ local hoặc artifact, giải thích như sau:
- `preview/` chứa HTML đã render theo môi trường
- `state/dev.json`, `state/staging.json`, `state/production.json` mô tả trạng thái deploy
- `state/production-history.json` lưu current version và previous version để phục vụ rollback production
- `state/rolling.log` mô phỏng rolling update log
- `state/blue-green.json` mô phỏng active color sau blue/green

Bạn cũng có thể chạy local nếu cần minh hoạ nhanh:

```bash
CI_COMMIT_SHORT_SHA=demo123 sh scripts/deploy-dev.sh
CI_COMMIT_SHORT_SHA=demo456 sh scripts/deploy-staging.sh
CI_COMMIT_TAG=v1.0.0 sh scripts/deploy-production.sh
CI_COMMIT_TAG=v1.0.1 sh scripts/deploy-production.sh
sh scripts/rollback-production.sh
sh scripts/simulate-rolling.sh
sh scripts/simulate-blue-green.sh
sh scripts/rollback-blue-green.sh
```

## 16. Thứ tự trình bày đề xuất cho 2 tiếng

## 15. Cách giải thích file output để học viên dễ hình dung
Nếu muốn minh hoạ local hoặc artifact, giải thích như sau:
- `preview/` chứa HTML đã render theo môi trường
- `state/dev.json`, `state/staging.json`, `state/production.json` mô tả trạng thái deploy
- `state/rolling.log` mô phỏng rolling update log
- `state/blue-green.json` mô phỏng active color sau blue/green

Bạn cũng có thể chạy local nếu cần minh hoạ nhanh:

```bash
CI_COMMIT_SHORT_SHA=demo123 sh scripts/deploy-dev.sh
CI_COMMIT_SHORT_SHA=demo456 sh scripts/deploy-staging.sh
CI_COMMIT_TAG=v1.0.0 sh scripts/deploy-production.sh
sh scripts/simulate-rolling.sh
sh scripts/simulate-blue-green.sh
```

## 16. Thứ tự trình bày đề xuất cho 2 tiếng

### Phần 1 - Bối cảnh và mục tiêu (10-15 phút)
- Môi trường là gì
- Tại sao cần nhiều môi trường
- Vì sao production cần kiểm soát chặt hơn

### Phần 2 - Setup project trên GitLab (15-20 phút)
- Tạo project
- Push `main`
- Kiểm tra default branch
- Kiểm tra runner `runner_01`
- Mở các màn hình Pipelines / Jobs / Environments / Runners

### Phần 3 - Giải thích repo và pipeline (15-20 phút)
- Repo structure
- [`.gitlab-ci.yml`](../.gitlab-ci.yml)
- runner `runner_01`
- branch/tag rules

### Phần 4 - Live demo branch-to-environment flow (35-45 phút)
- feature branch
- `develop` -> `dev`
- `main` -> `staging`
- tag -> production manual

### Phần 5 - Live demo deployment strategies (20-25 phút)
- rolling update
- blue/green
- so sánh ưu/nhược điểm

### Phần 6 - Q&A + recap (10-15 phút)
- Hỏi lại học viên: khi nào dùng `dev`, `staging`, manual approval
- Nhắc lại khác biệt rolling vs blue/green

## 17. Checklist thao tác trước giờ bắt đầu
- [ ] Repo đã push lên GitLab
- [ ] `main` là default branch
- [ ] Runner `runner_01` đang online
- [ ] Runner được phép chạy cho project này
- [ ] `sh scripts/test.sh` chạy pass local
- [ ] Có quyền tạo branch/tag trên project
- [ ] Mở sẵn tab Pipelines, Jobs, Environments, Runners
- [ ] Đảm bảo branch `develop` tồn tại hoặc sẵn sàng tạo nó live
- [ ] Đảm bảo chưa có tag `v1.0.0` bị dùng trước đó; nếu có, dùng `v1.0.1`

## 18. Troubleshooting nhanh

### Runner không pick up job
Kiểm tra:
- Runner có online không
- Runner có tag `runner_01` không
- Project có cho phép runner đó chạy không

### Pipeline không hiện đúng job deploy
Kiểm tra:
- Bạn đang push đúng branch chưa
- Rule trong [`.gitlab-ci.yml`](../.gitlab-ci.yml) có match branch/tag đó không

### Production job không manual
Kiểm tra:
- Bạn trigger bằng tag `v*` chưa
- Có đang xem pipeline của branch thay vì pipeline của tag không

### Environment chưa hiện ra
Kiểm tra:
- Job deploy đã chạy xong chưa
- Job có block `environment:` đúng không

### Branch `develop` chưa có trên remote
Không sao, bạn có thể tạo live bằng đúng flow ở phần Demo 2:

```bash
git checkout main
git checkout -b develop
git commit --allow-empty -m "test: trigger develop deployment"
git push -u origin develop
```

### Tag `v1.0.0` đã tồn tại
Dùng tag mới hơn:

```bash
git tag v1.0.1
git push origin v1.0.1
```

## 19. Cách kết thúc buổi demo
Có thể chốt như sau:

> Hôm nay chúng ta đã thấy một pipeline có thể phản ứng khác nhau tuỳ branch và tag, map sang các environment khác nhau, đồng thời dùng manual gate để kiểm soát production. Chúng ta cũng đã so sánh rolling update và blue/green để hiểu cách triển khai an toàn hơn khi hệ thống lớn dần.
