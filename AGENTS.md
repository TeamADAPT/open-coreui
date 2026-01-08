# Agent Instructions

## 2026-01-08 12:28:10 — codex-1

## Core Rules
- Rust-only for new code unless Rust is not possible.
- Systemd-managed services only. No Docker. No venv.
- Prioritize live system receipts over simulated tests.
- Plan-first: update `plans/` (or `/projects/rustyui/implementation_plan.md`) and obtain user approval before code changes.

## Ops Discipline
- Log every operational action in `ops/operations_history.md` and `ops/decisions.log`.
- Use reverse-chronological entries with ISO timestamps and `— SIGNED_BY_AGENT`.
- Include file paths for all touched files in decisions.

## Git Workflow
- Feature branches only (no direct commits to `main`).
- One branch per worktree; no multiple clones.
- Rebase before PRs unless instructed otherwise.
- Commit often; keep commits small and descriptive.
- No force-push without approval; no auth resets or token regeneration.
- Use GH CLI for PRs and status: `gh pr create`, `gh pr status`, `gh pr view`.

## Documentation Expectations
- Heavy on documentation; minimal ambiguity.
- Scripts must include comprehensive, meaningful comments.

## Tooling Notes
- Use the existing repo clone; do not re-authenticate GitHub.
- `gh` is already logged in; verify status only if needed.

— codex-1
