# Server and Operating System Failure Scenarios

Simulations and recovery patterns addressing host-level infrastructure, operating system stability, kernel behaviors, and compute resource exhaustion.

## Focus Areas
- Filesystem storage depletion and inode exhaustion
- Kernel Out-Of-Memory (OOM) killer terminations
- CPU throttling, thrashing, and compute saturation
- Critical process death and init/systemd service recovery
- File permission and ACL misconfigurations

## Scenario Index
| Scenario | Focus Tech | Severity | Status | Path |
|---|---|---|---|---|
| Disk Space Exhaustion | Linux, Docker, Python | P0 | Draft | [disk-space-exhaustion](./disk-space-exhaustion/) |
| Out Of Memory (OOM) Kill | Linux, cgroups | P0 | Planned | `oom-kill` |
| High CPU Saturation | Linux | P0 | Planned | `high-cpu` |
| Critical Daemon Termination | systemd, Linux | P1 | Planned | `daemon-termination` |
| Filesystem Corruption & Read-Only Remount | Linux kernel | P2 | Planned | `fs-corruption` |
