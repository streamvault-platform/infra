#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE="docker compose --profile standard \
  -f ${SCRIPT_DIR}/docker-compose.yml \
  -f ${SCRIPT_DIR}/docker-compose.override.yml \
  -f ${SCRIPT_DIR}/docker-compose.debug.yml"

if [ ! -f "${SCRIPT_DIR}/.env" ]; then
  cp "${SCRIPT_DIR}/.env.debug.example" "${SCRIPT_DIR}/.env"
  echo ".env created from .env.debug.example — fill in secrets before re-running."
  exit 1
fi

(cd "${SCRIPT_DIR}/../pipeline" && sbt assembly)
docker build -t streamvault-pipeline:local "${SCRIPT_DIR}/../pipeline"

"${SCRIPT_DIR}/../core/mvnw" -f "${SCRIPT_DIR}/../core/pom.xml" package -DskipTests
docker build -t streamvault-core:local \
  -f "${SCRIPT_DIR}/../core/src/main/docker/Dockerfile.jvm" \
  "${SCRIPT_DIR}/../core"

docker build -t streamvault-web:local "${SCRIPT_DIR}/../web"

$COMPOSE down --remove-orphans
$COMPOSE up -d
