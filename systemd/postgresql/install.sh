#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PG_PASSWORD="${1:-postgres}"

echo "========================================"
echo "PostgreSQL Installer (Latest Version)"
echo "========================================"

# Install via official repo (Debian/Ubuntu)
install_debian() {
    apt-get update
    apt-get install -y wget gnupg2 lsb-release curl

    # Add PostgreSQL repo
    mkdir -p /usr/share/keyrings
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg --yes
    echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

    apt-get update

    # Get latest version available
    PG_VERSION=$(apt-cache search '^postgresql-[0-9]+$' | grep -oP 'postgresql-\K[0-9]+' | sort -rn | head -1)

    if [ -z "$PG_VERSION" ]; then
        echo "Error: Could not determine latest PostgreSQL version"
        exit 1
    fi

    echo "Latest version available: PostgreSQL ${PG_VERSION}"
    echo "Installing..."

    apt-get install -y postgresql-${PG_VERSION}
}

# Install via official repo (RHEL/CentOS)
install_rhel() {
    yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm

    # Get latest version
    PG_VERSION=$(yum list available postgresql*-server 2>/dev/null | grep -oP 'postgresql\K[0-9]+' | sort -rn | head -1)

    if [ -z "$PG_VERSION" ]; then
        PG_VERSION=17
    fi

    echo "Latest version available: PostgreSQL ${PG_VERSION}"
    echo "Installing..."

    yum install -y postgresql${PG_VERSION}-server postgresql${PG_VERSION}-contrib

    # Initialize database
    /usr/pgsql-${PG_VERSION}/bin/postgresql-${PG_VERSION}-setup initdb
}

# Detect OS and install
if [ -f /etc/debian_version ]; then
    install_debian
    CONFIG_DIR="/etc/postgresql/${PG_VERSION}/main"
    DATA_DIR="/var/lib/postgresql/${PG_VERSION}/main"
    SERVICE_NAME="postgresql@${PG_VERSION}-main"
elif [ -f /etc/redhat-release ]; then
    install_rhel
    CONFIG_DIR="/var/lib/pgsql/${PG_VERSION}/data"
    DATA_DIR="/var/lib/pgsql/${PG_VERSION}/data"
    SERVICE_NAME="postgresql-${PG_VERSION}"
else
    echo "Unsupported OS. Please install PostgreSQL manually."
    exit 1
fi

# Wait for cluster to initialize
sleep 2

# Backup original configs
cp "${CONFIG_DIR}/postgresql.conf" "${CONFIG_DIR}/postgresql.conf.original"
cp "${CONFIG_DIR}/pg_hba.conf" "${CONFIG_DIR}/pg_hba.conf.original"

# IMPORTANT: Keep data_directory and other critical settings from original
# Extract data_directory line from original config
DATA_DIR_LINE=$(grep "^data_directory" "${CONFIG_DIR}/postgresql.conf.original" || echo "data_directory = '${DATA_DIR}'")
HBA_FILE_LINE=$(grep "^hba_file" "${CONFIG_DIR}/postgresql.conf.original" || echo "")
IDENT_FILE_LINE=$(grep "^ident_file" "${CONFIG_DIR}/postgresql.conf.original" || echo "")
EXTERNAL_PID_LINE=$(grep "^external_pid_file" "${CONFIG_DIR}/postgresql.conf.original" || echo "")

# Create new config with system paths + our settings
{
    echo "# System paths (DO NOT MODIFY)"
    echo "${DATA_DIR_LINE}"
    [ -n "${HBA_FILE_LINE}" ] && echo "${HBA_FILE_LINE}"
    [ -n "${IDENT_FILE_LINE}" ] && echo "${IDENT_FILE_LINE}"
    [ -n "${EXTERNAL_PID_LINE}" ] && echo "${EXTERNAL_PID_LINE}"
    echo ""
    cat "${SCRIPT_DIR}/postgresql.conf"
} > "${CONFIG_DIR}/postgresql.conf"

# Copy pg_hba.conf
cp "${SCRIPT_DIR}/pg_hba.conf" "${CONFIG_DIR}/pg_hba.conf"

chown postgres:postgres "${CONFIG_DIR}/postgresql.conf" "${CONFIG_DIR}/pg_hba.conf"

# Restart the cluster service
echo "Restarting PostgreSQL..."
systemctl restart ${SERVICE_NAME}

# Wait for PostgreSQL to be ready
sleep 3

# Set postgres password
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '${PG_PASSWORD}';"

echo ""
echo "========================================"
echo "PostgreSQL ${PG_VERSION} installed!"
echo "========================================"
echo ""
echo "Service:  ${SERVICE_NAME}"
echo "Config:   ${CONFIG_DIR}/postgresql.conf"
echo "Data:     ${DATA_DIR}"
echo "Password: ${PG_PASSWORD}"
echo ""
echo "Commands:"
echo "  systemctl status ${SERVICE_NAME}"
echo "  systemctl restart ${SERVICE_NAME}"
echo ""
echo "Connect:"
echo "  sudo -u postgres psql"
echo "  psql -h localhost -U postgres -d postgres"
echo ""
echo "Connection string:"
echo "  postgresql://postgres:${PG_PASSWORD}@localhost:5432/postgres"
echo "========================================"
