# Documentation Guide

This document defines the conventions, writing standards, and structure required for scenarios and tools in `production-failure-scenarios`.

## 1. Scenario Folder Layout
Every scenario follows a modular directory layout:

```text
category-name/
└── scenario-slug/
    ├── README.md               # Main overview and quick start
    ├── scenario.md             # In-depth narrative and incident walkthrough
    ├── architecture.md         # System topology and component interactions
    ├── simulation/             # Setup, failure injection, and teardown scripts
    │   ├── setup.sh
    │   ├── reproduce-failure.sh
    │   └── teardown.sh
    ├── root-cause-analysis/    # RCA, log dumps, timeline, and forensic evidence
    │   └── analysis.md
    ├── solutions/              # Recovery methods
    │   ├── manual-recovery/    # Human runbooks
    │   ├── automated-recovery/ # Automated scripts and playbooks
    │   └── scripts/
    ├── testing/                # Verification scripts
    │   ├── test-cases.md
    │   └── validation.sh
    ├── prevention/             # Architectural guardrails and alerting
    │   └── preventive-measures.md
    └── screenshots/            # Terminal recordings, dashboards, diagrams
```

## 2. Scenario Metadata Header
Every scenario `README.md` must begin with YAML frontmatter:

```yaml
---
title: "Accidental Database Deletion"
category: "database-failures"
severity: "P0"
technologies: ["PostgreSQL", "Docker", "Python", "Bash"]
difficulty: "Intermediate"
estimated_time: "20m"
status: "Draft"
---
```

## 3. Style and Tone
- **Clarity and Precision:** Use concise, technical descriptions. Avoid ambiguous advice.
- **Show Expected Output:** When documenting terminal commands, include realistic expected output.
- **Explicit Prerequisites:** State all required tools, packages, and minimum Docker/OS versions.
- **Fail-Safe Instructions:** Warn readers before executing commands that modify data or simulate crashes.
