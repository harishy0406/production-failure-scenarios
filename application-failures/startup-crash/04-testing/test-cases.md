# Test Cases: Application Startup Crash

## Acceptance Criteria
Following recovery, the microservice must pass all checks before resolving the incident:

| Test ID | Objective | Procedure | Expected Result |
|---|---|---|---|
| TC-01 | Container State | `docker inspect scenario-startup-crash` | Status is "running" (not "restarting" or "exited") |
| TC-02 | Clean Exit Status | `docker inspect scenario-startup-crash --format '{{.State.ExitCode}}'` | Exit code is 0 |
| TC-03 | Health Endpoint | `curl -s http://localhost:8080/health` | HTTP 200 with JSON payload `{"status":"healthy"}` |
| TC-04 | Service API Endpoint | `curl -s http://localhost:8080/` | HTTP 200 with JSON payload `{"service":"auth-service"}` |
| TC-05 | Error Stream Cleanliness | `docker logs --tail 20 scenario-startup-crash` | No new `[CRITICAL]` or `Traceback` lines |
