---
title: "Disk Space Exhaustion (ENOSPC)"
category: "server-failures"
severity: "P0"
technologies: ["Linux", "Docker", "Bash", "Python"]
difficulty: "Beginner"
estimated_time: "15m"
status: "Draft"
---

# Scenario: Disk Space Exhaustion (ENOSPC)

## 1. Summary
A backend API server crashes after its mounted disk partition hits 100% capacity. An unrotated application log spammed debug output until the operating system returned error code ENOSPC (No space left on device). When engineers tried running `rm` to delete the large log file, disk space was still not freed because the running application process held the file descriptor open.

This scenario walks through reproducing the full disk crash safely in an isolated container, diagnosing the open file descriptor leak, reclaiming disk space without breaking the application, and configuring logrotate policies.

## 2. Metadata
- **Category:** Server & OS Failures
- **Severity:** P0 (Production writes blocked)
- **Primary Tech:** Linux, Docker, Bash, Python
- **Estimated Time:** 15 minutes
- **Status:** Draft

## 3. Quick Start
Run these commands from this scenario folder:

1. **Start the sandbox container:**
   ```bash
   ./01-simulation/setup.sh
   ```
2. **Trigger the disk exhaustion failure:**
   ```bash
   ./01-simulation/reproduce-failure.sh
   ```
3. **Investigate the root cause:**
   Check `02-root-cause-analysis/analysis.md` for triage steps with `df -h`, `du -sh`, and `lsof +L1`.
4. **Apply recovery:**
   Run the manual runbook in `03-solutions/manual-recovery/runbook.md` or use the automated cleanup script:
   ```bash
   python3 03-solutions/automated-recovery/cleanup.py --path /var/log/app --threshold 80
   ```
5. **Validate recovery:**
   ```bash
   ./04-testing/validation.sh
   ```
6. **Clean up:**
   ```bash
   ./01-simulation/teardown.sh
   ```

## 4. Incident Impact
- **Blast Radius:** All file writes fail on the affected mount point.
- **RTO:** Under 5 minutes if operators know to truncate or release open file handles.
- **RPO:** Zero data corruption if the application handles write exceptions gracefully.

## 5. Recovery Approaches
- **Approach 1 (Manual):** Truncate open files directly via `: > /var/log/app/app.log` or release deleted file descriptors from `/proc/<pid>/fd/`.
- **Approach 2 (Automated):** Run `cleanup.py` to inspect volume usage, preview targets with `--dry-run`, and truncate files safely.

## 6. Prevention
- Configure `logrotate` with compression and size-based rotation.
- Set up Prometheus node_exporter alerts at 80% (Warning) and 90% (Critical) disk utilization.
- Put volatile log paths (`/var/log`) on an independent filesystem or volume.
