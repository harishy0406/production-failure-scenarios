---
title: "Application Crash on Startup (CrashLoop)"
category: "application-failures"
severity: "P0"
technologies: ["Python", "Docker", "Bash"]
difficulty: "Beginner"
estimated_time: "15m"
status: "Draft"
---

# Scenario: Application Crash on Startup (CrashLoop)

## 1. Summary
A new microservice deployment instantly fails on launch, entering a continuous restart crash loop with exit code 1. A required configuration variable (`DATABASE_URL`) was omitted from the release deployment manifest. Upstream API gateways and load balancers fail health check probes and begin returning HTTP 502 Bad Gateway to incoming user traffic.

This scenario demonstrates reproducing a container startup crash loop, inspecting exit codes and unhandled initialization exceptions via Docker, performing emergency configuration rollback, and establishing pre-flight configuration schema validation.

## 2. Metadata
- **Category:** Application & API Failures
- **Severity:** P0 (Total service outage after release)
- **Primary Tech:** Python, Docker, Bash
- **Estimated Time:** 15 minutes
- **Status:** Draft

## 3. Quick Start
Execute the following commands from this scenario directory:

1. **Start the sandbox environment:**
   ```bash
   ./01-simulation/setup.sh
   ```
2. **Inject the bad deployment:**
   ```bash
   ./01-simulation/reproduce-failure.sh
   ```
3. **Investigate the container crash:**
   Follow diagnostic steps in `02-root-cause-analysis/analysis.md` using `docker ps -a`, `docker inspect`, and `docker logs`.
4. **Apply configuration recovery:**
   Follow manual steps in `03-solutions/manual-recovery/runbook.md` or execute the automated recovery tool:
   ```bash
   python3 03-solutions/automated-recovery/recover_config.py
   ```
5. **Validate service health:**
   ```bash
   ./04-testing/validation.sh
   ```
6. **Teardown the sandbox:**
   ```bash
   ./01-simulation/teardown.sh
   ```

## 4. Incident Impact
- **Blast Radius:** All incoming traffic targeting this microservice receives HTTP 502 / connection refused.
- **RTO:** Under 5 minutes with configuration rollback.
- **RPO:** Zero (application state not yet persisted).

## 5. Recovery Approaches
- **Approach 1 (Manual):** Inspect container exit codes and logs, identify missing key in `.env`, patch configuration, and restart.
- **Approach 2 (Automated):** Run `recover_config.py` to restore the last verified environment state and bring the container back to healthy status.

## 6. Prevention
- Implement strict startup configuration schema validation (e.g. Pydantic / Zod) in CI pre-flight checks.
- Enforce mandatory readiness probes and blue/green or canary deployment policies.
