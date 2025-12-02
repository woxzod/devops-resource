# Monitoring Stack

Complete observability stack with metrics, logs, and visualization.

## Components

| Service | Port | Description |
|---------|------|-------------|
| cAdvisor | 8080 | Container metrics |
| Node Exporter | 9100 | Host metrics |
| Prometheus | 9090 | Metrics storage & querying |
| Promtail | - | Log collector |
| Loki | 3100 | Log storage |
| Grafana | 3000 | Visualization |

## Quick Start

```bash
docker-compose up -d
```

## Access

- **Grafana:** http://localhost:3000 (admin/admin)
- **Prometheus:** http://localhost:9090

## Architecture

```
┌─────────────┐     ┌─────────────┐
│  cAdvisor   │────▶│             │
└─────────────┘     │             │
                    │  Prometheus │────▶┌─────────────┐
┌─────────────┐     │             │     │             │
│Node Exporter│────▶│             │     │   Grafana   │
└─────────────┘     └─────────────┘     │             │
                                        │             │
┌─────────────┐     ┌─────────────┐     │             │
│  Promtail   │────▶│    Loki     │────▶│             │
└─────────────┘     └─────────────┘     └─────────────┘
```

## Configuration Files

- `prometheus/prometheus.yml` - Prometheus scrape config
- `prometheus/alerts.yml` - Alert rules
- `promtail/promtail.yml` - Log collection config
- `loki/loki.yml` - Loki storage config
- `grafana/provisioning/` - Grafana auto-provisioning
