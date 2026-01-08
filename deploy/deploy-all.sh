#!/bin/bash
# Deploy Open CoreUI: HTTP Server + Desktop App

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="/data/adapt/platform/aiml/open-coreui"
DEPLOY_DIR="$SCRIPT_DIR"

echo "=== Open CoreUI Deployment Script ==="
echo ""

# Step 1: Build everything
echo "[1/5] Building frontend..."
cd "$APP_DIR/frontend" && bun install && bun run build

echo "[2/5] Building backend..."
cd "$APP_DIR/backend"
rm -rf target
cargo build --release
mkdir -p "$DEPLOY_DIR/bin"
cp target/release/open-webui-rust "$DEPLOY_DIR/bin/open-coreui-x86_64-unknown-linux-gnu"

echo "[3/5] Building desktop app (Tauri)..."
cd "$APP_DIR/src-tauri"
cargo fetch
cargo tauri build

echo "[4/5] Initializing database with user 'x' as admin..."
mkdir -p "$DEPLOY_DIR/data"
cd "$SCRIPT_DIR"
chmod +x init-db.sh
./init-db.sh

echo "[5/5] Installing systemd services..."

# Install HTTP server service
cp "$DEPLOY_DIR/open-coreui-http.service" ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable open-coreui-http.service

# Install and run desktop app (extract to system)
if [ -f "$APP_DIR/src-tauri/target/release/bundle/deb/Open.CoreUI.Desktop_*.deb" ]; then
    echo "Installing desktop app from .deb package..."
    sudo dpkg -i "$APP_DIR/src-tauri/target/release/bundle/deb/Open.CoreUI.Desktop_"*.deb || true
    sudo apt-get install -f -y || true
elif [ -f "$APP_DIR/src-tauri/target/release/bundle/AppImage/Open-CoreUI-Desktop-x86_64.AppImage" ]; then
    echo "Desktop app built at: $APP_DIR/src-tauri/target/release/bundle/AppImage/Open-CoreUI-Desktop-x86_64.AppImage"
    echo "Run: chmod +x and execute the AppImage to install"
fi

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "HTTP Server:"
echo "  - URL: http://localhost:15565"
echo "  - Service: systemctl --user start open-coreui-http"
echo "  - Logs: journalctl --user -u open-coreui-http -f"
echo ""
echo "Desktop App:"
echo "  - Installed via package manager or AppImage"
echo ""
echo "User 'x' has admin access (password: x)"
echo ""
echo "To start the HTTP server now:"
echo "  systemctl --user start open-coreui-http"
