# Preventive Measures and Safeguards

## 1. Principle of Least Privilege
- Separate maintenance roles from application service accounts.
- Deny `DROP DATABASE` and `TRUNCATE` privileges on all routine administrative roles.
- Restrict superuser credentials behind an approval workflow with multi-factor authentication (MFA).

## 2. Guardrails & Protective Configuration
- Use connection brokers (e.g., PgBouncer) or proxy layers with read-only routing for analytics and staging.
- Implement statement timeouts and SQL linting hooks to prevent unintentional mass deletions.

## 3. Continuous Backup & Monitoring
- Enforce regular automated base backups with write-ahead log (WAL) archiving to durable object storage.
- Automate periodic restore drills in isolated test runners to verify backup integrity continuously.
- Set up immediate alerts for DDL events (`DROP`, `TRUNCATE`, `ALTER`) in Alertmanager or SIEM.
