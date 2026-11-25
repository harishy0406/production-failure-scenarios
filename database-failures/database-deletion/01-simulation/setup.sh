#!/usr/bin/env bash
# Sandbox Setup: spins up PostgreSQL container, verifies initial data, and generates initial base backup.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== [1/3] Starting Isolated PostgreSQL Sandbox ==="
docker compose up -d

echo "=== [2/3] Waiting for PostgreSQL readiness ==="
until docker exec scenario-pg-deletion pg_isready -U postgres -d production_db >/dev/null 2>&1; do
    echo "Waiting for database cluster to initialize..."
    sleep 2
done

echo "=== [3/3] Creating Initial Production Base Backup ==="
docker exec scenario-pg-deletion mkdir -p /var/backups/postgres/base
docker exec scenario-pg-deletion pg_dump -U postgres -d production_db -F c -f /var/backups/postgres/base/production_db_base.dump

echo "Setup completed successfully. Simulation sandbox is ready."
