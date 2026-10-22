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
