# Phase 3: Extreme Task Service Hardening (3000% Progress)

The `workspace-service` is pristine. Now we strike at the very heart of CollabSpace: the **Task Service**.

During my deep reconnaissance, I discovered that the `task-service` currently has **zero unit tests**, a missing `lint` script, and a **fragmented CQRS architecture** where duplicate command handlers exist across both `application/commands/` and `application/usecases/` (the residue of an incomplete refactoring).

This plan will obliterate that technical debt and establish an unshakeable foundation for the core task domain.

## User Review Required
> [!IMPORTANT]
> The `task-service` has duplicated handler files (e.g., `assign-task.handler.ts` exists in both `commands/` and `usecases/`). I will forensically identify the active handlers, delete the stale ones, and fix all module imports. Please confirm you approve of this architectural cleanup.

## Open Questions
> [!NOTE]
> Do you want me to also write tests for the `notification-service` in this phase, or should we treat the 16+ CQRS handlers in `task-service` as the sole focus of this "Extreme 3000%" sprint? My recommendation is to focus intensely on `task-service` first to guarantee 100% perfection.

## Proposed Changes

### 1. Forensic Architecture Cleanup
We will eliminate the structural chaos in the CQRS implementation.

#### [DELETE] Stale Command Handlers
- `src/application/commands/assign-task.handler.ts` (Duplicate)
- `src/application/commands/change-task-status.handler.ts` (Duplicate)
- `src/application/commands/delete-task.handler.ts` (Duplicate)
- `src/application/commands/update-task-details.handler.ts` (Duplicate)
- `src/application/queries/get-task-by-id.handler.ts` (Duplicate)
- `src/application/queries/get-tasks.handler.ts` (Duplicate)

#### [MODIFY] `src/app.module.ts` (or relevant module)
- Remap all CQRS handler registrations to strictly use the `src/application/usecases/` directory.

### 2. Extreme 100% Test Coverage Implementation
We will write strictly typed, comprehensive unit tests for all 17 active CQRS handlers, covering domain logic, Mongoose persistence, and RabbitMQ event publishing.

#### [NEW] Task Lifecycle Tests
- `create-task.handler.spec.ts`
- `update-task-details.handler.spec.ts`
- `change-task-status.handler.spec.ts` (Must verify `DONE → TODO` rejection)
- `assign-task.handler.spec.ts` (Must verify UserReplica validation and RabbitMQ emit)
- `delete-task.handler.spec.ts`
- `get-task-by-id.handler.spec.ts`
- `get-tasks.handler.spec.ts`

#### [NEW] Comment Lifecycle Tests
- `create-comment.handler.spec.ts` (Must verify RabbitMQ emit)
- `edit-comment.handler.spec.ts`
- `delete-comment.handler.spec.ts`
- `get-task-comments.handler.spec.ts`

#### [NEW] User Replica & Attachment Tests
- `create-user-replica.handler.spec.ts`
- `sync-user-replica.handler.spec.ts`
- `upload-attachment.handler.spec.ts`
- `delete-attachment.handler.spec.ts`

### 3. Production Hardening

#### [MODIFY] `package.json`
- Inject standard `lint`, `format`, and `test:cov` scripts to enforce CI/CD compliance.

#### [MODIFY] `Dockerfile`
- Prune the production stage to exclusively copy `dist/` and `node_modules/`, enforcing non-root execution.

#### [NEW] `test/jest-e2e.json`
- Implement E2E testing scaffolding.

---

## Verification Plan

### Automated Tests
```powershell
pnpm install
pnpm run lint
pnpm run build
pnpm test
```
The goal is **0 lint errors**, **0 build warnings**, and **17 test suites passing** with 100% logic coverage for the CQRS layer.
