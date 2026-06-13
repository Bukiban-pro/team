# Phase 3 Extreme Hardening Tasks

## Task Service
- `[ ]` Delete duplicated command/query handlers in `commands/` and `queries/` folders
- `[ ]` Fix `app.module.ts` (or equivalent) to import handlers from `usecases/`
- `[ ]` Add missing `lint` and `test` scripts to `package.json`
- `[ ]` Create 100% unit tests for `task-service` (17 handlers)
- `[ ]` Prune `Dockerfile` for production
- `[ ]` Add `jest-e2e.json`

## Notification Service
- `[ ]` Fix `package.json` `lint` script and dev dependencies
- `[ ]` Create unit tests for notification use cases
- `[ ]` Create unit tests for RabbitMQ event listeners
- `[ ]` Create unit tests for WebSocket gateway
- `[ ]` Prune `Dockerfile` for production
- `[ ]` Add `jest-e2e.json`

## Verification
- `[ ]` `pnpm install` in both services
- `[ ]` Run `lint`, `build`, and `test` for `task-service`
- `[ ]` Run `lint`, `build`, and `test` for `notification-service`
