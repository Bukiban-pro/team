# Workspace Collaboration Management System

Hệ thống cho phép:

- tạo **workspace**
- mời **thành viên**
- phân quyền
- tạo **project / task**
- quản lý team

Giống một bản **mini của Notion / Slack / Jira**.

# Các chức năng chính

### 1\. Workspace Management

- tạo workspace
- xoá workspace
- quản lý workspace

### 2\. Member Invitation

- mời thành viên qua email
- join workspace
- accept / reject invitation

### 3\. Role & Permission

- owner
- admin
- member

### 4\. Project / Task

- tạo project
- tạo task
- assign task cho member

### 5\. Notification

- thông báo khi:
  - được mời
  - được assign task

# Microservices có thể chia

### 1️⃣ Auth Service

- login
- register
- JWT

### 2️⃣ Workspace Service

- tạo workspace
- quản lý workspace
- list workspace của user

### 3️⃣ Membership Service

- join workspace
- role
- permission

### 4️⃣ Invitation Service

- gửi lời mời
- accept / reject

### 5️⃣ Project Service

- project
- task
- assign member

### 6️⃣ Notification Service

- email
- in-app notification

# Flow mời thành viên

User A tạo workspace  
↓  
Invite member  
↓  
Invitation Service  
↓  
Email link  
↓  
User B accept  
↓  
Membership Service  
↓  
User B join workspace

# Kiến trúc microservices

Client  
↓  
API Gateway  
↓  
\-----------------------------  
Auth Service  
Workspace Service  
Membership Service  
Invitation Service  
Project Service  
Notification Service  
\-----------------------------

# Chia việc cho nhóm 4

| **Sinh viên** | **Phụ trách**          |
| ------------- | ---------------------- |
| SV1           | Auth + API Gateway     |
| SV2           | Workspace + Membership |
| SV3           | Invitation Service     |
| SV4           | Project + Notification |