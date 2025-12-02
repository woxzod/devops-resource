#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install via official repo (Debian/Ubuntu)
install_debian() {
    apt-get install -y apt-transport-https software-properties-common wget
    mkdir -p /etc/apt/keyrings/
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
    apt-get update
    apt-get install -y grafana
}

# Install via official repo (RHEL/CentOS)
install_rhel() {
    cat <<EOF | tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
    yum install -y grafana
}

# Detect OS and install
if [ -f /etc/debian_version ]; then
    install_debian
elif [ -f /etc/redhat-release ]; then
    install_rhel
else
    echo "Unsupported OS. Please install Grafana manually."
    exit 1
fi

# Copy custom config (backup original first)
if [ -f /etc/grafana/grafana.ini ]; then
    cp /etc/grafana/grafana.ini /etc/grafana/grafana.ini.bak
fi
cp "${SCRIPT_DIR}/grafana.ini" /etc/grafana/grafana.ini
chown root:grafana /etc/grafana/grafana.ini
chmod 640 /etc/grafana/grafana.ini

# Setup provisioning directories
mkdir -p /etc/grafana/provisioning/{datasources,dashboards}

# Copy datasources config if exists
if [ -f "${SCRIPT_DIR}/datasources.yml" ]; then
    cp "${SCRIPT_DIR}/datasources.yml" /etc/grafana/provisioning/datasources/
    echo "Copied datasources.yml"
fi

chown -R root:grafana /etc/grafana/provisioning
chmod -R 755 /etc/grafana/provisioning

# Enable and start
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

echo "Grafana installed and started"
echo "Config: /etc/grafana/grafana.ini"
echo "Access: http://localhost:3000 (admin/admin)"
