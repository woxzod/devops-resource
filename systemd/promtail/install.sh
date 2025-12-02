#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${1:-2.9.2}"

# Create user and directories
useradd --no-create-home --shell /bin/false promtail || true
mkdir -p /etc/promtail /var/lib/promtail
chown promtail:promtail /etc/promtail /var/lib/promtail

# Download and install
cd /tmp
wget https://github.com/grafana/loki/releases/download/v${VERSION}/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip
mv promtail-linux-amd64 /usr/local/bin/promtail
chmod +x /usr/local/bin/promtail
chown promtail:promtail /usr/local/bin/promtail

# Cleanup
rm -f promtail-linux-amd64.zip

# Add promtail to adm group for log access
usermod -aG adm promtail

# Copy config file
if [ ! -f /etc/promtail/promtail.yml ]; then
    cp "${SCRIPT_DIR}/promtail.yml" /etc/promtail/promtail.yml
    echo "Copied promtail.yml to /etc/promtail/"
fi

chown -R promtail:promtail /etc/promtail

# Install service
cp "${SCRIPT_DIR}/promtail.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable promtail
systemctl start promtail

echo "Promtail installed and started"
echo "Config: /etc/promtail/promtail.yml"
