# PostgreSQL

PostgreSQL database server.

## Quick Start

```bash
docker-compose up -d
```

## Default Credentials

- **User:** postgres
- **Password:** postgres
- **Database:** postgres
- **Port:** 5432

## Connection

```bash
# Connect via psql
psql -h localhost -U postgres -d postgres

# Connection string
postgresql://postgres:postgres@localhost:5432/postgres
```

## Initialization Scripts

Place `.sql` or `.sh` files in the `init/` directory. They will be executed on first container start (alphabetical order).

Example `init/01-create-db.sql`:
```sql
CREATE DATABASE myapp;
CREATE USER myuser WITH PASSWORD 'mypassword';
GRANT ALL PRIVILEGES ON DATABASE myapp TO myuser;
```

## Data Persistence

Data is stored in the `postgres_data` Docker volume.

## Backup

```bash
# Backup
docker exec postgresql pg_dump -U postgres mydb > backup.sql

# Restore
docker exec -i postgresql psql -U postgres mydb < backup.sql
```
