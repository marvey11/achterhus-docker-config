#!/bin/bash
set -e

# Execute SQL commands against Postgres using environment variables
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    -- Secure public schema
    REVOKE ALL ON SCHEMA public FROM PUBLIC;

    ----------------------------------------------------
    -- Telemetry Service
    ----------------------------------------------------
    CREATE USER telemetry_app WITH PASSWORD '$TELEMETRY_APP_PASSWORD';
    CREATE SCHEMA IF NOT EXISTS telemetry AUTHORIZATION telemetry_app;
    ALTER USER telemetry_app SET search_path TO telemetry;
    GRANT ALL ON SCHEMA telemetry TO telemetry_app;
    ALTER DEFAULT PRIVILEGES IN SCHEMA telemetry GRANT ALL ON TABLES TO telemetry_app;
    ALTER DEFAULT PRIVILEGES IN SCHEMA telemetry GRANT ALL ON SEQUENCES TO telemetry_app;
EOSQL
