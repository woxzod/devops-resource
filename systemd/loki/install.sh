#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${1:-2.9.2}"

# Create user and directories
useradd --no-create-home --shell /bin/false loki || true
mkdir -p /etc/loki /var/lib/loki /var/lib/loki/chunks /var/lib/loki/rules
chown -R loki:loki /etc/loki /var/lib/loki

# Download and install
cd /tmp
wget https://github.com/grafana/loki/releases/download/v${VERSION}/loki-linux-amd64.zip
unzip loki-linux-amd64.zip
mv loki-linux-amd64 /usr/local/bin/loki
chmod +x /usr/local/bin/loki
chown loki:loki /usr/local/bin/loki

# Cleanup
rm -f loki-linux-amd64.zip

# Copy config file
if [ ! -f /etc/loki/loki.yml ]; then
    cp "${SCRIPT_DIR}/loki.yml" /etc/loki/loki.yml
    echo "Copied loki.yml to /etc/loki/"
fi

chown -R loki:loki /etc/loki

# Install service
cp "${SCRIPT_DIR}/loki.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable loki
systemctl start loki

echo "Loki installed and started"
echo "Config: /etc/loki/loki.yml"
echo "Access: http://localhost:3100"
