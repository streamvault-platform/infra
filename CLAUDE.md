# Streamvault Infra — Claude Instructions

## Project
Deployment artifacts for Streamvault — self-hostable music streaming platform.
No application code lives here. Everything here is infra/config only.

For platform-wide context and service descriptions, see the root CLAUDE.md.

## What lives here
```
docker-compose.yml          ← standard + full profile services
docker-compose.override.yml ← full-profile-only services (Prometheus, Grafana, Kafka UI)
envoy/                      ← static Envoy config
helm/                       ← Helm chart (chart API v2, values.yaml documented with comments)
prometheus/                 ← scrape configs
kafka-topics.sh             ← topic init script (run by kafka-init container on first boot)
dev-deploy.sh               ← local Kubernetes deploy via Helm (uses local image tags)
```

## Docker Compose profiles

| Profile | Services |
|---------|----------|
| `standard` | Postgres 18.3, Kafka 4.2.0 (KRaft), Redis 8.6.2, RustFS 1.0.0-beta.1, Envoy 1.38.0, Core, Pipeline |
| `full` | Everything in standard + Prometheus v3.11.3, Grafana 13.0.1, Kafka UI v0.7.2 |

Init containers (run once, `restart: "no"`): `kafka-init` (creates topics), `rustfs-init` (creates bucket), `jwt-init` (generates RSA key pair).

## Stack constraints
- Kafka: KRaft mode only. No Zookeeper. `apache/kafka` official image.
- PostgreSQL: version 18.x. One named volume per service schema.
- Envoy: static config (`envoy.yaml`). No xDS or dynamic config.
- Helm: chart API version v2. All values documented with `# --` comments.
- All secrets via environment variables. No hardcoded credentials anywhere.
- Health checks on every Docker Compose service.
- Always pin image versions — never use `latest`.

## Envoy role
Edge gateway only — not a service mesh. Routes:
- `/api/*` → `streamvault-core:8080`
- `/stream/*` → `streamvault-core:8080`
- `/ws/*` → `streamvault-core:8080` (WebSocket upgrade)

No sidecar proxies. No mTLS between internal services.

## Naming conventions
- Docker Compose services: `streamvault-<component>` (e.g. `streamvault-core`, `streamvault-kafka`)
- Helm values prefix: `sv.*`
- Image org: `ghcr.io/streamvault-platform/<service>:<version>`

## Do NOT
- Add application code or business logic
- Use Docker Swarm syntax
- Use Zookeeper for Kafka
- Hardcode ports other than the documented defaults (core: 8080, envoy: 8080/8443)
- Use `latest` image tags — always pin versions
- Change Helm values prefix from `sv.*`
