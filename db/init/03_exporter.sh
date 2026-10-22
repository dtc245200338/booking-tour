#!/bin/bash
set -e
psql -v ON_ERROR_STOP=1 -v pw="$EXPORTER_DB_PASSWORD" \
     --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<'EOSQL'
CREATE ROLE exporter LOGIN PASSWORD :'pw' NOSUPERUSER NOCREATEDB NOCREATEROLE;
GRANT pg_monitor TO exporter;
EOSQL
