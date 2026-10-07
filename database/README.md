# PostgreSQL & pgAdmin Setup Guide

This repository contains a containerized database stack using PostgreSQL 16 and pgAdmin 4, routed through an Nginx reverse proxy gateway.

---

## Prerequisites

- **Docker** (v20.10+) and **Docker Compose** (v2.0+) installed.
- The external network `achterhus-network` must exist prior to starting the services.

To create the network manually if it does not exist yet:

```bash
docker network create achterhus-network
```

---

## Environment Configuration

Create a `.env` file in the root directory alongside `docker-compose.yaml`. This file configures credentials and initial database settings.

### `.env` Template

```env
# PostgreSQL Configuration
POSTGRES_USER=myuser
POSTGRES_PASSWORD=supersecretpassword
POSTGRES_DB=appdb

# pgAdmin Configuration
PGADMIN_DEFAULT_EMAIL=admin@example.com
PGADMIN_PASSWORD=adminpassword
```

> ⚠️ **Security Warning**: Never commit your filled `.env` file to version control. Ensure `.env` is listed in your `.gitignore` file.

---

## Database Initialisation & Custom Scripts

When the PostgreSQL container starts for the very first time (with an uninitialized data volume), it automatically performs the following:

1. Creates the root user specified by `POSTGRES_USER` with `POSTGRES_PASSWORD`.
2. Creates the default database specified by `POSTGRES_DB`.
3. Grants full superuser permissions on `POSTGRES_DB` to `POSTGRES_USER`.

### Running Custom Initialisation Scripts

To automatically seed schema structures, create extra users, or install extensions (e.g., `uuid-ossp`, `pg_trgm`) during initial startup:

1. Create an `./init-scripts/` directory next to `docker-compose.yaml`.
2. Place your `.sql` or `.sh` files inside `./init-scripts/`.

Files in `./init-scripts/` are executed in **alphabetical order**.

**Example:** `./init-scripts/01-extensions.sql`

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

*Note: Initialisation scripts are executed **only once** when the database data directory is empty. Subsequent container restarts ignore these scripts.*

---

## Gateway & Routing Configuration

The pgAdmin management panel is served through the Nginx gateway subpath `/pgadmin/`.

| Service | Internal URL | Gateway Endpoint | Access / Port |
| :--- | :--- | :--- | :--- |
| **PostgreSQL** | `postgres:5432` | N/A | Internal only (`achterhus-network`) |
| **pgAdmin** | `pgadmin:80` | `http://achterhus.local/pgadmin/` | Proxied via Nginx Gateway |

### Connecting pgAdmin to PostgreSQL

1. Open `http://achterhus.local/pgadmin/` (or `http://localhost/pgadmin/`) in your browser.
2. Log in using your `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_PASSWORD`.
3. Click **Add New Server** and enter the following settings on the **Connection** tab:
   - **Host name/address**: `postgres`
   - **Port**: `5432`
   - **Maintenance database**: *value of `POSTGRES_DB`*
   - **Username**: *value of `POSTGRES_USER`*
   - **Password**: *value of `POSTGRES_PASSWORD`*

---

## Maintenance & Backups

Database data persists across container recreations inside the named Docker volume `postgres_data`.

### 1. Live Logical Backup (`pg_dumpall`)

Creates a full backup file without taking the database offline:

```bash
docker exec -t postgres pg_dumpall -U myuser > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Live Single-Database Backup (`pg_dump`)

Backs up a specific database in compressed custom format:

```bash
docker exec -t postgres pg_dump -U myuser -d appdb -F c > appdb_$(date +%Y%m%d).dump
```

### 3. Restoring a Database

**From plain SQL dump:**

```bash
cat backup.sql | docker exec -i postgres psql -U myuser -d appdb
```

**From custom dump format (`.dump`):**

```bash
docker exec -i postgres pg_restore -U myuser -d appdb --clean < appdb.dump
```

### 4. Cold Volume Snapshot (Offline Backup)

To archive the underlying `postgres_data` volume directly:

```bash
# 1. Temporarily pause the postgres database container
docker compose stop postgres

# 2. Extract volume content into a tar archive
docker run --rm \
  -v postgres_data:/volume \
  -v $(pwd):/backup \
  busybox tar cvzf /backup/postgres_data_$(date +%Y%m%d).tar.gz -C /volume .

# 3. Restart the database service
docker compose start postgres
```

---

## Useful Commands

```bash
# Start all services in detached mode
docker compose up -d

# View real-time database logs
docker compose logs -f postgres

# Access PostgreSQL CLI (psql) inside the container
docker exec -it postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

# Stop all services
docker compose down
```
