# Infrastructure Handoff

This document provides the complete context necessary to seamlessly continue the infrastructure hardening effort in a new session.

## Current State

- **Active Branch**: `fix/infra-hardening-cleanup`
- **Base Branch**: `origin/main` (We abandoned our old `feat/architecture-hardening` branch because it contained application-level modifications that violated our role boundaries).
- **Working Directory**: Clean (All infra fixes have been committed).
- **Recent Git History**: We just committed the infrastructure fixes via `fix(infra): clean infrastructure hardening`.

## What Was Achieved

We successfully applied several critical infrastructure bug fixes onto the team's evolved architecture:
1. **RabbitMQ Crash Fix**: Replaced a duplicate `rabbitmq-server` call with `tail -f /dev/null` in `infrastructure/rabbitmq/docker-entrypoint.sh` to prevent container crashing during local spinup.
2. **Standalone DB Compose**: Added a missing `collabspace-network` bridge definition to `infrastructure/docker/docker-compose.db.yml` so it can be spun up independently.
3. **Docker Build EPERM Fixes**: Removed `corepack prepare pnpm@9.15.0 --activate` from all 5 service `Dockerfile`s, fixing `operation not permitted` errors during build.
4. **Service Documentation**: Overwrote the default NestJS boilerplate `README.md` files in all 5 services with professional, architecture-accurate documentation.

## Critical Context: The `.claude` Framework & Role Boundaries

During the last session, we discovered the team is strictly using a `.claude/` agent framework on `main`. You must respect these rules:

1. **Role Boundaries**: As the Infrastructure Engineer, you **DO NOT** modify application code (`src/` files). That is the domain of application developers (Võ Trung Tín, Lê Ngọc Anh) and their specific subagents (`nest-reviewer`, `mvp-implementer`).
2. **Observability**: Do not inject `nestjs-pino`, `@nestjs/terminus`, or `@nestjs/throttler`. The application team handles logging instrumentation, caching, and domain logic. Our job is pure operations: K8s manifests, Dockerfiles, docker-compose, CI pipelines, Traefik routing, and monitoring agents.
3. **Source of Truth**: Always consult `docs/team/phan-phu-tho-infrastructure-backlog.md` for your infrastructure tasks and `.claude/rules/infrastructure.md` for operational constraints.
4. **Helm vs K8s Manifests**: The team uses an umbrella Helm chart (`infrastructure/helm/collabspace`). If you modify routing, you must update BOTH `k8s/ingress.yaml` AND the Helm `ingressroute.yaml`.

## Next Steps

When you resume, you should:
1. Push the `fix/infra-hardening-cleanup` branch and open a Pull Request against `main`.
2. Check `docs/team/phan-phu-tho-infrastructure-backlog.md` to see the next uncompleted priority item. Good candidates for the next session:
   - **Secret Management**: Set up External Secrets Operator + `ExternalSecret` for staging (P0).
   - **Metrics & Scrape Configs**: Verify Prometheus scrape configs for the new OTel `MetricsService` (P0).
   - **CI/CD Pipelines**: Build a Jenkinsfile or GitHub Actions CI/CD (P1).
