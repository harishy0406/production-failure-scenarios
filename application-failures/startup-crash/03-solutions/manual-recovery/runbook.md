# Manual Recovery Runbook: Application Startup Crash

**Target Service:** Authentication API (`scenario-startup-crash`)  
**Target Port:** 8080 (HTTP)  
**Required Tools:** `docker`, `curl`, `diff`

---

## Step 1: Diagnose the Crash Reason
Check why the container is restarting:
```bash
docker logs --tail 25 scenario-startup-crash
```
Look for lines beginning with `[CRITICAL]` or unhandled exception traces. Notice the missing variable:
```text
KeyError: "Missing required environment variable: 'DATABASE_URL'"
```

---

## Step 2: Compare Environment Files
Inspect which keys are missing compared to the reference template:
```bash
diff 01-simulation/.env 01-simulation/config.example.env
```

---

## Step 3: Patch Configuration
Add the missing `DATABASE_URL` entry back into `01-simulation/.env`:
```bash
echo "DATABASE_URL=postgres://appuser:securepassword@db:5432/production_db" >> 01-simulation/.env
```

---

## Step 4: Restart the Service
Recreate the container with the corrected environment:
```bash
cd 01-simulation
docker compose up -d --force-recreate
```

---

## Step 5: Verify Health
Confirm the container remains in running state and returns HTTP 200:
```bash
# Check container state
docker ps --filter "name=scenario-startup-crash"

# Check health endpoint
curl -i http://localhost:8080/health
```

Proceed to run `./04-testing/validation.sh` to confirm full recovery.
