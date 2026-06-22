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

### Pre-Defense Setup
1. **Terminal:** Open your local terminal. Ensure you have downloaded the Digital Ocean `kubeconfig` file from the DOKS dashboard. Set your context: `set KUBECONFIG=C:\path\to\your\doks-kubeconfig.yaml`.
2. **Grafana:** Navigate to `https://collabspace.ngocanh2005it.site/grafana` and log in (Credentials: `admin` / `admin123`).
3. **Dashboard:** Open the **CollabSpace Service Health** dashboard on the projector.
4. **Explore Tab:** Open a second Grafana tab pointing to the **Explore** section (for querying Loki logs later).

---

### Demonstration 1: Massive Load & Telemetry
- **Action:** Open your local terminal and execute the load-testing script:
  > **[CRITICAL WARNING FOR PHAN PHU THO]:** *You MUST have Docker Desktop running on your local machine before executing this. If Docker is closed, the script will instantly fail and you will be deemed the villain. Start Docker now.*
  ```bash
  cd docs/defense
  1-ACT-HEARTBEAT.bat
  ```
- **Explanation:** "To prove our infrastructure is robust, I am initiating a simulated load test against our live cluster. On the Grafana dashboard, you can see Prometheus instantly capturing the surge in HTTP request rates and visualizing the CPU utilization. Our cluster handles the load while maintaining stable latency, proving our metric scraping is operating in real-time."

### Demonstration 2: Live Zero-Downtime Scaling
- **Action:** Open your local terminal and execute:
  `kubectl scale deployment workspace-service -n collabspace --replicas=3`
- **Explanation:** "A major advantage of Kubernetes is elastic scalability. I just commanded the cluster to scale the Workspace Service from 1 instance to 3 instances. Kubernetes is currently pulling the container images and scheduling them across our 3 distinct physical nodes. The Traefik API Gateway instantly detects these new pods and begins load-balancing traffic across them, achieving instant scale-out without dropping a single user request."

### Demonstration 3: Automated Safeguards (Failed Rollout Prevention)
- **Action:** In your local terminal, execute:
  `kubectl set image deployment/auth-service auth-service=nginx:alpine -n collabspace`
- **Explanation:** "I just simulated pushing a completely broken, corrupted update to production. In a traditional deployment, the site would instantly crash. However, because I engineered strict Kubernetes Readiness and Liveness probes, the cluster tests the new version, detects it is broken (the container runs but fails the readiness health check), and *refuses* to terminate the old, healthy version. The users experience zero downtime despite a catastrophic deployment error."
- **Action:** Execute `kubectl rollout undo deployment/auth-service -n collabspace`
- **Explanation:** "And with a single command, I instantly rollback the deployment state to the previous stable configuration, neutralizing the threat."

### Demonstration 4: Centralized Log Aggregation (Loki)
- **Action:** Switch to the Grafana **Explore** tab. Select the `Loki` data source. Run a simple query like `{namespace="collabspace", app="auth-service"}`.
- **Explanation:** "In a distributed architecture, SSHing into servers to read logs is obsolete. I engineered a centralized logging stack using Promtail and Loki. As you can see, the logs from every container on every node are streamed centrally to this dashboard. We can instantly search for errors across the entire application stack in milliseconds."

### Demonstration 5: Secure Secret Injection (Vault)
- **Action:** In your local terminal, execute:
  `kubectl get externalsecrets -n collabspace`
- **Explanation:** "Finally, to prove our zero-trust security posture: there are absolutely no database passwords stored in our codebase. The External Secrets Operator you see here is actively communicating with our encrypted HashiCorp Vault, dynamically injecting the credentials into the Kubernetes pods at runtime."
