# Canonical Event Schema (Phase 5)

## 2026-01-08 12:02:12 — codex-1

## Envelope
- `event_id` (uuid)
- `event_type` (string)
- `timestamp` (unix_ms)
- `org_id`
- `project_id`
- `run_id`
- `actor_id`
- `payload` (json)

## Core Event Types
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
- `collab.comment.recorded`
- `eval.scored`

## Payload Conventions
- All payloads are versioned: `payload.version` (semver).
- Artifact payloads include `artifact_ref`.
- Kernel execution payloads include `kernel_id`, `kernel_version`, `abi_hash`.

— codex-1
