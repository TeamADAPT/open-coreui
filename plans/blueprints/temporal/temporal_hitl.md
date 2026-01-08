# Temporal + HITL Blueprint (Phase 3)

## 2026-01-08 12:02:12 — codex-1

## Goals
- Make Temporal the orchestration backbone for all agent workflows.
- Make HITL approval and comments first-class in workflow state.
- Keep UI minimal: approvals + comments only.

## Namespace + Task Queues
- Namespace: `rusty-ui`
- Task queues (per service):
  - `core-api`
  - `agent-orchestrator`
  - `runtime-wasm`
  - `collab-state`
  - `evals`

## Workflow Catalog
- `AgentRunWorkflow`
  - Orchestrates a single agent run from request to completion.
- `CollaborativeRunWorkflow`
  - Multi-agent coordination; spawns child workflows per agent.
- `HumanReviewWorkflow`
  - HITL checkpoints, approvals, and comments.
- `PlanExecuteWorkflow`
  - Planner -> Executor -> Evaluator flow.

## Activities
- `ExecuteWasmKernel`
- `InvokeTool`
- `PersistArtifact`
- `VectorSearch`
- `GraphExpand`
- `EmitEvent`
- `RecordCheckpoint`
- `RecordApproval`

## Signals
- `human.approve`
- `human.reject`
- `human.comment`
- `agent.interrupt`
- `agent.resume`

## Queries
- `get_run_state`
- `get_checkpoints`
- `get_comments`

## HITL Data Model
- **Checkpoint**: run_id, step_id, status, payload_ref, created_at
- **Approval**: checkpoint_id, decision, actor_id, created_at
- **Comment**: checkpoint_id, actor_id, content, created_at

## Receipts
- Live Temporal workflow execution with UI evidence.
- HITL approval and comment flow captured as workflow history.

— codex-1
