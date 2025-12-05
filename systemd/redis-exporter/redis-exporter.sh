#!/bin/bash

# Redis Exporter Installation Script for Rocky Linux

set -e

REDIS_EXPORTER_VERSION="1.80.1"
REDIS_ADDR="redis://127.0.0.1:6379"
LISTEN_PORT="9121"

echo "==> Downloading Redis Exporter v${REDIS_EXPORTER_VERSION}..."
cd /tmp
wget -q https://github.com/oliver006/redis_exporter/releases/download/v${REDIS_EXPORTER_VERSION}/redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "==> Installing..."
tar xzf redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo mv redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64/redis_exporter /usr/local/bin/
sudo chmod +x /usr/local/bin/redis_exporter

echo "==> Creating systemd service..."
sudo tee /etc/systemd/system/redis_exporter.service > /dev/null <<EOF
[Unit]
Description=Redis Exporter
After=network.target redis.service

[Service]
Type=simple
Environment=REDIS_ADDR=${REDIS_ADDR}
ExecStart=/usr/local/bin/redis_exporter --web.listen-address=:${LISTEN_PORT}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "==> Starting service..."
sudo systemctl daemon-reload
sudo systemctl enable redis_exporter
sudo systemctl start redis_exporter

echo "==> Cleaning up..."
rm -rf /tmp/redis_exporter-v${REDIS_EXPORTER_VERSION}.linux-amd64*

echo "==> Verifying..."
sleep 2
if curl -s http://localhost:${LISTEN_PORT}/metrics | grep -q "redis_up 1"; then
    echo "==> Redis Exporter installed and running successfully!"
else
    echo "==> Warning: redis_up metric not found. Check if Redis is running."
fi

echo ""
echo "Next steps:"
echo "1. Add to prometheus.yml:"
echo "   - job_name: 'redis'"
echo "     static_configs:"
echo "       - targets: ['localhost:${LISTEN_PORT}']"
echo ""
echo "2. Reload Prometheus: sudo systemctl reload prometheus"
echo "3. Import Grafana dashboard ID: 763"