# Streamvault Infra

Local development infrastructure for Streamvault — a self-hostable music and video streaming platform.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) 24+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.20+

## Setup

```bash
cp .env.example .env
# Edit .env — at minimum set POSTGRES_PASSWORD, REDIS_PASSWORD, JWT_SECRET, KAFKA_CLUSTER_ID
```

Generate a Kafka cluster ID (required once):

```bash
docker run --rm bitnami/kafka:3.7.1 kafka-storage.sh random-uuid
```

## Starting the stack

| Profile | Services | Command |
|---------|----------|---------|
| `minimal` | PostgreSQL only | `docker compose --profile minimal up -d` |
| `standard` | + Kafka, Redis | `docker compose --profile standard up -d` |
| `full` | + Envoy, Core, Pipeline | `docker compose --profile full up -d` |

With observability (Prometheus + Grafana):

```bash
docker compose -f docker-compose.yml -f docker-compose.override.yml --profile full up -d
```

## Creating Kafka topics

Run once after first boot with the `standard` or `full` profile:

```bash
docker compose exec streamvault-kafka bash /infra/kafka-topics.sh
```

Or from the host (requires Kafka CLI on PATH):

```bash
KAFKA_BOOTSTRAP_SERVERS=localhost:9092 bash kafka-topics.sh
```

## Port reference

| Service | Host port | Notes |
|---------|-----------|-------|
| Envoy HTTP | 8080 | Main ingress — all app traffic goes here |
| Envoy HTTPS | 8443 | TLS termination (cert not included) |
| Envoy admin | — | Internal only (9901) |
| Prometheus | 9090 | Override only |
| Grafana | 3000 | Override only |

All other services (Postgres, Kafka, Redis, Core, Pipeline) are on the internal
`streamvault-net` network only and not reachable from the host.
