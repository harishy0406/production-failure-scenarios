# Application and API Failure Scenarios

Simulations covering application runtimes, microservices interactions, deployment hazards, and unexpected crash events.

## Focus Areas
- Unhandled application exceptions and ungraceful crashes
- Upstream and downstream API timeouts and cascading outages
- Elevated HTTP 5xx error rate spikes
- Bad application deployment and automated rollback strategies
- Thread pool exhaustion and memory leak degradation

## Scenario Index
| Scenario | Focus Tech | Severity | Status | Path |
|---|---|---|---|---|
| Application Crash on Startup | Python, Docker, Bash | P0 | Draft | [startup-crash](./startup-crash/) |
| Upstream Dependency Timeout | REST / gRPC | P0 | Planned | `api-timeout` |
| HTTP 500 Spike After Release | Web App / API Gateway | P1 | Planned | `500-spike` |
| Bad Deployment Rollback | CI/CD / Docker | P1 | Planned | `bad-deployment-rollback` |
| Application Memory Leak | Java / Node / Python | P2 | Planned | `memory-leak` |
