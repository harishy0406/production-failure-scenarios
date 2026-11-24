# Production Failure Scenarios

An open, hands-on engineering repository treating real-world IT production failures as complete, reproducible case studies.

**Philosophy:** *Understand the failure. Find the root cause. Restore the system. Automate the recovery. Prevent it from happening again.*

---

## 1. Repository Overview

In production incident response, engineers are often expected to diagnose and resolve critical outages under severe time pressure. `production-failure-scenarios` provides a practical laboratory for rehearsal, automated recovery engineering, and root cause analysis across modern IT stacks.

Each scenario follows the complete incident lifecycle:
```text
Failure Simulation -> Forensic RCA -> Recovery Solutions -> Validation -> Prevention
```

---

## 2. Failure Categories

| Category | Primary Focus | Reference / Key Scenarios |
|---|---|---|
| [database-failures/](./database-failures/) | Availability, replication, corruption, data loss | Accidental DB Deletion, Disk-Full Crash |
| [server-failures/](./server-failures/) | OS stability, compute/memory exhaustion, storage | Disk Space Exhaustion, OOM Kill, High CPU |
| [network-failures/](./network-failures/) | DNS, TLS expiry, firewall misconfigurations, routing | DNS Failure, TLS Expiry, Network Drops |
| [application-failures/](./application-failures/) | Process crashes, API timeouts, memory leaks | App Startup Crash, Upstream Timeout |
| [cloud-infrastructure/](./cloud-infrastructure/) | Containers, orchestrators, cloud storage | Docker Crash Loop, Kubernetes Pod Failure |
| [security-incidents/](./security-incidents/) | Leaked credentials, misconfigured IAM, containment | Credential Leakage, Over-Permissive Roles |
| [monitoring-and-alerting/](./monitoring-and-alerting/) | Telemetry failures, broken alerting routes | Alertmanager Black Hole, Telemetry Disk Full |

---

## 3. Scenario Directory Anatomy

Every scenario follows a standardized, modular structure:

```text
category-name/
└── scenario-slug/
    ├── README.md               # Overview, metadata, quick start
    ├── scenario.md             # Detailed incident narrative
    ├── architecture.md         # System topology and components
    ├── simulation/             # Setup, failure injection, and teardown
    ├── root-cause-analysis/    # Log evidence, timeline, root cause
    ├── solutions/              # Manual runbooks & automated recovery scripts
    ├── testing/                # Post-recovery health & data integrity tests
    ├── prevention/             # Architectural guardrails & monitoring alerts
    └── screenshots/            # Visual artifacts and terminal captures
```

---

## 4. Shared Utilities

The [`shared-tools/`](./shared-tools/) directory provides reusable building blocks:
- **`shared-tools/monitoring/`**: Universal health checks and service ping probes.
- **`shared-tools/recovery-scripts/`**: Reusable recovery primitives and rollback automations.
- **`shared-tools/diagnostics/`**: Forensic log grabbers and system status analyzers.

---

## 5. Getting Started

### Prerequisites
- Docker and Docker Compose
- Bash or PowerShell
- Python 3.10+

### Running Your First Scenario
Explore the reference scenario:
```bash
cd database-failures/database-deletion
cat README.md
```

Follow the quick start commands documented in the scenario README to run the sandbox simulation.

---

## 6. Contribution & Templates

- Review the [Contribution Guide](./docs/contribution-guide.md) to understand the Definition of Done.
- Review the [Documentation Guide](./docs/documentation-guide.md) for formatting conventions.
- Use the [Scenario Template](./templates/scenario-template.md) when scaffolding a new scenario.
- Use the [Incident Report Template](./templates/incident-report-template.md) for postmortem writeups.

---

## 7. License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
