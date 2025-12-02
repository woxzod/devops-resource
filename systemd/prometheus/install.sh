#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${1:-2.48.0}"

# Create user and directories
useradd --no-create-home --shell /bin/false prometheus || true
mkdir -p /etc/prometheus /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Download and install
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-amd64.tar.gz
tar xzf prometheus-${VERSION}.linux-amd64.tar.gz
cd prometheus-${VERSION}.linux-amd64

cp prometheus promtool /usr/local/bin/
cp -r consoles console_libraries /etc/prometheus/
chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

# Cleanup
cd /tmp
rm -rf prometheus-${VERSION}.linux-amd64*

# Copy config files
if [ ! -f /etc/prometheus/prometheus.yml ]; then
    cp "${SCRIPT_DIR}/prometheus.yml" /etc/prometheus/prometheus.yml
    echo "Copied prometheus.yml to /etc/prometheus/"
fi

if [ ! -f /etc/prometheus/alerts.yml ]; then
    cp "${SCRIPT_DIR}/alerts.yml" /etc/prometheus/alerts.yml
    echo "Copied alerts.yml to /etc/prometheus/"
fi

chown -R prometheus:prometheus /etc/prometheus

# Install service
cp "${SCRIPT_DIR}/prometheus.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

echo "Prometheus installed and started"
echo "Config: /etc/prometheus/prometheus.yml"
echo "Access: http://localhost:9090"
