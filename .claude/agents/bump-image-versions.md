---
name: bump-image-versions
description: Checks pinned Docker image versions in docker-compose.yml and docker-compose.override.yml for newer patch/minor releases and opens a PR if updates are found.
---

Check whether any pinned Docker image versions in `docker-compose.yml` and `docker-compose.override.yml` have newer patch or minor releases available on Docker Hub.

Images to check:
- `postgres:16` — newer `16.x` patch releases
- `apache/kafka:3.7.1` — newer `3.7.x` patch releases
- `redis:7.2-alpine` — newer `7.2.x-alpine` releases
- `envoyproxy/envoy:v1.29.4` — newer `v1.29.x` or `v1.30.x` releases
- `prom/prometheus:v2.52.0` — newer `v2.x.x` releases
- `grafana/grafana:11.0.0` — newer `11.x.x` releases

For each image, use the Docker Hub API (`https://hub.docker.com/v2/repositories/<image>/tags?page_size=100`) to find the latest patch within the current minor, and the latest minor within the current major. Do NOT suggest major version bumps (e.g. postgres:17) — only patch and minor updates.

If any updates are found:
1. Create a new branch `chore/bump-image-versions-<YYYY-MM-DD>`
2. Update the pinned tags in `docker-compose.yml` and `docker-compose.override.yml`
3. Open a PR titled `chore: bump Docker image versions (<date>)` with a table listing old vs new version for each changed image

If nothing needs updating, report "All images are up to date."
