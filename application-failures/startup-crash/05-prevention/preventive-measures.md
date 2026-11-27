# Preventive Measures: Application Startup Crashes

## 1. Automated Pre-Flight Environment Validation
- Integrate configuration validation tools directly into CI/CD pipelines before executing deploy steps.
- Use strict typing libraries (e.g. Pydantic in Python, Zod in TypeScript, Viper in Go) to parse and validate all environment variables at build or test time.

## 2. Canary and Blue/Green Deployment Strategy
- Never replace 100% of running application pods simultaneously.
- Route 5% of traffic to canary containers and assert that readiness probes pass before decommissioning healthy older containers.

## 3. Container Orchestration Readiness Probes
- Define explicit readiness probes in Kubernetes or Docker Compose:
```yaml
healthcheck:
  test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')"]
  interval: 5s
  timeout: 3s
  retries: 3
  start_period: 5s
```
- Ingress routers will automatically withhold customer traffic until the container successfully passes its health check.
