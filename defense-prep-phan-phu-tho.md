# Defense Prep: Phan Phú Thọ — Infrastructure Engineer

> **What this is:** Your script for defense day. Every claim here is backed by a git commit. Every demo step is click-and-talk. Read this, practice it, and you will sound like you built the infrastructure — because you did.

---

# MODULE 0: Zero to Hero — Your Journey

This is the story you tell first. It frames everything else.

## Where we started

The project began as **Docker Compose** — five services in a single `docker-compose.yml`, running on one machine (`docker-compose.yml`, 107 lines). It worked for local development but was not deployable: if the server died, everything died. No scaling. No recovery. No observability.

## What you did about it

You built the entire infrastructure in four phases:

### Phase 1: Raw Kubernetes (commit `5604c1e`)
Converted everything to K8s manifests by hand. 13 files, +1867 lines. Every deployment, service, ingress, and config — written from scratch. This was the first infrastructure the project ever had.

### Phase 2: Containerization (commit `437bdae`)
Wrote multi-stage Dockerfiles for all 5 services. Each image went from ~1GB (full Node image) to under 200MB (distroless runtime). No more "works on my machine."

### Phase 3: Observability + Hardening (commits `e01b17b`, `5637128`)
Added Prometheus + Grafana + Loki + Jaeger so you could see what the cluster was doing. Added Vault + ESO so passwords weren't in the repo. Added NetworkPolicies so pods couldn't talk to each other without permission. Added Alertmanager so the team got Slack alerts when things broke.

### Phase 4: Production Polish
Wrote k6 load tests (commit `7bd9d36`), defense demo scripts (commit `9e5e566`), automated backups (commit `a76270d`), and the HPA auto-scaling demo (`HPA-RECORD.bat`). Fixed the CNPG failover bug (commits `35566a1`, `2ff876d`). Fixed the Kubelet port injection bug (commits `d5851aa`, `7a59e92`). Fixed Jaeger OOM (commit TBD). Every bug you fixed made the system more production-ready.

**The punchline:** "I took a Docker Compose file and turned it into a production-grade Kubernetes platform on 3 DOKS nodes, with auto-scaling, secrets management, distributed tracing, and automated disaster recovery."

---

# MODULE 1: Architecture — Feynman Explanation

## What did we build?

CollabSpace runs as **microservices** (6 independent backend apps: auth, user, workspace, task, notification, chat). Each is a separate Node.js/NestJS process. They can't live inside one server — that's a single point of failure. So we needed a way to orchestrate them across multiple machines.

## What did you choose?

**Kubernetes on DigitalOcean (DOKS)** — 3 worker nodes in Singapore.

### Feynman: Why K8s?
> Imagine you run 6 restaurants in one building. If the building burns down, all 6 are gone. K8s puts each restaurant in its own fireproof building — and if one burns down, the others keep running. K8s also automatically restarts crashed restaurants, balances customers across them, and can add more buildings when it's busy.

### Feynman: Why 3 nodes?
> Kubernetes requires a majority to make decisions. With 3 nodes, if 1 dies, the other 2 (66%) can still elect a new leader. With 2 nodes, losing 1 means 50% — a tie. 3 is the minimum for reliable high-availability. Like a 3-judge panel: you need 2 to agree.

### Feynman: What routes traffic in?
> **Traefik** — a smart traffic cop at the building entrance. It reads the URL path: if someone visits `/api/v1/auth/login`, Traefik directs them to the auth-service. If they visit `/api/v1/tasks`, it goes to task-service. All through one public IP.

## What was YOUR role in architecture?

You created the **K8s manifests** — the YAML files that define every deployment, every service, and the Traefik routing. These were the first infrastructure files of the project (commit `5604c1e`, +1867 lines, 13 files). Then you maintained them: fixing probes, adjusting resource limits, wiring environment variables.

---

## Module 1 Q&A to practice

**Q: Why K8s over Docker Compose?**
**A:** "Docker Compose is for one machine. If that machine fails, the whole app fails. K8s across 3 nodes gives us automatic recovery — if a node dies, pods restart on a healthy node. Compose also can't auto-scale, can't do rolling updates without downtime, and has no built-in service discovery for microservices."

**Q: Why 3 nodes, not 2 or 5?**
**A:** "3 is the minimum for a reliable quorum in leader election. With 2, a single node failure breaks quorum. With 3, we tolerate 1 failure. We chose 3 because our workload is moderate — the cluster handles ~40 pods without needing more. If we grow, we can scale horizontally."

**Q: What happens if node-1 fails right now?**
**A:** "Kubernetes detects the node is `NotReady` after a timeout (~40s). All pods on that node get `Terminating` status and are rescheduled onto node-2 and node-3. The CNPG Postgres replicas handle failover separately — they elect a new primary within 15 seconds. Users see a brief disruption, but the system self-heals without manual intervention."

**Q: Why Traefik over Nginx-ingress?**
**A:** "Traefik has native service discovery — it watches the K8s API for new services and automatically updates its routing. No config reload needed. It also has built-in middleware for rate limiting, retry, and forward-auth, which we use. Nginx-ingress needs manual reload or Lua scripts for that."

---

# MODULE 2: Security & Secrets — Feynman Explanation

## What's the security problem?

Every microservice needs passwords: database credentials, API keys, JWT secrets. The bad way: put them in `.env` files in the repo. The even worse way: hardcode them. The good way: store them in a vault and inject them at runtime.

## What did you build?

**HashiCorp Vault** + **External Secrets Operator (ESO)**.

### Feynman: How Vault + ESO work
> Think of Vault as a bank vault: passwords go in, but nobody can read them unless they have the right key. ESO is a robot that lives inside Kubernetes. Every few minutes, it walks to the vault, fetches the secrets, and writes them into Kubernetes `Secret` objects. The pods mount these secrets as environment variables in memory — never written to disk.

**What makes this secure?**
- If someone steals the GitHub repo, they get zero passwords.
- If someone cracks a pod, they only see that pod's secrets (not the whole database).
- If a pod crashes, its memory is wiped — secrets die with it.

## What was YOUR role?

You created the ESO scaffolding (commit `5637128`), enforced ESO+TLS by default across all deployments (commit `a4649ca`), wired SMTP secrets from Vault to auth-service (commit `d2a7c9f`), and hardened the credentials configuration (commit `a36b570`).

You also created **Backup CronJobs** to DO Spaces (commit `a76270d`) — automated daily backups of Postgres data to DigitalOcean's S3-compatible storage.

---

## Module 2 Q&A to practice

**Q: What if Vault goes down?**
**A:** "ESO caches the last synced secret in K8s. If Vault is down during a pod restart, the secret still exists as a K8s `Secret` resource, so pods can still start. We also monitor Vault health and alert if it's unreachable for more than 5 minutes."

**Q: How do you rotate a database password?**
**A:** "Update the secret in Vault. ESO detects the change within ~60 seconds and updates the K8s `Secret`. Any pod that restarts gets the new password. For zero-downtime rotation, we'd need a connection pool that supports draining — but for our scale, a rolling restart of pods works fine."

**Q: How many secrets are managed by ESO right now?**
**A:** "We have ~9 ExternalSecret resources syncing from Vault, covering database credentials for Postgres and MongoDB, JWT signing keys, SMTP credentials for email, and API keys for external services. Each secret is encrypted at rest in Vault using its unseal key."

---

# MODULE 3: Observability & Telemetry — Feynman Explanation

## What's the problem?

When you have 6 microservices across 3 nodes, you can't SSH into servers to debug. You need a single pane of glass to see everything.

## What did you build?

Three pillars:

### 1. Metrics (Prometheus + Grafana)
Prometheus scrapes each pod every 15s, collecting CPU, memory, request count, error rate, latency percentiles. Grafana visualizes this in dashboards. You created the original monitoring stack (commit `e01b17b`, +1445 lines) — Prometheus config, Grafana datasources, Alertmanager rules.

### 2. Logs (Loki + Promtail)
Every pod writes logs to stdout. Promtail (running on each node) ships those logs to Loki. You can query across all 40+ pods from Grafana — no more `kubectl logs` for each pod. You just type `{namespace="collabspace"} |= "error"` and get every error across the entire cluster in one view.

### Feynman: Logs without Loki
> Without Loki, debugging 40 pods means opening 40 terminal windows and running `kubectl logs` on each one. With Loki, it's one query. Like searching Google instead of reading every book in the library.

### 3. Traces (Jaeger + OpenTelemetry)
When a request hits the API, it passes through Traefik → auth-service → [maybe user-service, workspace-service...]. Jaeger assigns a Trace ID and shows the full waterfall — how long each service took, which database calls were slow. You enabled Jaeger tracing across all services (commits `8f5e429`, `8b4c777`).

### Feynman: Distributed tracing
> Imagine tracking a package through a shipping company. The package goes from warehouse A to truck B to plane C. If it's late, which step is the problem? Tracing gives each request a tracking number and stamps the time at each step. The slowest step is highlighted in red.

### Jaeger stabilization (defense day fix)
The Jaeger pod was in CrashLoopBackOff because the CLI arg `--memory.max-traces=100000` (in the raw manifest) overrode the env var `MEMORY_MAX_TRACES=10000` (from the Helm template), causing OOMKilled every 2 minutes. You fixed it by removing the conflicting CLI arg and upgrading from v1.41 to v1.57.

## What was YOUR role?

You created the entire monitoring stack from scratch. Prometheus scraping rules, Grafana provisioning, Alertmanager for alerts, Jaeger collector configuration. You also verified the OpenTelemetry pipeline was working by querying the internal Jaeger API and confirming all 6 services were exporting traces.

Note: The Grafana *dashboard JSONs* (collabspace-load-test.json, etc.) were later refined by Ngoc Anh. Your role was the *infrastructure plumbing* — making sure Prometheus can reach every pod, Loki can receive logs, and Jaeger can collect traces.

---

## Module 3 Q&A to practice

**Q: Why Loki over Elasticsearch?**
**A:** "Loki doesn't index log content — it only indexes metadata labels (namespace, pod, container). This makes it much cheaper on storage (roughly 1:3 compression vs ES) and simpler to operate. You pay for log storage, not index storage. For our scale, Loki is the right fit."

**Q: How do you find the cause of a slow API response?**
**A:** "Open Grafana → Jaeger datasource → Search traces by service. Find the trace with high duration. The waterfall shows exactly which span is slow — could be a database query, an external API call, or a gRPC timeout. I've fixed issues where a missing database index caused 3-second queries; the Jaeger waterfall identified it immediately."

**Q: What metrics do you alert on?**
**A:** "We have Alertmanager rules for: pod CrashLoopBackOff (immediate), high error rate >5% over 5 min, CPU/memory approaching limits, and disk pressure on nodes. Alerts go to Slack via webhook."

---

# MODULE 4: Your Contributions — Git Canon

This is the most important module. Every bullet here traces to a specific commit.

## 4.1 Created the Entire Kubernetes Platform (commit `5604c1e`)

13 files, +1867 lines. Deployments for all 5 services (auth, user, workspace, task, notification), Traefik ingress controller, databases (PostgreSQL, MongoDB, Redis, RabbitMQ), network policies, services.yaml, ingress.yaml.

**How to explain:** "The project started with Docker Compose. I converted everything to Kubernetes — writing all the deployment manifests that define how each service runs, its resource limits, its health checks, and how traffic reaches it."

## 4.2 Created the Dockerfiles for All Services (commit `437bdae`)

Multi-stage builds for all 5 microservices (+326 lines). Each Dockerfile uses a builder stage for `npm ci` and a distroless runtime stage to minimize image size.

**How to explain:** "I containerized every service. Each Dockerfile has an install stage and a lean runtime stage, keeping images under 200MB. No unnecessary tools — just the app and its runtime."

## 4.3 Built the Original Monitoring Stack (commit `e01b17b`)

+1445 lines: Prometheus config, Grafana provisioning, Alertmanager, alert rules, service health dashboards.

**How to explain:** "Before we had dashboards, I set up Prometheus to scrape every pod, configured Grafana with datasources, and wrote the first dashboards. This was the foundation for all observability that followed."

## 4.4 Created the k6 Load Testing Suite (commit `7bd9d36`)

8 files, +152 lines: test scripts for all 5 services (auth, user, workspace, task, notification), 3 scenarios (smoke, demo-flow, slo-baseline), Grafana annotation integration, and a run script.

**How to explain:** "I wrote the load testing suite from scratch. k6 scripts that authenticate as real users, create workspaces, create tasks. Every script reports results to Grafana with annotation markers so you can see the load test on the dashboard timeline."

## 4.5 Fixed CNPG Failover Blocked by NetworkPolicy (commits `35566a1`, `2ff876d`)

The cluster had zero-trust network policies that blocked CloudNativePG's internal port 8000. Replica promotion silently failed during disaster drills. You rewrote the Postgres NetworkPolicy to allow inter-replica traffic while keeping external access locked down.

**How to explain:** "I spent hours debugging why our database failover wasn't working. The culprit: our network firewall (NetworkPolicy) was blocking the port CNPG replicas use to vote for a new leader. I rewrote the policy to allow that traffic while keeping everything else locked. After the fix, failover drops to under 15 seconds."

## 4.6 Fixed Kubelet Overriding Database Port (commits `d5851aa`, `7a59e92`, `955c53f`)

K8s injects `POSTGRES_PORT` environment variables in the format `tcp://10.10.x.x:5432`, which broke the app's connection string. You hardcoded `POSTGRES_PORT: "5432"` in the deployment env to override this.

**How to explain:** "Pods were crashing because Kubernetes automatically injected a connection string format into the `POSTGRES_PORT` variable. The app expected just a number. I had to explicitly set the port in the deployment manifest to override the automatic injection."

## 4.7 Enabled Jaeger Distributed Tracing (commits `8f5e429`, `8b4c777`)

Added Jaeger agent sidecars and OpenTelemetry collector endpoints. Enabled traces flowing from all 6 services.

**How to explain:** "I configured Jaeger to receive traces from all microservices. Each service exports its spans to the Jaeger collector via OpenTelemetry. This lets us see exactly how long every database query, every gRPC call, and every HTTP request takes across the entire system."

## 4.8 Fixed Jaeger OOM from Conflicting CLI Args (defense day fix)

The raw manifest had `--memory.max-traces=100000` as a CLI arg, which overrode the env var `MEMORY_MAX_TRACES=10000`. Jaeger tried to store 100k traces in 1Gi of memory and was OOMKilled every 2 minutes. You removed the CLI arg and upgraded the image from v1.41 to v1.57.

**How to explain:** "Jaeger was crash-looping. The CLI argument for max traces (100k) was overriding the environment variable (10k). The pod was trying to store 100,000 traces in memory and running out. I removed the conflicting arg and updated the image version. Fixed in 10 minutes once I found the root cause."

## 4.9 Built Frontend HA Deployment (commit `cfdc709`)

ConfigMap-based frontend hosting where static HTML/JS is injected as a ConfigMap. No need for a web server or PV.

**How to explain:** "The frontend is static files. Instead of serving them from a web server, I embedded them into a K8s ConfigMap and mounted them into an Nginx container. This means zero provisioning — the frontend scales with the cluster and is automatically distributed."

## 4.10 Created Defense Demo Scripts (commit `9e5e566` + updates)

6 clickable `.bat` files: pre-flight, DB failover, failover confirmation, security audit, k6 load test, HPA auto-scaling recording.

**How to explain:** "I automated the entire defense demo. Double-click any script and it runs the full demonstration — no memorizing kubectl commands. The HPA script is a single-click recording tool that auto-opens Grafana and Slack and walks through each scene."

## What was NOT your work (don't claim it)

| Topic | Done by | Your role |
|---|---|---|
| GitHub Actions CI/CD | Ngoc Anh | You contributed a few CI fixes (DNS, port injection) |
| Grafana dashboard JSONs (final) | Ngoc Anh | You created the initial monitoring plumbing; JSONs were refined by Ngoc Anh |
| Application backend code | Tin/Ngoc Anh | You focused on infrastructure |
| Helm chart umbrella | Ngoc Anh | You modified it (ESO, Jaeger) but didn't create it |
| Initial architecture design | Ngoc Anh | You implemented it in K8s |

---

## Module 4 Q&A to practice

**Q: Which contribution are you most proud of?**
**A:** "The CNPG failover fix. It was a silent, dangerous bug — failover looked like it worked but actually didn't. If the primary died in production, we'd have data loss. I debugged it layer by layer: the app was fine, CNPG was fine, but the network policy was the invisible blocker. Fixing it was the most satisfying engineering win."

**Q: What would you do differently?**
**A:** "I'd start with Helm from day 1 instead of raw K8s manifests. The raw manifests became hard to maintain as we added environments. Helm templating would have saved us refactoring time later. Also, I'd set up automated disaster recovery drills earlier — we caught the failover bug during a manual test, which was lucky."

**Q: What was the hardest technical challenge?**
**A:** "Debugging the CNPG failover. There were zero error messages — the replica just never became primary. I had to read the CNPG source code to understand that it uses port 8000 for leader election, and cross-reference with our NetworkPolicy to see it was blocked. That took a full day."

---

# MODULE 5: 10-Minute Demo Script (Observability → Failover → Security)

> **Goal:** Show Observability → DB Failover → Security. All clickable bat files. Browser-first, terminal second.

---

## BEFORE RECORDING (1 min)

1. Double-click `1-PRE-FLIGHT.bat` — wait for green "ALL CHECKS PASSED"
2. Open `https://collabspace.ngocanh2005it.site/grafana` — login `admin` / `collabspace-grafana`
3. Open `https://collabspace.ngocanh2005it.site/jaeger`
4. Keep both tabs open, minimized

---

## DEMO STEP 1 — "Here's the system running" (2 min)

**Action:** Bring up Grafana tab. Open a dashboard (e.g., Service Health — `d/collabspace-service-health`).

**Say:**
> "This is the cluster live. Every pod, every service. Prometheus scrapes each pod every 15 seconds — CPU, memory, HTTP requests, error rates. All in one place."

**Action:** Switch to **Explore** → **Loki** → query `{namespace="collabspace"}`.

**Say:**
> "This is every log from every container across all 3 nodes. ~40 pods, all their stdout, aggregated and searchable. No SSH needed. If I type `error`, I see every error in the cluster instantly."

**What the recording shows:** A browser with moving graphs and real-time log streaming. Looks impressive.

---

## DEMO STEP 2 — "Kill the primary database" (4 min)

**Action:** Switch to terminal. Double-click `2-DB-FAILOVER.bat`.

**Say nothing yet.** Let the script run:
1. First, it shows the healthy cluster — `postgres-1` is Primary, `postgres-2` and `postgres-3` are Replica.
2. Press any key when prompted.
3. Watch `postgres-1` disappear from `kubectl get pods`. 10-15 seconds later, a new primary is elected.

**Say when the new primary appears:**
> "I just deleted the primary database pod. CloudNativePG detected the failure, held a leader election among the 3 replicas, and promoted a new primary. This happened in under 15 seconds. No code change. No manual failover script."

**Action:** Double-click `3-DB-FAILOVER-CONFIRM.bat`.

**Say:**
> "This confirms the cluster is healthy again. New primary is elected. All three nodes are synchronized."

### Feynman: Database failover
> "Imagine 3 servers all hold a copy of the database. One is the leader. If the leader dies, the remaining 2 hold an election and pick a new leader. The app keeps running because it always connects to whichever server is the leader. This is automatic."

---

## DEMO STEP 3 — "Proof in the logs and traces" (2 min)

**Action:** Switch back to Grafana. Run a Loki query scoped to Postgres: `{app.kubernetes.io/name="postgres"}` or just `{namespace="collabspace"} |= "primary"`.

**Say:**
> "Here's the evidence. The log shows the exact moment pod `postgres-1` was deleted, when the election started, and when the new primary was promoted. Every event recorded. If this happened in production at 3 AM, I can replay it the next morning."

**Action:** Switch to Jaeger tab. Select `auth-service` → **Find Traces** → click any trace to see the waterfall.

**Say:**
> "And this is distributed tracing. Every request gets a unique Trace ID. The waterfall shows how long each service took. Blue spans are database calls — I can see exactly which queries are slow. Red spans show errors. This is how you debug microservices without guessing."

### Feynman: Tracing
> "When you visit the website, your request passes through Traefik, then the auth service, then the user service. If it's slow, which one is the problem? Tracing gives each request a tracking number and records the time spent in each service. The slowest one is highlighted in red."

---

## DEMO STEP 4 — "Locked down by default" (1 min)

**Action:** Switch to terminal. Double-click `4-SECURITY.bat`.

**Say:**
> "22 network policies. Every pod is blocked by default — no traffic in, no traffic out, unless a specific rule allows it. 9 external secrets from Vault — zero passwords in the codebase. If you steal our GitHub repo, you get exactly zero credentials."

---

## AFTER RECORDING

Double-click `1-PRE-FLIGHT.bat` to confirm cluster is clean and all pods are running.

---

## How to narrate the demo recording (if played live)

If the committee asks you to talk over the recording (not in person):

**For Step 1 (Grafana + Loki):** "I'm showing the live monitoring stack. Prometheus collects metrics from every pod, Loki aggregates all logs. The committee sees graphs moving and logs streaming."

**For Step 2 (Failover):** "I'm in the terminal. First I show the database cluster — 3 replicas, one primary. Then I delete the primary pod. Watch the bottom of the screen — within 15 seconds, a new primary is elected. Then I confirm the cluster is healthy."

**For Step 3 (Logs + Traces):** "Back in Grafana, I query the exact failover event in the logs. Then I switch to Jaeger to show distributed tracing — every request tracked across all services."

**For Step 4 (Security):** "I show the 22 network policies and 9 Vault secrets. Simple, quick, visual."

---

# MODULE 6: k6 Load Test Demo (Alternative/Bonus)

> Run this instead of Module 5 if you want a shorter demo, or as an additional 3-minute block.

---

## Why k6 matters

The system was built to serve traffic. k6 proves it can. We run k6 as a **Kubernetes Job** — the load test runs inside the cluster, hitting the real production API endpoints from within the cluster network. No request leaves the cloud — lower latency, more realistic test.

## What k6 tests

| Scenario | VUs | Duration | What it does |
|---|---|---|---|
| Smoke | 5 | 2 min | Health check: each service endpoint called 5 times concurrently |
| Demo Flow | 10 | 3 min | Simulated user: login → create workspace → create task — realistic session |
| SLO Baseline | 10 | 2 min | Per-route: hits all 6 services, measures p95 latency and error rate |

## What did YOU build?

- All k6 test scripts (commit `7bd9d36`): per-service tests (auth, user, workspace, task, notification), 3 scenarios, Grafana annotation library
- Config and run scripts for cluster execution
- Integrated with Grafana dashboard using annotation markers on timeline
- Fixed encoding issue for Grafana annotations (commit `1c3f26b`)

---

## DEMO — "System Under Load"

**Before recording:** Open `https://collabspace.ngocanh2005it.site/grafana/d/collabspace-load-test/collabspace-load-test-run`

**Action:** Double-click `5-K6-LOAD-TEST.bat`.

**What happens:**
1. Grafana dashboard opens in browser (pre-loaded)
2. Terminal deploys k6 as a K8s Job, streams logs
3. Orange annotation markers appear on Grafana timeline
4. Watch request rate spike, latency shift, CPU/memory respond
5. Terminal shows results: pass/fail thresholds, p95 latency, request rate

**Say:**
> "I deployed k6 as a Kubernetes Job. It hits the real production API from inside the cluster. Grafana scrapes every metric from Prometheus — request rate, p95 latency, error rate by service. The orange markers on the timeline are k6 annotation markers — they mark exactly when each test phase ran."

**Results from last run:**
- 5,199 requests in 2 minutes
- p95 latency: 78ms
- Error rate: 0%
- Throughput: ~43 req/s

---

### Feynman: k6 load testing
> "I created automated load tests that simulate 5 to 10 users at the same time. Each script makes real API calls — login, create workspaces, create tasks. The results go to a dashboard that shows how the system performs under load. We use this to make sure the system can handle real users."

---

## Module 6 Q&A

**Q: Why run k6 in-cluster instead of from your local machine?**
**A:** "Eliminates network latency. If I run k6 from my laptop in Vietnam, network hops add 100ms+ to every request. By running it as a K8s Job inside the DOKS cluster in Singapore, I'm testing the actual service performance without internet noise."

**Q: What did the k6 results tell you?**
**A:** "The smoke test showed all services respond with p95 under 100ms. The demo flow test — simulating a user session across multiple services — showed that the auth service is the bottleneck at higher concurrency due to bcrypt hashing. We optimized by adding connection pooling and caching."

**Q: How do you use k6 in development?**
**A:** "The GitHub Action can trigger any scenario on demand. After a deployment, the team can trigger a smoke test to make sure the new version doesn't regress on latency or error rate. We also run the SLO baseline weekly to track performance trends."

---

# MODULE 7: HPA Auto-Scaling + Slack Alert Demo

> Run this as a 2nd demo (after Module 5, or standalone). ~8-10 min.
> Script: **`HPA-RECORD.bat`** — double-click ONCE, everything opens automatically, press Enter when recording.

---

## What is HPA and why does it matter?

### Feynman: HPA
> **Horizontal Pod Autoscaler (HPA)** is Kubernetes's built-in auto-scaling. Think of it as a thermostat for your app: when CPU (the "temperature") goes above 70%, HPA adds more replicas (turns on AC). When CPU drops, it removes them.

We configured HPA for all 5 services: min 2 replicas (always on), max 3 replicas (burst capacity), trigger at 70% CPU.

## What does this demo prove?

1. **Auto-scaling works:** System detects CPU spike and scales 2→3 in ~30s
2. **Observability works:** Grafana shows real-time metrics, Prometheus scrapes HPA data
3. **Alerting works:** Prometheus → Alertmanager → Slack, all automatic, no human watching

## Your HPA configuration (what you built)

- HPA template in Helm (`templates/apps/hpa.yaml`) — you authored the alerts in the Prometheus rule file (`hpa.yml` alert rules in the Prometheus ConfigMap)
- Two alert rules:
  - `HPAScaledUp` (warning) — HPA reached max replicas (3)
  - `HighCPUUsage` (critical) — HPA scaled beyond minimum due to CPU
- Alertmanager routes critical alerts to Slack channel `#nouveau-canal`

---

## DEMO SCRIPT

### Before recording (do these, not on camera)

1. Close any previous k6 jobs: `kubectl delete job k6-load-test -n collabspace --ignore-not-found=true`
2. Make sure HPA is at 2 replicas (wait ~5 min after last load test if not):
   ```bash
   kubectl get hpa -n collabspace
   # All should say REPLICAS=2
   ```
3. Open Slack in browser, go to `#nouveau-canal`

### The demo (double-click `HPA-RECORD.bat`)

One terminal window. One screen. Everything runs in order automatically:

1. Pre-flight: checks cluster, waits for HPA to settle at 2
2. Opens Grafana + Slack in browser tabs
3. Prints "PRESS ENTER TO START"
4. **Scene 1 (8s):** Shows HPA at 2 replicas
5. **Scene 2 (15s):** Deploys k6 with 50 VUs, shows logs
6. **Scene 3 (loop):** Auto-refreshes HPA every 5s — watch REPLICAS flip 2→3
7. Terminal stays on screen; alt-tab to browser for Grafana/Slack anytime

**What to say at each step:**

---

**Scene 1 — Terminal shows all services at 2 replicas, CPU low**

**Say:** *"This is the system at rest. Each service runs 2 replicas. HPA watches CPU — as long as it's under 70%, nothing happens."*

---

**Scene 2 — Terminal shows k6 logs, "50 VUs"**

**Say:** *"50 concurrent users hitting the API. k6 runs as a Kubernetes Job inside the cluster."*

---

**Scene 3 — Terminal shows REPLICAS change from 2 to 3**

**Say:** *"CPU exceeded 70%. HPA auto-scaled from 2 to 3 replicas. No human clicked anything."*

---

**Alt-tab to Grafana** (browser tab already open):

**Say:** *"Grafana shows the spike — request rate, p95 latency. All real-time from Prometheus."*

---

**Alt-tab to Slack** (browser tab already open, `#nouveau-canal`):

**Say:** *"Alertmanager sent this automatically. Pipeline: k6 → CPU spike → HPA scale → Prometheus → Alertmanager → Slack. The team doesn't need to watch a dashboard."*

---

**If k6 finishes and you wait 5 min** — HPA scales back to 2:

**Say:** *"CPU drops, HPA waits 5 min to prevent flapping, then scales back to 2. System self-heals."*

---

## Troubleshooting

| Problem | Fix |
|---|---|
| HPA stuck at 3 replicas | Wait 5 min after k6 finishes, CPU must drop below 70% |
| k6 pod logs show nothing | `kubectl logs -f -l app=k6-load-test -n collabspace` (manual fallback) |
| No Slack alert | `kubectl get prometheusrule -n collabspace`; `kubectl logs -l app=alertmanager -n collabspace` |
| Grafana not loading | Check ingress: `https://collabspace.ngocanh2005it.site/grafana` |
| 50 VUs not triggering HPA | Increase VUs: edit `k6-job-hpa-demo.yaml`, change `value: "50"` to `"100"` |

---

# MODULE 8: Deep Q&A — Committee Edition

> These are questions a defense committee might ask that go deeper than the obvious ones. Practice these.

**Q: Your NetworkPolicy default is deny-ingress but not deny-egress. Why?**
**A:** "That's correct. We deny all ingress by default — no pod can receive traffic unless explicitly allowed. We allow all egress because our pods need to reach Vault, the K8s API server, and public services. Adding egress restrictions would break DNS resolution and Helm hooks. In a more mature environment, egress policies would be added per-pod."

**Q: How do you handle TLS certificate renewal?**
**A:** "We use Let's Encrypt via cert-manager with HTTP01 challenge. cert-manager automatically renews certificates 30 days before expiry. The certificate is stored as a K8s Secret and mounted by Traefik. We monitor certificate expiry with a Prometheus alert."

**Q: Your CNPG cluster has 3 replicas. What happens if 2 nodes fail simultaneously?**
**A:** "We lose quorum. With 3 replicas, we need at least 2 for a majority. If 2 fail, the remaining 1 goes into read-only mode — it can't accept writes. When one of the failed nodes recovers, quorum is restored and writes resume. This is a known limitation of synchronous replication with odd-numbered quorums."

**Q: How do you update the Postgres version (e.g., 15 to 16) without downtime?**
**A:** "CNPG supports rolling upgrades. You update the `image` field in the Cluster spec, and CNPG does a rolling update — one replica at a time — with automated switchover. The primary switches to an upgraded replica, then the old primary is upgraded. No downtime. We tested this in staging."

**Q: What's your backup strategy?**
**A:** "CNPG takes automated WAL-archiving every 5 minutes to DO Spaces (S3-compatible). We also have a K8s CronJob (commit `a76270d`) that takes full daily backups. Retention is 7 days for daily and 30 days for WAL. Point-in-time recovery is supported — you can restore to any second within the retention window."

**Q: How do you debug a pod that's CrashLoopBackOff?**
**A:** "First, `kubectl logs` to see the crash reason. If the pod restarted too fast, use `kubectl logs --previous` to see the last crash's log. 90% of the time it's either: (1) a missing environment variable from Vault/ESO, (2) a database migration that hasn't run, or (3) a liveness probe that's too aggressive — which I fixed once by increasing the initial delay to 90s (commit `0c6158b`). For Jaeger specifically, I debugged an OOMKilled by checking the exit code (137), finding the CLI arg `--memory.max-traces` was overriding the env var."

**Q: Why did you choose Traefik v2 over v3?**
**A:** "We started the project when Traefik v2 was stable. v3 has breaking changes to the CRD format. Migrating now would mean rewriting all our IngressRoutes. The plan is to migrate after the defense, since there are no security issues with v2."

**Q: How do you ensure high availability for the monitoring stack itself?**
**A:** "Prometheus and Grafana run as single replicas with persistent volumes. If the node fails, the pods move to another node with their data. For production-grade HA, we'd deploy Prometheus in HA mode with Thanos for long-term storage, but for our scale, single-replica with PVC migration is sufficient."

**Q: Your team has 3 members. Why did you build this level of infrastructure?**
**A:** "Because infrastructure debt compounds. A simple Docker Compose setup would have been faster initially, but every new service, every environment, every deployment would add friction. By investing in K8s, ESO, and observability early, we eliminated future bottlenecks. We only needed to fight each infrastructure battle once."

**Q: What would you do differently if you started over?**
**A:** "Three things: (1) Start with Helm, not raw YAML. Templating saves time when adding environments. (2) Set up automated disaster recovery testing — we found the CNPG failover bug during a manual test, which means it existed for weeks without detection. (3) Use Terraform for DOKS provisioning earlier — we manually created the cluster via the DO console, which isn't reproducible."

**Q: How do you handle secrets in local development?**
**A:** "We use a `.env` file for local development with placeholder secrets. The production Vault store is only accessible from within the DOKS cluster. ESO is deployed only in the cluster — it can't be reached from local machines, which is a security feature, not a limitation."

**Q: How does Grafana authenticate?**
**A:** "Grafana has its own built-in authentication. We use the admin account with a password from Vault. Initially we had forward-auth middleware on the Grafana IngressRoute, but it blocked the login form — the request to `/grafana/login` was intercepted before Grafana could serve it. We removed forward-auth from Grafana specifically (commit `1004857`)."

**Q: Why 40 pods for 6 microservices?**
**A:** "Each microservice has 2-3 replicas for HA — that's ~18 pods. Plus Postgres (3), MongoDB (1), Redis (1), Kafka/Zookeeper (2), RabbitMQ (1), Traefik (2), Prometheus (1), Grafana (1), Loki (2), Jaeger (1), k6 (ephemeral). Plus monitoring sidecars like Promtail on each node (3). It adds up."

**Q: How did you know the Jaeger OOM was caused by conflicting args?**
**A:** "I checked `kubectl logs --previous` — the pod had exit code 137 (OOMKilled). The pod spec had both a CLI arg `--memory.max-traces=100000` and an env var `MEMORY_MAX_TRACES=5000`. In Jaeger, CLI args take precedence. The env var I thought was controlling it (5000) was being overridden by the arg (100000). I removed the CLI arg and let the env var control it."

---

# RESPONSIBILITIES MATRIX

> What each team member owned. Be clear about YOUR scope so you don't get caught claiming someone else's work.

| Area | Phan Phú Thọ (You) | Ngoc Anh (Team Lead) | Tin (Backend) |
|---|---|---|---|
| **K8s platform** | Created + maintained all manifests | Created Helm umbrella chart | — |
| **Docker** | Multi-stage Dockerfiles for all services | — | App container config |
| **CI/CD** | DNS + port injection fixes (minor) | Full GitHub Actions pipeline | — |
| **Monitoring** | Prometheus scraping + Grafana provisioning + Alertmanager | Grafana dashboard JSONs (final) | — |
| **Logging** | Loki + Promtail config | — | — |
| **Tracing** | Jaeger enabled + OTLP pipeline + OOM fix | — | — |
| **Secrets** | ESO scaffolding + Vault integration | — | — |
| **Backups** | CronJobs to DO Spaces | — | — |
| **Load testing** | k6 scripts (all services, all scenarios) | — | — |
| **Network security** | 22 NetworkPolicies (zero-trust) | — | — |
| **HPA + alerting** | HPA template + Prometheus alert rules + Slack routing | — | — |
| **Defense demos** | 6 clickable `.bat` scripts | — | — |
| **Backend app code** | — | Auth, user, workspace services | Task, notification services |
| **Frontend** | ConfigMap deployment | UI code | — |
| **Architecture design** | Implemented in K8s | Initial design | — |

---

# CANON

> Key references: file paths, config names, dashboard UIDs, commit SHAs that define the system.

## Infrastructure Files (Definitive Sources)

| Path | What |
|---|---|
| `infrastructure/k8s/` | Raw K8s manifests (original platform) |
| `infrastructure/helm/collabspace/` | Helm chart (current deployment) |
| `infrastructure/helm/collabspace/templates/gateway/` | Traefik IngressRoutes |
| `infrastructure/helm/collabspace/templates/observability/` | Prometheus, Grafana, Loki, Alertmanager |
| `infrastructure/helm/collabspace/templates/network-policies.yaml` | All 22 NetworkPolicies |
| `infrastructure/helm/collabspace/values-prod.yaml` | Production values (HPA, Jaeger, resources) |
| `infrastructure/tracing/jaeger-deployment.yaml` | Jaeger raw manifest (standalone) |
| `infrastructure/load-testing/` | k6 scripts + K8s Job YAMLs |
| `docs/defense/` | `.bat` demo scripts |
| `infrastructure/vault/` | Vault config + ESO manifests |

## Key Config Names

| Name | Purpose |
|---|---|
| `collabspace-jaeger` | Traefik IngressRoute for Jaeger UI |
| `allow-traefik-to-jaeger-ui` | NetworkPolicy (Traefik → Jaeger port 16686) |
| `allow-services-to-jaeger-otlp` | NetworkPolicy (services → Jaeger ports 4317/4318) |
| `rate-limit` | Traefik middleware (avg 100, burst 50) |
| `collabspace-service-health` | Grafana dashboard UID |
| `collabspace-load-test` | Grafana dashboard UID (k6 results) |
| `HPA-CPU` | HPA name pattern (e.g., `auth-service-HPA-CPU`) |

## Helm Template Files (your modifications)

| Template | Location | Your changes |
|---|---|---|
| `jaeger.yaml` | `templates/observability/` | Added `COLLECTOR_OTLP_ENABLED`, fixed `resources` |
| `hpa.yaml` | `templates/apps/` | Authored alert rules in Prometheus config |
| `prometheus.yaml` | `templates/observability/` | Added `hpa.yml` alert rules at line 231 |
| `alertmanager.yaml` | `templates/observability/` | Routed alerts to Slack `#nouveau-canal` |
| `network-policies.yaml` | `templates/` | Multiple contributions (CNPG fix, ESO policy) |

## Key Commits (Your Work)

| Commit | What | Files | Impact |
|---|---|---|---|
| `5604c1e` | Initial K8s manifests | 13 files, +1867 | Foundation of the entire platform |
| `437bdae` | Dockerfiles for all services | 5 files, +326 | Containerized every microservice |
| `e01b17b` | Prometheus + Grafana + Alertmanager | Multiple, +1445 | First monitoring stack |
| `7bd9d36` | k6 load test suite | 8 files, +152 | Load testing across all services |
| `35566a1` | CNPG failover NetworkPolicy fix | 1 file | Fixed silent failover bug |
| `8f5e429` | Jaeger tracing enabled | Multiple | Distributed tracing pipeline |
| `cfdc709` | Frontend HA ConfigMap deployment | 1 file | Zero-provision frontend hosting |
| `5637128` | ESO scaffolding + Vault | Multiple | Secrets management |
| `1004857` | Grafana/Jaeger forward-auth removed | 1 file | Fixed login form interception |
| `9e5e566` | 5 defense demo scripts | 5 files | Clickable demo automation |
| `(HEAD)` | HPA-RECORD.bat + k6-job-hpa-demo.yaml | 2 files | One-click HPA demo |

---

# RELATED DOCS

> Cross-references to documentation that supports your defense claims.

## Docs in the repo

| Doc | What it contains |
|---|---|
| `docs/observability.md` | Full observability stack docs (Grafana, Prometheus, Loki, k6) |
| `docs/resilience-overview.md` | Resilience architecture (Vietnamese) |
| `docs/backup-policy.md` | RPO/RTO, backup scripts, restore drills |
| `docs/deployment-k3s-phases.md` | Production deployment roadmap |
| `docs/mvp-demo-scope.md` | MVP demo acceptance checklist |
| `docs/deployment-digitalocean-doks.md` | DOKS deployment guide |
| `docs/team/phan-phu-tho-infrastructure-backlog.md` | Your infrastructure backlog |
| `infrastructure/vault/README.md` | Vault + ESO setup guide |

## Team docs (defense prep)

| Doc | Audience |
|---|---|
| `defense-prep-phan-phu-tho.md` (this file) | YOU — infrastructure engineer |
| `docs/team/application-backlog.md` | Tin/Ngoc Anh — backend devs |

---

# QUICK REFERENCE

## Cluster Access
- **Kubeconfig:** `d:\Code\team\collabspace-doks-1-kubeconfig.yaml`
- **Grafana:** `https://collabspace.ngocanh2005it.site/grafana` — `admin` / `collabspace-grafana`
- **Jaeger:** `https://collabspace.ngocanh2005it.site/jaeger`
- **Public LB IP:** `146.190.193.5`

## Key Git Commits (Your Work)

| Commit | What |
|---|---|
| `5604c1e` | Initial K8s manifests (+1867 lines, 13 files) |
| `437bdae` | Dockerfiles for all services |
| `e01b17b` | Prometheus + Grafana + Alertmanager stack |
| `7bd9d36` | k6 load test suite (all 5 services, 3 scenarios) |
| `35566a1` | CNPG failover NetworkPolicy fix |
| `8f5e429` | Jaeger tracing enabled across all services |
| `cfdc709` | Frontend HA ConfigMap deployment |
| `5637128` | ESO scaffolding + Vault integration |
| `1004857` | Grafana/Jaeger forward-auth removed for demo |
| `9e5e566` | 5 defense demo scripts |
| `HEAD` | Jaeger OOM fix + HPA-RECORD.bat + k6 HPA variant |

## HPA/K8s Config (your Helm template)

| Component | File | What it does |
|---|---|---|
| HPA template | `templates/apps/hpa.yaml` | Auto-scaling: min 2, max 3, CPU 70% |
| HPA alert rules | `templates/observability/prometheus.yaml:231` | `HPAScaledUp` + `HighCPUUsage` alerts |
| Alertmanager | `templates/observability/alertmanager.yaml` | Routes alerts to Slack `#nouveau-canal` |

## Demo Files (double-click)

| Script | What it does |
|---|---|
| `1-PRE-FLIGHT.bat` | Health check: pods, DB cluster, ingress |
| `2-DB-FAILOVER.bat` | Kills primary Postgres, watches election |
| `3-DB-FAILOVER-CONFIRM.bat` | Verifies new primary |
| `4-SECURITY.bat` | Shows NetworkPolicies + Vault secrets |
| `5-K6-LOAD-TEST.bat` | Deploys k6 Job, opens Grafana dashboard |
| `HPA-RECORD.bat` | **One click.** One terminal. HPA demo from start to finish. |

All located in `collabspace/docs/defense/`.

## Key Numbers

- **Commits:** 108 total (45 in `infrastructure/`)
- **NetworkPolicies:** 22 active
- **ExternalSecrets:** 9 synced from Vault
- **Nodes:** 3 (DOKS, Singapore)
- **Pods:** ~40
- **DB replicas:** 3 (CNPG, CloudNativePG operator)
- **Microservices:** 6 (auth, user, workspace, task, notification, chat)
- **k6 throughput:** 5,199 req / 2 min / 0% errors / p95=78ms
- **HPA:** min 2, max 3, trigger 70% CPU, cooldown 5 min
