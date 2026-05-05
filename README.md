# Streamvault Infra

Deployment artifacts for Streamvault — a self-hostable music and video streaming platform.
Supports local dev via Docker Compose and production deployments via Helm.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.20+
- [Helm](https://helm.sh/docs/intro/install/) 3.12+ (for Kubernetes deployments)

## Docker Compose

### Setup

```bash
cp .env.example .env
# Edit .env — fill in POSTGRES_PASSWORD, REDIS_PASSWORD, JWT_SECRET, KAFKA_CLUSTER_ID
```

Generate a Kafka cluster ID (required once per environment):

```bash
python3 -c "import uuid; print(uuid.uuid4())"
```

### Profiles

| Profile | Services | Command |
|---------|----------|---------|
| `standard` | Postgres, Kafka, Redis, Envoy, rustfs, Core, Pipeline | `docker compose --profile standard up -d` |
| `full` | Everything in standard + Prometheus + Grafana | `docker compose --profile full up -d` |

Kafka topics are created automatically on first boot via an init container. No manual steps required.

### Port reference

| Service | Host port | Notes |
|---------|-----------|-------|
| Envoy HTTP | 8080 | Main ingress — all app traffic |
| Envoy HTTPS | 8443 | TLS termination (cert not included) |
| rustfs | 9000 | |
| Prometheus | 9090 | `full` profile only |
| Grafana | 3000 | `full` profile only |


All other services (Postgres, Kafka, Redis, Core, Pipeline) are on the internal
`streamvault-net` network and not reachable from the host.

## Helm (Kubernetes)

### Install

```bash
helm install streamvault ./helm \
  --set sv.postgres.password=<secret> \
  --set sv.redis.password=<secret> \
```

### With observability

```bash
helm install streamvault ./helm \
  ... \
  --set sv.observability.enabled=true \
  --set sv.observability.grafana.adminPassword=<secret>
```

### Upgrade

```bash
helm upgrade streamvault ./helm -f my-values.yaml
```

Kafka topics are created automatically as a post-install/post-upgrade Job.


### pgAdmin 4

helm install pgadmin4 runix/pgadmin4 \
  --set env.email=admin@example.com \
  --set env.password=supersecret