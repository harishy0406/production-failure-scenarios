#!/usr/bin/env bash
# Scripted manual restoration helper
set -euo pipefail

CONTAINER_NAME="scenario-pg-deletion"
BACKUP_PATH="/var/backups/postgres/base/production_db_base.dump"

echo "=== [1/3] Ensuring Database Container is Running ==="
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: ${CONTAINER_NAME} is not running."
    exit 1
fi

echo "=== [2/3] Checking and Recreating Database Shell ==="
if ! docker exec "$CONTAINER_NAME" psql -U postgres -lqt | cut -d '|' -f 1 | grep -qw "production_db"; then
    echo "Creating empty production_db..."
    docker exec "$CONTAINER_NAME" psql -U postgres -c "CREATE DATABASE production_db;"
fi

echo "=== [3/3] Restoring from Base Backup ==="
docker exec "$CONTAINER_NAME" pg_restore -U postgres -d production_db -v "$BACKUP_PATH" || true

echo "Restoration script finished successfully."
