#!/bin/bash
set -e

# Create user and directories
useradd --no-create-home --shell /bin/false minio || true
mkdir -p /data/minio
chown minio:minio /data/minio

# Download and install
cd /tmp
wget https://dl.min.io/server/minio/release/linux-amd64/minio
chmod +x minio
mv minio /usr/local/bin/
chown minio:minio /usr/local/bin/minio

# Copy environment file
cp minio.env /etc/default/minio
chmod 600 /etc/default/minio

# Install service
cp minio.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable minio
systemctl start minio

echo "MinIO installed and started"
echo "API: http://localhost:9000"
echo "Console: http://localhost:9001"
