#!/bin/bash
set -e

VERSION="${1:-1.7.0}"

# Create user
useradd --no-create-home --shell /bin/false node_exporter || true

# Download and install
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.linux-amd64.tar.gz
tar xzf node_exporter-${VERSION}.linux-amd64.tar.gz
cp node_exporter-${VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Cleanup
rm -rf node_exporter-${VERSION}.linux-amd64*

# Install service
cp node-exporter.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable node-exporter
systemctl start node-exporter

echo "Node Exporter installed and started"
