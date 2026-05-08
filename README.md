# streamvault-infra

[![CI](https://github.com/streamvault-platform/infra/actions/workflows/ci.yml/badge.svg)](https://github.com/streamvault-platform/infra/actions/workflows/ci.yml)
![License](https://img.shields.io/badge/license-Apache%202.0-blue)

Deployment artifacts for [Streamvault](https://github.com/streamvault-platform) — Docker Compose for local/self-hosted, Helm for Kubernetes.

---

## Docker Compose

### Setup

```sh
cp .env.example .env
# Fill in: POSTGRES_PASSWORD, REDIS_PASSWORD, RUSTFS_SECRET_KEY, GF_SECURITY_ADMIN_PASSWORD
# Generate a Kafka cluster ID (required once):
python3 -c "import uuid; print(uuid.uuid4())"
# Add the output as KAFKA_CLUSTER_ID in .env
```

### Profiles

| Profile | Services | Command |
|---------|----------|---------|
| `standard` | Postgres, Kafka, Redis, RustFS, Envoy, Core, Pipeline | `docker compose --profile standard up -d` |
| `full` | Everything in standard + Prometheus, Grafana, Kafka UI | `docker compose --profile full up -d` |

Kafka topics and the RustFS bucket are created automatically on first boot via init containers.

### Port reference

| Service | Host port | Notes |
|---------|-----------|-------|
| Envoy HTTP | `8080` | Main ingress — all app traffic goes here |
| Envoy HTTPS | `8443` | TLS (cert not included) |
| RustFS | `9000` | S3 API |
| Kafka UI | `8090` | `full` profile only |
| Prometheus | `9090` | `full` profile only |
| Grafana | `3000` | `full` profile only |

All other services (Postgres, Kafka, Redis, Core, Pipeline) are on the internal `streamvault-net` network and not reachable from the host.

---

## Helm (Kubernetes)

### Install

```sh
helm install streamvault ./helm \
  --namespace streamvault --create-namespace \
  --set sv.postgres.password=<secret> \
  --set sv.redis.password=<secret> \
  --set sv.rustfs.secretKey=<secret>
```

### With observability

```sh
helm install streamvault ./helm \
  --namespace streamvault --create-namespace \
  --set sv.postgres.password=<secret> \
  --set sv.redis.password=<secret> \
  --set sv.rustfs.secretKey=<secret> \
  --set sv.observability.enabled=true \
  --set sv.observability.grafana.adminPassword=<secret> \
  --set sv.observability.kafkaUi.enabled=true
```

### Upgrade

```sh
helm upgrade streamvault ./helm -f my-values.yaml
```

### Local dev (Kubernetes)

```sh
# Build local images first, then:
./dev-deploy.sh
```

`dev-deploy.sh` overrides core and pipeline image tags to `local` with `imagePullPolicy: Never`.

---

## Image versions

| Service | Compose | Helm |
|---------|---------|------|
| Postgres | `18.3` | `18.3` |
| Kafka | `4.2.0` | `4.2.0` |
| Redis | `8.6.2-alpine` | `8.6.2-alpine` |
| Envoy | `v1.38.0` | `v1.38.0` |
| RustFS | `1.0.0-beta.1` | `1.0.0-beta.1` |
| Prometheus | `v3.11.3` | `v3.11.3` |
| Grafana | `13.0.1` | `13.0.1` |
| Kafka UI | `v0.7.2` | `v0.7.2` |

App images (`core`, `pipeline`) are versioned independently — see their respective repos.
