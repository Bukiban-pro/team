# Workspace Collaboration Management System

## Microservices Architecture Technical Report

## 1. Introduction

### 1.1 System Objective

Workspace Collaboration Management System is a platform that enables
multiple users to collaborate within shared workspaces. The system
allows users to:

- Create and manage workspaces
- Invite members
- Assign roles and permissions
- Create and manage tasks
- Communicate through comments
- Track work progress

The system is designed using **Microservices Architecture** to achieve:

- Scalability
- Service independence
- Fault isolation
- Independent deployment

---

# 2. System Architecture

The system follows the **Microservices + API Gateway** architectural
pattern.

Client applications communicate with backend services through a
centralized API Gateway.

Core services:

- API Gateway
- Auth Service
- User Service
- Workspace Service
- Task Service
- Notification Service

Infrastructure components:

- Message Broker (Kafka / RabbitMQ)
- Prometheus (Monitoring)
- Grafana (Visualization)
- Jaeger (Distributed tracing)
- ELK Stack (Logging)

---

# 3. Microservices Decomposition

The system is divided based on **Domain Driven Design (DDD)**
principles.

## 3.1 Auth Service

Responsible for authentication and authorization.

Features:

- User login
- User registration
- JWT token issuing
- Refresh token
- Authentication validation

Example APIs:

POST /auth/login\
POST /auth/register\
POST /auth/refresh\
GET /auth/me

Database: PostgreSQL

Tables:

- users
- roles
- permissions

---

## 3.2 User Service

Responsible for managing user profile information.

Features:

- Update profile
- Retrieve profile
- Manage avatar

Example APIs:

GET /users/{id}\
PATCH /users/{id}

Database: PostgreSQL

Tables:

- profiles

---

## 3.3 Workspace Service

Responsible for managing collaborative workspaces.

Features:

- Create workspace
- Invite members
- Manage workspace roles
- List workspace members

Example APIs:

POST /workspaces\
GET /workspaces\
POST /workspaces/{id}/invite\
GET /workspaces/{id}/members

Database: PostgreSQL

Tables:

- workspaces
- workspace_members
- workspace_roles

---

## 3.4 Task Service

Responsible for task management.

Features:

- Create task
- Update task
- Assign task
- Comment on task
- Track task status

Example APIs:

POST /tasks\
GET /tasks\
PATCH /tasks/{id}\
POST /tasks/{id}/comments

Database: MongoDB

Collections:

- tasks
- task_comments
- task_assignments

Reason for MongoDB:

Flexible schema for tasks and nested comments.

---

## 3.5 Notification Service

Responsible for sending notifications when system events occur.

Examples:

- Task assigned
- Workspace invitation
- New comment

Communication method:

Event-driven architecture using message broker.

Example events:

TASK_ASSIGNED\
WORKSPACE_INVITED\
COMMENT_CREATED

Database: Redis / MongoDB

---

# 4. API Gateway

API Gateway responsibilities:

- Request routing
- Authentication middleware
- Rate limiting
- Service aggregation

Possible technologies:

- NestJS Gateway
- Kong
- Nginx

---

# 5. Message Broker

Services communicate asynchronously using **Kafka or RabbitMQ**.

Example workflow:

Task Service publishes event:

TASK_ASSIGNED

Notification Service consumes event and sends notification.

Benefits:

- Loose coupling
- Asynchronous communication
- Improved scalability

---

# 6. Polyglot Persistence

Each microservice manages its own database.

Service Database

---

Auth Service PostgreSQL
User Service PostgreSQL
Workspace Service PostgreSQL
Task Service MongoDB
Notification Service Redis / MongoDB

Advantages:

- Technology flexibility
- Database optimization per service
- Reduced cross-service coupling

---

# 7. CI/CD Pipeline

Each service has its own CI/CD pipeline.

Typical pipeline stages:

1.  Code push to repository
2.  Run automated tests
3.  Build Docker image
4.  Push image to container registry
5.  Deploy to Kubernetes

Example tools:

- GitHub Actions
- Docker
- Kubernetes

Example CI pipeline:

- Run unit tests
- Build service container
- Deploy service

---

# 8. Monitoring

Monitoring stack:

Prometheus collects metrics such as:

- Request count
- Request latency
- CPU usage
- Memory usage

Grafana visualizes metrics using dashboards.

Example dashboards:

- Service health
- Request throughput
- Error rate

---

# 9. Distributed Tracing

Distributed tracing helps track requests across multiple services.

Tools:

- OpenTelemetry
- Jaeger

Example request trace:

Client → API Gateway → Task Service → Notification Service

Benefits:

- Debugging latency
- Identifying bottlenecks

---

# 10. Logging

Centralized logging uses **ELK Stack**.

Components:

- Elasticsearch
- Logstash
- Kibana

Logs from services are aggregated and indexed for searching and
monitoring.

Example log entry:

service: task-service\
event: task_created\
user_id: 123\
timestamp: 2026-03-26

---

# 11. Testing Strategy

### Unit Testing

Each service has independent unit tests.

Tool:

- Jest

---

### Integration Testing

Tests communication between services.

Example:

Task Service → Notification Service event flow.

---

### End-to-End Testing

Tests the entire system workflow.

Tools:

- Cypress
- Playwright

---

# 12. Observability

Observability stack:

Component Tool

---

Metrics Prometheus
Visualization Grafana
Tracing Jaeger
Logging ELK Stack

These tools together provide full system observability.

---

# 13. Team Task Distribution (4 Members)

## Member 1 --- Infrastructure Engineer

### Assigned: Phan Phú Thọ

Responsibilities:

- Docker containerization
- Kubernetes deployment
- CI/CD pipelines
- Monitoring setup
- Tracing setup

Tasks:

- Setup Kubernetes cluster
- Configure Prometheus
- Configure Grafana dashboards
- Configure Jaeger tracing
- Implement GitHub Actions pipelines

---

## Member 2 --- Auth & User Service

### Assigned: Lê Ngọc Anh

Responsibilities:

- Auth service
- User service

Tasks:

- JWT authentication
- Role-based access control
- Profile APIs
- Unit tests

---

## Member 3 --- Workspace Service

### Assigned: Ngô Minh Tiến

Responsibilities:

- Workspace management

Tasks:

- Workspace CRUD APIs
- Member invitations
- Role management
- Integration tests

---

## Member 4 --- Task & Notification Service

### Assigned: Võ Trung Tín

Responsibilities:

- Task service
- Notification service

Tasks:

- Task CRUD APIs
- Comment system
- Event publishing
- Notification consumers

---

# 14. Deployment Architecture

Deployment uses **Docker containers orchestrated by Kubernetes**.

Application pods:

- api-gateway
- auth-service
- user-service
- workspace-service
- task-service
- notification-service

Infrastructure pods:

- kafka / rabbitmq
- prometheus
- grafana
- jaeger
- elasticsearch

---

# 15. Conclusion

The microservices architecture allows the Workspace Collaboration
Management System to:

- scale independently
- isolate failures
- deploy services independently
- use polyglot persistence

With CI/CD pipelines, monitoring, distributed tracing, and testing
strategies, the system demonstrates a **production-ready microservices
architecture**.
