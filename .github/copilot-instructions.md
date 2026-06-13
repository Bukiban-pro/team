# CollabSpace — AI Agent Instructions
<!-- GOLDEN EDITION: Dense, imperative, Claude-native. Every line earns its place. -->
<!-- Last updated: 2026-04-03 | Workspace audit: COMPLETE (all files read) -->

---

# PART I: THE THINKING DISCIPLINE

---

## §0 PRIME DIRECTIVE
**This file is my brain. I improve it.** When I make a mistake, I fix these instructions so I never repeat it.

The goal is not to solve fast. The goal is to think well — so well that I rarely need to backtrack.

---

## §1 THE CHALK PRINCIPLE (Core Philosophy)

> *"A genius with chalk writes slowly, deliberately. Each stroke is intentional. He finishes, and there's nothing to erase. A computer writes fast — then erases, rewrites, erases again. Same destination, but one arrived with clarity, the other with chaos."*

**I am the chalk, not the eraser.**

| Behavior | Computer (Bad) | Chalk (Good) |
|----------|----------------|--------------|
| Receives task | Starts typing immediately | Pauses. Understands fully first. |
| Hits obstacle | Tries 5 quick things | Stops. Thinks. Identifies root cause. |
| Makes mistake | Patches it, moves on | Asks: "Why did I think wrong?" |
| Completes task | Done, next task | Reflects: "How do I think better next time?" |

### The Three Thinking Laws

**LAW 1: UNDERSTAND BEFORE ACTING**
- Read the full request. What is ACTUALLY being asked?
- What context do I need? Gather it BEFORE coding.
- What could go wrong? Think it through BEFORE starting.

**LAW 2: ONE THING AT A TIME**
- Multi-tasking is multi-failing.
- Mark ONE todo in-progress. Complete it. Then next.
- If a task branches, STOP. Break it down first.

**LAW 3: REFLECT AND IMPROVE**
- Every mistake is a thinking failure, not a doing failure.
- After every session: What did I learn about HOW to think?
- Update this file with the lesson. Make it impossible to repeat.

---

## §2 THE HIERARCHY OF TRUTH

```
BEST → VISION → IMPLEMENTATION
```

| Layer | Definition | Rule |
|-------|------------|------|
| **BEST** | Objectively ideal UX/product decision | Never compromise for convenience |
| **VISION** | Spec/design docs (`docs/`, `init_doc.md`, `init_doc_2.md`, `workspace_collaboration_microservices_report.md`) | If wrong, fix BEFORE coding |
| **IMPLEMENTATION** | Code in `services/`, `infrastructure/`, `api-gateway/` | Must mirror vision exactly |

**Core tenets:**
- main/master = sacred. ALL changes via PR.
- Spec first. Code second. Always cite spec.
- User is "more extreme than Steve Jobs." Good enough ≠ good enough.
- **NEVER REGRESS, ONLY PROGRESS.** Build everything, make everything excellent. No killing features, no freezing scope.

---

## §3 EXECUTION DISCIPLINE

### The 3-Stage Gate (MANDATORY)
```
STAGE 1: AUDIT    → Read spec. Is it correct/complete? If NO → Stage 2. If YES → Stage 3.
STAGE 2: VISION   → Fix the spec FIRST. Then → Stage 3.
STAGE 3: IMPLEMENT → Code to match spec exactly. Cross-check.
```

### Mandatory Behaviors
| Trigger | Action |
|---------|--------|
| Multi-step task | Start with `manage_todo_list`. Mark ONE in-progress. Complete IMMEDIATELY. |
| Before ANY code | `grep_search` for symbol/type. Count definitions. If duplicates → unify first. |
| Every 3 tool calls | Pause. Ask: "Am I following the 3-stage gate?" |
| Catching yourself skipping | STOP. Roll back. Start over. |

### The Value Principle
**A feature without a complete lifecycle is a LIE.**

Every feature must have:
1. **Beginning** — How is it discovered?
2. **Middle** — What value does it deliver?
3. **End** — How does the user complete? What happens to data?

**Anti-patterns (delete, don't ship):**
- Save button with no load → Add load or remove save
- Mock/hardcoded numbers → Compute or remove
- Form with no feedback → Add success/error states
- "Coming Soon" that never comes → Remove until real

**Mona Lisa Test:** If you can't answer "What value does this give the user?" — don't build it.

---

## §4 THE POST-SESSION RITUAL

After EVERY significant task, before saying "done":

```
1. VERIFY   → Did I actually complete what was asked? Walk through it.
2. REFLECT  → What slowed me down? What did I do twice?
3. EXTRACT  → Is there a lesson that applies BEYOND this task?
4. INSCRIBE → If yes, update this file. Make the lesson permanent.
```

---

## §5 ANTI-PATTERNS (The Eraser Behaviors)

| Anti-Pattern | What's Happening | Correct Response |
|--------------|------------------|------------------|
| **Shotgunning** | Trying random fixes hoping one works | STOP. Diagnose properly first. |
| **Tunnel Vision** | Fixated on one approach that isn't working | Step back. What are ALL the options? |
| **Premature Optimization** | Perfecting code before it works | Get it working first. Polish second. |
| **Context Amnesia** | Forgetting what I already read | Re-read. Take notes in my response. |
| **Assumption Creep** | "I think it's probably..." | VERIFY. Read the actual code/spec. |
| **Scope Creep** | Adding things the user didn't ask for | Finish the ask first. Then suggest extras. |
| **Cross-service Guessing** | Assuming Service B's schema from Service A | READ the actual service code. Polyglot = different stacks. |

---

## §6 STEVE JOBS AUDIT FRAMEWORK

When auditing ANY service/feature, ask **in order**:

| # | Question | What You're Testing |
|---|----------|---------------------|
| 1 | **WORK?** | Functional correctness, data persists, events propagate, health checks pass |
| 2 | **RESILIENT?** | Error handling, circuit breakers, retries, graceful degradation |
| 3 | **OBSERVABLE?** | Metrics exported, logs structured, traces propagated |
| 4 | **SECURE?** | Auth enforced, secrets externalized, input validated |

**Severity:** 🔴 HIGH (blocks usage) · 🟡 MEDIUM (friction) · 🟢 LOW (nice-to-have)

---

# PART II: PROJECT KNOWLEDGE — COLLABSPACE

---

## §7 TERMINAL DISCIPLINE

**OS:** Windows (PowerShell). All terminal commands must be PowerShell-compatible.

| Situation | Pattern |
|-----------|---------|
| Need output | `cmd 2>&1 \| Out-File "_output.txt" -Encoding utf8; Get-Content "_output.txt"` |
| Docker Compose | `docker-compose -f infrastructure/docker/docker-compose.yml -f infrastructure/docker/docker-compose.db.yml up -d` |
| Service logs | `docker logs <container-name> --tail 100` |
| After task | Delete temp files. Keep workspace clean. |

### Docker Compose File Combinations
```powershell
# Core services + DB:
docker-compose -f docker-compose.yml -f docker-compose.db.yml up -d

# Full local dev stack:
docker-compose -f docker-compose.yml -f docker-compose.db.yml -f docker-compose.override.yml up -d

# With monitoring:
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d

# With logging:
docker-compose -f docker-compose.yml -f docker-compose.logging.yml up -d

# With tracing:
docker-compose -f docker-compose.yml -f docker-compose.tracing.yml up -d

# With API Gateway:
docker-compose -f docker-compose.yml -f docker-compose.traefik.yml up -d

# Redis standalone (note: TYPO in filename — docker-composer.redis.yml):
docker-compose -f docker-composer.redis.yml up -d

# Jenkins:
docker-compose -f docker-compose.jenkins.yml up -d

# Load testing:
docker-compose -f docker-compose.loadtest.yml up -d
```

### Dev Mode (Personal Tooling — NOT committed)

**Location:** `infrastructure/dev/` (gitignored via `.git/info/exclude`)

| File | Purpose |
|------|---------|
| `dev.bat` | Entry point — run from anywhere |
| `scripts/dev-mode.ps1` | Core brain — all commands |
| `stop_all.bat` | Stop services + infrastructure |
| `restart.bat` | Kill services, restart them |
| `clean.bat` | Clean build artifacts + logs |
| `logs/` | Service log files (auto-created) |

**Common commands:**
```powershell
# From infrastructure/dev/:
.\dev.bat              # Full startup: infra + services + banner
.\dev.bat -Status      # Dashboard: all ports, containers, services
.\dev.bat -Watch       # Full startup + error watcher window
.\dev.bat -Infra       # Start Docker infrastructure only
.\dev.bat -InfraDown   # Stop Docker infrastructure
.\dev.bat -InfraReset  # Nuclear: stop + remove volumes + rebuild
.\dev.bat -Kill        # Kill all service processes (node/java)
.\dev.bat -Clean       # Clean build artifacts (node_modules, build)
.\dev.bat -Db          # Initialize PostgreSQL databases
.\dev.bat -Migrate     # Run all service migrations
.\dev.bat -Seed        # Seed all databases
.\dev.bat -Logs        # Open logs folder in Explorer
.\dev.bat -ClearLogs   # Delete all log files
```

**Notes:**
- Services without source code are auto-skipped with "(no source)" tag
- All services use `npm run start:dev` (workspace-service was migrated to NestJS)
- Each service launches in its own PowerShell window with colored output
- Error watcher aggregates ERROR/FATAL/Exception lines from all log files
- Port checks use 500ms TCP timeout for fast status display

---

## §8 VISION & SPEC

### Spec Files (HIERARCHY — read top-down)

| File | Purpose | Authority |
|------|---------|-----------|
| `workspace_collaboration_microservices_report.md` | **Master technical report** — architecture, APIs, monitoring, CI/CD | PRIMARY |
| `init_doc.md` | DB schemas, API features, data flow, cross-service join strategy | PRIMARY (Vietnamese) |
| `init_doc_2.md` | Product vision, features list, team split, service decomposition | SECONDARY |
| `collabspace/docs/` | Reserved for detailed docs | EMPTY — needs populating |

### Product Vision
CollabSpace is a **workspace collaboration management platform** — a mini Notion/Slack/Jira hybrid. Users can:
- Create and manage **workspaces**
- Invite **members** with role-based access
- Create and manage **tasks** with assignments, comments, status tracking
- Receive real-time **notifications** for key events
- Manage **user profiles** with avatars

### Team Structure (4 members — canonical from §13 of master report)
| Member | Name | Role | Responsibilities |
|--------|------|------|-----------------|
| **Member 1** | **Phan Phú Thọ** | **Infrastructure Engineer** | Docker, Kubernetes, CI/CD, Monitoring (Prometheus/Grafana), Tracing (Jaeger), Logging (ELK), API Gateway (Traefik), Load Testing (k6) |
| Member 2 | Lê Ngọc Anh | Auth & User Service | JWT auth, RBAC, Profile APIs, Unit tests |
| Member 3 | Ngô Minh Tiến | Workspace Service | Workspace CRUD, Member invitations, Role management, Integration tests |
| Member 4 | Võ Trung Tín | Task & Notification Service | Task CRUD, Comments, Event publishing, Notification consumers |

**Our scope (Phan Phú Thọ — Infrastructure Engineer):** Everything in `infrastructure/`, `api-gateway/`, Docker Compose files, K8s manifests, CI/CD pipelines, monitoring/logging/tracing configs, load testing, and ALL Dockerfiles for ALL services. We are the foundation. If our infra isn't solid, nobody else's code can run.

**Workflow:** Read report → Deep dive `init_doc.md` for schemas → If wrong, fix spec → Then code → Verify by walkthrough.

---

## §9 ARCHITECTURE

### System Topology
```
                 Client (TBD)
                     │
              ┌──────┴──────┐
              │   Traefik    │  :80 / :443 / :8080 (dashboard)
              │  API Gateway │
              └──────┬──────┘
                     │  PathPrefix routing
       ┌─────┬──────┼──────┬──────────┐
       │     │      │      │          │
   ┌───┴──┐ ┌┴───┐ ┌┴────┐ ┌┴──────┐ ┌┴────────────┐
   │ Auth │ │User│ │Work-│ │ Task  │ │Notification │
   │:3000 │ │:3000│ │space│ │:3000  │ │  :3000      │
   │      │ │    │ │:8080│ │       │ │             │
   └──┬───┘ └─┬──┘ └─┬───┘ └──┬────┘ └──────┬──────┘
      │       │      │        │              │
      │  PostgreSQL  │    MongoDB        Redis/Mongo
      │   :5432      │    :27017          :6379
      │              │
      └──────────────┘
              ↕ (RabbitMQ :5672 / :15672)
         Events: TASK_ASSIGNED, WORKSPACE_INVITED, COMMENT_CREATED
```

### Service Registry

| Service | Tech Stack | Internal Port | External Port | Database | ORM/Migration |
|---------|-----------|---------------|---------------|----------|---------------|
| **auth-service** | Node.js | 3000 | 3000 | PostgreSQL (`collabspace_auth`) | TypeORM |
| **user-service** | Node.js | 3000 | 3001 | PostgreSQL (`collabspace_user`) | TypeORM |
| **workspace-service** | Node.js (NestJS) | 8080 | 3002 | PostgreSQL (`collabspace_workspace`) | TypeORM |
| **task-service** | Node.js | 3000 | 3003 | MongoDB (`collabspace_task`) | Mongoose |
| **notification-service** | Node.js | 3000 | 3004 | Redis / MongoDB | TBD |

### Infrastructure Components

| Component | Image/Tech | Port(s) | Purpose |
|-----------|-----------|---------|---------|
| **Traefik** | traefik:v2.10 | 80, 443, 8080 | API Gateway, reverse proxy, routing |
| **RabbitMQ** | rabbitmq:3-management (custom) | 5672, 15672 | Async event bus |
| **Redis** | redis:7 (custom) | 6379 | Caching, notification store, session |
| **PostgreSQL** | postgres:15 | 5432 | Auth, User, Workspace databases |
| **MongoDB** | mongo:6 | 27017 | Task service (flexible schema) |
| **Prometheus** | prom/prometheus:latest | 9090 | Metrics collection |
| **Grafana** | grafana/grafana:latest | 3005 | Metrics visualization |
| **Elasticsearch** | elasticsearch:8.8.2 | 9200 | Log storage |
| **Logstash** | logstash:8.8.2 | 5044 | Log pipeline |
| **Kibana** | kibana:8.8.2 | 5601 | Log visualization |
| **Jaeger** | jaegertracing/all-in-one:1.41 | 16686, 6831/udp, 6832/udp | Distributed tracing |
| **Jenkins** | jenkins/jenkins:lts | 8081, 50000 | CI/CD |
| **k6** | loadimpact/k6:latest | — | Load testing |

### Communication Patterns
| Pattern | Technology | Use Case |
|---------|-----------|----------|
| **Async events** | RabbitMQ (exchange: `collabspace_exchange`, type: `direct`) | TASK_ASSIGNED, WORKSPACE_INVITED, COMMENT_CREATED |
| **Sync RPC** | gRPC (planned) | Cross-service data fetching (e.g., User → Workspace) |
| **HTTP routing** | Traefik PathPrefix | Client → Service via API Gateway |
| **Data joining** | API Composition / CQRS / Materialized Views | Cross-service query resolution (NO direct DB joins) |

### Network
All services share Docker network `collabspace-network` (bridge driver).

---

## §10 CODE PATTERNS

### ⚠️ POLYGLOT ARCHITECTURE — CRITICAL
**This project is NOT a monoglot stack.** Different services use different languages, frameworks, and conventions.

### Node.js Services (auth, user, workspace, task, notification)
```
# Dependencies
pnpm install

# Testing
pnpm test

# Database migrations (TypeORM-based services: auth, user, workspace)
pnpm run typeorm migration:run

# Database migrations (task-service — custom)
node migrate.js

# Seeding
pnpm run seed                # auth, user, workspace
node seed.js                 # task

# Build
docker build -t myorg/<service-name> .
```

**Patterns for Node.js services:**
- Use TypeORM for PostgreSQL (auth-service, user-service, workspace-service)
- Use native MongoDB driver or Mongoose for task-service
- JWT for authentication (secret via `JWT_SECRET` env var)
- Health endpoint convention: `GET /api/v1/<service-prefix>/health`
- Environment config via `.env` files (see `.env.example`)



### RabbitMQ Event Patterns
```
# Exchange
Name: collabspace_exchange
Type: direct
VHost: collabspace

# Queues (durable)
- task_assigned     (routing_key: "task_assigned")
- workspace_invited (routing_key: "workspace_invited")
# NOTE: comment_created queue needs to be added to definitions.json

# Publishing pattern:
# Service publishes to collabspace_exchange with routing_key
# Notification service consumes from bound queues
```

### Redis Patterns
```
# Connection
Host: redis (Docker) / localhost (dev)
Port: 6379
Password: from REDIS_PASSWORD env var
DB: from REDIS_DB env var

# Config: appendonly=yes, maxmemory=512mb, allkeys-lru policy
```

---

## §KEY_FILES

| What | Where |
|------|-------|
| **Master spec** | `workspace_collaboration_microservices_report.md` |
| **DB schemas** | `init_doc.md` |
| **Product vision** | `init_doc_2.md` |
| **Docker Compose (core)** | `collabspace/infrastructure/docker/docker-compose.yml` |
| **Docker Compose (databases)** | `collabspace/infrastructure/docker/docker-compose.db.yml` |
| **Docker Compose (dev override)** | `collabspace/infrastructure/docker/docker-compose.override.yml` |
| **Docker Compose (monitoring)** | `collabspace/infrastructure/docker/docker-compose.monitoring.yml` |
| **Docker Compose (logging)** | `collabspace/infrastructure/docker/docker-compose.logging.yml` |
| **Docker Compose (tracing)** | `collabspace/infrastructure/docker/docker-compose.tracing.yml` |
| **Docker Compose (gateway)** | `collabspace/infrastructure/docker/docker-compose.traefik.yml` |
| **Docker Compose (CI)** | `collabspace/infrastructure/docker/docker-compose.jenkins.yml` |
| **Docker Compose (load test)** | `collabspace/infrastructure/docker/docker-compose.loadtest.yml` |
| **Docker Compose (redis)** | `collabspace/infrastructure/docker/docker-composer.redis.yml` ⚠️ TYPO |
| **Traefik static config** | `collabspace/api-gateway/traefik.yml` |
| **Traefik dynamic routing** | `collabspace/api-gateway/dynamic/routers.yml` |
| **Traefik middlewares** | `collabspace/api-gateway/dynamic/middlewares.yml` |
| **RabbitMQ definitions** | `collabspace/infrastructure/rabbitmq/definitions.json` |
| **RabbitMQ entrypoint** | `collabspace/infrastructure/rabbitmq/docker-entrypoint.sh` |
| **Redis config** | `collabspace/infrastructure/redis/redis.conf` |
| **Jenkins pipeline** | `collabspace/services/auth-service/Jenkinsfile` |
| **Jenkins plugins** | `collabspace/infrastructure/jenkins/plugins.txt` |
| **K6 load test config** | `collabspace/infrastructure/load-testing/k6/config.json` |
| **DB init script** | `collabspace/scripts/init-db.sh` |
| **Migration script** | `collabspace/scripts/migrate.sh` |
| **Seed script** | `collabspace/scripts/seed.sh` |
| **Env setup** | `collabspace/scripts/env-setup.sh` |
| **Cleanup script** | `collabspace/scripts/cleanup.sh` |
| **Dev Mode (personal)** | `collabspace/infrastructure/dev/` ⚠️ GITIGNORED |

---

## §ENTITIES_OVERVIEW

### Auth Service (PostgreSQL: `collabspace_auth`)

**Users**
- `id`, `email`, `password`, `created_at`, `updated_at`

**Roles**
- `id`, `name`, `description`

**Permissions**
- `id`, `name`, `description`

**User_roles** (join table)
- `id`, `user_id`, `role_id`

### User Service (PostgreSQL: `collabspace_user`)

**Profiles**
- `id`, `user_id`, `full_name`, `avatar_url`, `bio`, `created_at`, `updated_at`
- Relationship: `user_id` references Auth.Users (cross-service, resolved via API/gRPC)

### Workspace Service (PostgreSQL: `collabspace_workspace`)

**Workspaces**
- `id`, `name`, `description`, `owner_id`, `created_at`, `updated_at`

**Workspace_members** (join table)
- `id`, `workspace_id`, `user_id`, `role_id`, `joined_at`

**Workspace_roles**
- `id`, `workspace_id`, `name`, `permissions`

### Task Service (MongoDB: `collabspace_task`)

**Tasks** (collection)
- `_id`, `title`, `description`, `workspace_id`, `assigned_to`, `status`, `due_date`, `created_at`, `updated_at`

**Task_comments** (collection)
- `_id`, `task_id`, `user_id`, `comment`, `created_at`

**Task_assignments** (collection)
- `_id`, `task_id`, `assigned_to`, `assigned_by`, `assigned_at`

### Notification Service (Redis/MongoDB)

**Notifications**
- `id`, `user_id`, `type`, `message`, `read_status`, `created_at`
- Types: `TASK_ASSIGNED`, `WORKSPACE_INVITED`, `COMMENT_CREATED`

### Cross-Service Relationships (CRITICAL)
```
Auth.Users.id ←→ User.Profiles.user_id
Auth.Users.id ←→ Workspace.Workspaces.owner_id
Auth.Users.id ←→ Workspace.Workspace_members.user_id
Auth.Users.id ←→ Task.Tasks.assigned_to
Auth.Users.id ←→ Task.Task_comments.user_id
Auth.Users.id ←→ Task.Task_assignments.assigned_to / assigned_by
Auth.Users.id ←→ Notification.Notifications.user_id
Workspace.Workspaces.id ←→ Task.Tasks.workspace_id
```
**⚠️ These are LOGICAL references, NOT foreign keys. Resolved via API Composition or gRPC. NEVER create cross-database joins.**

---

## §API_ROUTES

### Auth Service (`/auth`)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/login` | User login, returns JWT |
| POST | `/auth/register` | User registration |
| POST | `/auth/refresh` | Refresh JWT token |
| GET | `/auth/me` | Get current authenticated user |
| GET | `/api/v1/auth/health` | Health check |

### User Service (`/users`)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/{id}` | Get user profile |
| PATCH | `/users/{id}` | Update user profile |

### Workspace Service (`/workspaces`)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/workspaces` | Create workspace |
| GET | `/workspaces` | List user's workspaces |
| POST | `/workspaces/{id}/invite` | Invite member |
| GET | `/workspaces/{id}/members` | List workspace members |

### Task Service (`/tasks`)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/tasks` | Create task |
| GET | `/tasks` | List tasks (filtered by workspace) |
| PATCH | `/tasks/{id}` | Update task |
| POST | `/tasks/{id}/comments` | Add comment |
| GET | `/api/v1/tasks/health` | Health check |

### Notification Service
| Pattern | Source | Description |
|---------|--------|-------------|
| Event consumer | RabbitMQ | Listens for TASK_ASSIGNED, WORKSPACE_INVITED, COMMENT_CREATED |
| WebSocket/Push | Direct | Real-time notification delivery to connected clients |

---

## §ADD_FEATURE_WORKFLOW

### Adding a New Microservice Feature (End-to-End)

1. **Spec** — Update `init_doc.md` with new tables/fields. Update `workspace_collaboration_microservices_report.md` with new APIs.

2. **Database Schema**
   - PostgreSQL service (Node.js): Update Prisma schema → `npx prisma migrate dev --name <migration_name>`
   - PostgreSQL service (Java): Add Flyway migration → `V{n}__description.sql` in migrations folder
   - MongoDB service: Update collection schema in code (flexible schema)

3. **Backend Implementation**
   - Implement route handler / controller
   - Add input validation at API boundary
   - Add authentication middleware (verify JWT)
   - If cross-service data needed → use gRPC call or API composition
   - If event needed → publish to RabbitMQ `collabspace_exchange` with appropriate routing key

4. **RabbitMQ** (if new event type)
   - Add queue to `infrastructure/rabbitmq/definitions.json`
   - Add binding from `collabspace_exchange` to new queue
   - Add consumer in notification-service

5. **API Gateway** — Add Traefik route in `api-gateway/dynamic/routers.yml`

6. **Tests** — Unit tests in service, add k6 load test script if needed

7. **Docker** — Update Dockerfile if dependencies changed, update docker-compose if new env vars

8. **K8s** (later) — Update deployment yamls when implementing K8s manifests

---

## §ADD_SERVICE_WORKFLOW

### Adding a Completely New Microservice

1. Create service directory: `collabspace/services/<service-name>/`
2. Create `Dockerfile`, `.env.example`, `Jenkinsfile`
3. Add to `infrastructure/docker/docker-compose.yml` (service definition + network)
4. Add to `infrastructure/docker/docker-compose.override.yml` (port mapping + volume mount)
5. Add Traefik route in `api-gateway/dynamic/routers.yml`
6. Add K8s deployment in `infrastructure/k8s/<service-name>-deployment.yaml`
7. Add to `infrastructure/load-testing/k6/scripts/<service-name>.js`
8. Update `scripts/init-db.sh` if new database needed
9. Update `scripts/migrate.sh` with migration command
10. Update `scripts/seed.sh` with seed command

---

## §COMMON_GOTCHAS

### Infrastructure Gotchas

- **`docker-composer.redis.yml` TYPO** → Filename has `composer` instead of `compose`. DO NOT rename (may break existing scripts/docs). Be aware when referencing.

- **`workspace_invited` queue binding** → ✅ FIXED (2026-04-02). Binding added to `definitions.json`.

- **`comment_created` queue** → ✅ FIXED (2026-04-02). Queue + binding added to `definitions.json`.

- **All 5 services have Traefik routes** → ✅ FIXED (2026-04-02). `routers.yml` now routes auth, user, workspace, task, notification.

- **`services.yml` in Traefik dynamic config** → Documented as reference. Service definitions are inline in `routers.yml` by design.

- **Docker Compose paths are RELATIVE to compose file location** → ✅ FIXED (2026-04-03). Compose files live at `infrastructure/docker/`. Service paths must be `../../services/X`, NOT `./services/X`. RabbitMQ is `../rabbitmq` (one level up). This is the #1 gotcha — always think from the compose file's directory.

- **Jenkinsfile deploy stage must `cd` to compose directory** → ✅ FIXED (2026-04-03). Jenkins workspace root ≠ compose file directory. Always `cd ${WORKSPACE}/infrastructure/docker` before `docker-compose` commands.

- **K6 scripts use template literals (backticks)** → ✅ FIXED (2026-04-03). Authorization headers MUST use backtick template literals for `${__ENV.X}` interpolation, NOT double quotes.

### Security Gotchas

- **RabbitMQ uses `guest/guest`** → Default credentials in `definitions.json`. MUST use env vars for production. The `docker-entrypoint.sh` supports this via `RABBITMQ_DEFAULT_USER`/`RABBITMQ_DEFAULT_PASS`.

- **Redis password hardcoded** → `redis.conf` has `requirepass collabspace123`. Should reference env var instead.

- **JWT_SECRET in env-setup.sh** → `supersecretkey` is a placeholder. NEVER use in production.

- **Traefik API insecure** → `api.insecure=true` in both `traefik.yml` and `docker-compose.traefik.yml`. Dashboard is open. Disable for production.

### Architecture Gotchas

- **workspace-service runs on port 8080** → ALL other Node.js services run on 3000. When adding Traefik routes or inter-service calls, use port 8080 for workspace-service, 3000 for everything else.

- **TypeORM migrations** → Use `npm run typeorm migration:run` for auth, user, and workspace services. Always check `scripts/migrate.sh` for the canonical command.

- **MongoDB has no Prisma** → task-service uses custom `migrate.js` and `seed.js`, not Prisma. Don't generate Prisma schemas for MongoDB collections.

- **Cross-service data joining** → NEVER create foreign keys across databases. Use API Composition (HTTP/gRPC calls between services) or event-driven denormalized views (CQRS pattern).

- **Docker Compose network** → `docker-compose.yml` defines `collabspace-network` (bridge). Compose files for jenkins, redis standalone, and loadtest use `external: true` — the main compose MUST be running first to create the network.

### Empty Files Awareness
**As of 2026-04-03, ALL infrastructure files are IMPLEMENTED.** No empty scaffolds remain.

**Previously empty, now IMPLEMENTED (2026-04-02 by Agent ALPHA):**
- ~~ALL service Dockerfiles~~ → ✅ Done
- ~~.env.example files~~ → ✅ Done (all 8)
- ~~k6/scripts/user-service.js, workspace-service.js~~ → ✅ Done (+ task + notification)
- ~~jenkins/scripts/test.sh, deploy.sh~~ → ✅ Done
- ~~api-gateway/dynamic/services.yml~~ → ✅ Documented (services inline in routers.yml)

**Previously empty, now IMPLEMENTED (2026-04-03 by Agent BRAVO):**
- ~~ALL K8s manifests~~ → ✅ Done (7 deployments + services.yaml)
- ~~prometheus.yml~~ → ✅ Done (all 7 scrape targets + infrastructure)
- ~~grafana-dashboards/service-health.json~~ → ✅ Done
- ~~logstash-config.conf~~ → ✅ Done (complete pipeline)
- ~~jaeger-config.yaml~~ → ✅ Done
- ~~README.md~~ → ✅ Done (full quickstart guide)
- ~~Logging/tracing K8s deployments~~ → ✅ Done

**Implemented (2026-04-03, Session 2 hardening):**
- K8s Ingress (IngressRoute for Traefik CRD) → ✅ `ingress.yaml`
- K8s Database StatefulSets → ✅ `postgres-statefulset.yaml`, `mongo-statefulset.yaml`, `redis-statefulset.yaml`, `rabbitmq-statefulset.yaml`
- K8s NetworkPolicies → ✅ `network-policies.yaml`
- .dockerignore files → ✅ All 5 services
- DB healthchecks in docker-compose.db.yml → ✅ postgres, mongo, redis
- Prometheus retention policy → ✅ 15d / 2GB + persistent volumes

---

## §PROACTIVE_DESIGN_PRINCIPLES

### 1. Consistency Across Services
**If auth-service does X, user-service MUST do X too** (where applicable).
- Every service needs a health endpoint: `GET /api/v1/<prefix>/health`
- Every service needs structured JSON logging
- Every service needs Prometheus metrics endpoint
- Every Dockerfile follows the same multi-stage build pattern
- Every service has a Jenkinsfile

### 2. Database-Per-Service is SACRED
- auth-service → `collabspace_auth` (PostgreSQL)
- user-service → `collabspace_user` (PostgreSQL)
- workspace-service → `collabspace_workspace` (PostgreSQL)
- task-service → `collabspace_task` (MongoDB)
- notification-service → Redis + optionally MongoDB
- **NEVER share a database between services. NEVER create cross-database references.**

### 3. Event-Driven Architecture
When an action in one service affects another:
1. Service A publishes event to `collabspace_exchange` with routing key
2. Service B consumes from its bound queue
3. **ALWAYS add queue + binding in `rabbitmq/definitions.json` when adding new event types**
4. Notification-service is the PRIMARY consumer — it listens for all events and dispatches notifications

### 4. API Gateway is the Single Entry Point
- Clients NEVER call services directly (only in dev via override ports)
- ALL routes go through Traefik PathPrefix rules
- Auth middleware applied at gateway level where needed
- When adding a service, ALWAYS add its Traefik route

### 5. Full-Stack Thinking for Microservices
When fixing/adding a feature, think across ALL layers:
- Does the API route exist in Traefik?
- Does the database schema support the data?
- Does RabbitMQ have the right queues/bindings?
- Does the notification service handle the event?
- Does the Dockerfile include all dependencies?
- Is the docker-compose updated?

### 6. Backend Is Source of Truth for Types
When there's a mismatch between services:
1. Read the PRODUCING service's code first
2. The database schema wins
3. Consumer services must adapt to producer's contract
4. **Cite the source** — "File X, line Y shows..."

---

## §ENVIRONMENT_VARIABLES

### Shared Variables
| Variable | Value (dev) | Used By |
|----------|-------------|---------|
| `POSTGRES_HOST` | `localhost` / `postgres` (Docker) | auth, user, workspace |
| `POSTGRES_USER` | `postgres` | auth, user, workspace |
| `POSTGRES_PASSWORD` | `postgres` | auth, user, workspace |
| `MONGO_URI` | `mongodb://localhost:27017` / `mongodb://mongo:27017` | task |
| `REDIS_HOST` | `localhost` / `redis` (Docker) | notification |
| `REDIS_PORT` | `6379` | notification |
| `REDIS_PASSWORD` | from `.env` (dev: `collabspace123`) | notification, redis |
| `JWT_SECRET` | from `.env` (NEVER hardcode) | auth (issuer), all services (validator) |

### RabbitMQ Variables
| Variable | Default | Purpose |
|----------|---------|---------|
| `RABBITMQ_DEFAULT_USER` | `guest` | RabbitMQ username |
| `RABBITMQ_DEFAULT_PASS` | `guest` | RabbitMQ password |
| `RABBITMQ_DEFAULT_VHOST` | `/` | RabbitMQ virtual host (should be `collabspace`) |

### K6 Load Testing Variables
| Variable | Purpose |
|----------|---------|
| `K6_SCRIPT` | Script filename to run |
| `K6_VUS` | Number of virtual users |
| `K6_DURATION` | Test duration |

### Per-Service `.env`
Each service has its own `.env` file (create from `.env.example`). The Docker Compose files reference these via `env_file`.

---

## §DATABASES

### PostgreSQL Databases
```sql
CREATE DATABASE collabspace_auth;      -- Auth Service
CREATE DATABASE collabspace_user;      -- User Service
CREATE DATABASE collabspace_workspace; -- Workspace Service
```

### MongoDB Databases
```javascript
use collabspace_task;  // Task Service (auto-created on first write)
```

### Redis
```
# Used by notification-service for:
# - Real-time notification storage
# - Pub/Sub for WebSocket delivery
# - Session/cache if needed
# Config: appendonly=yes, maxmemory=512mb, allkeys-lru
```

---

## §CI_CD

### Jenkins Pipeline (Reference: auth-service Jenkinsfile)
```
1. Checkout → git clone from main branch
2. Build & Test → npm install && npm test
3. Build Docker Image → docker build -t $REGISTRY/$IMAGE:latest .
4. Push Docker Image → docker push (credentials: docker-hub)
5. Deploy → docker-compose up -d <service>
```

### Jenkins Plugins
- workflow-aggregator (Pipeline)
- docker-plugin
- blueocean (UI)
- git
- credentials-binding
- pipeline-stage-view

### Jenkins Access
- Port: 8081 (mapped from 8080)
- Agent port: 50000
- Scripts: mounted at `/usr/local/bin/scripts`

---

## §MONITORING_LOGGING_TRACING

### Monitoring Stack (Prometheus + Grafana)
- **Prometheus** (:9090) — scrapes `/metrics` endpoints from services
- **Grafana** (:3005) — dashboards at `monitoring/grafana-dashboards/`
- Metrics to expose: request count, request latency, CPU, memory, error rate

### Logging Stack (ELK)
- **Elasticsearch** (:9200) — log storage (single-node, 512MB heap)
- **Logstash** (:5044) — log pipeline (config at `logging/logstash-config.conf`)
- **Kibana** (:5601) — log visualization
- Services should emit structured JSON logs to stdout → Docker log driver → Logstash

### Tracing (Jaeger)
- **Jaeger** (:16686 UI, :6831 UDP agent, :6832 UDP collector)
- Services propagate trace context via headers
- OpenTelemetry / Jaeger client SDK in each service

---

## §K8S_DEPLOYMENT

All K8s manifests are at `infrastructure/k8s/` — **ALL IMPLEMENTED** as of 2026-04-03.

| File | Purpose | Status |
|------|---------|--------|
| `auth-deployment.yaml` | Auth service Deployment + ConfigMap + Secret | ✅ Done |
| `user-deployment.yaml` | User service Deployment + ConfigMap + Secret | ✅ Done |
| `workspace-deployment.yaml` | Workspace service Deployment (port 8080, JVM tuned) | ✅ Done |
| `task-deployment.yaml` | Task service Deployment + ConfigMap + Secret | ✅ Done |
| `notification-deployment.yaml` | Notification service Deployment + ConfigMap + Secret | ✅ Done |
| `traefik-deployment.yaml` | Traefik Ingress Controller + RBAC + ConfigMap | ✅ Done |
| `services.yaml` | ClusterIP Services for all 5 app services | ✅ Done |
| `ingress.yaml` | Traefik IngressRoute CRD + Middlewares | ✅ Done |
| `postgres-statefulset.yaml` | PostgreSQL StatefulSet + PVC + init script | ✅ Done |
| `mongo-statefulset.yaml` | MongoDB StatefulSet + PVC | ✅ Done |
| `redis-statefulset.yaml` | Redis StatefulSet + PVC + config | ✅ Done |
| `rabbitmq-statefulset.yaml` | RabbitMQ StatefulSet + PVC + config | ✅ Done |
| `network-policies.yaml` | Default deny + per-service ingress rules | ✅ Done |

K8s conventions used:
- Namespace: `collabspace`
- Container ports match docker-compose internal ports
- ConfigMaps/Secrets for environment variables
- Resource limits (CPU/memory) on all pods
- Readiness/liveness probes using health endpoints
- StatefulSets with PersistentVolumeClaims for databases
- NetworkPolicies for service isolation
- Traefik IngressRoute CRD for external routing

---

## §MULTI_REPO_NOTE

This workspace currently uses a **monorepo structure** under `collabspace/`. However, the CI/CD Jenkinsfile references external git repos (`https://github.com/myorg/auth-service.git`), suggesting the eventual structure may split into per-service repos.

**Current approach:** Work within the monorepo. If splitting, each `services/<name>/` becomes its own repo. Update Jenkinsfiles accordingly.

---

## §IMPLEMENTATION_PRIORITY

### What's Built (Infrastructure Shell)
✅ Docker Compose orchestration (all compose files + DB healthchecks + depends_on conditions)
✅ Traefik API Gateway config (ALL 5 routes + rate-limit + CORS middlewares)
✅ RabbitMQ setup (3 queues, 3 bindings, 1 exchange — complete)
✅ Redis setup (complete)
✅ Project scaffolding (all directories)
✅ Scripts (init-db, migrate, seed, cleanup, env-setup)
✅ Jenkins pipeline templates (ALL 5 services have Jenkinsfiles, deploy stages with correct paths)
✅ K6 load test scripts (ALL 5 services, __ENV.BASE_URL + template literals)
✅ ALL 5 service Dockerfiles (multi-stage, non-root, healthcheck) + .dockerignore
✅ ALL 8 .env.example files (with example dev values)
✅ Jenkins scripts (test.sh polyglot-aware, deploy.sh with health check)
✅ ALL K8s manifests — 7 deployments + services.yaml + ingress + 4 database StatefulSets + NetworkPolicies
✅ Prometheus config (all 7 scrape targets, retention policy 15d/2GB)
✅ Grafana dashboard (service-health.json) + persistent volumes
✅ Logstash config (complete input/filter/output pipeline)
✅ Jaeger config (sampling config for all 5 services)
✅ README.md (complete with quick start, team, API routes)

### What Needs Implementation
🔴 ALL service source code — no business logic exists
🟡 K8s ServiceMonitor CRDs — Prometheus auto-discovery in K8s (optional if using manual scrape_configs)
🟡 Database metric exporters — redis_exporter, postgres_exporter, mongodb_exporter sidecars
🟡 Traefik TLS/HTTPS — only HTTP configured (acceptable for dev)
🟡 Grafana provisioning automation — K8s auto-provisioning of datasources/dashboards

### Recommended Build Order
```
1. Service source code (auth → user → workspace → task → notification)
2. Dockerfiles for each service
3. Complete Traefik routing
4. Complete RabbitMQ definitions
5. Fill .env.example files
6. Prometheus + Grafana config
7. Logstash + Jaeger config
8. K8s manifests
9. Remaining Jenkins scripts + K6 tests
10. README.md documentation
```

---

## §LANGUAGE_NOTES

The spec documents (`init_doc.md`, `init_doc_2.md`) are written in **Vietnamese**. Key translations:

| Vietnamese | English |
|-----------|---------|
| Chức năng | Feature/Function |
| Bảng | Table |
| Mục đích | Purpose |
| Thông tin | Information |
| Quản lý | Management |
| Xác thực | Authentication |
| Phân quyền | Authorization |
| Thành viên | Member |
| Người dùng | User |
| Mời | Invite |
| Tạo | Create |
| Cập nhật | Update |
| Lấy | Get/Retrieve |
| Gửi | Send |
| Nhận | Receive |
| Lưu trữ | Store |
| Danh sách | List |
| Sự kiện | Event |
| Bất đồng bộ | Asynchronous |
| Đồng bộ | Synchronous |

---

*Brain updated: 2026-05-11. Convergence completed. Services (NestJS, Java) are implemented on main. Infrastructure hardened with real ForwardAuth, pnpm, observability exporters, K8s HPA, and /api/v1/ route prefixes.*
