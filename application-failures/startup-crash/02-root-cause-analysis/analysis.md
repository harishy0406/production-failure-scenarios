# Root Cause Analysis: Application Crash on Startup

## 1. Incident Overview
- **Incident Description:** Authentication service enters CrashLoopBackOff with Exit Code 1.
- **Root Cause Classification:** Unhandled initialization exception caused by missing mandatory environment configuration (`DATABASE_URL`).

## 2. Forensic Investigation & Evidence

### Step 1: Check Container Status and Exit Code
Run docker inspection to capture the process termination details:
```bash
docker inspect scenario-startup-crash --format 'Status: {{.State.Status}} | ExitCode: {{.State.ExitCode}} | Error: {{.State.Error}}'
```

Sample output:
```text
Status: restarting | ExitCode: 1 | Error: 
```

### Step 2: Extract Crash Logs & Stack Trace
Read the standard error output produced immediately before the process died:
```bash
docker logs --tail 30 scenario-startup-crash
```

Sample output:
```text
[2026-11-27T10:15:02Z] [INFO] Initializing authentication service v2.4.0...
[2026-11-27T10:15:02Z] [ERROR] Configuration validation failed!
Traceback (most recent call last):
  File "/app/app.py", line 22, in <module>
    raise KeyError(f"Missing required environment variable: '{var}'")
KeyError: "Missing required environment variable: 'DATABASE_URL'"
```

### Step 3: Compare Active Environment against Schema
Inspect environment variables passed into the container:
```bash
docker exec scenario-startup-crash env 2>/dev/null || docker inspect scenario-startup-crash --format '{{range .Config.Env}}{{println .}}{{end}}'
```

Notice that `DATABASE_URL` is absent, while other variables like `PORT=8080` and `APP_ENV=production` are present.

## 3. Contributing Factors
1. Deployment automation did not perform an environment variable dry-run before replacing the healthy container.
2. The application failed fast during initialization (which is good practice), but no canary deployment or rollback gate was configured.
