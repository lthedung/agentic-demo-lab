# GitLab CI/CD Session 4 — Speaker Notes Chi Tiết

**Chủ đề:** Environment Management & Deployment Strategies  
**Thời lượng:** 2 tiếng  
**Mục tiêu:** Giúp học viên hiểu cách quản lý môi trường deploy trong GitLab CI/CD và cách chọn chiến lược deployment an toàn cho dự án thực tế.  
**Đối tượng:** Học viên đã biết các khái niệm cơ bản về GitLab CI/CD, đã viết được `.gitlab-ci.yml`, đã chạy được pipeline, test, coverage và SonarQube.

---

## Tổng quan phân bổ thời gian — 120 phút

| Phần | Slide | Thời lượng gợi ý | Mục tiêu |
|---|---:|---:|---|
| Mở đầu & định hướng | 1–3 | 7 phút | Giới thiệu mục tiêu buổi học |
| Environment Management | 4–13 | 58 phút | Hiểu Dev/Staging/Production, GitLab Environments, variables, approval gates |
| Deployment Strategies | 14–19 | 35 phút | Hiểu Rolling Update, Blue/Green và cách chọn strategy |
| Demo / thực hành | 20 | 15 phút | Minh họa pipeline deploy thực tế |
| Kết thúc | 21 | 5 phút | Tổng kết, hỏi đáp, định hướng tiếp theo |

**Nguyên tắc trình bày:**  
Không đọc từng chữ trên slide. Slide là hình minh họa. Người trình bày cần giải thích logic, ví dụ thực tế và rủi ro phía sau từng ý.

---

# Slide 1 — GitLab CI/CD Session 4

## Thời lượng
**2 phút**

## Mục tiêu slide
Mở đầu buổi học, giới thiệu chủ đề Session 4 và chuyển tư duy từ CI sang CD.

## Nội dung nên trình bày

Chào mọi người, hôm nay chúng ta sẽ học **GitLab CI/CD Session 4**.

Ở các session trước, chúng ta đã đi qua các phần nền tảng như:

- GitLab CI/CD là gì
- Cách viết file `.gitlab-ci.yml`
- Cách chạy pipeline
- Cách viết pipeline để test
- Cách đo test coverage
- Cách tích hợp kiểm tra chất lượng code như SonarQube

Đến Session 4, trọng tâm sẽ chuyển từ **CI — Continuous Integration** sang phần gần hơn với **CD — Continuous Delivery / Continuous Deployment**.

Nói đơn giản:

```text
CI trả lời câu hỏi:
Code có build được không?
Code có test pass không?
Code có đạt quality gate không?

CD trả lời câu hỏi:
Code đã đủ an toàn để deploy chưa?
Deploy lên môi trường nào?
Ai được deploy?
Nếu lỗi thì rollback thế nào?
```

Điểm quan trọng của session này là:  
**Deploy không chỉ là chạy một câu lệnh để đưa code lên server. Deploy là một quy trình kiểm soát rủi ro.**

Nếu team deploy thiếu kiểm soát, Production có thể bị lỗi, user thật bị ảnh hưởng, dữ liệu có thể gặp sự cố và team mất rất nhiều thời gian để xử lý incident.

## Câu nói nhấn mạnh
> Một pipeline tốt không chỉ là pipeline chạy xanh. Một pipeline tốt phải giúp team release an toàn, có kiểm soát và có thể khôi phục khi có lỗi.

## Chuyển ý
Sau khi nắm mục tiêu buổi học, chúng ta đi vào agenda để biết session này gồm những phần nào.

---

# Slide 2 — Agenda

## Thời lượng
**3 phút**

## Mục tiêu slide
Cho học viên biết cấu trúc buổi học và các phần chính sẽ đi qua.

## Nội dung nên trình bày

Agenda hôm nay gồm 2 nhóm nội dung chính.

## 1. Environment Management

Phần đầu tiên là **Environment Management**, tức là quản lý các môi trường deploy.

Trong một dự án thật, chúng ta thường không chỉ có một môi trường duy nhất.  
Thông thường sẽ có:

- Development
- Staging
- Production

Mỗi môi trường có mục đích khác nhau, mức độ rủi ro khác nhau và quy tắc deploy khác nhau.

Development dùng để kiểm tra nhanh.  
Staging dùng để kiểm thử trước Production.  
Production là môi trường thật, nơi user thật sử dụng sản phẩm.

## 2. Deployment Strategies

Phần thứ hai là **Deployment Strategies**, tức là chiến lược deploy.

Chúng ta sẽ học:

- Manual deployment
- Automatic deployment
- Rolling update
- Blue/Green deployment

Mỗi strategy có điểm mạnh, điểm yếu và tình huống sử dụng riêng.

Ví dụ:

- Dev thường phù hợp với auto deploy
- Production thường cần manual approval
- Hệ thống nhiều instance có thể dùng rolling update
- Hệ thống cần rollback nhanh có thể dùng Blue/Green

## Câu nói nhấn mạnh
> Học deployment không phải chỉ để biết YAML. Quan trọng hơn là biết khi nào nên deploy, deploy bằng cách nào và kiểm soát rủi ro ra sao.

## Chuyển ý
Trước khi học strategy, chúng ta cần hiểu tại sao Environment Management lại quan trọng.

---

# Slide 3 — Environment Management

## Thời lượng
**2 phút**

## Mục tiêu slide
Mở đầu phần Environment Management.

## Nội dung nên trình bày

Phần đầu tiên của session là **Environment Management**.

Trong dự án thực tế, phần mềm không đi thẳng từ máy developer lên Production.  
Nếu làm như vậy, rủi ro rất cao.

Thay vào đó, hệ thống thường được chia thành nhiều môi trường.

Ví dụ:

```text
Developer code
→ Development
→ Staging
→ Production
```

Mỗi môi trường giống như một lớp kiểm tra.

Development giúp phát hiện lỗi sớm.  
Staging giúp kiểm thử gần giống Production.  
Production là nơi chạy thật cho user thật.

Environment Management giúp team trả lời các câu hỏi:

- Code đang chạy ở môi trường nào?
- Version nào đang ở Dev?
- Version nào đang ở Staging?
- Version nào đang ở Production?
- Ai đã deploy?
- Deploy lúc nào?
- Nếu lỗi thì rollback version nào?

## Câu nói nhấn mạnh
> Environment Management là nền móng của deployment an toàn.

## Chuyển ý
Bây giờ ta đi vào lý do cụ thể: vì sao Environment Management lại quan trọng?

---

# Slide 4 — Why Environment Management Matters

## Thời lượng
**7 phút**

## Mục tiêu slide
Giải thích rủi ro khi chỉ dùng một môi trường hoặc deploy trực tiếp lên Production.

## Nội dung nên trình bày

Slide này trả lời câu hỏi:

> Tại sao không nên deploy trực tiếp từ developer lên Production?

Trong dự án thật, nếu chỉ dùng một môi trường hoặc deploy thẳng lên Production, rủi ro rất lớn.

## 1. Code chưa được test đầy đủ

Một đoạn code có thể chạy trên máy developer nhưng lỗi trên server.

Lý do thường gặp:

- Thiếu environment variables
- Dependency khác version
- Database schema khác
- Config khác local
- API endpoint khác
- Permission khác
- Network hoặc firewall khác

Ví dụ:  
Developer test login ở local thấy ổn. Nhưng khi lên Production, OAuth callback URL sai nên user không đăng nhập được.

## 2. Bug ảnh hưởng trực tiếp user thật

Nếu deploy thẳng Production, lỗi không còn nằm trong môi trường test nữa. User thật sẽ gặp ngay.

Ví dụ:

```text
Developer sửa chức năng thanh toán
→ Deploy thẳng Production
→ Bug tính sai tiền
→ User bị tính sai đơn hàng
→ Team phải hotfix khẩn cấp
```

Lỗi này ảnh hưởng trực tiếp đến doanh thu, trải nghiệm người dùng và uy tín sản phẩm.

## 3. Dữ liệu Production có thể bị ảnh hưởng

Production dùng dữ liệu thật.

Nếu một migration sai hoặc logic xử lý dữ liệu bị lỗi, hậu quả có thể nặng hơn lỗi giao diện.

Có thể xảy ra:

- Dữ liệu bị mất
- Dữ liệu bị ghi đè
- Dữ liệu bị sai logic
- Không thể rollback dễ dàng
- Báo cáo kinh doanh bị sai
- User mất niềm tin

## 4. Khó kiểm soát ai deploy và deploy lúc nào

Nếu không có GitLab Environments hoặc deployment history rõ ràng, khi có sự cố team sẽ phải hỏi:

```text
Ai vừa deploy?
Deploy commit nào?
Deploy branch nào?
Deploy lúc mấy giờ?
Có release note không?
Có rollback version không?
```

Trong incident thật, việc mất thời gian truy tìm thông tin sẽ làm sự cố kéo dài hơn.

## 5. Rollback khó

Rollback không chỉ là “quay lại code cũ”.

Rollback còn liên quan đến:

- Image version
- Database migration
- Config
- Cache
- Environment variables
- Third-party integration

Nếu team không biết version nào đang chạy, rollback sẽ rất rối.

## Ví dụ dễ hiểu

Cách làm rủi ro:

```text
Developer → Production
```

Cách làm an toàn hơn:

```text
Developer → Dev → Staging → Production
```

## Câu hỏi tương tác
Bạn có thể hỏi học viên:

1. Nếu Production bị lỗi sau deploy, thông tin đầu tiên bạn muốn biết là gì?
2. Theo bạn, môi trường nào nên được deploy tự động?
3. Môi trường nào nên cần người duyệt?

## Key takeaway
> Environment Management giúp team kiểm soát rủi ro release trước khi rủi ro đó chạm tới user thật.

## Chuyển ý
Sau khi biết vì sao cần Environment Management, chúng ta sẽ tìm hiểu các environment phổ biến trong phần mềm.

---

# Slide 5 — Common Software Environments

## Thời lượng
**8 phút**

## Mục tiêu slide
Giải thích rõ Development, Staging và Production.

## Nội dung nên trình bày

Một hệ thống phần mềm thực tế thường có nhiều môi trường để tách biệt quá trình phát triển, kiểm thử và vận hành thật.

Ba môi trường phổ biến nhất là:

```text
Development
Staging
Production
```

## 1. Development Environment

Development là môi trường dành cho developer kiểm tra nhanh các thay đổi mới.

Môi trường này thường gắn với branch `develop`.

Khi code được push hoặc merge vào `develop`, pipeline có thể tự động deploy lên Dev.

## Mục đích của Development

Development dùng để:

- Kiểm tra tính năng mới sau khi code được push hoặc merge
- Phát hiện lỗi sớm trong quá trình phát triển
- Kiểm tra tích hợp giữa các module hoặc service
- Cho phép developer review nhanh phiên bản mới
- Giúp feedback loop ngắn hơn

Ví dụ:  
Developer làm tính năng `Google Login`. Sau khi merge vào `develop`, hệ thống tự deploy lên `dev.example.com` để team kiểm tra nhanh.

## Đặc điểm của Development

Development thường:

- Thay đổi thường xuyên
- Có thể không ổn định 100%
- Dùng dữ liệu giả hoặc dữ liệu test
- Có thể deploy tự động từ `develop`
- Không phục vụ user thật

Điểm cần nhấn mạnh:  
Development không cần quá nhiều thủ tục approval, vì mục tiêu của nó là tốc độ feedback.

## 2. Staging Environment

Staging là môi trường kiểm thử trước Production.

Staging nên giống Production càng nhiều càng tốt.

Giống ở đây bao gồm:

- Cấu hình hệ thống
- Database schema
- Service dependency
- Biến môi trường
- Cách deploy
- Logging
- Monitoring
- API endpoint gần giống Production

## Mục đích của Staging

Staging dùng để:

- QA testing
- UAT testing
- Regression testing
- Smoke testing trước release
- Demo cho Product Owner, BA, client hoặc stakeholder
- Kiểm tra cấu hình gần giống Production

Ví dụ:  
Sau khi code ổn ở Dev, team merge vào `main`, pipeline deploy lên `staging.example.com`. QA kiểm thử trên Staging trước khi release thật.

## Đặc điểm của Staging

Staging thường:

- Ổn định hơn Development
- Không nên thay đổi tùy tiện
- Cấu hình nên gần giống Production
- Có thể dùng dữ liệu giả lập hoặc dữ liệu đã ẩn thông tin nhạy cảm
- Là bước kiểm tra cuối trước Production

Điểm cần nhấn mạnh:  
Nếu Staging quá khác Production, việc test trên Staging sẽ không còn nhiều ý nghĩa.

## 3. Production Environment

Production là môi trường thật, nơi người dùng cuối sử dụng hệ thống.

Đây là môi trường có rủi ro cao nhất.

## Mục đích của Production

Production dùng để:

- Phục vụ user thật
- Chạy version chính thức của sản phẩm
- Xử lý dữ liệu thật
- Đảm bảo ổn định, bảo mật và hiệu năng

## Đặc điểm của Production

Production cần:

- Kiểm soát quyền deploy
- Manual approval trước khi deploy
- Logging
- Monitoring
- Alerting
- Rollback plan
- Deployment history rõ ràng

Ví dụ:

```text
release tag v1.2.0
→ manual deploy
→ app.example.com
```

## Key takeaway
> Mỗi environment có mục đích, mức rủi ro và quy tắc release riêng.

## Chuyển ý
Tiếp theo, chúng ta sẽ học cách code đi từ environment này sang environment khác thông qua promotion flow và release gates.

---

# Slide 6 — Environment Promotion Flow & Release Gates

## Thời lượng
**9 phút**

## Mục tiêu slide
Giải thích cách code được promote qua các môi trường và vì sao cần release gates.

## Nội dung nên trình bày

Slide này nói về một khái niệm rất quan trọng: **Environment Promotion**.

Environment Promotion là quá trình đưa một version phần mềm đi qua nhiều môi trường theo thứ tự kiểm soát.

Flow phổ biến:

```text
Feature Branch
→ Development
→ Staging
→ Production
```

Code không nên nhảy thẳng lên Production.  
Mỗi bước phải có điều kiện kiểm tra.

## Promotion là gì?

Promotion không chỉ là deploy sang môi trường tiếp theo.

Promotion là quyết định rằng:

> Version này đã đủ điều kiện để đi sang môi trường có rủi ro cao hơn.

Mỗi bước trả lời một câu hỏi khác nhau:

| Bước | Câu hỏi cần trả lời |
|---|---|
| Feature Branch → Development | Code mới có chạy được không? |
| Development → Staging | Code đã đủ ổn để QA/UAT kiểm thử chưa? |
| Staging → Production | Version này đã đủ an toàn cho user thật chưa? |

## Gate 1 — Before Development

Trước khi deploy lên Development, cần các check cơ bản.

Nên có:

- Build passed
- Unit tests passed
- Code review completed
- No critical dependency errors
- Merge request validated

Mục tiêu của Gate 1 là tránh đưa code hỏng hoàn toàn vào môi trường Dev dùng chung.

Ví dụ lỗi bị chặn ở Gate 1:

- Build fail
- Test fail
- Dependency thiếu
- Syntax error
- Code chưa review

## Gate 2 — Before Staging

Trước khi deploy lên Staging, version cần ổn định hơn.

Nên có:

- Dev deployment is stable
- Automated tests passed
- No blocker bugs
- Merge to `main` or release branch
- Ready for QA/internal review

Mục tiêu của Gate 2 là đảm bảo Staging không biến thành môi trường Dev thứ hai.

Nếu Dev còn lỗi blocker mà đã deploy lên Staging, QA sẽ mất thời gian test một bản chưa đủ ổn định.

## Gate 3 — Before Production

Trước khi deploy Production, yêu cầu cần chặt hơn.

Nên có:

- QA/UAT approved
- Smoke test passed
- Release tag created
- Manual approval confirmed
- Rollback plan ready
- Monitoring ready

Đây là gate quan trọng nhất vì Production phục vụ user thật.

## Ví dụ thực tế

Tính năng: Google Login

Flow:

```text
feature/google-login
→ develop
→ dev.example.com
→ main
→ staging.example.com
→ tag v1.2.0
→ manual deploy
→ app.example.com
```

Ở mỗi bước, version phải pass gate trước khi đi tiếp.

## Câu hỏi tương tác

- Theo bạn, Gate nào quan trọng nhất trước Production?
- Nếu bỏ qua Staging, rủi ro gì có thể xảy ra?
- Manual approval có nên áp dụng cho Dev không?

## Key takeaway
> Một release flow tốt kiểm soát khi nào code được đi tiếp, đi đến đâu và dưới điều kiện nào.

## Chuyển ý
Tiếp theo, chúng ta sẽ xem GitLab CI/CD dùng branch và tag để điều hướng code đến từng environment như thế nào.

---

# Slide 7 — Environment Flow in CI/CD

## Thời lượng
**7 phút**

## Mục tiêu slide
Giải thích mapping giữa branch/tag và environment trong CI/CD.

## Nội dung nên trình bày

Trong GitLab CI/CD, environment thường được điều khiển bằng branch hoặc tag.

Một mapping phổ biến là:

```text
feature/*  → test only
develop    → deploy to Dev
main       → deploy to Staging
tag v*     → deploy to Production
```

Ý tưởng chính là:  
**Không phải commit nào cũng được đi thẳng lên Production.**

## Flow 1 — Feature branch

Feature branch thường dùng để phát triển một tính năng hoặc sửa một lỗi cụ thể.

Ví dụ:

```text
feature/google-login
feature/payment-fix
bugfix/profile-avatar
```

Khi push feature branch, pipeline thường chạy:

```text
Push feature branch
→ Build
→ Test
→ No deployment
```

Không deploy vì code ở feature branch chưa chắc đã đủ ổn.

Feature branch dùng cho:

- Merge request validation
- Unit test
- Lint
- Build check
- Code quality analysis

## Flow 2 — Develop branch

Khi feature được review và merge vào `develop`, pipeline có thể deploy lên Dev.

Flow:

```text
Merge to develop
→ Build
→ Test
→ Deploy Dev
```

Develop branch dùng cho:

- Internal testing
- Developer review
- Early integration check
- Shared Dev environment
- Catch issues early

Mục tiêu là cho team thấy version mới hoạt động thế nào trong môi trường Dev.

## Flow 3 — Main branch

Khi code đủ ổn, team merge vào `main`.

Flow:

```text
Merge to main
→ Build
→ Test
→ Deploy Staging
```

Main branch thường đại diện cho bản ổn định hơn.

Main branch dùng cho:

- QA testing
- UAT testing
- Regression testing
- Pre-release validation
- Stakeholder/client demo

## Flow 4 — Release tag

Khi team muốn release chính thức, tạo tag.

Ví dụ:

```text
v1.2.0
v1.2.1
v2.0.0
```

Flow:

```text
Create tag v1.2.0
→ Build
→ Test
→ Manual Deploy Production
```

Tag dùng cho:

- Official release
- Controlled production deploy
- Stable version delivery
- Rollback reference
- Audit and traceability

## Vì sao tag quan trọng?

Tag giúp team biết version Production là version nào.

Nếu có lỗi, team có thể nói rõ:

```text
Production hiện đang chạy v1.2.0.
Rollback về v1.1.9 nếu cần.
```

## Key takeaway
> Branch và tag rules định nghĩa đường đi của release.

## Chuyển ý
Sau khi biết branch/tag điều khiển flow, chúng ta cần biết GitLab hiển thị và tracking các environment này như thế nào.

---

# Slide 8 — GitLab Environments Overview

## Thời lượng
**7 phút**

## Mục tiêu slide
Giải thích GitLab Environments và giá trị tracking deployment trong GitLab UI.

## Nội dung nên trình bày

GitLab Environments giúp team theo dõi ứng dụng đang được deploy ở đâu và ai đã deploy.

Nếu một job không khai báo `environment`, GitLab chỉ biết job đó đã chạy.

Nhưng nếu job có khai báo `environment`, GitLab hiểu đây là một deployment đến một môi trường cụ thể.

## GitLab có thể hiển thị gì?

GitLab Environments có thể cho biết:

- Environment name
- Environment URL
- Latest deployment
- Deployment history
- Deployed commit
- Person who triggered deploy
- Deployment time
- Deployment status

Thông tin này cực kỳ quan trọng khi có sự cố.

Ví dụ khi Production bị lỗi, team có thể kiểm tra:

```text
Commit nào vừa được deploy?
Ai deploy?
Deploy lúc nào?
Job deploy có pass không?
URL environment là gì?
```

## Ví dụ `.gitlab-ci.yml`

```yaml
deploy_dev:
  stage: deploy
  script:
    - echo "Deploying to Dev"
  environment:
    name: dev
    url: https://dev.example.com
```

Trong ví dụ này:

- `name: dev` giúp GitLab tạo hoặc cập nhật environment tên `dev`
- `url` giúp GitLab hiển thị link truy cập nhanh đến environment đó
- Job này được GitLab xem là một deployment job

## Common environments

Các environment thường gặp:

```text
dev
staging
production
review/feature-login
review/feature-payment
```

## Review Apps

Review Apps là temporary environments cho feature branch hoặc merge request.

Ví dụ:

```text
review/feature-login
```

Review Apps hữu ích vì:

- Reviewer có thể xem tính năng trực tiếp
- Không ảnh hưởng Dev/Staging chung
- Mỗi feature có môi trường riêng
- Có thể xóa sau khi merge request đóng

## Ví dụ thực tế

Developer tạo MR cho tính năng `feature-payment`.

GitLab có thể tạo review app:

```text
review/feature-payment
```

Reviewer mở URL và kiểm tra tính năng trước khi merge.

## Key takeaway
> GitLab Environments làm cho deployment trở nên nhìn thấy được, truy vết được và dễ quản lý hơn.

## Chuyển ý
Tiếp theo, chúng ta sẽ học cú pháp khai báo environment trong `.gitlab-ci.yml`.

---

# Slide 9 — Environments in `.gitlab-ci.yml`

## Thời lượng
**8 phút**

## Mục tiêu slide
Giải thích cách định nghĩa environment trong `.gitlab-ci.yml`.

## Nội dung nên trình bày

Để GitLab tracking deployment, job deploy cần có block `environment`.

## Basic syntax

Ví dụ:

```yaml
deploy_staging:
  stage: deploy
  script:
    - echo "Deploy to Staging server"
  environment:
    name: staging
    url: https://staging.example.com
```

Đây là cấu trúc cơ bản của một deploy job có environment.

## Giải thích từng field

## `stage: deploy`

```yaml
stage: deploy
```

Field này cho biết job thuộc stage deploy.

Trong pipeline, chúng ta có thể có nhiều stage:

```yaml
stages:
  - build
  - test
  - deploy
```

Job deploy nên nằm trong stage `deploy`.

## `script`

```yaml
script:
  - echo "Deploy to Staging server"
```

`script` là nơi đặt các command deploy thật.

Trong ví dụ đơn giản, ta chỉ dùng `echo`.

Nhưng trong thực tế, script có thể là:

```text
ssh into server
docker compose up -d
kubectl apply
helm upgrade
cloud CLI deploy
```

## `environment.name`

```yaml
environment:
  name: staging
```

Đây là tên environment trong GitLab.

Nên dùng tên rõ ràng:

```text
dev
staging
production
```

Không nên dùng tên mơ hồ như:

```text
server1
test2
new-env
```

Vì sau này team khó hiểu và khó audit.

## `environment.url`

```yaml
url: https://staging.example.com
```

URL giúp team mở nhanh environment từ GitLab UI.

Nếu không có URL, GitLab vẫn tracking environment, nhưng team mất tiện ích truy cập nhanh.

## Environment name examples

Một số tên chuẩn nên dùng:

```text
dev
staging
production
```

Với review app có thể dùng:

```text
review/feature-login
review/feature-payment
```

## Deploy script examples

Tùy hạ tầng, script deploy có thể là:

```text
ssh into server
docker compose up -d
kubectl apply
helm upgrade
cloud CLI deploy
```

Ví dụ server truyền thống:

```yaml
script:
  - ssh user@server "cd app && docker compose up -d"
```

Ví dụ Kubernetes:

```yaml
script:
  - kubectl apply -f k8s/
```

## Best practices

Nên:

- Dùng tên environment rõ ràng
- Thêm URL cho mỗi environment
- Tách riêng job Production
- Không mix nhiều environment trong một job
- Dùng manual approval cho Production

Không nên:

```text
Một job deploy nhưng lúc thì deploy Dev, lúc thì deploy Production tùy biến quá nhiều.
```

Vì như vậy pipeline khó đọc, khó debug và dễ deploy nhầm.

## Key takeaway
> Một deployment job tốt phải nói rõ nó deploy cái gì và deploy đến đâu.

## Chuyển ý
Bây giờ ta sẽ xem một pipeline nhiều environment hoàn chỉnh.

---

# Slide 10 — Pipeline for Multiple Environments

## Thời lượng
**9 phút**

## Mục tiêu slide
Minh họa một pipeline có build, test và deploy nhiều environment.

## Nội dung nên trình bày

Slide này cho thấy một pipeline đầy đủ hơn.

Pipeline structure:

```text
Build
→ Test
→ Deploy Dev
→ Deploy Staging
→ Deploy Production
```

Điểm quan trọng:  
Tất cả đều nằm trong cùng pipeline, nhưng mỗi deploy job có rule riêng.

## Cấu trúc pipeline

Thông thường pipeline có các stage:

```yaml
stages:
  - build
  - test
  - deploy
```

Trong đó:

- `build` tạo artifact hoặc image
- `test` kiểm tra chất lượng code
- `deploy` đưa app lên environment

## Deploy Dev

Job `deploy_dev` thường chạy khi branch là `develop`.

```yaml
deploy_dev:
  stage: deploy
  script:
    - echo "Deploying to Dev"
  environment:
    name: dev
    url: https://dev.example.com
  only:
    - develop
```

Ý nghĩa:

```text
Push hoặc merge vào develop
→ deploy lên Dev
```

## Deploy Staging

Job `deploy_staging` thường chạy khi branch là `main`.

```yaml
deploy_staging:
  stage: deploy
  script:
    - echo "Deploying to Staging"
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - main
```

Ý nghĩa:

```text
Merge vào main
→ deploy lên Staging
```

## Deploy Production

Job `deploy_production` nên dùng tag và manual approval.

```yaml
deploy_production:
  stage: deploy
  script:
    - echo "Deploying to Production"
  environment:
    name: production
    url: https://app.example.com
  when: manual
  only:
    - tags
```

Ý nghĩa:

```text
Create tag v1.2.0
→ hiện manual Production job
→ người có quyền bấm deploy
```

## How it works

| Trigger | Result |
|---|---|
| Push to `develop` | Deploy Dev |
| Merge to `main` | Deploy Staging |
| Create tag `v1.2.0` | Manual Production job |

## Điểm cần nhấn mạnh

Đừng để mọi branch đều deploy Production.

Một pattern kém an toàn:

```text
Push to main → auto deploy Production
```

Pattern này chỉ phù hợp khi team rất trưởng thành, có test tốt, rollback tốt, monitoring tốt và production risk thấp.

## Key takeaway
> Mỗi environment nên có deployment rule riêng.

## Chuyển ý
Tiếp theo, ta sẽ nói về cấu hình và secrets — phần rất dễ gây lỗi bảo mật nếu làm sai.

---

# Slide 11 — Environment Variables and Secrets

## Thời lượng
**9 phút**

## Mục tiêu slide
Giải thích biến môi trường và cách bảo vệ secrets trong GitLab CI/CD.

## Nội dung nên trình bày

Mỗi environment thường cần cấu hình khác nhau.

Ví dụ:

| Environment | DB_HOST |
|---|---|
| Dev | `dev-db.example.com` |
| Staging | `staging-db.example.com` |
| Production | `prod-db.example.com` |

Cùng một app, nhưng không thể dùng chung toàn bộ config.

## Vì sao mỗi environment cần config riêng?

Vì mỗi environment có thể dùng:

- Database khác
- API URL khác
- Redis/cache khác
- Storage bucket khác
- OAuth callback URL khác
- Payment sandbox hoặc payment live khác
- Logging level khác
- Secret key khác

Ví dụ:

```text
Dev dùng payment sandbox.
Production dùng payment live.
```

Nếu dùng nhầm config Production trong Dev, có thể tạo giao dịch thật trong lúc test. Đây là lỗi rất nguy hiểm.

## Common variables

Các biến thường gặp:

```text
DB_HOST
DB_USERNAME
DB_PASSWORD
API_KEY
SSH_PRIVATE_KEY
DOCKER_REGISTRY_USER
DOCKER_REGISTRY_PASSWORD
KUBE_CONFIG
JWT_SECRET
```

Một số biến là config bình thường.  
Một số biến là secret nhạy cảm.

Ví dụ secret:

```text
DB_PASSWORD
API_KEY
SSH_PRIVATE_KEY
JWT_SECRET
KUBE_CONFIG
```

## Không hard-code secrets

Không nên commit các file sau vào Git:

```text
.env
private_key.pem
credentials.json
production-secret.yml
```

Vì Git lưu lịch sử.  
Nếu secret đã commit, dù xóa ở commit sau, secret vẫn có thể tồn tại trong Git history.

## Rủi ro ví dụ

```text
Production password committed to Git
→ Secret exposed in Git history
→ Security incident
→ Rotation required
```

Khi secret bị lộ, team phải:

- Rotate secret
- Thu hồi key cũ
- Kiểm tra access log
- Đánh giá mức độ rò rỉ
- Update CI/CD variables
- Có thể phải báo cáo incident

## Best practices

Nên dùng **GitLab CI/CD Variables**.

Best practices:

- Use GitLab CI/CD Variables
- Mask sensitive variables
- Protect production variables
- Scope variables by environment
- Do not echo secrets in logs
- Rotate secrets if leaked

## Mask variables

Masked variable giúp tránh secret bị in ra log.

Không nên làm:

```yaml
script:
  - echo $DB_PASSWORD
```

## Protected variables

Production variables nên được protect để chỉ protected branches hoặc protected tags mới dùng được.

Ví dụ:

```text
Production secret chỉ dùng khi deploy từ tag v*
```

## Environment-scoped variables

Nếu GitLab setup hỗ trợ, có thể scope variables theo environment:

```text
DB_HOST cho Dev
DB_HOST cho Staging
DB_HOST cho Production
```

Điều này giúp giảm nguy cơ dùng nhầm config.

## Key takeaway
> Secrets không thuộc về source code. Secrets phải được bảo vệ, che log, phân quyền và quản lý theo môi trường.

## Chuyển ý
Sau khi hiểu environment và secrets, chúng ta chuyển sang câu hỏi quan trọng: deploy tự động hay deploy thủ công?

---

# Slide 12 — Manual vs Automatic Deployment

## Thời lượng
**8 phút**

## Mục tiêu slide
So sánh manual deployment và automatic deployment.

## Nội dung nên trình bày

Deployment có thể là automatic hoặc manual.

Không có lựa chọn đúng cho mọi trường hợp.  
Lựa chọn phụ thuộc vào rủi ro của environment.

## Automatic Deployment

Automatic deployment nghĩa là job tự chạy khi pipeline đến stage deploy.

Ví dụ:

```yaml
deploy_dev:
  stage: deploy
  script:
    - echo "Auto deploy to Dev"
  environment:
    name: dev
  only:
    - develop
```

Trong ví dụ này, khi code merge vào `develop`, job deploy Dev tự chạy.

## Automatic phù hợp với

- Development
- Internal testing
- Feature preview
- Low-risk services
- Môi trường cần feedback nhanh

## Ưu điểm của Automatic

- Feedback nhanh
- Ít thao tác thủ công
- Giảm tình trạng quên deploy
- Tăng tốc development cycle
- Developer thấy kết quả sớm

## Nhược điểm của Automatic

- Code lỗi có thể được deploy nhanh
- Nếu rule yếu, có thể deploy nhầm
- Không lý tưởng cho Production nhạy cảm
- Cần automated test đủ tốt

## Manual Deployment

Manual deployment nghĩa là job chờ người dùng bấm nút deploy.

Ví dụ:

```yaml
deploy_production:
  stage: deploy
  script:
    - echo "Manual deploy to Production"
  environment:
    name: production
  when: manual
```

`when: manual` làm cho job không chạy tự động.

## Manual phù hợp với

- Production
- Major releases
- High-risk systems
- Approval-based workflow
- Hệ thống có dữ liệu nhạy cảm
- Release cần chọn thời điểm

## Ưu điểm của Manual

- Kiểm soát tốt hơn
- Có release ownership rõ ràng
- Giảm deploy nhầm
- Phù hợp với approval process

## Nhược điểm của Manual

- Chậm hơn automatic
- Cần người có quyền bấm deploy
- Có thể tạo bottleneck
- Nếu phụ thuộc một người, release có thể bị chậm

## Decision rule

```text
Low risk → automatic
High risk → manual
```

Ví dụ:

```text
Dev → automatic
Staging → automatic hoặc manual tùy team
Production → manual
```

## Câu hỏi tương tác

- Có nên auto deploy Production không?
- Trường hợp nào Production có thể auto deploy?
- Nếu manual quá nhiều thì vấn đề gì xảy ra?

## Key takeaway
> Automatic tối ưu tốc độ. Manual tối ưu kiểm soát.

## Chuyển ý
Với Production, manual thôi chưa đủ. Ta cần hiểu thêm deployment gates và approval flow.

---

# Slide 13 — Deployment Gates and Approval Flow

## Thời lượng
**8 phút**

## Mục tiêu slide
Giải thích approval flow trước Production.

## Nội dung nên trình bày

Production deployment nên đi qua các gate rõ ràng trước khi release.

Một approval flow phổ biến:

```text
Merge to main
→ Build
→ Unit Test
→ Security Scan
→ Deploy to Staging
→ QA Testing
→ UAT Approval
→ Manual Deploy to Production
→ Post-deploy Monitoring
```

## Vì sao cần approval gates?

Trước Production, team cần xác nhận:

- Build passed
- Tests passed
- Security scan passed
- Staging is stable
- QA approved
- UAT approved
- Release note ready
- Rollback version known
- Monitoring dashboard ready
- Deployment owner confirmed

## Giải thích từng bước

## Merge to main

Code đã qua review và được merge vào branch ổn định.

## Build

Ứng dụng được build từ source code.  
Nếu build fail, không nên đi tiếp.

## Unit Test

Kiểm tra logic ở mức nhỏ.  
Nếu test fail, không deploy.

## Security Scan

Kiểm tra vulnerability hoặc dependency có rủi ro.  
Đặc biệt quan trọng với Production.

## Deploy to Staging

Đưa version lên Staging để kiểm thử gần giống Production.

## QA Testing

QA kiểm thử chức năng và regression.

## UAT Approval

Business user, PO hoặc stakeholder xác nhận nghiệp vụ đúng.

## Manual Deploy to Production

Người có quyền bấm deploy Production.

## Post-deploy Monitoring

Sau deploy, phải theo dõi hệ thống.

Theo dõi:

- Error rate
- Logs
- Metrics
- Latency
- User complaints
- Business metrics

## GitLab control options

GitLab hỗ trợ các cơ chế kiểm soát như:

```text
when: manual
protected branches
protected tags
protected environments
required approvals
role-based permissions
```

## Example

```yaml
deploy_production:
  stage: deploy
  script:
    - echo "Deploying production"
  environment:
    name: production
  when: manual
  only:
    - main
```

## Điểm cần nhấn mạnh

Production deployment không nên là side effect của việc push code.

Nó phải là một hành động có chủ đích.

## Key takeaway
> Production deployment nên có chủ đích, được duyệt và có thể truy vết.

## Chuyển ý
Sau phần Environment Management, chúng ta chuyển sang phần Deployment Strategies.

---

# Slide 14 — Deployment Strategies

## Thời lượng
**2 phút**

## Mục tiêu slide
Mở đầu phần Deployment Strategies.

## Nội dung nên trình bày

Chúng ta đã biết cách quản lý môi trường và approval flow.

Bây giờ ta chuyển sang câu hỏi tiếp theo:

> Khi deploy một version mới, chúng ta nên deploy bằng chiến lược nào?

Có nhiều cách deploy:

- Manual deployment
- Automatic deployment
- Rolling update
- Blue/Green deployment

Trong phần tiếp theo, chúng ta tập trung vào hai strategy rất quan trọng:

1. Rolling Update
2. Blue/Green Deployment

Hai strategy này giúp giảm downtime và giảm rủi ro production.

## Chuyển ý
Đầu tiên, chúng ta sẽ học Rolling Update Strategy.

---

# Slide 15 — Rolling Update Strategy

## Thời lượng
**9 phút**

## Mục tiêu slide
Giải thích Rolling Update ở mức concept và risk.

## Nội dung nên trình bày

Rolling update là chiến lược deploy version mới từ từ, từng instance một.

Thay vì cập nhật toàn bộ hệ thống cùng lúc, rolling update cập nhật theo từng phần.

## Ví dụ setup

Giả sử hệ thống có 4 instance:

```text
app-1: version 1
app-2: version 1
app-3: version 1
app-4: version 1
```

Tất cả instance đang nhận traffic thông qua load balancer.

## Rolling update flow

Khi deploy version 2:

```text
1. Remove app-1 from traffic
2. Update app-1 to version 2
3. Check app-1 health
4. Add app-1 back to traffic
5. Repeat for app-2, app-3, app-4
```

Trong lúc update app-1, các app còn lại vẫn phục vụ user.

## During deployment

Có thể có trạng thái:

```text
app-1: version 2
app-2: version 1
app-3: version 1
app-4: version 1
```

Nghĩa là trong một khoảng thời gian, hệ thống chạy song song version cũ và version mới.

## Ưu điểm

Rolling update có các lợi ích:

- Giảm downtime
- Không dừng toàn bộ hệ thống
- An toàn hơn deploy all-at-once
- Phù hợp với hệ thống nhiều instance

## Nhược điểm

Rolling update cũng có rủi ro:

- Version cũ và mới có thể chạy cùng lúc
- App cần backward compatibility
- Database migration phải xử lý cẩn thận
- Cần health check tốt

## Database migration warning

Ví dụ rủi ro:

```text
App v2 cần column mới
Migration thay đổi schema
App v1 vẫn đang chạy
App v1 không hiểu schema mới
→ lỗi runtime
```

Vì vậy, migration nên tương thích ngược nếu dùng rolling update.

## Common platforms

Rolling update thường dùng với:

- Kubernetes
- Docker Swarm
- Auto Scaling Group
- Load balancer + multiple servers

## Key takeaway
> Rolling update giảm downtime, nhưng app phải chịu được mixed-version traffic.

## Chuyển ý
Tiếp theo, chúng ta sẽ xem cách GitLab CI/CD trigger Rolling Update trong thực tế, đặc biệt với Kubernetes.

---

# Slide 16 — Rolling Update Example in CI/CD

## Thời lượng
**8 phút**

## Mục tiêu slide
Giải thích ví dụ Rolling Update bằng GitLab CI/CD và Kubernetes.

## Nội dung nên trình bày

Ý chính của slide này:

```text
GitLab triggers the deployment.
Infrastructure performs the rolling update.
```

GitLab không tự làm toàn bộ rolling update.  
GitLab chạy command để gọi hạ tầng bên dưới, ví dụ Kubernetes.

## Example with Kubernetes

```yaml
deploy_production:
  stage: deploy
  script:
    - kubectl set image deployment/my-app my-app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - kubectl rollout status deployment/my-app
  environment:
    name: production
    url: https://example.com
  when: manual
  only:
    - main
```

## Giải thích command

## `kubectl set image`

Command này cập nhật image mới cho Kubernetes Deployment.

Ví dụ:

```text
my-app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
```

Nghĩa là Kubernetes sẽ dùng image được build từ commit hiện tại.

## `$CI_COMMIT_SHA`

Đây là biến có sẵn của GitLab.

Nó đại diện cho commit hiện tại.

Dùng `$CI_COMMIT_SHA` giúp image version rõ ràng và traceable.

## `kubectl rollout status`

Command này chờ rollout hoàn tất.

Nếu rollout thành công, job pass.  
Nếu rollout lỗi hoặc timeout, job fail.

## Rollback

Rollback có thể dùng:

```bash
kubectl rollout undo deployment/my-app
```

Command này yêu cầu Kubernetes quay lại revision trước đó.

## Required controls

Để rolling update an toàn, cần:

- Health check
- Readiness probe
- Liveness probe
- Compatible database migration
- Timeout control
- Logs and monitoring

## Readiness probe

Readiness probe trả lời câu hỏi:

```text
Pod này đã sẵn sàng nhận traffic chưa?
```

Nếu chưa ready, Kubernetes không nên route traffic đến pod đó.

## Liveness probe

Liveness probe trả lời câu hỏi:

```text
Pod này còn sống không?
```

Nếu app bị treo, Kubernetes có thể restart pod.

## Monitor after rollout

Sau rollout cần theo dõi:

- Error rate
- Latency
- CPU/memory
- 5xx response
- Business metrics
- User complaints

## Key takeaway
> GitLab bắt đầu release, nhưng Kubernetes kiểm soát hành vi rolling update.

## Chuyển ý
Rolling update phù hợp với nhiều hệ thống, nhưng nếu cần rollback nhanh hơn, ta có thể dùng Blue/Green Deployment.

---

# Slide 17 — Blue/Green Deployment Strategy

## Thời lượng
**9 phút**

## Mục tiêu slide
Giải thích Blue/Green Deployment.

## Nội dung nên trình bày

Blue/Green deployment sử dụng hai môi trường gần giống Production.

```text
Blue = current live environment
Green = new version environment
```

## Initial state

Ban đầu:

```text
User traffic → Blue
Green → idle / testing
```

Blue đang phục vụ user thật.  
Green chưa nhận traffic user thật.

## Deployment flow

Khi có version mới:

```text
1. Deploy new version to Green
2. Run smoke test on Green
3. Validate Green
4. Switch traffic from Blue to Green
5. Keep Blue for rollback
```

## Sau khi switch

```text
User traffic → Green
Blue → standby rollback
```

Green trở thành môi trường live.  
Blue được giữ lại để rollback nếu có lỗi.

## Ưu điểm

Blue/Green có các lợi ích:

- Near-zero downtime
- Test trước khi user thật dùng
- Rollback nhanh bằng cách switch traffic về Blue
- Phù hợp với release rủi ro cao

## Nhược điểm

Blue/Green cũng có chi phí:

- Cần nhiều infrastructure hơn
- Setup phức tạp hơn
- Cần load balancer hoặc routing
- Database migration có thể khó

## Ví dụ

Current:

```text
traffic → blue.example.com
```

New release:

```text
deploy v2 → green.example.com
test green
switch traffic → green
keep blue for rollback
```

## Điểm cần nhấn mạnh

Blue/Green không chỉ là có hai server.

Điểm quan trọng nhất là:

```text
Kiểm soát traffic
Rollback nhanh
Không làm user bị downtime
```

## Key takeaway
> Blue/Green chủ yếu là chiến lược kiểm soát traffic và rollback nhanh.

## Chuyển ý
Tiếp theo, chúng ta sẽ xem Blue/Green được mô phỏng trong GitLab CI/CD như thế nào.

---

# Slide 18 — Blue/Green Deployment Example

## Thời lượng
**8 phút**

## Mục tiêu slide
Giải thích ví dụ pipeline Blue/Green trong GitLab CI/CD.

## Nội dung nên trình bày

Một pipeline Blue/Green nên tách rõ các bước:

```text
Build image
→ Run tests
→ Deploy to Green
→ Smoke test Green
→ Switch traffic to Green
→ Keep Blue for rollback
```

Điểm quan trọng là không gộp deploy và switch traffic vào cùng một bước quá sớm.

## Example `.gitlab-ci.yml`

Pipeline có thể có các stage:

```yaml
stages:
  - build
  - test
  - deploy
  - smoke_test
  - switch
```

## `deploy_green`

```yaml
deploy_green:
  stage: deploy
  script:
    - echo "Deploy new version to Green"
  environment:
    name: production-green
    url: https://green.example.com
  when: manual
  only:
    - main
```

Job này deploy version mới lên Green, nhưng chưa đưa traffic thật vào.

## `smoke_test_green`

```yaml
smoke_test_green:
  stage: smoke_test
  script:
    - curl -f https://green.example.com/health
  only:
    - main
```

Smoke test kiểm tra Green có hoạt động không.

Có thể kiểm tra:

- Health endpoint
- Database connection
- Login basic flow
- Critical API
- External service connection

## `switch_to_green`

```yaml
switch_to_green:
  stage: switch
  script:
    - echo "Switch traffic from Blue to Green"
  environment:
    name: production
    url: https://example.com
  when: manual
  only:
    - main
```

Job này đại diện cho bước chuyển traffic thật từ Blue sang Green.

## Traffic switch có thể dùng

- Load balancer
- Nginx config
- Kubernetes service selector
- DNS routing
- Cloud traffic manager
- API gateway

## Warning

Blue/Green rollback nhanh ở tầng application traffic.

Nhưng database rollback vẫn có thể khó.

Ví dụ:

```text
Green deploy migration mới
Database schema thay đổi
Blue app cũ không tương thích schema mới
Switch traffic về Blue vẫn lỗi
```

Vì vậy migration cần backward-compatible.

## Key takeaway
> Blue/Green pipeline phải tách rõ deploy, validate, switch và rollback.

## Chuyển ý
Sau khi biết Rolling Update và Blue/Green, câu hỏi tiếp theo là: nên chọn strategy nào?

---

# Slide 19 — Choosing the Right Deployment Strategy

## Thời lượng
**9 phút**

## Mục tiêu slide
Hướng dẫn chọn deployment strategy phù hợp.

## Nội dung nên trình bày

Không có deployment strategy nào đúng cho mọi hệ thống.

Cần chọn dựa trên:

- Risk
- Infrastructure
- Team maturity
- Rollback capability
- User impact
- Monitoring readiness

## Strategy decision matrix

| Situation | Recommended strategy |
|---|---|
| Dev environment | Automatic deployment |
| Test environment | Automatic deployment |
| Staging environment | Automatic or manual |
| Small production | Manual deployment |
| Production with many instances | Rolling update |
| Critical production | Blue/Green |
| Large database migration | Manual + rollback plan |
| Low team maturity | Simple manual flow |

## Khi nào dùng Automatic?

Dùng khi:

- Dev
- Internal tools
- Feature preview
- Low-risk services
- Cần fast feedback

Automatic phù hợp khi tốc độ quan trọng hơn kiểm soát.

## Khi nào dùng Manual?

Dùng khi:

- Production
- Major releases
- Sensitive systems
- Approval required
- Release timing matters

Manual phù hợp khi kiểm soát quan trọng hơn tốc độ.

## Khi nào dùng Rolling Update?

Dùng khi:

- Có multiple instances
- Có load balancer
- Health checks đã sẵn sàng
- App hỗ trợ mixed versions
- Muốn giảm downtime

Rolling update phù hợp với hệ thống scale nhiều instance.

## Khi nào dùng Blue/Green?

Dùng khi:

- Cần rollback nhanh
- Release có high risk
- Có đủ infrastructure
- Có thể switch traffic an toàn

Blue/Green phù hợp với hệ thống critical và cần rollback rất nhanh.

## Nguyên tắc thực tế

Nếu team chưa mature, đừng bắt đầu bằng strategy quá phức tạp.

Có thể bắt đầu với:

```text
Dev auto deploy
Staging deploy theo main
Production manual
```

Sau đó khi hệ thống lớn hơn, thêm:

```text
Rolling update
Blue/Green
Canary
Feature flags
```

## Final takeaway
> Hãy chọn strategy đơn giản nhất nhưng vẫn đáp ứng được yêu cầu rủi ro và độ tin cậy của hệ thống.

## Chuyển ý
Bây giờ chúng ta có thể chuyển sang phần demo để thấy các khái niệm này trong pipeline thực tế.

---

# Slide 20 — Demo

## Thời lượng
**15 phút**

## Mục tiêu slide
Thực hành hoặc mô phỏng một pipeline deploy nhiều environment.

## Gợi ý demo

Nếu có repo GitLab sẵn, demo theo flow sau.

## Demo flow đề xuất

## Bước 1 — Mở `.gitlab-ci.yml`

Giải thích các stage:

```yaml
stages:
  - build
  - test
  - deploy
```

Nói rõ:

- build tạo package hoặc image
- test kiểm tra code
- deploy đưa app lên environment

## Bước 2 — Chỉ ra job deploy Dev

```yaml
deploy_dev:
  stage: deploy
  environment:
    name: dev
    url: https://dev.example.com
  only:
    - develop
```

Giải thích:

- Chỉ chạy trên `develop`
- Deploy lên `dev`
- GitLab tracking environment `dev`

## Bước 3 — Chỉ ra job deploy Staging

```yaml
deploy_staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - main
```

Giải thích:

- Chỉ chạy trên `main`
- Dùng cho QA/UAT
- Là checkpoint trước Production

## Bước 4 — Chỉ ra job deploy Production

```yaml
deploy_production:
  stage: deploy
  environment:
    name: production
    url: https://app.example.com
  when: manual
  only:
    - tags
```

Giải thích:

- Chỉ xuất hiện khi tạo tag
- Không chạy tự động
- Cần người có quyền bấm deploy

## Bước 5 — Mở GitLab Environments UI

Cho học viên xem:

- dev
- staging
- production
- deployment history
- latest deployment
- URL
- commit deployed

## Bước 6 — Tạo tình huống hỏi học viên

Hỏi:

1. Nếu muốn Dev auto deploy, rule nên đặt ở đâu?
2. Nếu muốn Production chỉ deploy từ tag, cần rule gì?
3. Nếu Production bị lỗi, thông tin nào trong GitLab giúp debug?
4. Secret Production nên để ở đâu?
5. Khi nào nên dùng Rolling Update thay vì Manual simple deployment?

## Nếu không có demo thực tế

Có thể demo bằng sơ đồ và YAML mẫu.

Đi qua flow:

```text
feature branch → test only
develop → deploy dev
main → deploy staging
tag v1.2.0 → manual production
```

## Key takeaway
> Demo giúp học viên thấy rằng Environment Management không chỉ là lý thuyết. Nó được thể hiện trực tiếp trong `.gitlab-ci.yml`, pipeline rules và GitLab UI.

---

# Slide 21 — Thank You

## Thời lượng
**5 phút**

## Mục tiêu slide
Tổng kết nội dung và kết thúc buổi học.

## Nội dung nên trình bày

Cảm ơn mọi người đã tham gia Session 4.

Trong buổi này, chúng ta đã học:

## 1. Environment Management

- Vì sao cần nhiều environment
- Vai trò của Development, Staging, Production
- Environment promotion flow
- Release gates
- GitLab Environments
- Cách khai báo environment trong `.gitlab-ci.yml`
- Environment variables và secrets

## 2. Deployment Strategies

- Manual deployment
- Automatic deployment
- Rolling update
- Blue/Green deployment
- Cách chọn deployment strategy phù hợp

## 3. Tư duy quan trọng

Điều quan trọng nhất của Session 4 không phải là nhớ từng dòng YAML.

Điều quan trọng là hiểu:

```text
Deploy lên đâu?
Deploy khi nào?
Ai được deploy?
Có kiểm tra trước deploy không?
Có rollback không?
Có monitoring sau deploy không?
```

## Final message

> Một deployment pipeline tốt không phải là pipeline deploy nhanh nhất.  
> Một deployment pipeline tốt là pipeline deploy an toàn, có thể quan sát, có thể truy vết và có thể rollback.

## Gợi ý câu hỏi cuối buổi

- Trong project thật của bạn, hiện có những environment nào?
- Production deploy đang manual hay automatic?
- Team có rollback plan rõ chưa?
- Secret hiện đang lưu ở đâu?
- Nếu deploy lỗi, team có biết rollback version nào không?

## Kết thúc
Cảm ơn mọi người.  
Phần tiếp theo có thể đi sâu hơn vào demo thực tế hoặc advanced deployment như Canary, Feature Flags và Kubernetes deployment patterns.

---

# Phụ lục — Các câu hỏi kiểm tra nhanh cuối buổi

## Câu 1
**Dev, Staging và Production khác nhau như thế nào?**

Gợi ý trả lời:
- Dev dùng cho kiểm tra nhanh
- Staging dùng cho kiểm thử trước release
- Production dùng cho user thật

## Câu 2
**Vì sao Production nên có manual approval?**

Gợi ý trả lời:
- Rủi ro cao
- User thật bị ảnh hưởng
- Dữ liệu thật
- Cần người chịu trách nhiệm
- Cần kiểm soát thời điểm release

## Câu 3
**GitLab Environments giúp gì?**

Gợi ý trả lời:
- Tracking environment
- Deployment history
- Commit deployed
- URL
- Người deploy
- Thời điểm deploy

## Câu 4
**Secrets có nên commit vào Git không?**

Gợi ý trả lời:
Không. Nên dùng GitLab CI/CD Variables, mask, protect và phân quyền theo environment.

## Câu 5
**Rolling Update có nhược điểm gì?**

Gợi ý trả lời:
- Có thể chạy song song version cũ và mới
- Cần backward compatibility
- Database migration phải cẩn thận
- Cần health check tốt

## Câu 6
**Blue/Green phù hợp khi nào?**

Gợi ý trả lời:
- Cần rollback nhanh
- Production critical
- Release rủi ro cao
- Có đủ hạ tầng chạy song song
- Có khả năng switch traffic an toàn

---

# Phụ lục — Thông điệp chốt cho người học

Sau Session 4, người học cần nhớ:

```text
Không deploy Production theo cảm tính.
Không để secret trong source code.
Không để mọi commit đi thẳng lên Production.
Không deploy nếu không biết rollback thế nào.
Không release nếu không có monitoring sau deploy.
```

Một flow căn bản nhưng an toàn:

```text
feature/* → test only
develop → deploy Dev
main → deploy Staging
tag v* → manual deploy Production
```

Một deployment pipeline trưởng thành nên có:

```text
Build
Test
Quality/Security checks
Environment rules
Approval gates
Protected secrets
Deployment history
Monitoring
Rollback plan
```
