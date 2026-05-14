# Session 4 Demo Step-by-Step Guide

## 1. Mục tiêu buổi demo
- Giải thích flow deploy theo môi trường trong GitLab CI/CD.
- Cho học viên thấy pipeline thay đổi theo branch và tag.
- Minh hoạ `dev`, `staging`, `production`, manual approval, rolling update, và blue/green.
- Dùng runner tag `runner_01` để học viên nhìn thấy job được pick up bởi đúng runner.

## 2. Những gì cần chuẩn bị trước khi lên lớp

### 2.1. Repo đã có sẵn
Repo này đã có các thành phần chính:
- `.gitlab-ci.yml`
- `app/index.html`
- `scripts/build.sh`
- `scripts/test.sh`
- `scripts/deploy-dev.sh`
- `scripts/deploy-staging.sh`
- `scripts/deploy-production.sh`
- `scripts/simulate-rolling.sh`
- `scripts/simulate-blue-green.sh`
- `README.md`

### 2.2. GitLab project
Trước buổi demo, đảm bảo bạn đã:
1. Tạo project trên GitLab.
2. Push repo này lên GitLab.
3. Có ít nhất 1 runner khả dụng với tag `runner_01`.
4. Bật quyền tạo environment trong project.

### 2.3. Kiểm tra local trước buổi demo
Chạy local để chắc chắn code demo hoạt động:

```bash
sh scripts/test.sh
```

Expected:
- Script chạy thành công.
- Có tạo ra `dist/`, `preview/`, và các file trong `state/`.
- Không có lỗi missing file/script.

## 3. Các màn hình GitLab cần mở sẵn
Trong lúc trình bày, nên ghim sẵn các màn hình sau trong tab browser:
1. **Build > Pipelines**
2. **Build > Jobs**
3. **Operate > Environments**
4. **Settings > CI/CD > Runners** hoặc trang runner tương đương của project/group
5. Repo source để mở `.gitlab-ci.yml`

## 4. Cách mở đầu buổi demo
Có thể nói ngắn gọn như sau:

> Trong session này, chúng ta không deploy lên hạ tầng thật. Thay vào đó, chúng ta mô phỏng flow CI/CD an toàn bằng static app, state file, và environment artifacts. Mục tiêu là hiểu cách GitLab điều phối pipeline, environment, approval, và deployment strategy.

Sau đó mở [README.md](../README.md) và giải thích nhanh phần:
- Demo Flow
- Runner
- Key Commands
- Teaching Notes

## 5. Giải thích pipeline trước khi chạy
Mở [.gitlab-ci.yml](../.gitlab-ci.yml) và đi qua các ý chính:

### 5.1. Stages
- `build`
- `test`
- `deploy`
- `strategy`

### 5.2. Runner tag
Chỉ vào đoạn:
- `tags: runner_01`

Thông điệp nên nói:
> Mọi job trong demo này đều yêu cầu runner có tag `runner_01`, nên học viên sẽ thấy rõ job được route đúng runner.

### 5.3. Mapping branch/tag sang môi trường
Giải thích:
- `feature/*` chỉ validation
- `develop` deploy `dev`
- `main` deploy `staging`
- tag `v*` mở manual production deploy

## 6. Demo 1 - Feature branch chỉ chạy validation

### 6.1. Chạy lệnh

```bash
git checkout -b feature/session4-validation-demo
git commit --allow-empty -m "test: trigger feature validation pipeline"
git push -u origin feature/session4-validation-demo
```

### 6.2. Trên GitLab UI
Vào **Build > Pipelines** rồi mở pipeline mới nhất.

### 6.3. Điều cần chỉ cho học viên
- Pipeline có job validation.
- Không có deploy sang `dev`, `staging`, hay `production`.
- Rule branch đang chặn deploy ở feature branch.

### 6.4. Câu nói gợi ý
> Đây là lớp bảo vệ đầu tiên. Developer có thể push feature branch liên tục để kiểm tra chất lượng mà không làm ảnh hưởng môi trường chia sẻ.

## 7. Demo 2 - Branch `develop` deploy lên `dev`

### 7.1. Chạy lệnh

```bash
git checkout main
git checkout -b develop
git commit --allow-empty -m "test: trigger develop deployment"
git push -u origin develop
```

### 7.2. Trên GitLab UI
- Mở **Build > Pipelines**.
- Mở pipeline branch `develop`.
- Cho học viên thấy job `deploy_dev` chạy.

### 7.3. Mở trang environment
Vào **Operate > Environments**.

### 7.4. Điều cần chỉ cho học viên
- Environment `dev` xuất hiện.
- Có lịch sử deploy.
- Có thể bấm vào environment để xem artifact/output tương ứng nếu cần.

### 7.5. Câu nói gợi ý
> `dev` là môi trường tích hợp sớm. Chúng ta chấp nhận thay đổi thường xuyên ở đây để team kiểm tra nhanh sau khi merge hoặc push vào nhánh tích hợp.

## 8. Demo 3 - Branch `main` deploy lên `staging`

### 8.1. Chạy lệnh
Nếu đang ở branch khác, quay lại `main` rồi tạo một commit rỗng để trigger pipeline:

```bash
git checkout main
git commit --allow-empty -m "test: trigger staging deployment"
git push origin main
```

### 8.2. Trên GitLab UI
- Mở pipeline mới nhất của `main`.
- Chỉ cho học viên job `deploy_staging`.

### 8.3. Mở environment
Vào **Operate > Environments** và chỉ cho học viên thấy `staging`.

### 8.4. Điều cần nói
> `staging` gần production hơn `dev`. Thường đây là nơi QA, UAT, hoặc business review trước khi release.

### 8.5. Góc nhìn giảng giải
So sánh `develop -> dev` và `main -> staging` để học viên thấy:
- cùng một repo
- cùng pipeline engine
- nhưng khác rule theo branch
- dẫn tới khác môi trường đích

## 9. Demo 4 - Tag release và manual production deployment

### 9.1. Tạo tag

```bash
git checkout main
git tag v1.0.0
git push origin v1.0.0
```

### 9.2. Trên GitLab UI
- Vào **Build > Pipelines**.
- Mở pipeline của tag `v1.0.0`.
- Chỉ cho học viên thấy job `deploy_production` ở trạng thái **manual**.

### 9.3. Trước khi bấm manual job
Dừng lại khoảng 15-30 giây để giải thích:
- Tại sao production không auto deploy.
- Manual approval là điểm kiểm soát rủi ro.
- Một release có thể đã build xong nhưng chưa được phép vào production ngay.

### 9.4. Thực hiện deploy manual
Bấm **Play** cho job `deploy_production`.

### 9.5. Sau khi job chạy xong
Mở **Operate > Environments** và chỉ cho học viên thấy `production`.

### 9.6. Câu nói gợi ý
> Đây là mô hình thường gặp trong doanh nghiệp: build và kiểm thử có thể tự động, nhưng bước vào production vẫn cần approval để đáp ứng kiểm soát thay đổi.

## 10. Demo 5 - Rolling update simulation

### 10.1. Điều kiện chạy
Dùng pipeline của branch `main` vì job strategy đang được bật manual trên `main`.

### 10.2. Trên GitLab UI
- Mở pipeline mới nhất của `main`.
- Bấm manual job `simulate_rolling_update`.

### 10.3. Mở job log
Chỉ cho học viên log dạng:
- `updating instance 1 of 4`
- `health check passed for instance 1`
- ...
- `updating instance 4 of 4`

### 10.4. Thông điệp nên nói
> Rolling update thay từng instance một, giảm downtime và giảm blast radius. Nếu có lỗi, ta thường phát hiện trước khi toàn bộ hệ thống bị ảnh hưởng.

### 10.5. Điểm nhấn giảng dạy
Nhấn mạnh trade-off:
- Ưu điểm: an toàn hơn, ít gián đoạn hơn
- Nhược điểm: rollout chậm hơn, phức tạp hơn kiểu replace toàn bộ

## 11. Demo 6 - Blue/Green simulation

### 11.1. Trên GitLab UI
- Trong pipeline `main`, bấm manual job `simulate_blue_green`.

### 11.2. Mở job log
Chỉ cho học viên các dòng:
- `deployed new version to green`
- `smoke test passed for green`
- `switching active environment: blue -> green`

### 11.3. Điều cần giải thích
> Blue/green nghĩa là ta giữ môi trường hiện tại đang phục vụ traffic và triển khai phiên bản mới ở môi trường song song. Chỉ khi kiểm tra xong mới chuyển traffic sang màu mới.

### 11.4. So sánh với rolling
- Rolling: đổi dần từng instance trong cùng một environment logic
- Blue/green: có hai phiên bản môi trường song song rồi chuyển active color

### 11.5. Cách nói ngắn gọn
> Rolling thì thay dần. Blue/green thì chuẩn bị sẵn môi trường mới rồi flip traffic.

## 12. Cách giải thích file output để học viên dễ hình dung
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

## 13. Thứ tự trình bày đề xuất cho 2 tiếng

### Phần 1 - Bối cảnh và mục tiêu (10-15 phút)
- Môi trường là gì
- Tại sao cần nhiều môi trường
- Vì sao production cần kiểm soát chặt hơn

### Phần 2 - Giải thích repo và pipeline (15-20 phút)
- Repo structure
- `.gitlab-ci.yml`
- runner `runner_01`
- branch/tag rules

### Phần 3 - Live demo branch-to-environment flow (35-45 phút)
- feature branch
- develop -> dev
- main -> staging
- tag -> production manual

### Phần 4 - Live demo deployment strategies (20-25 phút)
- rolling update
- blue/green
- so sánh ưu/nhược điểm

### Phần 5 - Q&A + recap (10-15 phút)
- Hỏi lại học viên: khi nào dùng `dev`, `staging`, manual approval
- Nhắc lại khác biệt rolling vs blue/green

## 14. Checklist thao tác trước giờ bắt đầu
- [ ] Repo đã push lên GitLab
- [ ] Runner `runner_01` đang online
- [ ] `sh scripts/test.sh` chạy pass local
- [ ] Có quyền tạo branch/tag trên project
- [ ] Mở sẵn tab Pipelines, Jobs, Environments, Runners
- [ ] Đảm bảo branch `develop` tồn tại nếu muốn demo nhanh
- [ ] Đảm bảo chưa có tag `v1.0.0` bị dùng trước đó; nếu có, dùng `v1.0.1`

## 15. Troubleshooting nhanh

### Runner không pick up job
Kiểm tra:
- Runner có online không
- Runner có tag `runner_01` không
- Project có cho phép runner đó chạy không

### Pipeline không hiện đúng job deploy
Kiểm tra:
- Bạn đang push đúng branch chưa
- Rule trong [.gitlab-ci.yml](../.gitlab-ci.yml) có match branch/tag đó không

### Production job không manual
Kiểm tra:
- Bạn trigger bằng tag `v*` chưa
- Có đang xem pipeline của branch thay vì pipeline của tag không

### Environment chưa hiện ra
Kiểm tra:
- Job deploy đã chạy xong chưa
- Job có block `environment:` đúng không

## 16. Cách kết thúc buổi demo
Có thể chốt như sau:

> Hôm nay chúng ta đã thấy một pipeline có thể phản ứng khác nhau tuỳ branch và tag, map sang các environment khác nhau, đồng thời dùng manual gate để kiểm soát production. Chúng ta cũng đã so sánh rolling update và blue/green để hiểu cách triển khai an toàn hơn khi hệ thống lớn dần.
