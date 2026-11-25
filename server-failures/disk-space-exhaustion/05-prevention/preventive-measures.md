# Preventive Measures: Disk Space Exhaustion

## 1. Filesystem Architecture & Partition Isolation
- Never place application logs, temporary uploads, or database WAL files on the root partition (`/`).
- Mount `/var/log` on an independent logical volume or dedicated disk. If an application log spams debug lines, only that isolated partition fills up, preventing kernel panics, SSH lockouts, or system-wide crashes.

## 2. Automated Log Rotation
- Deploy `logrotate` policies across all application services.
- Always use the `copytruncate` directive if the application does not have built-in support for reopening file descriptors on `SIGHUP`.
- Compress rotated logs using `gzip` or `zstd` to save 80% to 90% of space immediately.

## 3. Prometheus Alerting Rules
Configure threshold alerts in Prometheus / Alertmanager to give on-call engineers ample warning before an outage occurs:

```yaml
groups:
  - name: disk_alerts
    rules:
      - alert: DiskSpaceWarning
        expr: (node_filesystem_avail_bytes{mountpoint="/var/log"} / node_filesystem_size_bytes{mountpoint="/var/log"}) * 100 < 20
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Disk space on {{ $labels.mountpoint }} is below 20%"

      - alert: DiskSpaceCritical
        expr: (node_filesystem_avail_bytes{mountpoint="/var/log"} / node_filesystem_size_bytes{mountpoint="/var/log"}) * 100 < 10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Disk space on {{ $labels.mountpoint }} is below 10%"
```

## 4. Application Safeguards
- Configure production logging frameworks to use capped file sizes (e.g. RollingFileAppender in Java/Python/Go with max 100MB per file and max 5 backups).
- Avoid leaving verbose debug logging enabled in production configurations.
