# Detailed Scenario Narrative: Application Startup Crash

## Context
At 10:15 UTC, the deployment pipeline rolled out version v2.4.0 of the user authentication service. Immediately following rollout, the container orchestration platform detected failing readiness probes.

Load balancers routing to the service began returning HTTP 502 Bad Gateway errors. Within 60 seconds, error rate alarms triggered across all dependent frontend gateways.

When inspecting the container fleet:
```text
CONTAINER ID   IMAGE                COMMAND                  STATUS                          PORTS
a1b2c3d4e5f6   auth-service:v2.4.0  "python -u app.py"       Restarting (1) 3 seconds ago
```

## Why It Happens in Production
1. **Missing Release Variables:** A developer added a new mandatory dependency (e.g. `DATABASE_URL` or `JWT_SECRET`) in code, but the CI/CD secret manager was not updated prior to trigger.
2. **Naming Mismatch:** The code expects `DATABASE_URL` while Helm/Terraform injected `DB_CONNECTION_STRING`.
3. **Lack of Pre-Flight Validation:** Deployments were executed directly without validating that the runtime environment satisfies all required schema constraints before switching traffic.

## Investigation Path
1. Check process status:
   ```bash
   docker ps -a --filter "name=scenario-startup-crash"
   ```
2. Inspect exact container exit code and termination reason:
   ```bash
   docker inspect scenario-startup-crash --format '{{.State.Status}} (ExitCode: {{.State.ExitCode}})'
   ```
3. Read the crash stack trace from container stdout/stderr:
   ```bash
   docker logs --tail 20 scenario-startup-crash
   ```

## Resolution
Identify the missing required environment variable, restore the last known-good configuration from backup or version control, and restart the container to verify clean startup.
