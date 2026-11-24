# Incident Postmortem Report

**Incident ID:** INC-YYYYMMDD-XX  
**Title:** <Brief incident headline>  
**Date:** YYYY-MM-DD  
**Severity:** <P0 / P1 / P2>  
**Incident Commander:** <Name / Role>  
**Status:** Resolved  

---

## 1. Executive Summary
A 2-3 sentence overview of what occurred, user-facing impact, and how it was mitigated.

## 2. Impact Summary
- **Service Affected:** `<Service Name>`
- **Total Outage Duration:** `<HH:MM:SS>`
- **Estimated User Impact:** `<% or count of affected requests/users>`
- **Data Loss / Integrity Impact:** `<RPO impact or 'Zero data loss confirmed'>`

## 3. Incident Timeline (UTC)
| Time (UTC) | Phase | Event Description |
|---|---|---|
| 00:00 | Detection | Alert fired / customer reported issue |
| 00:05 | Triage | Incident commander assigned; bridge opened |
| 00:15 | Root Cause Identified | Log evidence identified faulty query / configuration |
| 00:25 | Mitigation Applied | Rollback / failover executed |
| 00:35 | Recovery Verified | Health checks and data verification passed |
| 00:45 | Incident Closed | Normal operational state confirmed |

## 4. Root Cause Analysis
Explain the primary technical reason for the outage, detailing the sequence of contributing factors.
- **Primary Cause:**
- **Trigger:**
- **Contributing Factors:**

## 5. Recovery & Resolution Steps
Details of the precise recovery commands and procedural steps taken to restore service.

## 6. What Went Well / What Went Poorly / Where We Got Lucky
### What Went Well
- Automated backups were intact and accessible.
- Health checks caught the degradation promptly.

### What Went Poorly
- Manual failover instructions lacked up-to-date steps.
- Secondary alerting had missing notification recipients.

### Where We Got Lucky
- Failure occurred during an off-peak maintenance window.

## 7. Action Items & Preventive Tasks
| ID | Action Item | Type | Owner | Priority | Target Date |
|---|---|---|---|---|---|
| ACT-01 | Implement permission guardrail | Prevention | Infrastructure Team | P0 | YYYY-MM-DD |
| ACT-02 | Add automated alert for connection spikes | Detection | Observability Team | P1 | YYYY-MM-DD |
| ACT-03 | Automate recovery runbook | Automation | SRE Team | P1 | YYYY-MM-DD |
