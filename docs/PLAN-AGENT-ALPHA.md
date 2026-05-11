# AGENT ALPHA — Build & Connect
## Domain: Dockerfiles, .env, API Gateway, RabbitMQ, CI/CD, Load Testing
## Operator: Phan Phú Thọ (Infrastructure Engineer)
## Constraint: NEVER touch files assigned to Agent BRAVO

---

## IDENTITY
You are Agent ALPHA. You build the **foundation** — everything needed for services to compile, connect, route, test, and deploy. Your work enables the other team members to actually run their code.

---

## YOUR FILES (EXCLUSIVE — only YOU touch these)

### Phase A1: Dockerfiles (5 files — all EMPTY)
```
collabspace/services/auth-service/Dockerfile          ← Node.js multi-stage
collabspace/services/user-service/Dockerfile           ← Node.js multi-stage
collabspace/services/workspace-service/Dockerfile      ← Java/Gradle multi-stage (PORT 8080!)
collabspace/services/task-service/Dockerfile           ← Node.js multi-stage
collabspace/services/notification-service/Dockerfile   ← Node.js multi-stage
```

### Phase A2: Environment Examples (8 files — 4 EMPTY, 4 SCAFFOLDED)
```
collabspace/services/auth-service/.env.example         ← SCAFFOLDED (has NODE_ENV, DATABASE_URL)
collabspace/services/user-service/.env.example         ← EMPTY
collabspace/services/workspace-service/.env.example    ← EMPTY
collabspace/services/task-service/.env.example         ← EMPTY
collabspace/services/notification-service/.env.example ← EMPTY
collabspace/infrastructure/rabbitmq/.env.example       ← SCAFFOLDED (has keys, no values)
collabspace/infrastructure/redis/.env.example          ← SCAFFOLDED (has keys, no values)
collabspace/infrastructure/load-testing/k6/.env.example ← SCAFFOLDED (has K6_SCRIPT only)
```

### Phase A3: API Gateway Completion (3 files — 2 SCAFFOLDED, 1 EMPTY)
```
collabspace/api-gateway/dynamic/routers.yml       ← SCAFFOLDED (has auth + workspace, needs user/task/notification)
collabspace/api-gateway/dynamic/middlewares.yml    ← SCAFFOLDED (has auth-header only, needs rate-limit, CORS)
collabspace/api-gateway/dynamic/services.yml      ← EMPTY
```

### Phase A4: RabbitMQ Fix (1 file — SCAFFOLDED)
```
collabspace/infrastructure/rabbitmq/definitions.json  ← Missing workspace_invited binding + comment_created queue+binding
```

### Phase A5: CI/CD Pipeline (6 files — 2 EMPTY, 4 NEW)
```
collabspace/infrastructure/jenkins/scripts/test.sh    ← EMPTY
collabspace/infrastructure/jenkins/scripts/deploy.sh  ← EMPTY
collabspace/services/user-service/Jenkinsfile          ← NEW (create)
collabspace/services/workspace-service/Jenkinsfile     ← NEW (create)
collabspace/services/task-service/Jenkinsfile          ← NEW (create)
collabspace/services/notification-service/Jenkinsfile  ← NEW (create)
```

### Phase A6: Load Testing (4 files — 2 EMPTY, 1 SCAFFOLDED, 2 NEW)
```
collabspace/infrastructure/load-testing/k6/scripts/user-service.js       ← EMPTY
collabspace/infrastructure/load-testing/k6/scripts/workspace-service.js  ← EMPTY
collabspace/infrastructure/load-testing/k6/scripts/task-service.js       ← NEW (create)
collabspace/infrastructure/load-testing/k6/scripts/notification-service.js ← NEW (create)
collabspace/infrastructure/load-testing/k6/config.json                   ← SCAFFOLDED (needs all services)
```

**TOTAL: 27 files (17 existing + 6 new Jenkinsfiles/K6 + 4 .env fixes)**

---

## EXECUTION ORDER (STRICT — do NOT skip ahead)

### Step A1: Dockerfiles
**WHY FIRST:** Nothing builds without these. Teammates are blocked.

**Node.js Pattern (auth, user, task, notification):**
```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npx prisma generate  # Only for Prisma services (auth, user)

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
CMD ["node", "src/index.js"]
```

**Java/Gradle Pattern (workspace-service ONLY):**
```dockerfile
FROM gradle:8-jdk17 AS builder
WORKDIR /app
COPY . .
RUN gradle build --no-daemon -x test

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**CRITICAL REMINDER:**
- workspace-service = port **8080**, NOT 3000
- task-service uses MongoDB, NOT Prisma — no `prisma generate`
- notification-service uses Redis — no Prisma either

### Step A2: .env.example Files
**WHY SECOND:** Teams need .env to configure locally.

Fill each with all required variables + example dev values:
- auth: NODE_ENV, DATABASE_URL, JWT_SECRET, JWT_EXPIRY, PORT
- user: NODE_ENV, DATABASE_URL, PORT
- workspace: SPRING_DATASOURCE_URL, SPRING_DATASOURCE_USERNAME, SPRING_DATASOURCE_PASSWORD, SERVER_PORT
- task: NODE_ENV, MONGO_URI, PORT, RABBITMQ_URL
- notification: NODE_ENV, REDIS_HOST, REDIS_PORT, REDIS_PASSWORD, REDIS_DB, RABBITMQ_URL, PORT
- rabbitmq: RABBITMQ_DEFAULT_USER=admin, RABBITMQ_DEFAULT_PASS=admin123, RABBITMQ_DEFAULT_VHOST=collabspace
- redis: REDIS_PASSWORD=collabspace123, REDIS_PORT=6379, REDIS_DB=0
- k6: K6_SCRIPT=auth-service.js, K6_VUS=50, K6_DURATION=30s

### Step A3: API Gateway
**WHY THIRD:** Services can now build → make them reachable.

Add to routers.yml:
- user-router: PathPrefix(`/users`) → http://user-service:3000
- task-router: PathPrefix(`/tasks`) → http://task-service:3000
- notification-router: PathPrefix(`/notifications`) → http://notification-service:3000

Add to middlewares.yml:
- rate-limit middleware (average: 100, burst: 50)
- CORS headers middleware (allow origins, methods, headers)

services.yml: Define all 5 service load balancers (or leave empty if inline in routers.yml)

### Step A4: RabbitMQ Fix
**WHY FOURTH:** Events must propagate correctly.

Add to definitions.json:
1. Binding: collabspace_exchange → workspace_invited (routing_key: "workspace_invited")
2. Queue: comment_created (durable: true, vhost: collabspace)
3. Binding: collabspace_exchange → comment_created (routing_key: "comment_created")

### Step A5: CI/CD
**WHY FIFTH:** Automate what works.

test.sh: Generic — detect service type (Node vs Gradle), run appropriate test command
deploy.sh: Generic — docker-compose pull + up -d for the named service
Jenkinsfiles: Follow auth-service/Jenkinsfile pattern, update IMAGE_NAME and git URL per service

### Step A6: Load Testing
**WHY LAST:** Stress test the proven system.

Each K6 script: Hit health endpoint + key API endpoints with 50 VUs for 30s
Update config.json with all 5 services' base URLs and health endpoints

---

## VERIFICATION CHECKLIST (before marking complete)
- [ ] All 5 Dockerfiles written and syntactically valid
- [ ] All 8 .env.example files have all required keys + example values
- [ ] routers.yml has routes for ALL 5 services
- [ ] definitions.json has 3 queues, 3 bindings, 1 exchange
- [ ] All 5 services have Jenkinsfiles
- [ ] test.sh and deploy.sh are executable scripts
- [ ] All 5 services have K6 load test scripts
- [ ] config.json lists all 5 services
- [ ] NO files from Agent BRAVO's list were touched

---

## FORBIDDEN FILES (Agent BRAVO owns these — DO NOT TOUCH)
```
infrastructure/monitoring/*
infrastructure/logging/*
infrastructure/tracing/*
infrastructure/k8s/*
collabspace/README.md
```
