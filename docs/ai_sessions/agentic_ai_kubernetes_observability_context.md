# Context for Agentic AI: Kubernetes Infrastructure / Observability Task

I have been given SSH access to our project droplet/server.

## Server Access

```bash
ssh root@167.172.77.110
```

After login, I am inside the Ubuntu server as root:

```bash
root@collabspace:~#
```

The server appears to be running our project stack through Kubernetes.

## Teammate Instruction

My teammate told me to run:

```bash
kubectl get pods -n collabspace
```

They said this is to view the “full stack” of the system.

## Project Context

The Kubernetes namespace is:

```text
collabspace
```

My teammate said I will continue working on infrastructure, especially observability, but the current setup is not fully completed yet.

Observability may include components such as:

- Grafana
- Prometheus
- Loki
- Tempo
- OpenTelemetry
- metrics-server
- logging agents
- dashboards
- alerts
- Kubernetes service/deployment monitoring

## My Current Skill Context

I am not very familiar with Kubernetes, infrastructure, or observability yet.

Please guide me step by step and explain what each command means before suggesting it.

## Safety Rules

Do **not** run or suggest destructive commands unless I explicitly confirm.

Avoid commands such as:

```bash
kubectl delete ...
kubectl apply ...
kubectl edit ...
kubectl rollout restart ...
systemctl restart ...
reboot
rm -rf ...
```

Prefer read-only diagnostic commands first.

Safe commands are generally things like:

```bash
kubectl get ...
kubectl describe ...
kubectl logs ...
kubectl top ...
```

But please still explain each command before suggesting it.

## Immediate Goal

Help me safely inspect the current Kubernetes stack in the `collabspace` namespace.

First command to analyze:

```bash
kubectl get pods -n collabspace
```

After I provide the output, please:

1. Explain what each pod likely does.
2. Identify whether any pod looks unhealthy.
3. Explain important columns like `READY`, `STATUS`, `RESTARTS`, and `AGE`.
4. Identify observability-related services.
5. Suggest the next safe read-only command to run.
6. Help me understand what part of observability may still be incomplete.

## Response Style I Need

Please keep guidance practical and beginner-friendly.

For each suggested command, use this format:

```text
Command:
<command>

What it does:
<simple explanation>

Why we run it:
<reason>

Risk level:
Read-only / Safe
```

## Current Known Information

- I can SSH into the server successfully.
- The server prompt is:

```bash
root@collabspace:~#
```

- The server is Ubuntu 24.04.3 LTS.
- Kubernetes is available through `kubectl`.
- The namespace to inspect is:

```text
collabspace
```

## First Task

Ask me to run:

```bash
kubectl get pods -n collabspace
```

Then wait for my output and help me interpret it.
