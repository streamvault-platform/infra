---
name: bump-helm-image-versions
description: Checks pinned Docker image tags in helm/values.yaml for newer patch/minor releases and opens a PR if updates are found.
---

Check whether any pinned Docker image tags in `helm/values.yaml` have newer patch or minor releases available on Docker Hub.

Images to check (field path → current tag):
- `sv.postgres.image.tag` = `"16.13"` — newer `16.x` patch releases
- `sv.kafka.image.tag` = `"3.7.2"` — newer `3.7.x` patch releases (repository: `apache/kafka`)
- `sv.redis.image.tag` = `"7.2.13-alpine"` — newer `7.2.x-alpine` releases
- `sv.envoy.image.tag` = `"v1.29.12"` — newer `v1.29.x` releases only (do NOT bump to v1.30+)
- `sv.observability.prometheus.image.tag` = `"v2.55.1"` — newer `v2.x.x` releases (repository: `prom/prometheus`)
- `sv.observability.grafana.image.tag` = `"11.6.14"` — newer `11.x.x` releases (repository: `grafana/grafana`)

Do NOT check `sv.core.image.tag` or `sv.pipeline.image.tag` — those are app images versioned separately.
Do NOT suggest major version bumps — only patch and minor updates.

For each image, use the Docker Hub API (`https://hub.docker.com/v2/repositories/<repo>/tags?page_size=100`) to find the latest applicable version.

If any updates are found:
1. Create a new branch `chore/bump-helm-image-versions-<YYYY-MM-DD>`
2. Update the tags in `helm/values.yaml`
3. Update the version references in `.claude/agents/bump-helm-image-versions.md` to match the new tags
4. Open a PR titled `chore: bump Helm image versions (<date>)` with a table listing old vs new tag for each changed image into develop branch (never main)

If nothing needs updating, report "All Helm image tags are up to date."
