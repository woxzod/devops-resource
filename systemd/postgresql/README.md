# PostgreSQL Systemd Installation

Installs the latest PostgreSQL version from the official repository.

## Quick Install

```bash
# Clone/copy files to server
scp -r postgresql/ user@server:~/

# Run installer (default password: postgres)
sudo ./install.sh

# Or with custom password
sudo ./install.sh my_secure_password
```

## What It Does

1. Adds official PostgreSQL APT/YUM repository
2. Installs the **latest** PostgreSQL version automatically
3. Configures optimized settings (memory, logging, connections)
4. Enables remote connections from any IP
5. Sets the postgres user password

## Files

| File | Description |
|------|-------------|
| `install.sh` | Main installer script |
| `postgresql.conf` | PostgreSQL configuration (tuning, logging) |
| `pg_hba.conf` | Client authentication (allows remote connections) |

## Connection Details

| Setting | Value |
|---------|-------|
| Host | `<server-ip>` |
| Port | `5432` |
| User | `postgres` |
| Password | (set during install) |
| Database | `postgres` |

**Connection string:**
```
postgresql://postgres:<password>@<server-ip>:5432/postgres
```

## Commands

```bash
# Check status
systemctl status postgresql@<version>-main

# Restart
systemctl restart postgresql@<version>-main

# View logs
journalctl -u postgresql@<version>-main -f

# Connect locally
sudo -u postgres psql
```

## Configuration

Config files are located at:
```
/etc/postgresql/<version>/main/postgresql.conf
/etc/postgresql/<version>/main/pg_hba.conf
```

After editing, restart PostgreSQL:
```bash
systemctl restart postgresql@<version>-main
```

## Uninstall

```bash
systemctl stop postgresql
apt purge -y postgresql* libpq*
rm -rf /var/lib/postgresql/ /etc/postgresql/ /var/log/postgresql/
apt autoremove -y
```

## Supported OS

- Ubuntu / Debian
- RHEL / CentOS / Rocky Linux
