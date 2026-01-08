# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Open CoreUI is a lightweight Rust/Svelte implementation of Open WebUI. It consists of:
- **Backend**: Rust Actix-web server with SQLite database
- **Frontend**: SvelteKit + Vite application (built with Bun)
- **Desktop**: Tauri-based native desktop application

## Build Commands

```bash
# Install dependencies
cd frontend && bun install        # Frontend dependencies
cd backend && cargo fetch         # Rust dependencies
cd src-tauri && cargo fetch       # Tauri dependencies

# Build commands
make build-frontend              # Build frontend to frontend/build/
make build-backend               # Build backend with embedded frontend
make build-backend-slim          # Build backend without embedded frontend
make build-desktop               # Build Tauri desktop app
make prepare-*                   # Fetch dependencies only

# Run commands
make run-backend                 # Run backend dev server (with hot reload)
make run-backend-slim            # Run backend without embedded frontend
cargo tauri dev                  # Run desktop app in dev mode
```

## Architecture

### Backend (`backend/`)
- Actix-web 4.x with Rust runtime (Tokio)
- SQLite database via sqlx (config: `~/.config/open-coreui/data.sqlite3`)
- Frontend embedded at build time via `rust-embed` feature
- Default port: 8168

### Frontend (`frontend/`)
- SvelteKit 2.x with Vite 5.x
- Tailwind CSS 4.x
- i18n support (English, Chinese)
- Node.js: 18.13.0 - 22.x, npm >= 6.0.0

### Desktop (`src-tauri/`)
- Tauri 2.x desktop application
- Wraps the same backend binary

## Server Configuration

Key environment variables (see `CLI.md` for complete reference):

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST` | `0.0.0.0` | Server host |
| `PORT` | `8168` | Server port |
| `CONFIG_DIR` | `~/.config/open-coreui` | Config/data directory |
| `WEBUI_AUTH` | `true` | Enable authentication |
| `ENABLE_SIGNUP` | `true` | Enable user registration |
| `DATABASE_URL` | `sqlite://{CONFIG_DIR}/data.sqlite3` | Database path |

## Deployment

Backend binary location after build: `bin/open-coreui-{host}`

To run as a systemd service, create `~/.config/systemd/user/open-coreui.service` and use:
```bash
systemctl --user daemon-reload
systemctl --user enable --now open-coreui.service
```
