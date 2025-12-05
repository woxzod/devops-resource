#!/bin/bash
# HashiCorp Vault Installation Script for Rocky Linux 9
# Author: DevOps Team
# Date: December 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== HashiCorp Vault Installation Script ===${NC}"

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')
echo -e "${YELLOW}Detected server IP: ${SERVER_IP}${NC}"

# Step 1: Install dnf plugins and add HashiCorp repo
echo -e "${GREEN}[1/7] Adding HashiCorp repository...${NC}"
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Step 2: Install Vault
echo -e "${GREEN}[2/7] Installing Vault...${NC}"
sudo dnf install -y vault

# Step 3: Create directories
echo -e "${GREEN}[3/7] Creating directories...${NC}"
sudo mkdir -p /etc/vault.d
sudo mkdir -p /opt/vault/data
sudo mkdir -p /opt/vault/tls

# Step 4: Generate TLS certificate with proper SANs
echo -e "${GREEN}[4/7] Generating TLS certificates...${NC}"
sudo openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /opt/vault/tls/tls.key \
  -out /opt/vault/tls/tls.crt \
  -subj "/CN=vault" \
  -addext "subjectAltName=IP:${SERVER_IP},IP:127.0.0.1,DNS:localhost,DNS:$(hostname)"

# Step 5: Create Vault configuration
echo -e "${GREEN}[5/7] Creating Vault configuration...${NC}"
sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
# Vault Configuration

ui = true

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}

api_addr = "https://${SERVER_IP}:8200"
cluster_addr = "https://${SERVER_IP}:8201"
EOF

# Step 6: Set permissions
echo -e "${GREEN}[6/7] Setting permissions...${NC}"
sudo chown -R vault:vault /opt/vault
sudo chmod 750 /opt/vault/data
sudo chmod 750 /opt/vault/tls
sudo chmod 640 /opt/vault/tls/tls.key
sudo chmod 644 /opt/vault/tls/tls.crt

# Step 7: Enable and start Vault
echo -e "${GREEN}[7/7] Starting Vault service...${NC}"
sudo systemctl enable vault
sudo systemctl start vault

# Wait for Vault to start
sleep 3

# Check status
if sudo systemctl is-active --quiet vault; then
    echo -e "${GREEN}=== Vault installed successfully! ===${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Set environment variables:"
    echo "   export VAULT_ADDR='https://${SERVER_IP}:8200'"
    echo "   export VAULT_SKIP_VERIFY=true"
    echo ""
    echo "2. Initialize Vault:"
    echo "   vault operator init"
    echo ""
    echo "3. Unseal Vault (run 3 times with different keys):"
    echo "   vault operator unseal <key>"
    echo ""
    echo "4. Login with root token:"
    echo "   vault login <root-token>"
    echo ""
    echo "5. Enable KV secrets engine:"
    echo "   vault secrets enable -path=secret kv-v2"
    echo ""
    echo -e "${RED}IMPORTANT: Save your unseal keys and root token securely!${NC}"
else
    echo -e "${RED}Vault failed to start. Check logs:${NC}"
    echo "sudo journalctl -u vault --no-pager -n 50"
    exit 1
fi