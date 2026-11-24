# Contribution Guide

Welcome to the `production-failure-scenarios` project. We welcome practical, well-engineered failure scenarios and recovery automations.

## 1. Philosophy and Quality Standards
Each scenario in this repository represents a complete engineering case study:
`Incident -> Root Cause -> Recovery -> Automation -> Prevention`

Every contribution must meet our **Definition of Done (DoD)** before being merged.

## 2. Definition of Done
To be marked as complete, a scenario must satisfy:
1. **Isolated & Safe:** Simulations must execute strictly in isolated environments (Docker Compose, sandboxed containers, or local mocks). It must never touch host systems destructively.
2. **Reproducible in Minutes:** A new engineer must be able to reproduce the scenario with one or two clear commands.
3. **Thorough RCA:** Root cause analysis must cite observable technical evidence (logs, error codes, metrics).
4. **Multiple Recovery Paths:** Document at least one manual runbook and provide an alternative recovery option where applicable.
5. **Idempotent Automation:** Automated recovery scripts must be idempotent and safe to re-run.
6. **Integrity Validation:** Automated tests or validation scripts must assert service health and data consistency post-recovery.
7. **Prevention & Detection:** Include preventative guardrails and monitoring/alerting definitions.
8. **Clean Code & Linting:** Scripts must pass project linters (ShellCheck for bash, Ruff/flake8 for python).

## 3. Contribution Workflow
1. **Fork the Repository:** Create a feature branch (`feature/my-scenario-name`).
2. **Scaffold the Scenario:**
   - Choose the relevant category folder (`database-failures/`, `server-failures/`, etc.).
   - Follow the structure in `templates/scenario-template.md`.
3. **Build the Simulation:**
   - Include `simulation/setup.sh`, `simulation/reproduce-failure.sh`, and `simulation/teardown.sh`.
   - Provide a clean `docker-compose.yml` or container spec with pinned versions.
4. **Provide Solutions & Automation:**
   - Include manual runbooks and executable recovery scripts in `solutions/`.
5. **Write Validation Tests:**
   - Ensure `testing/validation.sh` verifies both service availability and data integrity.
6. **Submit a Pull Request:**
   - Complete the PR template with reproduction steps and verification logs.

## 4. Safety and Security Rules
- **Never include production credentials or sensitive keys.** Use placeholder values and `.env.example` files.
- Scripts with destructive commands (`rm -rf`, `DROP DATABASE`, etc.) must include sandbox confirmation checks.
