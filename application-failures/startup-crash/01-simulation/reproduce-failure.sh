#!/usr/bin/env bash
# Failure injection: simulates deploying a broken environment configuration missing DATABASE_URL.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CONTAINER_NAME="scenario-startup-crash"

echo "=== [WARNING] Simulating Bad Configuration Deployment ==="

# Assert container is active
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container ${CONTAINER_NAME} is not running. Execute setup.sh first."
    exit 1
fi

echo "Writing bad configuration (omitting mandatory DATABASE_URL)..."
cat << 'EOF' > .env
PORT=8080
APP_ENV=production
# DATABASE_URL is missing!
JWT_SECRET=production-secret-token-key-2026
EOF

echo "Restarting service to apply deployment..."
docker compose up -d --force-recreate

echo "Waiting for container startup attempt..."
sleep 3

echo "Inspecting container state..."
docker inspect "$CONTAINER_NAME" --format 'Status: {{.State.Status}} | ExitCode: {{.State.ExitCode}}'

echo "Recent crash log snippet:"
docker logs --tail 5 "$CONTAINER_NAME" || true

echo "=== [INCIDENT CONFIRMED] Service is in crash loop. Outage is active. ==="
