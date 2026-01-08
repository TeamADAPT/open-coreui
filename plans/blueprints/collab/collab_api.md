# Collaboration API + UI Blueprint (Phase 6)

## 2026-01-08 12:21:44 — codex-1

## Goals
- Minimal HITL UI: approvals + comments only.
- Collaboration state as a first-class API surface.

## API Endpoints (core-api)
- `POST /api/collab/checkpoints`
- `GET /api/collab/checkpoints?run_id=...`
- `POST /api/collab/approvals`
- `POST /api/collab/comments`

## Data Model
- **Checkpoint**: id, run_id, step_id, payload_ref, status, created_at
- **Approval**: id, checkpoint_id, decision, actor_id, created_at
- **Comment**: id, checkpoint_id, actor_id, content, created_at

## UI Minimal Scope
- Approve/Reject buttons
- Comment thread per checkpoint

## Receipts
- Live HITL approval recorded in Temporal history and collab API.

— codex-1
