# Test Cases & Validation Plan: Disk Space Exhaustion

## Acceptance Criteria
Following recovery, the system must satisfy the following checks before marking the incident resolved:

| Test ID | Test Target | Verification Command | Expected Result |
|---|---|---|---|
| TC-01 | Disk Utilization | `df -h /var/log/app` | `Use%` is strictly below 80% |
| TC-02 | Service Health | `docker ps` | App container is in `Up` status without crash loops |
| TC-03 | Write Capabilities | `touch /var/log/app/.canary && rm /var/log/app/.canary` | Operation returns exit code 0 |
| TC-04 | App Error Stream | `docker logs --tail 20 scenario-disk-exhaustion` | No new `[CRITICAL] Write failed: [Errno 28]` messages |
| TC-05 | Inode Availability | `df -i /var/log/app` | `IUse%` is healthy (< 50%) |
