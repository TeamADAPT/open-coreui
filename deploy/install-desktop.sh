#!/bin/bash
# Install Open CoreUI Desktop App
# Run this on a machine with a display (not a headless server)

set -e

APP_DIR="/data/adapt/platform/aiml/open-coreui"
DEB_FILE="$APP_DIR/src-tauri/target/release/bundle/deb/Open.CoreUI.Desktop_"*.deb
APPIMAGE="$APP_DIR/src-tauri/target/release/bundle/AppImage/Open-CoreUI-Desktop-x86_64.AppImage"

echo "=== Open CoreUI Desktop App Installer ==="
echo ""

if [ -f "$DEB_FILE" ]; then
    echo "Found .deb package: $(basename $DEB_FILE)"
    echo "Installing..."
    sudo dpkg -i "$DEB_FILE" || {
        echo "Dependencies missing, installing..."
        sudo apt-get update
        sudo apt-get install -f -y
    }
    echo "Desktop app installed successfully!"
    echo "Run: Open CoreUI Desktop"
elif [ -f "$APPIMAGE" ]; then
    echo "Found AppImage: $(basename $APPIMAGE)"
    chmod +x "$APPIMAGE"
    echo "To install, copy to /usr/local/bin or your applications folder:"
    echo "  cp '$APPIMAGE' /usr/local/bin/open-coreui-desktop"
    echo "  chmod +x /usr/local/bin/open-coreui-desktop"
    echo ""
    echo "Or run directly: $APPIMAGE"
else
    echo "Desktop app not built yet."
    echo "To build:"
    echo "  cd $APP_DIR/src-tauri"
    echo "  cargo tauri build"
    echo ""
    echo "Requirements:"
    echo "  - Ubuntu/Debian: sudo apt-get install libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev"
    echo "  - System Rust toolchain"
fi

echo ""
echo "=== Desktop App Configuration ==="
echo ""
echo "The desktop app will connect to:"
echo "  - HTTP Backend: http://localhost:15565"
echo ""
echo "To change the backend URL, edit:"
echo "  ~/.config/open-coreui/open-coreui.conf"
