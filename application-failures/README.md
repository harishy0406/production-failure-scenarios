# Application and API Failure Scenarios

Simulations covering application runtimes, microservices interactions, deployment hazards, and unexpected crash events.

## Focus Areas
- Unhandled application exceptions and ungraceful crashes
- Upstream and downstream API timeouts and cascading outages
- Elevated HTTP 5xx error rate spikes
- Bad application deployment and automated rollback strategies
- Thread pool exhaustion and memory leak degradation

## Scenario Index
| Scenario | Focus Tech | Severity | Status |
|---|---|---|---|
| Application Crash on Startup | Node / Python / Go | P0 | Planned |
| Upstream Dependency Timeout | REST / gRPC | P0 | Planned |
| HTTP 500 Spike After Release | Web App / API Gateway | P1 | Planned |
| Bad Deployment Rollback | CI/CD / Docker | P1 | Planned |
| Application Memory Leak | Java / Node / Python | P2 | Planned |
