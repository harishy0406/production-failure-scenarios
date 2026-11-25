# Root Cause Analysis: Disk Space Exhaustion

## Incident Details
- **Symptom:** API write operations fail with `[Errno 28] No space left on device`.
- **Affected Mount:** `/var/log/app` (100% capacity reached).
- **Contributing Bug:** Debug logging was left enabled after a recent deployment, printing full payloads for every incoming request without rotation.

## Evidence & Forensic Commands

### 1. Check Filesystem Usage
Run this to see which partition is saturated:
```bash
df -h /var/log/app
```
Expected output during incident:
```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/vdb1        50M   50M     0 100% /var/log/app
```

### 2. Check Directory Sizes
Find the directories consuming the most space:
```bash
du -sh /var/log/app/* | sort -hr
```

### 3. Check for Deleted Files Held Open by Processes
If files were removed with `rm` but disk space did not recover:
```bash
lsof +L1
```
Or check directly under proc:
```bash
ls -lh /proc/*/fd/* 2>/dev/null | grep '(deleted)'
```

Sample output:
```text
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NLINK   NODE NAME
python3  1420 root    3w   REG   8,17 52428800     0 131075 /var/log/app/app.log (deleted)
```
Explanation:
- `NLINK = 0`: The file was unlinked from the directory tree (via `rm`).
- `SIZE/OFF`: The file is still consuming 50MB of physical blocks.
- `PID 1420`: The process is still holding file descriptor 3 open.

## Remediation Takeaways
1. Never use `rm` on an actively written log file during an incident.
2. Truncate in place using `truncate -s 0 /var/log/app/app.log` or `: > /var/log/app/app.log`.
3. If the file is already deleted but held open, truncate it via `/proc/<PID>/fd/<FD>`:
   ```bash
   : > /proc/1420/fd/3
   ```
