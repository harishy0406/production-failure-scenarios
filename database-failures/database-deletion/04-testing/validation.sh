#!/usr/bin/env bash
# Validation script: confirms connectivity, table schemas, and data record counts
set -euo pipefail

CONTAINER="scenario-pg-deletion"
DB_NAME="production_db"

echo "=== [1/4] Checking Cluster & Database Connectivity ==="
docker exec "$CONTAINER" pg_isready -U postgres -d "$DB_NAME"

echo "=== [2/4] Verifying Table Schemas ==="
TABLE_COUNT=$(docker exec "$CONTAINER" psql -U postgres -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';")
echo "Found $TABLE_COUNT public tables."
if [ "$TABLE_COUNT" -lt 2 ]; then
    echo "[FAIL] Expected at least 2 tables (customers, orders)."
    exit 1
fi

echo "=== [3/4] Verifying Data Row Counts ==="
CUSTOMER_COUNT=$(docker exec "$CONTAINER" psql -U postgres -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM customers;" | tr -d '[:space:]')
ORDER_COUNT=$(docker exec "$CONTAINER" psql -U postgres -d "$DB_NAME" -t -c "SELECT COUNT(*) FROM orders;" | tr -d '[:space:]')

echo "Customers count: $CUSTOMER_COUNT (expected >= 3)"
echo "Orders count: $ORDER_COUNT (expected >= 4)"

if [ "$CUSTOMER_COUNT" -lt 3 ] || [ "$ORDER_COUNT" -lt 4 ]; then
    echo "[FAIL] Data row counts do not match pre-failure baseline!"
    exit 1
fi

echo "=== [4/4] Canary Read/Write Check ==="
docker exec "$CONTAINER" psql -U postgres -d "$DB_NAME" -c "INSERT INTO customers (name, email) VALUES ('Canary Check', 'canary@test.local');"
docker exec "$CONTAINER" psql -U postgres -d "$DB_NAME" -c "DELETE FROM customers WHERE email='canary@test.local';"

echo "=== [ALL PASS] Database recovery and data integrity verified! ==="
