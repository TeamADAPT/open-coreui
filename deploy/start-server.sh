#!/bin/bash
# Open CoreUI Server Startup Script
# Works with systemd user or direct execution

set -e

APP_DIR="/data/adapt/platform/aiml/open-coreui"
BINARY="$APP_DIR/bin/open-coreui-x86_64-unknown-linux-gnu"
ENV_FILE="$APP_DIR/deploy/open-coreui.env"
LOG_FILE="$APP_DIR/deploy/open-coreui.log"
PID_FILE="$APP_DIR/deploy/open-coreui.pid"

# Load environment
export $(cat "$ENV_FILE" | grep -v '^#' | xargs)

# Check if running
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Server already running with PID $OLD_PID"
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# Start the server
echo "Starting Open CoreUI on port $PORT..."
cd "$APP_DIR/deploy"

# Create data directory if needed
mkdir -p data uploads cache

# Run in background
nohup "$BINARY" >> "$LOG_FILE" 2>&1 &
SERVER_PID=$!

echo $SERVER_PID > "$PID_FILE"
echo "Server started with PID $SERVER_PID"
echo "Log file: $LOG_FILE"
echo "Access at: http://localhost:$PORT"

# Wait a moment and verify
sleep 2
if kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "Server is running successfully"
else
    echo "Server failed to start. Check logs: tail $LOG_FILE"
    exit 1
fi
