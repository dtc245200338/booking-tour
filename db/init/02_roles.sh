#!/bin/bash
# Tạo user riêng cho ứng dụng với quyền tối thiểu (hardening DB)
set -e
psql -v ON_ERROR_STOP=1 -v app_user="$APP_DB_USER" -v app_pw="$APP_DB_PASSWORD" \
     --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
CREATE ROLE :"app_user" LOGIN PASSWORD :'app_pw' NOSUPERUSER NOCREATEDB NOCREATEROLE;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO :"app_user";
GRANT SELECT ON tours, tour_schedules, tour_itineraries TO :"app_user";
GRANT SELECT, INSERT ON customers, bookings TO :"app_user";
GRANT UPDATE (full_name, phone) ON customers TO :"app_user";
GRANT UPDATE (seats_available) ON tour_schedules TO :"app_user";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO :"app_user";
EOSQL
