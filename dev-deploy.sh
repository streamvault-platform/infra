#!/usr/bin/env bash
set -euo pipefail

docker build -t streamvault-core:local -f ../core/src/main/docker/Dockerfile.jvm ../core
docker build -t streamvault-pipeline:local ../pipeline

helm upgrade --install streamvault ./helm -f helm/values.dev.yaml
