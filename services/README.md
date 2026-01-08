# Services Workspace

This directory hosts the Rust-only service binaries that implement the blueprint phases.
All services are designed for systemd deployment and should be built with `cargo build --release`.

## Services
- `core-api`: external API gateway and request router
- `agent-orchestrator`: Temporal workflow orchestration for agents
- `runtime-wasm`: WASM64 kernel execution plane (WASI-NN/WASI-GPU)
- `collab-state`: checkpoint, approval, and comment persistence
- `evals`: evaluation pipeline and metrics

## Build
From `services/`:

```bash
cargo build --release
```

Binaries are emitted to `services/target/release/`.
