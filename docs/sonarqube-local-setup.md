# SonarQube Local Setup cho GitLab CI/CD Demo

Tài liệu này hướng dẫn chạy SonarQube local để dùng với demo GitLab CI/CD Session 3.

## 1. Start SonarQube local

Chạy SonarQube bằng Docker:

```bash
docker run -d --name sonarqube \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  -p 9000:9000 \
  sonarqube:latest
```

Mở browser:

```text
http://localhost:9000
```

Login mặc định:

```text
username: admin
password: admin
```

Sau khi login lần đầu, đổi password admin theo yêu cầu của SonarQube.

## 2. Tạo SonarQube token

1. Đăng nhập SonarQube.
2. Bấm avatar/user menu ở góc phải.
3. Vào **My Account** hoặc **My Profile**.
4. Mở tab **Security**.
5. Tạo token mới cho CI/CD scanner.
6. Copy token ngay sau khi tạo.

Trong GitLab project, vào **Settings** → **CI/CD** → **Variables**, thêm:

```text
SONAR_TOKEN=<token-vừa-tạo>
```

Không commit token vào source code.

## 3. Trường hợp A: GitLab Runner chạy shell trên host

Dùng trường hợp này khi GitLab Runner được cài trực tiếp trên máy host và dùng shell executor.

Vì runner chạy cùng máy với Docker host, có thể dùng localhost:

```text
SONAR_HOST_URL=http://localhost:9000
```

Trong GitLab CI/CD Variables, thêm:

```text
SONAR_HOST_URL=http://localhost:9000
SONAR_TOKEN=<token-vừa-tạo>
```

Kiểm tra nhanh trên host:

```bash
curl http://localhost:9000
```

Nếu có HTML response từ SonarQube là runner shell thường sẽ truy cập được.

## 4. Trường hợp B: GitLab Runner chạy trong container

Dùng trường hợp này khi GitLab Runner cũng là một Docker container.

Không dùng:

```text
SONAR_HOST_URL=http://localhost:9000
```

Vì `localhost` bên trong job container là chính container đó, không phải máy host.

### Cách đơn giản nhất: dùng IP của máy host

Tìm IP LAN của máy host, ví dụ:

```text
192.168.1.50
```

Trong GitLab CI/CD Variables, đặt:

```text
SONAR_HOST_URL=http://192.168.1.50:9000
SONAR_TOKEN=<token-vừa-tạo>
```

Điều kiện:

- SonarQube container đã expose port `9000` bằng `-p 9000:9000`.
- GitLab Runner container truy cập được IP host.
- Firewall cho phép port `9000`.

### Nếu dùng Docker Desktop Mac/Windows

Có thể dùng hostname đặc biệt:

```text
SONAR_HOST_URL=http://host.docker.internal:9000
```

Trong GitLab CI/CD Variables:

```text
SONAR_HOST_URL=http://host.docker.internal:9000
SONAR_TOKEN=<token-vừa-tạo>
```

## 5. Test nhanh trong pipeline

Sau khi cấu hình variables, job `sonar-scan` trong `.gitlab-ci.yml` sẽ chạy:

```bash
sonar-scanner \
  -Dsonar.host.url=$SONAR_HOST_URL \
  -Dsonar.token=$SONAR_TOKEN \
  -Dsonar.qualitygate.wait=true
```

Nếu scanner báo không kết nối được SonarQube, kiểm tra lại:

1. SonarQube đã chạy chưa: `docker ps --filter name=sonarqube`
2. URL mở được từ browser chưa.
3. Runner đang là shell hay container.
4. `SONAR_HOST_URL` có dùng đúng địa chỉ cho loại runner chưa.
5. Firewall hoặc network có chặn port `9000` không.

## 6. Stop sau demo

Stop container:

```bash
docker stop sonarqube
```

Start lại:

```bash
docker start sonarqube
```

Xóa hẳn container:

```bash
docker rm -f sonarqube
```
