---
name: bump-helm-image-versions
description: Checks pinned Docker image tags in helm/values.yaml for newer patch/minor releases and opens a PR if updates are found.
---

Check whether any pinned Docker image tags in `helm/values.yaml` have newer patch or minor releases available on Docker Hub.

Images to check (field path → current tag):
- `sv.postgres.image.tag` = `"18.3"` — newer `18.x` patch releases
- `sv.kafka.image.tag` = `"4.2.0"` — newer `4.2.x` patch releases (repository: `apache/kafka`)
- `sv.redis.image.tag` = `"8.6.2-alpine"` — newer `8.6.x-alpine` releases
- `sv.envoy.image.tag` = `"v1.38.0"` — newer `v1.38.x` releases only (do NOT bump to v1.39+)
- `sv.observability.prometheus.image.tag` = `"v3.11.3"` — newer `v3.x.x` releases (repository: `prom/prometheus`)
- `sv.observability.grafana.image.tag` = `"13.0.1"` — newer `13.x.x` releases (repository: `grafana/grafana`)

Do NOT check `sv.core.image.tag` or `sv.pipeline.image.tag` — those are app images versioned separately.
Do NOT suggest major version bumps — only patch and minor updates.

For each image, use the Docker Hub API (`https://hub.docker.com/v2/repositories/<repo>/tags?page_size=100`) to find the latest applicable version.

If any updates are found:
1. Create a new branch `chore/bump-helm-image-versions-<YYYY-MM-DD>`
2. Update the tags in `helm/values.yaml`
3. Update the version references in `.claude/agents/bump-helm-image-versions.md` to match the new tags
4. Open a PR titled `chore: bump Helm image versions (<date>)` with a table listing old vs new tag for each changed image into develop branch (never main)

If nothing needs updating, report "All Helm image tags are up to date."
