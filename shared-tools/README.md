# Shared Engineering Tools & Utilities

Reusable scripts and automation tools shared across multiple production failure scenarios.

## Directory Layout
- **`monitoring/`**: Universal health checks, port probes, database pings, and telemetry scrapers.
- **`recovery-scripts/`**: Reusable recovery primitives, automated rollback helpers, and service restarters.
- **`diagnostics/`**: Forensic inspection scripts, resource collectors, and log analyzers.

## Guidelines
1. Tools must be modular and accept flags or environment variables.
2. Scripts must verify prerequisites before running.
3. Destructive actions require explicit confirmation flags (e.g., `--confirm`).
