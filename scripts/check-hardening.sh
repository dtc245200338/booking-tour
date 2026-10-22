#!/bin/bash
cd "$(dirname "$0")/.."
echo "== 1. User chạy container (non-root) =="
for c in tour_app tour_nginx tour_prometheus tour_grafana tour_loki tour_promtail; do
  printf '%-18s %s\n' "$c" "$(docker exec $c id 2>/dev/null | cut -d' ' -f1)"
done
echo; echo "== 2. read_only / cap_drop / no-new-privileges =="
for c in $(docker ps --format '{{.Names}}' | grep '^tour_'); do
  docker inspect -f '{{.Name}} ro={{.HostConfig.ReadonlyRootfs}} cap_drop={{.HostConfig.CapDrop}} secopt={{.HostConfig.SecurityOpt}}' $c
done
echo; echo "== 3. Network isolation =="
for n in frontend backend monitoring; do
  docker network inspect booking-tour_$n -f '{{.Name}} internal={{.Internal}}'
done
echo; echo "== 4. Cổng publish ra host =="
docker ps --format '{{.Names}}: {{.Ports}}' | grep -- '->' | grep '^tour_'
echo; echo "== 5. Độ dài mật khẩu trong .env =="
awk -F= '/PASSWORD/ {print $1" => "length($2)" ký tự"}' .env
echo; echo "== 6. Quyền DB: user tour_app không được DROP =="
docker exec tour_db psql -U tour_app -d tourdb -c "DROP TABLE tours;" 2>&1 | head -1
