# Systemd Services

Native systemd service files for running monitoring tools without Docker.

## Components

| Service | Port | Install Script |
|---------|------|----------------|
| cAdvisor | 8080 | Docker-based (no binary) |
| Node Exporter | 9100 | `node-exporter/install.sh` |
| Prometheus | 9090 | `prometheus/install.sh` |
| Promtail | - | `promtail/install.sh` |
| Loki | 3100 | `loki/install.sh` |
| Grafana | 3000 | `grafana/install.sh` |
| MinIO | 9000/9001 | `minio/install.sh` |

## Installation

Each directory contains:
- `*.service` - Systemd unit file
- `install.sh` - Installation script
- Config files (where applicable)

### Example: Install Node Exporter

```bash
cd node-exporter
chmod +x install.sh
sudo ./install.sh 1.7.0  # version is optional
```

## Service Management

```bash
# Start/Stop/Restart
sudo systemctl start node-exporter
sudo systemctl stop node-exporter
sudo systemctl restart node-exporter

# Enable/Disable on boot
sudo systemctl enable node-exporter
sudo systemctl disable node-exporter

# Check status
sudo systemctl status node-exporter

# View logs
sudo journalctl -u node-exporter -f
```

## Configuration Paths

| Service | Config Location |
|---------|-----------------|
| Prometheus | `/etc/prometheus/prometheus.yml` |
| Promtail | `/etc/promtail/promtail.yml` |
| Loki | `/etc/loki/loki.yml` |
| Grafana | `/etc/grafana/grafana.ini` |
| MinIO | `/etc/default/minio` |

## Data Paths

| Service | Data Location |
|---------|---------------|
| Prometheus | `/var/lib/prometheus` |
| Loki | `/var/lib/loki` |
| Grafana | `/var/lib/grafana` |
| MinIO | `/data/minio` |
