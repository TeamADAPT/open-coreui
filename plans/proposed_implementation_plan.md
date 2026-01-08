# Proposed Implementation Plan — Open CoreUI Magnum Opus (Rust + WASM64 + Temporal)

## 2026-01-08 11:29:06 — SIGNED_BY_AGENT

## Intent
Establish a Rust-first, WASM64-native platform with Temporal-based collaboration and HITL as first-class primitives. This plan is proposed and requires user approval before any implementation.

## Constraints
- Rust-only for new code unless Rust is not possible.
- Systemd-managed services only. No Docker. No venv.
- Live-system receipts over simulated tests.
- Security scope is explicitly out of scope for this plan phase.

## Scope
- Repository review update and gaps analysis (full sweep).
- Architectural blueprint for Rust + WASM64 + WASI-NN + WASI-GPU.
- Temporal integration for agents, collaboration, and HITL.
- Polyglot data plane utilization with explicit routing and event model.

## Deliverables
1. Updated comprehensive review report and production-readiness assessment (security excluded).
2. Systems blueprint: services, data flows, runtime contracts.
3. Temporal workflow catalog + activity inventory.
4. WASM64 kernel execution plane design.
5. Polyglot data plane routing matrix.
6. Implementation roadmap with milestones, dependencies, and receipts.

## Phased Plan (Proposed)

### Phase 1 — Repo Deep Review (No code changes)
- Sweep: `docs/`, `deploy/`, `tests/`, `ops/`, `backend/`, `frontend/`, `src-tauri/`.
- Map feature completeness, TODOs, stubs, and integration debt.
- Output: Review report with strong/weak areas and recommendations.
- Receipt: Review report added to `plans/`.

### Phase 2 — System Blueprint
- Define service boundaries: `core-api`, `agent-orchestrator`, `runtime-wasm`, `tool-registry`, `collab-state`, `evals`.
- Define canonical event schema (protobuf + JSON) for runs/tools/memory/artifacts.
- Define runtime contracts (WIT interfaces) for kernels and tools.
- Receipt: Architecture diagram (text) + schema specs committed.

### Phase 3 — Temporal + HITL First-Class
- Implement Temporal worker scaffolding in Rust.
- Workflows: `AgentRunWorkflow`, `CollaborativeRunWorkflow`, `HumanReviewWorkflow`, `PlanExecuteWorkflow`.
- Activities: `ExecuteWasmKernel`, `InvokeTool`, `VectorSearch`, `GraphExpand`, `EmitEvent`, `PersistArtifact`.
- HITL: approval queues, branching, and checkpoint comments.
- Receipt: Live Temporal workflow execution with UI evidence.

### Phase 4 — WASM64 Runtime Plane
- WASM64 executor with precompiled module cache.
- WASI-NN + WASI-GPU host functions.
- GPU scheduling policy in Rust.
- Kernel registry with ABI/version constraints.
- Receipt: Live kernel execution with GPU dispatch logs.

### Phase 5 — Polyglot Data Plane
- Data routing matrix by domain (graph, vector, doc, KV, relational, analytics).
- Stream ingestion via NATS/Redpanda and Materialize views.
- Unified query router in Rust.
- Receipt: Live data flow from events to ClickHouse/Materialize views.

### Phase 6 — Agent Collaboration UX/API
- Collaboration state endpoints (runs, checkpoints, comments).
- Agent-to-agent signals via Temporal + NATS.
- Receipt: Multi-agent collaboration trace with HITL checkpoint approvals.

## Open Questions — Answered
- Review report location and format: `plans/reviews/open-coreui.md` (Markdown, signed receipts).
- Kernel registry: `kernels.toml` + WIT hashes; semver + ABI hash pinning.
- Temporal: namespace `rusty-ui`; task queues per service.
- HITL UI: minimal approvals + comments only.

## Approval Gate
Approved by user with the above answers. Implementation may proceed.
