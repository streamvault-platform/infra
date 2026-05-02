---
name: bump-image-versions
description: Checks pinned Docker image versions in docker-compose.yml and docker-compose.override.yml for newer patch/minor releases and opens a PR if updates are found.
---

Check whether any pinned Docker image versions in `docker-compose.yml` and `docker-compose.override.yml` have newer patch or minor releases available on Docker Hub.

Images to check:
- `postgres:18.3` — newer `18.x` patch releases
- `apache/kafka:4.2.0` — newer `4.2.x` patch releases
- `redis:8.6.2-alpine` — newer `8.6.x-alpine` releases
- `envoyproxy/envoy:v1.38.0` — newer `v1.38.x` releases only (do NOT bump to v1.39+)
- `prom/prometheus:v3.11.3` — newer `v3.x.x` releases
- `grafana/grafana:13.0.1` — newer `13.x.x` releases

For each image, use the Docker Hub API (`https://hub.docker.com/v2/repositories/<image>/tags?page_size=100`) to find the latest patch within the current minor, and the latest minor within the current major. Do NOT suggest major version bumps (e.g. postgres:17) — only patch and minor updates.

If any updates are found:
1. Create a new branch `chore/bump-image-versions-<YYYY-MM-DD>`
2. Update the pinned tags in `docker-compose.yml` and `docker-compose.override.yml`
3. Update the version references in `.claude/agents/bump-image-versions.md` to match the new tags
4. Open a PR titled `chore: bump Docker image versions (<date>)` with a table listing old vs new version for each changed image, into develop branch (never main)

If nothing needs updating, report "All images are up to date."
