# LLM Tool Creation Runbook

**Date**: 2026-01-06
**Purpose**: Guide for agents to create tools on-the-fly with safety boundaries
**Applicable To**: User `agent` and domain-expert agents
**Status**: Active

## Overview

This runbook provides procedures for creating LLM tools that extend the Open WebUI / Open CoreUI capabilities. Tools can be written in Python or Rust, with Python being the current standard and Rust as the emerging option.

## Architecture Overview

### Current State
- **Location**: `/data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/`
- **Language**: Python (current), Rust (experimental)
- **Pattern**: Each tool is a file with a `class Tools:` containing methods
- **Registration**: Tools must be registered in SQLite database to appear in UI
- **Discovery**: Backend scans tools directory and loads tool definitions

### Tool Structure
```python
import os
import json
from typing import Any, Dict, List, Optional

class Tools:
    def __init__(self):
        # Initialize connections, clients, etc.
        pass

    def method_name(self, param1: type, param2: type) -> return_type:
        """
        Docstring explaining what the tool does.
        :param param1: Description
        :param param2: Description
        :return: What is returned
        """
        # Implementation here
        pass
```

## Directory Structure

### Tool Location Hierarchy
```
/data/adapt/projects/open-webui/backend/open_webui/apps/webui/
├── tools/                          # Production tools (Python)
│   ├── __init__.py
│   ├── tool_factory.py            # Metatool for tool creation
│   ├── session_manager.py         # Session persistence
│   ├── file_manager.py            # File operations
│   └── [your_tool].py             # New tools here
│
├── rust_tools/                    # NEW: Rust tools directory
│   ├── Cargo.toml                 # Rust workspace configuration
│   ├── src/                       # Source files
│   │   ├── lib.rs                 # Library entry point
│   │   └── tools/                 # Individual tool modules
│   │       ├── mod.rs
│   │       └── [your_tool].rs     # Rust tool implementations
│   └── target/                    # Build artifacts
│
├── routes/                        # Backend API routes
│   └── tools.py                   # Tool API endpoints
│
├── models/
│   └── tools.py                   # Database models
│
└── utils/
    └── tools.py                   # Tool utilities
```

## Python Tool Creation Procedure

### Step 1: Design the Tool

**Before writing code, answer these questions:**

1. **Purpose**: What specific problem does this tool solve?
2. **Input/Output**: What data goes in, what comes out?
3. **Dependencies**: What external systems does it need? (DB, APIs, files)
4. **Safety**: Can this tool cause damage? How to prevent it?
5. **Scope**: Should this be one tool or multiple specialized tools?

### Step 2: Create the Tool File

1. **Navigate to tools directory**:
   ```bash
   cd /data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/
   ```

2. **Create tool file** (use descriptive name with underscores):
   ```bash
   # Example: database_migration_helper.py
   touch [tool_name].py
   ```

3. **Set ownership**:
   ```bash
   chown agent:agent [tool_name].py
   chmod 644 [tool_name].py
   ```

### Step 3: Implement the Tool

**Template:**
```python
"""
[Tool Name] - [Brief Description]

[Detailed description of what the tool does and when to use it.]
"""

import os
import sys
import json
import sqlite3
from typing import Dict, List, Any, Optional, Union
from datetime import datetime

class Tools:
    def __init__(self):
        """Initialize the tool with necessary connections."""
        # Database connection
        self.db_path = "/data/adapt/projects/open-webui/backend/data/webui.db"

        # Configuration
        self.config_dir = "/data/adapt/projects/open-webui/backend"

        # Optional: Redis for caching
        # self.redis_client = self._init_redis()

        # Optional: Logging
        self.log_file = "/tmp/[tool_name].log"

    def _init_redis(self):
        """Initialize Redis connection (if needed)."""
        try:
            import redis
            return redis.Redis(
                host="localhost",
                port=int(os.getenv("REDIS_PORT", 18000)),
                db=0,
                password=os.getenv("DB_DEFAULT_PASSWORD"),
                decode_responses=True
            )
        except Exception as e:
            print(f"Redis connection failed: {e}")
            return None

    def _log(self, message: str, level: str = "INFO"):
        """Log messages to file."""
        timestamp = datetime.now().isoformat()
        log_entry = f"{timestamp} [{level}] {message}\n"
        with open(self.log_file, 'a') as f:
            f.write(log_entry)

    def validate_database(self) -> Dict[str, Any]:
        """
        Validate database schema and connections.

        :return: Dictionary with status and details
        """
        try:
            # Example validation logic
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()

            # Check tables exist
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = [row[0] for row in cursor.fetchall()]

            conn.close()

            return {
                "status": "success",
                "tables": tables,
                "message": f"Database validation passed. Found {len(tables)} tables."
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }

# Additional methods go here...
```

### Step 4: Test the Tool (Live Validation)

**Critical: Always test against live system, never in isolation**

1. **Start Python shell**:
   ```bash
   python3
   ```

2. **Import and test**:
   ```python
   import sys
   sys.path.append('/data/adapt/projects/open-webui/backend')

   from open_webui.apps.webui.tools.[tool_name] import Tools

   # Initialize
   tool = Tools()

   # Test each method
   result = tool.validate_database()
   print(result)
   ```

3. **Validate output**:
   - Check return types match expectations
   - Verify no exceptions
   - Confirm data is correct

### Step 5: Register in Database

```python
import sqlite3
import time
from pathlib import Path

def register_tool(tool_id: str, tool_name: str, tool_file: str):
    """
    Register tool in Open WebUI database.
    """
    db_path = "/data/adapt/projects/open-webui/backend/data/webui.db"

    # Read tool code
    tool_path = Path(f"/data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/{tool_file}")
    with tool_path.open('r') as f:
        content = f.read()

    # Connect and register
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    now = int(time.time())

    # Check if exists
    cursor.execute("SELECT id FROM tool WHERE id = ?", (tool_id,))
    if cursor.fetchone():
        # Update existing
        cursor.execute("""
            UPDATE tool
            SET name = ?, content = ?, updated_at = ?
            WHERE id = ?
        """, (tool_name, content, now, tool_id))
        print(f"Updated existing tool: {tool_id}")
    else:
        # Insert new
        cursor.execute("""
            INSERT INTO tool (id, user_id, name, content, specs, meta, access_control, created_at, updated_at)
            VALUES (?, 'agent', ?, ?, '[]', ?, NULL, ?, ?)
        """, (tool_id, tool_name, content,
              '{"description": "' + tool_name + '"}',
              now, now))
        print(f"Registered new tool: {tool_id}")

    conn.commit()
    conn.close()

# Usage
register_tool("my_tool_id", "My Tool Name", "my_tool.py")
```

### Step 6: Restart Service

```bash
sudo systemctl restart open-webui-enhanced
# Wait 10-30 seconds for service to fully restart
```

### Step 7: Verify in UI

1. Open Open WebUI in browser
2. Navigate to Workspace → Tools
3. Find your tool in the list
4. Test tool execution via chat interface

## Rust Tool Creation Procedure (Experimental)

### Why Rust?

**Advantages:**
- Memory safety and no runtime crashes
- Better performance for CPU-intensive tasks
- Type safety catches errors at compile time
- Concurrency without data races

**Challenges:**
- More complex setup
- Interfacing with Python backend requires FFI or HTTP API
- Compilation required before use
- Steeper learning curve

### Rust Tool Architecture

**Option 1: Standalone HTTP Microservices**

Each Rust tool runs as a separate HTTP service that the Python backend calls.

```rust
// rust_tools/src/tools/db_validator.rs
use axum::{
    routing::post,
    Router, Json, extract::State,
    http::StatusCode,
};
use serde::{Deserialize, Serialize};
use std::sync::Arc;
use sqlx::sqlite::SqlitePool;

#[derive(Deserialize)]
struct ValidateRequest {
    database_path: String,
}

#[derive(Serialize)]
struct ValidateResponse {
    status: String,
    tables: Vec<String>,
    message: String,
}

#[derive(Clone)]
struct AppState {
    pool: SqlitePool,
}

async fn validate_database(
    State(state): State<Arc<AppState>>,
    Json(req): Json<ValidateRequest>,
) -> Result<Json<ValidateResponse>, StatusCode> {
    // Implementation here
    Ok(Json(ValidateResponse {
        status: "success".to_string(),
        tables: vec!["table1".to_string()],
        message: "Database valid".to_string(),
    }))
}

#[tokio::main]
async fn main() {
    let pool = SqlitePool::connect("database.db")
        .await
        .expect("Failed to connect to database");

    let state = Arc::new(AppState { pool });

    let app = Router::new()
        .route("/validate", post(validate_database))
        .with_state(state);

    axum::Server::bind(&"0.0.0.0:3001".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

**Python wrapper:**
```python
import requests
import json

class Tools:
    def __init__(self):
        self.rust_service_url = "http://localhost:3001"

    def validate_database(self, database_path: str) -> Dict[str, Any]:
        """Call Rust service for validation."""
        response = requests.post(
            f"{self.rust_service_url}/validate",
            json={"database_path": database_path}
        )
        return response.json()
```

### Setting Up Rust Tools

1. **Initialize Rust workspace**:
   ```bash
   cd /data/adapt/projects/open-webui/backend/open_webui/apps/webui/
   mkdir -p rust_tools/src/tools
   cd rust_tools
   ```

2. **Create Cargo.toml**:
   ```toml
   [package]
   name = "webui-tools"
   version = "0.1.0"
   edition = "2021"

   [dependencies]
   axum = "0.7"
   tokio = { version = "1", features = ["full"] }
   serde = { version = "1.0", features = ["derive"] }
   serde_json = "1.0"
   sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "sqlite"] }
   anyhow = "1.0"
   ```

3. **Create src/lib.rs**:
   ```rust
   pub mod tools;
   ```

4. **Create src/tools/mod.rs**:
   ```rust
   pub mod db_validator;
   pub mod file_ops;
   // Add new modules here
   ```

5. **Build the project**:
   ```bash
   cargo build --release
   ```

## Safety Boundaries & Do's and Don'ts

### 🟢 APPROVED: Safe Operations

These operations are completely safe and encouraged:

- **Read-only database queries** (`SELECT` statements)
- **File reading** from approved directories
- **Configuration validation** and checking
- **Status monitoring** and health checks
- **Documentation generation**
- **Log analysis** (read-only)
- **API status checks**
- **Data export** (non-destructive)

### 🟡 CAUTION: Use with Validation

These require extra validation and safeguards:

- **Database schema modifications** - Always make backups first
- **File modifications** - Use transactional patterns with backups
- **Configuration changes** - Validate before applying, keep old config
- **Log rotation/cleanup** - Only remove old logs, not recent ones
- **Cache operations** - Safe but verify impact

**Required safeguards:**
```python
def safe_file_modify(file_path: str, new_content: str) -> str:
    """Safely modify file with backup."""
    import shutil
    try:
        # 1. Create backup
        backup_path = file_path + ".backup." + str(int(time.time()))
        shutil.copy2(file_path, backup_path)

        # 2. Validate new content
        # (Add validation logic here)

        # 3. Write new content
        with open(file_path, 'w') as f:
            f.write(new_content)

        # 4. Verify file is readable
        with open(file_path, 'r') as f:
            _ = f.read()

        return f"Success: File modified, backup at {backup_path}"
    except Exception as e:
        # Restore backup on error
        if os.path.exists(backup_path):
            shutil.copy2(backup_path, file_path)
        return f"Error: {str(e)} - backup restored"
```

### 🔴 PROHIBITED: Dangerous Operations

**NEVER perform these operations without human approval:**

- **Raw SQL execution** with user-provided strings (SQL injection risk)
- **System command execution** with user input (command injection)
- **File deletion** outside designated temporary directories
- **Database table dropping** or schema destruction
- **Configuration file overwriting** without backup
- **Service restart/kill** commands
- **Network firewall changes**
- **User privilege modifications**

**If a tool requires these:**
1. Create a validation layer that requires confirmation
2. Log all operations in an audit trail
3. Send notification before executing
4. Implement dry-run mode first

### 🔒 Authentication & Authorization

**Current system**: Auth disabled, auto-login as user 'x' (admin)

**For production with auth enabled:**

```python
def check_permission(user_id: str, action: str) -> bool:
    """
    Check if user has permission for action.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT role FROM user WHERE id = ?
    """, (user_id,))

    result = cursor.fetchone()
    if not result:
        return False

    role = result[0]
    conn.close()

    # Admin can do anything
    if role == "admin":
        return True

    # Add role-based permission logic here
    # return action in get_allowed_actions(role)

    return False
```

## Testing & Validation Procedures

### Level 1: Unit Testing (Mandatory)

Test each method with valid and invalid inputs:

```python
def test_validate_database():
    """Test database validation tool."""
    tool = Tools()

    # Test 1: Valid database
    result = tool.validate_database()
    assert result["status"] == "success"
    assert "tables" in result

    # Test 2: Invalid path (if method accepts path param)
    # result = tool.validate_database("/nonexistent/path.db")
    # assert result["status"] == "error"

    print("✓ All tests passed")

if __name__ == "__main__":
    test_validate_database()
```

### Level 2: Integration Testing (Mandatory)

Test tool in the actual Open WebUI environment:

```bash
# Terminal 1: Watch logs
sudo tail -f /var/log/open-webui-enhanced/

# Terminal 2: Trigger tool via UI or API
curl -X POST http://localhost:8080/api/tools/execute \
  -H "Content-Type: application/json" \
  -d '{"tool_id": "my_tool", "method": "validate_database"}'
```

### Level 3: End-to-End Testing (Mandatory for Production)

Test complete user workflows:

```python
# simulate_user_workflow.py
from open_webui.apps.webui.tools.my_tool import Tools
import json

def run_complete_workflow():
    """Simulate realistic user workflow."""
    tool = Tools()

    # Step 1: Initialize
    print("Step 1: Initializing...")

    # Step 2: Execute primary function
    print("Step 2: Executing main function...")
    result = tool.primary_function()
    print(json.dumps(result, indent=2))

    # Step 3: Validate results
    print("\nStep 3: Validating results...")
    assert result["status"] == "success"

    print("\n✓ Complete workflow passed")

if __name__ == "__main__":
    run_complete_workflow()
```

### Level 4: Load Testing (Optional, for high-frequency tools)

```python
import time
import statistics

def load_test():
    """Test tool performance under load."""
    tool = Tools()

    times = []
    for i in range(100):
        start = time.time()
        result = tool.fast_operation()
        end = time.time()
        times.append(end - start)

    print(f"Mean execution time: {statistics.mean(times):.4f}s")
    print(f"95th percentile: {statistics.quantiles(times, n=20)[18]:.4f}s")
    print(f"Max time: {max(times):.4f}s")
```

## Example: Complete Tool Creation Workflow

### Tool: Database Schema Analyzer

**Purpose**: Analyze database schema and provide optimization recommendations

**File**: `/data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/schema_analyzer.py`

```python
"""
Schema Analyzer - Analyze database schema and provide recommendations.

This tool examines the SQLite database schema to identify:
- Missing indexes
- Unused columns
- Schema inconsistencies
- Performance recommendations
"""

import sqlite3
import json
import re
from typing import Dict, List, Any

class Tools:
    def __init__(self):
        self.db_path = "/data/adapt/projects/open-webui/backend/data/webui.db"

    def analyze_schema(self) -> Dict[str, Any]:
        """
        Analyze database schema and return recommendations.

        :return: Dictionary with schema information and recommendations
        """
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()

            # Get all tables
            cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = [row[0] for row in cursor.fetchall()]

            analysis = {
                "tables": [],
                "total_tables": len(tables),
                "recommendations": []
            }

            for table in tables:
                # Analyze each table
                table_info = self._analyze_table(cursor, table)
                analysis["tables"].append(table_info)

                # Generate recommendations
                recommendations = self._generate_recommendations(table_info)
                analysis["recommendations"].extend(recommendations)

            conn.close()

            return {
                "status": "success",
                "analysis": analysis
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }

    def _analyze_table(self, cursor, table_name: str) -> Dict[str, Any]:
        """Analyze a single table."""
        # Get table info
        cursor.execute(f"PRAGMA table_info({table_name})")
        columns = cursor.fetchall()

        # Get indexes
        cursor.execute(f"PRAGMA index_list({table_name})")
        indexes = cursor.fetchall()

        # Get row count
        cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
        row_count = cursor.fetchone()[0]

        return {
            "name": table_name,
            "columns": len(columns),
            "indexes": len(indexes),
            "row_count": row_count,
            "column_details": columns,
            "index_details": indexes
        }

    def _generate_recommendations(self, table_info: Dict) -> List[str]:
        """Generate recommendations for a table."""
        recommendations = []

        # Check if table has many rows but no indexes
        if table_info["row_count"] > 1000 and table_info["indexes"] == 0:
            recommendations.append(
                f"Table '{table_info['name']}' has {table_info['row_count']} rows "
                f"but no indexes. Consider adding an index for better performance."
            )

        # Check for tables without created_at/updated_at
        column_names = [col[1] for col in table_info['column_details']]
        if 'created_at' not in column_names:
            recommendations.append(
                f"Table '{table_info['name']}' missing 'created_at' column. "
                "Consider adding it for audit purposes."
            )

        return recommendations

    def get_table_schema(self, table_name: str) -> Dict[str, Any]:
        """
        Get detailed schema for a specific table.

        :param table_name: Name of the table
        :return: Table schema details
        """
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()

            cursor.execute(f"PRAGMA table_info({table_name})")
            columns = cursor.fetchall()

            conn.close()

            return {
                "status": "success",
                "table": table_name,
                "columns": [
                    {
                        "cid": col[0],
                        "name": col[1],
                        "type": col[2],
                        "notnull": col[3],
                        "default": col[4],
                        "primary_key": col[5]
                    }
                    for col in columns
                ]
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }
```

**Testing the tool:**

```bash
cd /data/adapt/projects/open-webui/backend/
python3

# Test import
>>> from open_webui.apps.webui.tools.schema_analyzer import Tools

# Test instantiation
>>> tool = Tools()

# Test analysis
>>> result = tool.analyze_schema()
>>> print(json.dumps(result, indent=2))

# Test specific table
>>> result = tool.get_table_schema("user")
>>> print(json.dumps(result, indent=2))
```

**Registering the tool:**

```python
import sqlite3
import time
from pathlib import Path

def register_schema_analyzer():
    db_path = "/data/adapt/projects/open-webui/backend/data/webui.db"

    tool_path = Path("/data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/schema_analyzer.py")
    tool_code = tool_path.read_text()

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    now = int(time.time())

    cursor.execute("""
        INSERT INTO tool (id, user_id, name, content, specs, meta, access_control, created_at, updated_at)
        VALUES ('schema_analyzer', 'agent', 'Schema Analyzer', ?, '[]', ?, NULL, ?, ?)
    """, (tool_code, '{"description": "Analyze database schema and provide optimization recommendations"}', now, now))

    conn.commit()
    conn.close()
    print("Schema analyzer tool registered")

register_schema_analyzer()
```

**Verification:**

```bash
# Check tool file exists
ls -la /data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/schema_analyzer.py

# Check database registration
sqlite3 /data/adapt/projects/open-webui/backend/data/webui.db \
  "SELECT id, name FROM tool WHERE id = 'schema_analyzer'"

# Restart service
sudo systemctl restart open-webui-enhanced

# Check logs for errors
sudo journalctl -u open-webui-enhanced -n 50
```

## Troubleshooting

### Problem 1: Tool not appearing in UI

**Symptoms**: Tool registered in DB but not showing up

**Diagnosis**:
```bash
# Check tool specs field
sqlite3 /data/adapt/projects/open-webui/backend/data/webui.db \
  "SELECT id, specs FROM tool WHERE id = 'your_tool'"

# If specs is '[]', need to regenerate
curl -X POST http://localhost:8080/api/tools/regenerate-specs
```

**Solution**:
1. Ensure tool code has proper docstrings
2. Regenerate specs via API or UI
3. Restart service

### Problem 2: Tool import errors

**Symptoms**: `ImportError`, `ModuleNotFoundError`

**Diagnosis**:
```bash
# Test import manually
python3 -c "from open_webui.apps.webui.tools.your_tool import Tools; print('OK')"

# Check Python path
python3 -c "import sys; print('\n'.join(sys.path))"
```

**Solution**:
1. Ensure tool file has correct permissions
2. Check for syntax errors: `python3 -m py_compile your_tool.py`
3. Verify all imports are available

### Problem 3: Database locked

**Symptoms**: `sqlite3.OperationalError: database is locked`

**Solution**:
1. Check for concurrent access
2. Add retry logic:
```python
import time

def with_retry(func, max_retries=3):
    for i in range(max_retries):
        try:
            return func()
        except sqlite3.OperationalError as e:
            if "locked" in str(e) and i < max_retries - 1:
                time.sleep(0.1 * (i + 1))
                continue
            raise
```

### Problem 4: Permission denied

**Symptoms**: `PermissionError` when writing files

**Solution**:
1. Check file ownership: `ls -la file_path`
2. Ensure agent user has permissions: `chown agent:agent file_path`
3. Use appropriate directories: `/tmp/` for temp files, tool directory for persistent data

## Security Checklist

**Before deploying any tool, verify:**

- [ ] Tool only accesses approved directories
- [ ] All database operations use parameterized queries
- [ ] File paths are validated and sanitized
- [ ] System commands are never executed with user input
- [ ] Backup is created before destructive operations
- [ ] Tool logs all actions to audit trail
- [ ] Sensitive data is never logged
- [ ] API keys and credentials use environment variables
- [ ] Tool validates all inputs and rejects malformed data
- [ ] Error messages don't leak sensitive information
- [ ] Tool has timeout protection for long operations
- [ ] Resource limits are respected (CPU, memory, file handles)

## Performance Considerations

### For High-Frequency Tools

1. **Cache results** where appropriate:
```python
import functools
import time

@functools.lru_cache(maxsize=128)
def cached_expensive_operation(param):
    # Expensive computation here
    return result
```

2. **Use connection pooling**:
```python
from contextlib import contextmanager

@contextmanager
def get_db_connection():
    conn = sqlite3.connect(db_path)
    try:
        yield conn
    finally:
        conn.close()
```

3. **Batch operations** instead of N+1 queries

### For Long-Running Tools

1. **Implement progress tracking**:
```python
def long_running_task():
    total = 1000
    for i in range(total):
        # Process item
        # Log progress every 100 items
        if i % 100 == 0:
            print(f"Progress: {i}/{total} ({i/total*100:.1f}%)")
```

2. **Use background processing for tasks > 30 seconds**

## Emergency Procedures

### If a tool causes system issues:

1. **Disable tool immediately**:
```bash
# Move tool file to safe location
mv /data/adapt/projects/open-webui/backend/open_webui/apps/webui/tools/problematic_tool.py \
   /tmp/problematic_tool.py.bak
```

2. **Remove from database**:
```bash
sqlite3 /data/adapt/projects/open-webui/backend/data/webui.db \
  "DELETE FROM tool WHERE id = 'problematic_tool'"
```

3. **Restart service**:
```bash
sudo systemctl restart open-webui-enhanced
```

4. **Check logs for root cause**:
```bash
sudo journalctl -u open-webui-enhanced --since "5 minutes ago"
```

### Rollback Procedure

```bash
# Restore from backup
if [ -f "/path/to/tool.py.bak" ]; then
    cp /path/to/tool.py.bak /path/to/tool.py
    sudo systemctl restart open-webui-enhanced
    echo "Rolled back to previous version"
fi
```

## Contact & Support

**For questions or issues:**
- Review logs: `/var/log/open-webui-enhanced/`
- Check this runbook
- Refer to existing tools for examples
- Test in development environment before production

**System Administrator**: Available for emergency issues

---

**Document Version**: 1.0
**Last Updated**: 2026-01-06
**Next Review**: 2026-02-06
