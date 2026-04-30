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
| `standard` | Postgres, Kafka, Redis, Envoy, Core, Pipeline | `docker compose --profile standard up -d` |
| `full` | Everything in standard + Prometheus + Grafana | `docker compose --profile full up -d` |

### Creating Kafka topics

Run once after the first `standard` or `full` boot:

```bash
docker compose exec streamvault-kafka bash /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create ...
# Or use the bundled script:
docker compose exec streamvault-kafka bash -c \
  "KAFKA_BOOTSTRAP_SERVERS=localhost:9092 bash /scripts/create-topics.sh"
```

From the host (requires Kafka CLI on PATH):

```bash
KAFKA_BOOTSTRAP_SERVERS=localhost:9092 bash kafka-topics.sh
```

### Port reference

| Service | Host port | Notes |
|---------|-----------|-------|
| Envoy HTTP | 8080 | Main ingress — all app traffic |
| Envoy HTTPS | 8443 | TLS termination (cert not included) |
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
  --set sv.core.jwtSecret=<secret> \
  --set sv.kafka.clusterId=$(python3 -c "import uuid; print(uuid.uuid4())")
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
