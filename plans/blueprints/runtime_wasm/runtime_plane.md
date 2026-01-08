# WASM64 Runtime Plane Blueprint (Phase 4)

## 2026-01-08 12:21:44 — codex-1

## Goals
- WASM64 execution as the default runtime for kernels and tools.
- WASI-NN + WASI-GPU host functions with deterministic scheduling.
- Precompiled module cache and ABI-locked registry.

## Components
- **runtime-wasm** (service)
  - Wasmtime/Wasmer host
  - Module cache (precompiled artifacts)
  - Kernel dispatch
  - GPU scheduler
- **kernel registry** (data)
  - `kernels.toml` as source of truth
  - ABI hash pinning + semver enforcement

## Execution Flow
1. Resolve kernel by name + semver.
2. Validate ABI hash matches registry.
3. Load module from cache (or compile).
4. Execute `kernel_exec.exec` with WIT contract.
5. Emit `kernel.exec.completed` event.

## Scheduling
- Priority queue by kernel class (interactive, batch, eval).
- GPU-aware dispatch with concurrency caps.

## Receipts
- Live kernel execution log with ABI hash verification.

— codex-1
