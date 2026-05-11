# AGENT BRAVO — Observe & Orchestrate
## Domain: Monitoring, Logging, Tracing, Kubernetes, Documentation
## Operator: Phan Phú Thọ (Infrastructure Engineer)
## Constraint: NEVER touch files assigned to Agent ALPHA

---

## IDENTITY
You are Agent BRAVO. You build the **observability and orchestration layer** — everything needed, after services are running in Docker, to monitor them, trace them, log them, deploy them to Kubernetes, and document the whole system.

---

## YOUR FILES (EXCLUSIVE — only YOU touch these)

### Phase B1: Monitoring (3 files — all EMPTY)
```
collabspace/infrastructure/monitoring/prometheus.yml                          ← EMPTY
collabspace/infrastructure/monitoring/grafana-dashboards/service-health.json  ← EMPTY
collabspace/infrastructure/monitoring/grafana-deployment.yaml                 ← EMPTY (K8s)
```

### Phase B2: Logging (3 files — all EMPTY)
```
collabspace/infrastructure/logging/logstash-config.conf          ← EMPTY
collabspace/infrastructure/logging/elasticsearch-deployment.yaml ← EMPTY (K8s)
collabspace/infrastructure/logging/kibana-deployment.yaml        ← EMPTY (K8s)
```

### Phase B3: Tracing (2 files — all EMPTY)
```
collabspace/infrastructure/tracing/jaeger-config.yaml        ← EMPTY
collabspace/infrastructure/tracing/jaeger-deployment.yaml    ← EMPTY (K8s)
```

### Phase B4: Kubernetes — Application Services (7 files — all EMPTY)
```
collabspace/infrastructure/k8s/auth-deployment.yaml          ← EMPTY
collabspace/infrastructure/k8s/user-deployment.yaml          ← EMPTY
collabspace/infrastructure/k8s/workspace-deployment.yaml     ← EMPTY
collabspace/infrastructure/k8s/task-deployment.yaml          ← EMPTY
collabspace/infrastructure/k8s/notification-deployment.yaml  ← EMPTY
collabspace/infrastructure/k8s/traefik-deployment.yaml       ← EMPTY
collabspace/infrastructure/k8s/services.yaml                 ← EMPTY
```

### Phase B5: Documentation (1 file — EMPTY)
```
collabspace/README.md  ← EMPTY
```

**TOTAL: 16 files (all existing, all EMPTY)**

---

## EXECUTION ORDER (STRICT — do NOT skip ahead)

### Step B1: Prometheus Config
**WHY FIRST:** Monitoring is the eyes of the system. Without it, we're blind.

**File:** `infrastructure/monitoring/prometheus.yml`

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'auth-service'
    static_configs:
      - targets: ['auth-service:3000']
    metrics_path: '/auth/metrics'

  - job_name: 'user-service'
    static_configs:
      - targets: ['user-service:3000']
    metrics_path: '/users/metrics'

  - job_name: 'workspace-service'
    static_configs:
      - targets: ['workspace-service:8080']
    metrics_path: '/workspaces/metrics'

  - job_name: 'task-service'
    static_configs:
      - targets: ['task-service:3000']
    metrics_path: '/tasks/metrics'

  - job_name: 'notification-service'
    static_configs:
      - targets: ['notification-service:3000']
    metrics_path: '/notifications/metrics'

  - job_name: 'traefik'
    static_configs:
      - targets: ['traefik:8080']

  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
```

**CRITICAL REMINDER:**
- workspace-service = port **8080**, NOT 3000
- All Node services = port **3000**
- Traefik exposes metrics on dashboard port **8080**

### Step B2: Grafana Dashboard
**WHY SECOND:** Prometheus collects → Grafana visualizes.

**File:** `infrastructure/monitoring/grafana-dashboards/service-health.json`

Create a Grafana dashboard JSON with panels for:
- Request rate per service (rate of HTTP requests)
- Request latency (p50, p95, p99) per service
- Error rate (4xx, 5xx) per service
- Service up/down status
- CPU and memory usage per container

Use Prometheus as datasource. Follow Grafana dashboard JSON model.

### Step B3: Logstash Pipeline Config
**WHY THIRD:** Services emit logs → Logstash processes → Elasticsearch stores.

**File:** `infrastructure/logging/logstash-config.conf`

```conf
input {
  tcp {
    port => 5044
    codec => json_lines
  }
}

filter {
  if [service] {
    mutate {
      add_field => { "[@metadata][index]" => "collabspace-%{service}" }
    }
  } else {
    mutate {
      add_field => { "[@metadata][index]" => "collabspace-unknown" }
    }
  }

  date {
    match => [ "timestamp", "ISO8601" ]
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "%{[@metadata][index]}-%{+YYYY.MM.dd}"
  }
}
```

### Step B4: Jaeger Config
**WHY FOURTH:** Tracing follows logging — correlate requests across services.

**File:** `infrastructure/tracing/jaeger-config.yaml`

Configure Jaeger collector sampling strategy:
- Default: probabilistic sampling at 1.0 (sample everything in dev)
- Per-service overrides if needed
- Storage: in-memory for dev (all-in-one image handles this)

### Step B5: Kubernetes Manifests — Application Services
**WHY FIFTH:** Docker Compose is proven → now translate to K8s.

**For each service deployment YAML, include:**
1. `Deployment` (replicas: 2, namespace: collabspace)
2. `ConfigMap` (environment variables from .env.example)
3. Readiness probe: `GET /<prefix>/health` on internal port
4. Liveness probe: same endpoint, higher thresholds
5. Resource limits: 256Mi memory, 250m CPU (requests: 128Mi, 100m)

**Port mapping reference (CRITICAL):**
| Service | Container Port | Note |
|---------|---------------|------|
| auth-service | 3000 | Node.js |
| user-service | 3000 | Node.js |
| workspace-service | **8080** | **Java/Gradle** |
| task-service | 3000 | Node.js |
| notification-service | 3000 | Node.js |

**Health endpoint reference:**
| Service | Health Path |
|---------|------------|
| auth-service | `/auth/health` |
| user-service | `/users/health` |
| workspace-service | `/workspaces/health` |
| task-service | `/tasks/health` |
| notification-service | `/notifications/health` |

### Step B6: Kubernetes — services.yaml
**WHY SIXTH:** Deployments need ClusterIP services to be addressable.

**File:** `infrastructure/k8s/services.yaml`

Define ClusterIP services for all 5 application services:
- auth-service: port 3000 → targetPort 3000
- user-service: port 3000 → targetPort 3000
- workspace-service: port 8080 → targetPort 8080
- task-service: port 3000 → targetPort 3000
- notification-service: port 3000 → targetPort 3000

### Step B7: Kubernetes — Traefik Ingress Controller
**WHY SEVENTH:** Services are deployed → route external traffic.

**File:** `infrastructure/k8s/traefik-deployment.yaml`

Deploy Traefik as Ingress Controller:
- ServiceAccount + ClusterRole + ClusterRoleBinding
- Deployment with traefik:v2.10 image
- Service type LoadBalancer on ports 80, 443, 8080
- Mount dynamic config from ConfigMap

### Step B8: Kubernetes — Observability Stack
**WHY EIGHTH:** Infrastructure pods for monitoring/logging/tracing in K8s.

**Files:**
- `infrastructure/monitoring/grafana-deployment.yaml` — Grafana K8s deployment + service
- `infrastructure/logging/elasticsearch-deployment.yaml` — Elasticsearch K8s deployment + service
- `infrastructure/logging/kibana-deployment.yaml` — Kibana K8s deployment + service
- `infrastructure/tracing/jaeger-deployment.yaml` — Jaeger K8s deployment + service

Each follows the pattern:
- Deployment with 1 replica
- Service (ClusterIP)
- Appropriate resource limits
- Volume mounts where needed (Grafana dashboards, Logstash config)

### Step B9: README.md
**WHY LAST:** Document the fully built system.

**File:** `collabspace/README.md`

Include:
1. Project name and description
2. Architecture diagram (ASCII)
3. Service table (name, tech, port, database)
4. Quick start guide (docker-compose commands)
5. Development setup (env files, migrations)
6. Team members and responsibilities
7. Infrastructure components
8. Monitoring/Logging/Tracing URLs
9. CI/CD pipeline overview
10. Kubernetes deployment instructions

---

## VERIFICATION CHECKLIST (before marking complete)
- [ ] prometheus.yml scrapes all 5 services + traefik + self
- [ ] service-health.json is valid Grafana dashboard JSON
- [ ] logstash-config.conf has input/filter/output pipeline
- [ ] jaeger-config.yaml configures sampling strategy
- [ ] All 5 service K8s deployments have correct ports, probes, resources
- [ ] services.yaml defines ClusterIP for all 5 services
- [ ] traefik-deployment.yaml is a complete Ingress Controller setup
- [ ] All 4 observability K8s deployments are valid
- [ ] README.md covers architecture, setup, team, monitoring
- [ ] NO files from Agent ALPHA's list were touched

---

## FORBIDDEN FILES (Agent ALPHA owns these — DO NOT TOUCH)
```
services/*/Dockerfile
services/*/.env.example
services/*/Jenkinsfile (except auth — already exists)
api-gateway/dynamic/*
infrastructure/rabbitmq/definitions.json
infrastructure/jenkins/scripts/*
infrastructure/load-testing/*
infrastructure/rabbitmq/.env.example
infrastructure/redis/.env.example
```
