---
title: "Accidental Database Deletion"
category: "database-failures"
severity: "P0"
technologies: ["PostgreSQL", "Docker", "Bash", "Python"]
difficulty: "Intermediate"
estimated_time: "25m"
status: "Draft"
---

# Scenario: Accidental Database Deletion

## 1. Summary
A production PostgreSQL database is accidentally dropped by an operator (`DROP DATABASE production_db;`). This scenario demonstrates diagnosing the outage, evaluating the recovery point objective (RPO), performing Point-In-Time Recovery (PITR) and backup restoration, and establishing preventative access controls.

## 2. Metadata
- **Category:** Database Failures
- **Severity Level:** P0 (Critical - Total service outage)
- **Primary Technologies:** PostgreSQL 16, Docker, Bash, Python
- **Estimated Completion Time:** 25 minutes
- **Status:** Draft

## 3. Architecture & Topology
The environment simulates an application connected to a primary PostgreSQL container with automated base backups and continuous WAL archiving:

```text
[ Client Traffic ] ---> [ Backend API ]
                              |
                     (Database Connection)
                              v
                   [ PostgreSQL Primary ]
                    /                  \
       (Base Backups)              (Continuous WAL Archiving)
            v                                  v
     [ /backups/base ]                  [ /backups/wal ]
```

## 4. Quick Start
1. **Initialize Sandbox:**
   ```bash
   ./simulation/setup.sh
   ```
2. **Simulate Accidental Deletion:**
   ```bash
   ./simulation/reproduce-failure.sh
   ```
3. **Diagnose Incident:**
   Follow root cause investigation steps in [analysis.md](root-cause-analysis/analysis.md).
4. **Execute Recovery:**
   Follow the runbooks in `solutions/manual-recovery/` or run the automated recovery script in `solutions/automated-recovery/`.
5. **Validate Health & Data Integrity:**
   ```bash
   ./testing/validation.sh
   ```
6. **Teardown Environment:**
   ```bash
   ./simulation/teardown.sh
   ```

## 5. Incident Description and Impact
- **Blast Radius:** All transactions, customer sessions, and services relying on `production_db`.
- **RTO:** Under 15 minutes with automated point-in-time recovery.
- **RPO:** Near-zero data loss when WAL archive continuity is maintained.

## 6. Recovery Approaches
- **Approach 1: Full Backup Restoration:** Restores from the latest physical base backup.
- **Approach 2: Point-In-Time Recovery (PITR):** Replays WAL logs up to the instant prior to the `DROP DATABASE` timestamp.
- **Approach 3: Automated Scripted Recovery:** An idempotent Python script that automates restoration and validation.

## 7. Prevention and Monitoring
- Revoke destructive DDL privileges (`DROP`, `ALTER`) from daily application credentials.
- Enable connection proxy safeguards or query guardrails.
- Enforce automated continuous backup validation and alerting on anomalous DDL events.
