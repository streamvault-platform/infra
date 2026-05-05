# Streamvault Infra — Claude Instructions

## Project
Deployment artifacts for Streamvault — a self-hostable music/video streaming platform.
All infrastructure is defined here. No application code lives in this repo.

## What lives here
- docker-compose.yml (local dev + self-hosted Docker deployments)
- envoy/              (Envoy proxy config)
- helm/               (Helm chart for Kubernetes)
- prometheus/         (scrape configs)
- grafana/            (dashboard JSON exports)

## Docker Compose profiles
- `standard` — PostgreSQL 16, Kafka (KRaft, no Zookeeper), Redis, Envoy, core app, pipeline app
- `full`     — everything in standard + Prometheus + Grafana

## Stack constraints
- Kafka: KRaft mode only. No Zookeeper. apache/kafka image (official Apache image).
- PostgreSQL: version 16. One named volume per service schema.
- Envoy: static config (envoy.yaml). No xDS/dynamic config.
- Helm: chart API version v2. Values must be documented with comments.
- rustfs: S3 compatible in-cluster storage
- All secrets via environment variables. No hardcoded credentials anywhere.
- Health checks on every Docker Compose service.

## Envoy role
Edge gateway only — NOT a service mesh.
Routes:
  /api/*     → streamvault-core:8080
  /stream/*  → streamvault-core:8080
  /ws/*      → streamvault-core:8080 (WebSocket upgrade)
No sidecar proxies. No mTLS between internal services.

## Naming conventions
- Docker services: streamvault-core, streamvault-pipeline, streamvault-postgres,
  streamvault-kafka, streamvault-redis, streamvault-envoy
- Helm values prefix: sv.*

## Do NOT
- Add application code or business logic
- Use Docker Swarm syntax
- Use Zookeeper for Kafka
- Hardcode ports other than the documented defaults (core: 8080, envoy: 8443/8080)
- Use latest image tags — always pin versions