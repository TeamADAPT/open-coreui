# System Blueprint — Rust + WASM64 + Temporal (Phase 2)

## 2026-01-08 11:52:41 — codex-1

## Purpose
Define the target service boundaries, data flows, runtime contracts, and event model to enable a Rust-first, WASM64-native, Temporal-orchestrated platform.

## Services (Boundaries)
- **core-api**: External HTTP API gateway, request validation, session orchestration, feature routing.
- **agent-orchestrator**: Translates user intents into Temporal workflows and lifecycle events.
- **runtime-wasm**: Executes WASM64 kernels with WASI-NN/WASI-GPU host functions and module cache.
- **tool-registry**: Stores tool metadata, kernel bindings, ABI hashes, and version policies.
- **collab-state**: Stores collaboration artifacts (checkpoints, comments, approvals).
- **evals**: Offline/online evaluation service (metrics, scoring, regression tracking).

## Core Data Flows
1. **Request Intake**
   - core-api receives request → emits `agent.run.requested` event → agent-orchestrator starts Temporal workflow.
2. **Agent Execution**
   - workflow steps call runtime-wasm via activities → kernel execution → tool outputs persisted.
3. **Collaboration + HITL**
   - workflow reaches approval gate → collab-state persists checkpoint → human signals approval/rejection.
4. **Persistence**
   - primary writes to Postgres; auxiliary writes to vectors/graphs/analytics via event routing.

## Canonical Event Schema (Top-Level)
- `agent.run.requested`
- `agent.run.started`
- `agent.step.started`
- `agent.step.completed`
- `tool.call.started`
- `tool.call.completed`
- `kernel.exec.started`
- `kernel.exec.completed`
- `artifact.persisted`
- `collab.checkpoint.created`
- `collab.approval.recorded`
- `eval.scored`

## Temporal Conventions
- Namespace: `rusty-ui`
- Task queues: one per service (`core-api`, `agent-orchestrator`, `runtime-wasm`, `collab-state`, `evals`).
- Workflow IDs: `<org>/<project>/<run-id>`.

## Runtime Contracts
- Kernel execution is defined via WIT contracts in `plans/blueprints/wit/`.
- Kernel registry and versioning defined in `plans/blueprints/kernels.toml`.

## Receipts
- `plans/blueprints/system_blueprint.md`
- `plans/blueprints/wit/contracts.wit`
- `plans/blueprints/kernels.toml`

— codex-1
