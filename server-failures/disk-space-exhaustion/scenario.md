# Detailed Scenario Narrative: Disk Space Exhaustion

## Incident Background
At 02:15 UTC, the on-call engineer received high-priority alerts: the payment gateway service stopped processing transactions. Upstream requests started returning HTTP 500 errors.

When checking the application container logs, the following trace was repeating continuously:
```text
OSError: [Errno 28] No space left on device: '/var/log/app/app.log'
```

Attempts to create lock files, temporary files, or write new session states all failed with system error code 28 (`ENOSPC`).

## Why Common Quick Fixes Fail
When junior operators connect to a box running out of disk, the instinct is often:
```bash
rm /var/log/app/app.log
```

While the file name vanishes from directory listings (`ls`), the Linux kernel keeps the inode allocated as long as any running process has an open file handle referencing it.

Result:
- `df -h` still reports 100% disk usage.
- `du -sh /var/log/app` reports 0 bytes used.
- The confusion deepens while the outage continues.

## Investigation Path
1. Run `df -h` to see which filesystem mount is at 100%.
2. Run `du -sh /var/log/* | sort -hr` to locate which directory holds large files.
3. If `du` cannot find the missing gigabytes, run `lsof +L1` to find unlinked files that are still held open in memory by active processes.
4. Truncate the file descriptors directly instead of deleting them.

## Resolution
The engineer truncated the active file descriptor using `truncate -s 0` (or `cat /dev/null > file`), instantly freeing disk blocks while allowing the application to keep writing without an emergency restart.
