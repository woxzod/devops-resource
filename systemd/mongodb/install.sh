#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONGO_PASSWORD="${1:-mongo}"
MONGO_VERSION="${2:-7.0}"

echo "========================================"
echo "MongoDB Installer (Version ${MONGO_VERSION})"
echo "========================================"

# Install via official repo (Debian/Ubuntu)
install_debian() {
    apt-get update
    apt-get install -y gnupg curl

    # Add MongoDB repo
    curl -fsSL https://www.mongodb.org/static/pgp/server-${MONGO_VERSION}.asc | \
        gpg -o /usr/share/keyrings/mongodb-server-${MONGO_VERSION}.gpg --dearmor --yes

    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-${MONGO_VERSION}.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/${MONGO_VERSION} multiverse" | \
        tee /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list

    apt-get update
    apt-get install -y mongodb-org
}

# Install via official repo (RHEL/CentOS)
install_rhel() {
    cat <<EOF | tee /etc/yum.repos.d/mongodb-org-${MONGO_VERSION}.repo
[mongodb-org-${MONGO_VERSION}]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/${MONGO_VERSION}/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-${MONGO_VERSION}.asc
EOF
    yum install -y mongodb-org
}

# Detect OS and install
if [ -f /etc/debian_version ]; then
    install_debian
elif [ -f /etc/redhat-release ]; then
    install_rhel
else
    echo "Unsupported OS. Please install MongoDB manually."
    exit 1
fi

# Create directories
mkdir -p /var/lib/mongodb /var/log/mongodb /var/run/mongodb
chown -R mongodb:mongodb /var/lib/mongodb /var/log/mongodb /var/run/mongodb

# Backup original config
if [ -f /etc/mongod.conf ]; then
    cp /etc/mongod.conf /etc/mongod.conf.bak
fi

# First start WITHOUT auth to create admin user
cat > /etc/mongod.conf <<'EOF'
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log
net:
  port: 27017
  bindIp: 127.0.0.1
processManagement:
  timeZoneInfo: /usr/share/zoneinfo
  pidFilePath: /var/run/mongodb/mongod.pid
EOF

chown root:root /etc/mongod.conf
chmod 644 /etc/mongod.conf

# Enable and start (without auth first)
systemctl daemon-reload
systemctl enable mongod
systemctl start mongod

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to start..."
sleep 5

# Create admin user
echo "Creating admin user..."
mongosh --quiet <<EOF
use admin
db.createUser({
  user: "admin",
  pwd: "${MONGO_PASSWORD}",
  roles: [
    { role: "userAdminAnyDatabase", db: "admin" },
    { role: "readWriteAnyDatabase", db: "admin" },
    { role: "dbAdminAnyDatabase", db: "admin" },
    { role: "clusterAdmin", db: "admin" }
  ]
})
EOF

# Now apply full config with auth enabled and remote access
cp "${SCRIPT_DIR}/mongod.conf" /etc/mongod.conf
chown root:root /etc/mongod.conf
chmod 644 /etc/mongod.conf

# Restart with auth enabled
systemctl restart mongod

echo ""
echo "========================================"
echo "MongoDB ${MONGO_VERSION} installed!"
echo "========================================"
echo ""
echo "Service:  mongod"
echo "Config:   /etc/mongod.conf"
echo "Data:     /var/lib/mongodb"
echo "User:     admin"
echo "Password: ${MONGO_PASSWORD}"
echo ""
echo "Commands:"
echo "  systemctl status mongod"
echo "  systemctl restart mongod"
echo ""
echo "Connect:"
echo "  mongosh -u admin -p '${MONGO_PASSWORD}' --authenticationDatabase admin"
echo "  mongosh mongodb://admin:${MONGO_PASSWORD}@localhost:27017/admin"
echo ""
echo "Remote connection string:"
echo "  mongodb://admin:${MONGO_PASSWORD}@<server-ip>:27017/admin"
echo "========================================"
