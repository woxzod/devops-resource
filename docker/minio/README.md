# MinIO Configuration

MinIO is configured via environment variables in docker-compose.yml.

## Default Credentials

- **User:** minioadmin
- **Password:** minioadmin

## Ports

- **API:** 9000
- **Console:** 9001

## Usage

Access the MinIO console at http://localhost:9001

## Integration with Loki

To use MinIO as backend storage for Loki, update loki.yml:

```yaml
storage_config:
  aws:
    s3: http://minioadmin:minioadmin@minio:9000/loki
    s3forcepathstyle: true
```
