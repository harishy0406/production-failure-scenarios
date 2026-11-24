# Cloud and Infrastructure Failure Scenarios

Handling containerization breakdowns, container orchestrator state failures, infrastructure provisioning bugs, and cloud resource degradations.

## Focus Areas
- Docker container startup crashes and zombie processes
- Kubernetes Pod CrashLoopBackOff and OOMKilled events
- Cloud virtual machine or node host terminations
- Cloud storage (S3/blob) accidental deletion and lifecycle policy issues
- Persistent Volume (PV) claim attachments and storage lockouts

## Scenario Index
| Scenario | Focus Tech | Severity | Status |
|---|---|---|---|
| Docker Container Crash Loop | Docker, Compose | P1 | Planned |
| Kubernetes Pod CrashLoopBackOff | Kubernetes, kind/minikube | P1 | Planned |
| S3 Bucket Object Deletion | LocalStack / AWS | P2 | Planned |
| Persistent Volume Storage Detachment | Kubernetes | P2 | Planned |
