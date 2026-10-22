# Hệ thống Booking Tour / Du lịch

Website đặt tour du lịch (tour, lịch trình, khách hàng, booking).
**Stack:** Node.js (Express) · PostgreSQL · pgAdmin · Nginx (HTTPS) · Docker Compose

## Yêu cầu
- WSL2 (Ubuntu 24.04) + Docker Engine + Docker Compose v2

## Chạy hệ thống
```bash
git clone git@github.com:MSSV_CUA_BAN/booking-tour.git && cd booking-tour
cp .env.example .env            # sửa mật khẩu mạnh
./scripts/gen-cert.sh           # tạo chứng chỉ HTTPS tự ký
docker compose up -d --build
```

## Địa chỉ truy cập
| Dịch vụ | URL |
|---|---|
| Website (HTTPS) | https://localhost |
| pgAdmin | http://localhost:5050 |

## Kết nối pgAdmin → PostgreSQL
Host `db` · Port `5432` · DB `tourdb` · User `tour_admin` · Password trong `.env`

## Kiến trúc mạng
- `frontend`: nginx, app, pgadmin
- `backend` (internal): app, db, pgadmin → DB không truy cập được từ Internet

## Lộ trình commit
1. Web app + PostgreSQL + pgAdmin + Nginx reverse proxy (HTTPS, security headers)
2. Prometheus + Grafana
3. Loki + Promtail + LogQL + hardening

## Ghi chú
- pgAdmin chạy non-root với `no-new-privileges` nên lắng nghe cổng nội bộ 8080 (map ra `127.0.0.1:5050`).


## Giám sát trên Docker Desktop và WSL 2

Prometheus: http://localhost:9090 — Grafana: http://localhost:3000.

Dùng cAdvisor 0.55.1 với `cgroup: host` và socket containerd của Docker Desktop.
Không gắn `/sys` hoặc toàn bộ `/var/run` từ Ubuntu vì có thể che cgroup hoặc socket
của Docker Desktop. Không cần `pid: host`.

Trước lần chạy đầu, tạo volume dưới đây trong PowerShell Windows (không chạy trong Ubuntu):

```powershell
& "$env:LOCALAPPDATA\Programs\DockerDesktop\resources\bin\docker.exe" volume create --driver local --opt type=none --opt o=bind --opt device=/run/containerd booking-tour_cadvisor_containerd_desktop
```

Nếu Docker được cài cho mọi người dùng, dùng `docker.exe` trong
`C:\Program Files\Docker\Docker\resources\bin`.
Sau đó chạy `docker compose up -d` trong thư mục dự án Ubuntu.
Volume này chỉ gắn thư mục runtime để giám sát, không chứa dữ liệu PostgreSQL.

Truy vấn RAM theo MiB:

```promql
container_memory_usage_bytes{name=~"tour_.*"} / 1024 / 1024
```

Truy vấn CPU theo phần trăm một lõi:

```promql
rate(container_cpu_usage_seconds_total{name=~"tour_.*"}[2m]) * 100
```

Volume runtime chỉ đọc vẫn cung cấp kết nối API mạnh cho cAdvisor; chỉ dùng trong
môi trường thực hành có kiểm soát. Chưa dùng các cấu hình này làm bằng chứng đã
giám sát thành công cho đến khi trang Targets và truy vấn thực tế có dữ liệu.
