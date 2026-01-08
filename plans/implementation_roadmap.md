# Implementation Roadmap — Rust + WASM64 + Temporal

## 2026-01-08 12:25:45 — codex-1

## Overview
This roadmap consolidates Phases 2–6 into an executable sequence with receipts. Security is intentionally excluded.

## Phase 2 — System Blueprint (Complete)
- Artifacts:
  - `plans/blueprints/system_blueprint.md`
  - `plans/blueprints/wit/contracts.wit`
  - `plans/blueprints/kernels.toml`
- Receipt: blueprint files exist and are signed.

## Phase 3 — Temporal + HITL Blueprint (Complete)
- Artifacts:
  - `plans/blueprints/temporal/temporal_hitl.md`
- Receipt: blueprint file exists and is signed.

## Phase 4 — WASM64 Runtime Plane (Complete)
- Artifacts:
  - `plans/blueprints/runtime_wasm/runtime_plane.md`
- Receipt: blueprint file exists and is signed.

## Phase 5 — Polyglot Data Plane (Complete)
- Artifacts:
  - `plans/blueprints/data_plane/routing_matrix.md`
  - `plans/blueprints/data_plane/event_schema.md`
- Receipt: blueprint files exist and are signed.

## Phase 6 — Collaboration API + UI (Complete)
- Artifacts:
  - `plans/blueprints/collab/collab_api.md`
- Receipt: blueprint file exists and is signed.

## Execution Sequence (Proposed)
1. **Rust service scaffolds**
   - Create workspace layout for `core-api`, `agent-orchestrator`, `runtime-wasm`, `collab-state`, `evals`.
   - Receipt: `cargo build` succeeds for all services; systemd unit templates prepared.
2. **Temporal integration (Rust worker)**
   - Implement Temporal worker skeleton with task queues per service.
   - Receipt: Temporal UI shows active workers in `rusty-ui` namespace.
3. **WASM64 runtime service**
   - Implement module cache and kernel dispatch path using WIT contract.
   - Receipt: kernel execution logged with ABI hash verification.
4. **Collaboration API**
   - Implement approvals + comments endpoints in `core-api`.
   - Receipt: HITL approval recorded and queryable.
5. **Data plane routing**
   - Implement event emitter and routing stubs to Redpanda/NATS.
   - Receipt: event emission observed in running services.

## Receipts (Required)
- Live Temporal workflow execution evidence.
- Kernel dispatch logs with ABI hash verification.
- Live HITL approval evidence.
- Event emission evidence.

— codex-1
