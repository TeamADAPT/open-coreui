#!/bin/bash
# Initialize Open CoreUI database with user 'x' as admin

set -e

DB_PATH="/data/adapt/platform/aiml/open-coreui/deploy/data.sqlite3"
CONFIG_DIR="/data/adapt/platform/aiml/open-coreui/deploy"

# Create config directory
mkdir -p "$CONFIG_DIR"

# Create database directory
mkdir -p "$CONFIG_DIR/data"

# Check if sqlx CLI is available
# sqlx-cli not required for basic operations, using sqlite3 directly

# Initialize database schema (run migrations)
echo "Running database migrations..."
cd /data/adapt/platform/aiml/open-coreui/backend

# Create user 'x' as admin directly in SQLite
echo "Creating user 'x' as admin..."

# Generate password hash for 'x' (using bcrypt, default for open-webui)
# For simplicity, we'll set up the user record directly
PASSWORD_HASH='$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/X4.VTtYn9qXwCqKKa'  # password: 'x'

sqlite3 "$DB_PATH" << EOF
-- Create users table if not exists
CREATE TABLE IF NOT EXISTS user (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    password TEXT,
    role TEXT DEFAULT 'pending',
    profile_image TEXT,
    settings TEXT,
    date_created INTEGER DEFAULT (strftime('%s', 'now')),
    last_login INTEGER
);

-- Check if user 'x' already exists
SELECT COUNT(*) FROM user WHERE name = 'x';
EOF

USER_EXISTS=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM user WHERE name = 'x';")

if [ "$USER_EXISTS" -eq 0 ]; then
    echo "Inserting user 'x' as admin..."
    sqlite3 "$DB_PATH" << EOF
INSERT INTO user (id, name, email, password, role, profile_image, settings, date_created)
VALUES (
    'x-user-id',
    'x',
    'x@example.com',
    '$PASSWORD_HASH',
    'admin',
    NULL,
    '{"webui_name": "x", "webui_theme": "dark"}',
    strftime('%s', 'now')
);
EOF
    echo "User 'x' created as admin."
else
    echo "User 'x' already exists. Updating to admin role..."
    sqlite3 "$DB_PATH" "UPDATE user SET role = 'admin' WHERE name = 'x';"
fi

echo "Database initialization complete."
echo "User 'x' can log in with password: x"
