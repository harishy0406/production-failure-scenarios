#!/usr/bin/env bash
# Failure Injection: Accidental DROP DATABASE execution
set -euo pipefail

CONTAINER_NAME="scenario-pg-deletion"

echo "=== [WARNING] Simulating Accidental Database Deletion ==="

# Assert container is active
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: ${CONTAINER_NAME} is not running. Execute setup.sh first."
    exit 1
fi

echo "Injecting failure: DROP DATABASE production_db; (Simulating operator error)..."
docker exec -i "$CONTAINER_NAME" psql -U postgres -c "DROP DATABASE production_db;"

echo "Verifying failure state..."
if docker exec "$CONTAINER_NAME" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "production_db"; then
    echo "Unexpected: Database still exists!"
    exit 1
else
    echo "=== [INCIDENT CONFIRMED] production_db has been dropped. Outage is active. ==="
fi
