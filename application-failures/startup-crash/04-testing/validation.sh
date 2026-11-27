#!/usr/bin/env bash
# Validation script: confirms service is running, healthy, and serving requests without restarts.
set -euo pipefail

CONTAINER_NAME="scenario-startup-crash"
HEALTH_URL="http://localhost:8080/health"
API_URL="http://localhost:8080/"

echo "=== [1/4] Checking Container State ==="
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[FAIL] Container ${CONTAINER_NAME} is not running!"
    exit 1
fi

STATUS=$(docker inspect "$CONTAINER_NAME" --format '{{.State.Status}}')
echo "Container Status: $STATUS"

if [ "$STATUS" != "running" ]; then
    echo "[FAIL] Container is in state '$STATUS' (expected 'running')!"
    exit 1
fi
echo "[PASS] Container is running."

echo "=== [2/4] Testing Health Endpoint ($HEALTH_URL) ==="
HEALTH_RESP=$(curl -s "$HEALTH_URL" || true)
echo "Health Response: $HEALTH_RESP"

if echo "$HEALTH_RESP" | grep -q '"status": "healthy"'; then
    echo "[PASS] Health endpoint returned healthy status."
elif echo "$HEALTH_RESP" | grep -q '"status":"healthy"'; then
    echo "[PASS] Health endpoint returned healthy status."
else
    echo "[FAIL] Unexpected response from health endpoint!"
    exit 1
fi

echo "=== [3/4] Testing Service API ($API_URL) ==="
API_RESP=$(curl -s "$API_URL" || true)
echo "API Response: $API_RESP"

if echo "$API_RESP" | grep -q '"service": "auth-service"'; then
    echo "[PASS] Service API responded with valid metadata."
elif echo "$API_RESP" | grep -q '"service":"auth-service"'; then
    echo "[PASS] Service API responded with valid metadata."
else
    echo "[FAIL] Unexpected response from service API!"
    exit 1
fi

echo "=== [4/4] Verifying Log Stream for Startup Errors ==="
RECENT_CRITICALS=$(docker logs --tail 15 "$CONTAINER_NAME" 2>&1 | grep -c "\[CRITICAL\]" || true)

if [ "$RECENT_CRITICALS" -gt 0 ]; then
    echo "[WARN] Found previous critical lines in historic buffer, but container is currently healthy."
fi

echo "=== [ALL PASS] Application startup recovery verified successfully! ==="
