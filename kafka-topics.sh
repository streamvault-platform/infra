#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP="${KAFKA_BOOTSTRAP_SERVERS:-streamvault-kafka:9092}"
REPLICATION=1

topics=(
  "media.uploaded:3"
  "media.transcoded:3"
  "media.metadata-ready:3"
  "watch.sync-requested:3"
  "watch.sync-ready:3"
  "scrobble.events:6"
)

echo "Waiting for Kafka at ${BOOTSTRAP}..."
until /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server "${BOOTSTRAP}" &>/dev/null; do
  sleep 2
done
echo "Kafka is ready."

for entry in "${topics[@]}"; do
  topic="${entry%%:*}"
  partitions="${entry##*:}"

  if /opt/kafka/bin/kafka-topics.sh --bootstrap-server "${BOOTSTRAP}" --list | grep -qx "${topic}"; then
    echo "Topic already exists: ${topic}"
  else
    /opt/kafka/bin/kafka-topics.sh \
      --bootstrap-server "${BOOTSTRAP}" \
      --create \
      --topic "${topic}" \
      --partitions "${partitions}" \
      --replication-factor "${REPLICATION}"
    echo "Created: ${topic} (partitions=${partitions}, replication=${REPLICATION})"
  fi
done

echo "All topics ready."
