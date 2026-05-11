**DANH SÁCH CÁC CHỨC NĂNG VÀ THÔNG TIN CÁC BẢNG CƠ SỞ DỮ LIỆU**

- **Auth Service:**

**Chức năng**: Quản lý xác thực và phân quyền.  
**Database**: PostgreSQL

| **Bảng**    | **Mục đích**         | **Fields chính**                            |
| ----------- | -------------------- | ------------------------------------------- |
| Users       | Thông tin người dùng | Id, email, password, created_at, updated_at |
| Roles       | Các role có thể gán  | Id, name, description                       |
| Permissions | Quyền hạn chi tiết   | Id, name, description                       |
| User_roles  | Mapping user -> role | Id, user_id,role_id                         |

**Tính năng API:**

- Đăng nhập / Đăng ký
- JWT token issuance & refresh
- Xác thực request
- Gán role, kiểm tra permissions

- **User Service:**

**Chức năng**: Quản lý thông tin profile người dùng.  
**Database**: PostgreSQL

| **Bảng** | **Mục đích**      | **Fields chính**                                                |
| -------- | ----------------- | --------------------------------------------------------------- |
| Profiles | Thông tin profile | Id, user_id, full_name, avatar_url, bio, created_at, updated_at |

**Tính năng API:**

- Lấy profile
- Cập nhật profile
- Upload avatar

- **Workspace Service:**

**Chức năng**: Quản lý các workspace, thành viên và vai trò trong workspace.  
**Database**: PostgreSQL

| **Bảng**           | **Mục đích**              | **Fields chính**                                        |
| ------------------ | ------------------------- | ------------------------------------------------------- |
| Workspaces         | Thông tin workspace       | Id, name, description, owner_id, created_at, updated_at |
| Workspaces_members | Mapping user -> workspace | Id, workspace_id, user_id, role_id, joined_at           |
| Workspace_roles    | Role trong workspace      | Id, workspace_id, name, permissions                     |

**Tính năng API:**

- Tạo workspace
- Mời thành viên
- Quản lý role
- Lấy danh sách thành viên

- **Task Service:**

**Chức năng**: Quản lý tasks, comments, assignment.  
**Database**: MongoDB (flexible schema)

| **Bảng**         | **Mục đích**      | **Fields chính**                                                                              |
| ---------------- | ----------------- | --------------------------------------------------------------------------------------------- |
| Tasks            | Thông tin task    | \_id, title, description, workspace_id, assigned_to, status, due_date, created_at, updated_at |
| Task_comments    | Bình luận task    | \_id, task_id, user_id, comment, created_at                                                   |
| Task_assignments | Lịch sử phân công | \_id, task_id, assigned_to, assigned_by, assigned_at                                          |

**Tính năng API:**

- CRUD task
- Comment task
- Assign task, track status

- **Notification Service:**

**Chức năng**: Gửi notification khi có sự kiện trong hệ thống.  
**Database: Redis (hoặc MongoDB nếu muốn lưu lịch sử notification lâu dài)**

| **Bảng**      | **Mục đích**         | **Fields chính**                                    |
| ------------- | -------------------- | --------------------------------------------------- |
| Notifications | Notification lưu trữ | Id, user_id, type, message, read_status, created_at |

**Tính năng API / Event:**

- Nhận sự kiện từ RabbitMQ (TASK_ASSIGNED, WORKSPACE_INVITED, COMMENT_CREATED)
- Gửi notification đến user qua WebSocket / email / push
- Lưu notification (tuỳ chọn)

- **RabbitMQ / gRPC:**

- **RabbitMQ**: truyền event bất đồng bộ giữa các service (notification, task…)
- **gRPC**: gọi trực tiếp, đồng bộ giữa service (ví dụ: User Service → Workspace Service khi cần info user)

- **Giải quyết vấn đề JOIN dữ liệu trong kiến trúc Microservices:**

- Không join trực tiếp DB → dùng **event-driven denormalized view (CQRS or Materialized View)** hoặc **API composition**.