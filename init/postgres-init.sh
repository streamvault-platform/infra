#!/bin/bash
# Creates dedicated service accounts for streamvault-core.
# Runs once on first boot via docker-entrypoint-initdb.d.
# Requires DB_MIGRATOR_PASSWORD and DB_APP_PASSWORD in the container env.
set -e

psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     --dbname   "$POSTGRES_DB"   \
     --variable=migrator_pw="$DB_MIGRATOR_PASSWORD" \
     --variable=app_pw="$DB_APP_PASSWORD"           \
     --variable=db_name="$POSTGRES_DB"              \
<<-'EOF'
    -- Required by Flyway full-text search migrations; superuser creates it here.
    CREATE EXTENSION IF NOT EXISTS pg_trgm;

    -- Flyway runs migrations as this user; owns the public schema for DDL.
    CREATE USER streamvault_migrator WITH PASSWORD :'migrator_pw';

    -- Hibernate Reactive connects as this user; SELECT/INSERT/UPDATE/DELETE only.
    CREATE USER streamvault_core WITH PASSWORD :'app_pw';

    -- Migrator owns public so it can CREATE/ALTER/DROP tables and sequences.
    ALTER SCHEMA public OWNER TO streamvault_migrator;

    GRANT CONNECT ON DATABASE :"db_name" TO streamvault_migrator;
    GRANT CONNECT ON DATABASE :"db_name" TO streamvault_core;
    GRANT USAGE ON SCHEMA public TO streamvault_core;

    -- Any table/sequence the migrator creates in future migrations is
    -- automatically readable and writable by the app user.
    ALTER DEFAULT PRIVILEGES FOR ROLE streamvault_migrator IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO streamvault_core;
    ALTER DEFAULT PRIVILEGES FOR ROLE streamvault_migrator IN SCHEMA public
        GRANT USAGE, SELECT ON SEQUENCES TO streamvault_core;
EOF
