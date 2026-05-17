#!/usr/bin/env bash
set -euo pipefail

helm uninstall streamvault --namespace streamvault 2>/dev/null || true

(cd ../pipeline && sbt assembly)
docker build -t streamvault-pipeline:local ../pipeline

../core/mvnw -f ../core/pom.xml clean package -DskipTests
docker build -t streamvault-core:local -f ../core/src/main/docker/Dockerfile.jvm ../core

helm install streamvault ./helm --namespace streamvault --create-namespace \
  --set sv.core.image.repository=streamvault-core \
  --set sv.core.image.tag=local \
  --set sv.core.image.pullPolicy=Never \
  --set sv.pipeline.image.repository=streamvault-pipeline \
  --set sv.pipeline.image.tag=local \
  --set sv.pipeline.image.pullPolicy=Never \
  --set sv.core.storageBackend=filesystem \
  --set sv.core.mediaStorage=20Gi \
  --set sv.observability.kafkaUi.enabled=true