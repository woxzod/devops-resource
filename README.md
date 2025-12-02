# DevOps Resource

A collection of production-ready DevOps scripts, configurations, and automation tools.

## Structure

```
├── docker/            # Docker Compose configurations
├── systemd/           # Native systemd services with install scripts
├── scripts/           # Automation scripts
├── kubernetes/        # K8s manifests and Helm charts
├── terraform/         # Infrastructure as Code
├── ansible/           # Ansible playbooks and roles
└── ci-cd/             # CI/CD pipeline configs
```

## Tools

### Monitoring & Observability

| Tool | Description | Docker | Systemd |
|------|-------------|--------|---------|
| Prometheus | Metrics storage & alerting | [docker/monitoring/](docker/monitoring/) | [systemd/prometheus/](systemd/prometheus/) |
| Grafana | Visualization & dashboards | [docker/monitoring/](docker/monitoring/) | [systemd/grafana/](systemd/grafana/) |
| Loki | Log aggregation system | [docker/monitoring/](docker/monitoring/) | [systemd/loki/](systemd/loki/) |
| Promtail | Log collector for Loki | [docker/monitoring/](docker/monitoring/) | [systemd/promtail/](systemd/promtail/) |
| Node Exporter | Host metrics exporter | [docker/monitoring/](docker/monitoring/) | [systemd/node-exporter/](systemd/node-exporter/) |
| cAdvisor | Container metrics exporter | [docker/monitoring/](docker/monitoring/) | [systemd/cadvisor/](systemd/cadvisor/) |

### Databases

| Tool | Description | Docker | Systemd |
|------|-------------|--------|---------|
| PostgreSQL | Relational database (latest version) | [docker/postgresql/](docker/postgresql/) | [systemd/postgresql/](systemd/postgresql/) |
| MongoDB | NoSQL document database | [docker/mongodb/](docker/mongodb/) | [systemd/mongodb/](systemd/mongodb/) |

### Storage

| Tool | Description | Docker | Systemd |
|------|-------------|--------|---------|
| MinIO | S3-compatible object storage | [docker/minio/](docker/minio/) | [systemd/minio/](systemd/minio/) |

## Quick Start

### Docker

```bash
# Full monitoring stack (Prometheus, Grafana, Loki, Promtail, Node Exporter, cAdvisor)
cd docker/monitoring && docker-compose up -d

# PostgreSQL
cd docker/postgresql && docker-compose up -d

# MongoDB
cd docker/mongodb && docker-compose up -d

# MinIO
cd docker/minio && docker-compose up -d
```

### Systemd (Native Install)

```bash
# Copy files to server
scp -r systemd/<service>/ user@server:~/

# Run installer
cd <service>
chmod +x install.sh
sudo ./install.sh
```

#### PostgreSQL Example

```bash
# Install latest PostgreSQL with custom password
sudo ./install.sh my_secure_password

# Connects from anywhere with password authentication
psql -h <server-ip> -U postgres -d postgres
```

#### MongoDB Example

```bash
# Install MongoDB 7.0
sudo ./install.sh 7.0
```

## Default Ports & Credentials

| Service | Port | Default Credentials |
|---------|------|---------------------|
| Grafana | 3000 | admin / admin |
| Prometheus | 9090 | - |
| Loki | 3100 | - |
| Promtail | 9080 | - |
| Node Exporter | 9100 | - |
| cAdvisor | 8080 | - |
| MinIO API | 9000 | minioadmin / minioadmin |
| MinIO Console | 9001 | minioadmin / minioadmin |
| PostgreSQL | 5432 | postgres / (set on install) |
| MongoDB | 27017 | (create after install) |

## Connection Strings

```bash
# PostgreSQL
postgresql://postgres:<password>@<host>:5432/postgres

# MongoDB
mongodb://admin:<password>@<host>:27017/admin

# MinIO (S3-compatible)
AWS_ENDPOINT=http://<host>:9000
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
```

## License

MIT
