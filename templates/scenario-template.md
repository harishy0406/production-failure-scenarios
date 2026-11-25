---
title: "<Scenario Title>"
category: "<database-failures | server-failures | network-failures | application-failures | cloud-infrastructure | security-incidents | monitoring-and-alerting>"
severity: "<P0 | P1 | P2>"
technologies: ["<Tech1>", "<Tech2>"]
difficulty: "<Beginner | Intermediate | Advanced>"
estimated_time: "<e.g., 20 mins>"
status: "<Draft | Reviewed | Stable>"
---

# Scenario: <Scenario Name>

## 1. Summary
A concise overview explaining what failure occurs, the target environment, and why this failure is critical in production systems.

## 2. Metadata
- **Category:** `<Category>`
- **Severity Level:** `<P0 / P1 / P2>`
- **Target Tech Stack:** `<e.g., PostgreSQL, Docker, Linux>`
- **Estimated Completion Time:** `<e.g., 25 minutes>`
- **Prerequisites:** Docker, Docker Compose, Bash/PowerShell

## 3. Architecture & Topology
Provide a high-level overview or diagram of the system topology before failure.

```
[ Client / Traffic ] ---> [ Application / Service ] ---> [ Target Component ]
                                                               |
                                                        [ Storage / State ]
```

## 4. Quick Start
Step-by-step instructions to run the scenario locally:

1. **Setup Sandbox Environment:**
   ```bash
   ./01-simulation/setup.sh
   ```
2. **Inject / Reproduce Failure:**
   ```bash
   ./01-simulation/reproduce-failure.sh
   ```
3. **Investigate & Diagnose:**
   Follow the diagnostic steps in `02-root-cause-analysis/analysis.md`.
4. **Execute Recovery:**
   See `03-solutions/manual-recovery/` or run automated recovery in `03-solutions/automated-recovery/`.
5. **Validate Health & Data Integrity:**
   ```bash
   ./04-testing/validation.sh
   ```
6. **Teardown Sandbox:**
   ```bash
   ./01-simulation/teardown.sh
   ```

## 5. Incident Description & Impact Assessment
- **Blast Radius:** Scope of affected upstream services and clients.
- **RTO (Recovery Time Objective):** Target time to restore service.
- **RPO (Recovery Point Objective):** Maximum allowable data loss window.
- **Observed Symptoms:** Status codes, log signatures, metric spikes, error cascades.

## 6. Root Cause Analysis (RCA)
Summary of the root cause. Full timeline and forensic logs are documented in [analysis.md](root-cause-analysis/analysis.md).

## 7. Recovery Approaches
Detail at least two realistic recovery options:
- **Approach A (Manual):** Step-by-step human intervention runbook.
- **Approach B (Alternative/Standby):** Failover, replica promotion, or snapshot rollback.
- **Approach C (Automated):** Idempotent script execution.

## 8. Post-Recovery Validation
List validation assertions that prove both service availability and data integrity.

## 9. Prevention & Monitoring Strategy
- **Architectural Safeguards:** Permissions, guardrails, rate limits, read-only policies.
- **Alerting Rules:** Recommended Prometheus/alertmanager rules or health check probes.
- **Runbook References:** Production operational guidelines.
