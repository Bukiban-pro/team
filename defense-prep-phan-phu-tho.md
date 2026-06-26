# 🎓 Defense Preparation Guide: Phan Phú Thọ (Lead Infrastructure Engineer)

> **Document Purpose:** This guide outlines the cloud architecture, deployment strategies, and specific infrastructure contributions engineered by Phan Phú Thọ for the CollabSpace platform. It is designed to serve as your definitive reference for the final academic defense.

---

# MODULE 1: Cloud Architecture & Orchestration

## 1.1 Overview
CollabSpace is built on a distributed microservices architecture. To manage these services at an enterprise level, we implemented a robust, highly-available container orchestration platform.

## 1.2 Core Infrastructure Components
1. **Digital Ocean Kubernetes Service (DOKS):** We moved beyond a basic single-server deployment and provisioned a managed 3-node Kubernetes cluster. This guarantees High Availability (HA)—if a physical server node fails, Kubernetes automatically reschedules our application pods onto the surviving nodes with zero human intervention.
2. **Traefik (Ingress Controller):** Serves as our primary API Gateway. It intelligently routes incoming internet traffic to the correct internal microservice based on URL path definitions (e.g., routing `/api/v1/auth/*` directly to the `auth-service` deployment).

## 1.3 Expected Defense Q&A
**Q: Why deploy a complex Kubernetes cluster instead of just running Docker containers on a VM?**
**A:** "A single VM is a critical single point of failure. By engineering a 3-node managed Kubernetes cluster, our application achieves true fault tolerance and scalability. Kubernetes allows us to perform zero-downtime rolling updates, automatically balances traffic across multiple replicas, and guarantees that if a node crashes, our application remains online."

---

# MODULE 2: Security & Secret Management

## 2.1 Overview
In modern infrastructure, hardcoding passwords is a critical security vulnerability. We engineered a zero-trust secret management pipeline.

## 2.2 Core Security Components
1. **HashiCorp Vault:** Acts as our centralized, encrypted storage mechanism for all sensitive credentials and environment variables.
2. **External Secrets Operator (ESO):** A custom Kubernetes controller that continuously authenticates with Vault, retrieves the necessary secrets, and synchronizes them directly into native Kubernetes `Secret` resources for our pods to consume securely in RAM.

## 2.3 Expected Defense Q&A
**Q: How do you prevent sensitive database credentials from leaking?**
**A:** "We enforce a zero-trust model. Passwords are never stored in the codebase or in static `.env` files. We deployed HashiCorp Vault to securely store credentials. At runtime, the External Secrets Operator fetches these credentials from Vault and mounts them securely into the container's memory. If our Git repository or local machines are compromised, the attackers gain absolutely zero sensitive data."

---

# MODULE 3: Advanced Observability & Telemetry

## 3.1 Overview
Operating a distributed system requires absolute visibility. We deployed an enterprise-grade observability stack to monitor the cluster's health, traffic, and logs in real-time.

## 3.2 Core Observability Components
1. **Prometheus & Grafana:** Prometheus continuously scrapes metrics from our nodes and pods (CPU, RAM, HTTP request rates). Grafana aggregates this data into dynamic, real-time dashboards.
2. **Loki & Promtail (Log Aggregation):** Promtail collects the `stdout/stderr` logs from every single container across all 3 nodes and ships them to Loki. We no longer have to SSH into servers to read logs; everything is searchable centrally in Grafana.
3. **Jaeger (Distributed Tracing):** As an HTTP request travels through the Traefik Gateway into multiple microservices, Jaeger assigns it a unique Trace ID, allowing us to pinpoint exact latency bottlenecks across the network.

## 3.3 Expected Defense Q&A
**Q: If a user reports an error, how do you find the cause across 5 different microservices?**
**A:** "We don't SSH into servers to guess. Our centralized logging stack (Loki) aggregates logs from every microservice in real-time. We simply query Grafana for the user's ID or the Trace ID, and it instantly filters the logs across the entire cluster, showing us the exact microservice and line of code that threw the exception."

---

# MODULE 4: Primary Technical Contributions

When discussing task distribution, these are the core architectural and infrastructure responsibilities engineered by Phan Phú Thọ:

1. **Kubernetes Cluster Engineering:** Architected the deployment manifests, Services, and Traefik Ingress routing for the entire microservice ecosystem on Digital Ocean (DOKS).
2. **Zero-Trust Secret Management:** Deployed and integrated HashiCorp Vault with the External Secrets Operator (ESO) to completely eradicate hardcoded secrets from the deployment pipeline.
3. **Comprehensive Observability Stack:** Deployed and configured the Prometheus, Grafana, Loki, and Jaeger stacks, providing full cluster-wide metric scraping and centralized log aggregation.
4. **Stateful Data Store Provisioning:** Configured the highly-available deployments for our critical data stores, including the PostgreSQL instances and the MongoDB ReplicaSets.

*(Note: Lê Ngọc Anh's primary responsibilities included backend application development, CI/CD pipeline automation via GitHub Actions, and front-end integration).*

---

# MODULE 5: Live Infrastructure Demonstration Script

*This is the script for demonstrating your advanced infrastructure to the committee. We are moving beyond local scripts and demonstrating raw power on the live production cluster.*

### Pre-Defense Setup — Run These Before You Hit Record

1. **Set kubeconfig context:**
   `$env:KUBECONFIG="d:\Code\team\collabspace-doks-1-kubeconfig.yaml"`
2. **Verify cluster is healthy** (run this first, confirm all nodes are `Ready`):
   `kubectl get nodes`
3. **Open browser tabs (pre-load, do not close):**
   - `https://collabspace.ngocanh2005it.site/` — live frontend
   - `https://collabspace.ngocanh2005it.site/grafana` — Grafana (admin / collabspace-grafana)
   - `https://collabspace.ngocanh2005it.site/jaeger` — Jaeger tracing UI
4. **In Grafana:** Pre-open the **CollabSpace Service Health** dashboard on one tab, and the **Explore** section (Loki datasource) on a second tab.
5. **Scale services back to 1 replica** (reset state before demo):
   `kubectl scale deployment workspace-service -n collabspace --replicas=1`


---

### Demonstration 1: The Live Frontend & High Availability Destruction Test
- **Action:** Open the live production URL in your browser: `https://collabspace.ngocanh2005it.site/`
- **Explanation:** "Theory is a joke; we deploy for real users. This is our live, highly-available React frontend, served directly from our Kubernetes cluster through our Traefik HTTPS gateway. It is actively communicating with our microservices."
- **Action:** Open your local terminal and aggressively delete a single frontend pod:
  `kubectl get pods -l app=collabspace-frontend -n collabspace`
  *(Copy ONE of the pod names)*
  `kubectl delete pod <PASTE_POD_NAME_HERE> -n collabspace --force`
  Immediately refresh the browser multiple times.
- **Explanation:** "I just forcefully destroyed one of the frontend servers. Because we engineered a highly-available, multi-replica deployment, the Traefik Gateway instantly detects the node failure and routes your request to a surviving replica. You experience zero downtime. The system heals itself automatically."

### Demonstration 2: Live Zero-Downtime Scaling
- **Action:** Open your local terminal and execute:
  `kubectl scale deployment workspace-service -n collabspace --replicas=3`
- **Explanation:** "A major advantage of Kubernetes is elastic scalability. I just commanded the cluster to scale the Workspace Service from 1 instance to 3 instances. Kubernetes is currently pulling the container images and scheduling them across our 3 distinct physical nodes. The Traefik API Gateway instantly detects these new pods and begins load-balancing traffic across them, achieving instant scale-out without dropping a single user request."

### Demonstration 3: Stateful Database Failover (CloudNativePG)
- **Action:** In your local terminal, show the Postgres cluster status:
  `kubectl get cluster postgres -n collabspace`
- **Explanation:** "Microservices are easy to scale, but databases are hard. We deployed a CloudNativePG PostgreSQL cluster with 3 instances. I engineered strict NetworkPolicies to secure inter-node consensus. If the primary database node crashes..."
- **Action:** forcefully delete the primary postgres pod:
  `kubectl delete pod -l role=primary -n collabspace --force`
- **Explanation:** "...the cluster instantly loses its master. However, the CNPG operator immediately detects the failure, holds an election via the secured port 8000, and automatically promotes a replica to Primary. The microservices re-establish connection in seconds. No data is lost, and no human intervention is required."

### Demonstration 4: Automated Safeguards (Failed Rollout Prevention)
- **Action:** In your local terminal, execute:
  `kubectl set image deployment/auth-service auth-service=nginx:alpine -n collabspace`
- **Explanation:** "I just simulated pushing a completely broken, corrupted update to production. In a traditional deployment, the site would instantly crash. However, because I engineered strict Kubernetes Readiness and Liveness probes, the cluster tests the new version, detects it is broken (the container runs but fails the readiness health check), and *refuses* to terminate the old, healthy version. The users experience zero downtime despite a catastrophic deployment error."
- **Action:** Execute `kubectl rollout undo deployment/auth-service -n collabspace`
- **Explanation:** "And with a single command, I instantly rollback the deployment state to the previous stable configuration, neutralizing the threat."

### Demonstration 5: Centralized Log Aggregation (Loki)
- **Action:** Switch to the Grafana **Explore** tab. Select the `Loki` data source. Run a simple query like `{namespace="collabspace", app="auth-service"}`.
- **Explanation:** "In a distributed architecture, SSHing into servers to read logs is obsolete. I engineered a centralized logging stack using Promtail and Loki. As you can see, the logs from every container on every node are streamed centrally to this dashboard. We can instantly search for errors across the entire application stack in milliseconds."

### Demonstration 6: Secure Secret Injection (Vault)
- **Action:** In your local terminal, execute:
  `kubectl get externalsecrets -n collabspace`
- **Explanation:** "Finally, to prove our zero-trust security posture: there are absolutely no database passwords stored in our codebase. The External Secrets Operator you see here is actively communicating with our encrypted HashiCorp Vault, dynamically injecting the credentials into the Kubernetes pods at runtime."

### Demonstration 7: Distributed Tracing & Performance Profiling (Jaeger)
- **Action:** Open `https://collabspace.ngocanh2005it.site/jaeger`. Select any service (e.g. `auth-service`) from the dropdown and click **Find Traces**.
- **Explanation:** "In a microservices architecture, pinpointing where a request slows down is notoriously difficult. We solved this by enabling OpenTelemetry auto-instrumentation across all six services. Without writing a single line of manual tracking code, every request that enters through Traefik is assigned a unique Trace ID. This dashboard lets us visualize the exact millisecond-level latency of every downstream Postgres query, Kafka event, and inter-service HTTP call in real time."

---

# MODULE 6: Real-World Engineering Challenges Overcome

*These are five technically verified, production-grade infrastructure problems I diagnosed and resolved during the project. Each is traceable to a specific commit or cluster intervention.*

## 6.1 Neutralizing Kubelet Service Discovery Variable Injection
**The Problem:** During CI/CD rollouts, microservices began failing at startup with `CrashLoopBackOff`. The application logs revealed `ERR_INVALID_URL` on the database connection string.

**The Diagnosis:** I traced the root cause deep into the cluster. The Kubernetes Kubelet automatically injects legacy Service Discovery environment variables into every pod — including `POSTGRES_PORT=tcp://10.10.x.x:5432`. This was silently overwriting the clean integer port value we injected from HashiCorp Vault via `envFrom`, causing the database connection URL to become malformed.

**The Solution:** I hardcoded an explicit `POSTGRES_PORT: "5432"` entry in the deployment manifest's `env` array. In Kubernetes, explicitly declared `env` variables take strict precedence over `envFrom` and Kubelet-injected values. The conflict was permanently neutralized.

---

## 6.2 Rewriting the Postgres NetworkPolicy to Unblock CNPG Leader Elections *(Commit: 35566a1)*
**The Problem:** We provisioned CloudNativePG (CNPG) for high-availability PostgreSQL with automated failover. During disaster recovery drills, replica promotion was silently failing — the secondary pod never became Primary.

**The Diagnosis:** Our strict zero-trust Postgres NetworkPolicy was blocking port 8000, which is the internal channel CNPG replicas use for Raft-based leader election and WAL streaming synchronization.

**The Solution:** I completely rewrote the NetworkPolicy with surgical precision — adding explicit ingress and egress rules that exclusively whitelisted inter-pod traffic between the CNPG-managed replicas on the required ports, while keeping all external access locked down. Failovers now execute within seconds.

---

## 6.3 Enforcing POSIX Path Compliance via Tar Compression *(Commit: e51b0fc)*
**The Problem:** After migrating our CI/CD pipelines to run on Linux-based GitHub Actions runners, frontend deployments began failing when scripts attempted to copy files into the Kubernetes nodes. The failure was inconsistent and environment-dependent.

**The Diagnosis:** The deployment scripts were generating Windows-style backslash path strings (`\`), which are invalid on POSIX-compliant Linux file systems. The Kubernetes nodes rejected them outright.

**The Solution:** I restructured the frontend deployment pipeline to use `tar` for asset bundling. By compressing the static assets into a `.tar.gz` archive before transfer and extracting inside the container, I completely bypassed the OS-level path parsing step, guaranteeing consistent deployments regardless of the runner's operating system.

---

## 6.4 Selectively Bypassing Zero-Trust for Ephemeral Migration Jobs *(Commit: c5c4258)*
**The Problem:** We use Helm pre-upgrade hooks to run Prisma database migrations before new application pods come online, achieving zero-downtime schema changes. However, our default-deny NetworkPolicy was blocking these ephemeral migration pods from reaching the PostgreSQL cluster.

**The Solution:** Rather than opening a broad hole in the database firewall, I engineered a targeted NetworkPolicy rule using custom Helm-injected labels (`collabspace.dev/role: migration`). This rule exclusively whitelists migration pods — and only for the duration of the Helm hook — without compromising the cluster's security posture for any other workload.

---

## 6.5 Auditing and Validating the OpenTelemetry Tracing Pipeline
**The Problem:** Following the deployment of the Jaeger collector, there was ambiguity within the team about whether the Node.js microservices were actually exporting traces or if the OpenTelemetry SDK was silently failing to initialize.

**The Solution:** Rather than relying on the external Ingress (which has its own firewall rules), I executed directly into the cluster and queried the internal Jaeger API from within the pod network (`GET /jaeger/api/services`). The response confirmed that all six microservices — `auth-service`, `user-service`, `workspace-service`, `task-service`, `notification-service`, and `chat-service` — were actively registered and exporting spans. The `@opentelemetry/auto-instrumentations-node` SDK was correctly bootstrapped at process startup and successfully routing telemetry through port 4318 to the Jaeger collector.
