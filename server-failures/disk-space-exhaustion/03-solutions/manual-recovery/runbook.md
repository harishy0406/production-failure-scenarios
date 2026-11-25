# Manual Recovery Runbook: Disk Space Exhaustion

**Target Issue:** Partition mounted at `/var/log/app` has reached 100% capacity (`ENOSPC`).  
**Prerequisites:** Root or sudo access on the target host or container.

---

## Step 1: Confirm Disk Utilization
Check the current usage of the filesystem:
```bash
df -h /var/log/app
```
Note the percentage under `Use%`.

---

## Step 2: Locate the Culprit File
List files ordered by size in the target directory:
```bash
du -sh /var/log/app/* | sort -hr
```
Identify the largest file (e.g. `/var/log/app/app.log`).

---

## Step 3: Fast In-Place Truncation
Do not run `rm`. If you run `rm`, the process writing to the file keeps the blocks reserved.

Instead, truncate the file to 0 bytes:
```bash
# Option A: Built-in shell redirection (fastest)
: > /var/log/app/app.log

# Option B: Using the truncate utility
truncate -s 0 /var/log/app/app.log
```

---

## Step 4: Handling the "Already Deleted but Disk Still Full" Gotcha
If someone already ran `rm /var/log/app/app.log`, the file is gone from directory listings, but disk space is still at 100%.

1. Find the process holding the deleted file descriptor:
   ```bash
   lsof +L1
   ```
   Or look in proc directly:
   ```bash
   ls -lh /proc/*/fd/* 2>/dev/null | grep '(deleted)'
   ```

2. Locate the matching PID and file descriptor number (e.g. PID `1420`, FD `3`).

3. Truncate the file descriptor directly through procfs:
   ```bash
   : > /proc/1420/fd/3
   ```
   This immediately releases the disk blocks back to the OS without killing the application.

---

## Step 5: Confirm Disk Recovery
Verify disk usage is back below safety thresholds:
```bash
df -h /var/log/app
```
`Use%` should now be under 5%.
