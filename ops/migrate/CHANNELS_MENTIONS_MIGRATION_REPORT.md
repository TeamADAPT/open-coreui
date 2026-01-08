# Channels & Mentions Migration Report

**Repository**: open-coreui (Rust)
**Target Feature**: Full channels + @mentions from open-webui (Python)
**Analysis Date**: 2026-01-06
**Status**: IN PROGRESS

---

## Executive Summary

Migrating channels and mentions from open-webui (Python) to open-coreui (Rust) requires:
1. **PostgreSQL migration** (currently uses SQLite)
2. **Enhanced schema** for channels, members, mentions
3. **Service layer updates** in Rust
4. **Frontend port** of TipTap mention extension

---

## Part 1: Infrastructure Gap Analysis

### Your Platform (db_gpu_1.env) - Operational Services

| Service | Port | URL | Status | open-coreui Integration |
|---------|------|-----|--------|------------------------|
| **PostgreSQL** | 18030 | `x100-gpu:18030/adapt_db` | ✅ OPERATIONAL | ❌ Uses SQLite instead |
| **Redis** | 18010 | `x100-gpu:18010` | ✅ OPERATIONAL | ⚠️ Configurable |
| **DragonflyDB** | 18000 | `x100-gpu:18000` | ✅ OPERATIONAL | ❌ Not configured |
| **NATS** | 18040 | `x100-gpu:18040` | ✅ OPERATIONAL | ❌ Not configured |
| **Weaviate** | 18050 | `x100-gpu:18050` | ✅ OPERATIONAL | ❌ Not configured |
| **Qdrant** | 18055 | `x100-gpu:18055` | ✅ OPERATIONAL | ❌ Not configured |

### open-coreui Current State

| Component | Implementation | Config Var | Status |
|-----------|---------------|------------|--------|
| **Database** | SQLite (sqlx) | `DATABASE_URL` | Local file |
| **Redis** | Optional | `REDIS_URL` | Disabled |
| **Vector DB** | ChromaDB only | `VECTOR_DB` | Not configured |
| **Channels** | Basic | `ENABLE_CHANNELS` | Feature incomplete |

---

## Part 2: Feature Comparison

| Feature | open-webui (Python) | open-coreui (Rust) |
|---------|--------------------|-------------------|
| **Channels** | ✅ Full | ✅ Basic |
| **Channel Members** | ✅ Rich (role, status, mute, pin) | ⚠️ Minimal |
| **@Mentions** | ✅ Full (@users, @models, @channels) | ❌ Missing |
| **DM Channels** | ✅ Auto-create by user pair | ❌ Missing |
| **Group Channels** | ✅ Group-based membership | ❌ Missing |
| **Channel Files** | ✅ channel_file table | ❌ Missing |
| **Webhooks** | ✅ channel_webhook table | ❌ Missing |
| **Archive/Soft-delete** | ✅ archived_at, deleted_at | ❌ Missing |

---

## Part 3: Migration Requirements

### 3.1 Database Schema Updates

**File**: `backend/src/schema.sql`

```sql
-- Enhanced channel table (add missing columns)
ALTER TABLE channel ADD COLUMN is_private INTEGER;
ALTER TABLE channel ADD COLUMN updated_by TEXT;
ALTER TABLE channel ADD COLUMN archived_at INTEGER;
ALTER TABLE channel ADD COLUMN deleted_at INTEGER;
ALTER TABLE channel ADD COLUMN deleted_by TEXT;

-- Enhanced channel_member table
ALTER TABLE channel_member ADD COLUMN role TEXT;
ALTER TABLE channel_member ADD COLUMN status TEXT;
ALTER TABLE channel_member ADD COLUMN is_active INTEGER DEFAULT 1;
ALTER TABLE channel_member ADD COLUMN is_channel_muted INTEGER DEFAULT 0;
ALTER TABLE channel_member ADD COLUMN is_channel_pinned INTEGER DEFAULT 0;
ALTER TABLE channel_member ADD COLUMN invited_at INTEGER;
ALTER TABLE channel_member ADD COLUMN invited_by TEXT;
ALTER TABLE channel_member ADD COLUMN joined_at INTEGER;
ALTER TABLE channel_member ADD COLUMN left_at INTEGER;
ALTER TABLE channel_member ADD COLUMN last_read_at INTEGER;
ALTER TABLE channel_member ADD COLUMN updated_at INTEGER;

-- New: Message mentions table
CREATE TABLE IF NOT EXISTS message_mention (
    id TEXT PRIMARY KEY,
    message_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    mentioned_user_id TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (message_id) REFERENCES message(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES "user"(id) ON DELETE CASCADE,
    FOREIGN KEY (mentioned_user_id) REFERENCES "user"(id) ON DELETE CASCADE
);
```

### 3.2 Cargo.toml Changes

```toml
# Switch from SQLite to PostgreSQL
sqlx = { version = "0.8", features = [
    "runtime-tokio",
    "tls-rustls",
    "postgresql",  # ADD THIS
    "json",
    "chrono",
    "uuid",
    "migrate"
] }
```

### 3.3 Files to Create/Modify

| Component | Complexity | Files |
|-----------|-----------|-------|
| DB Schema | Medium | `schema.sql` |
| Mention Model | Low | `src/models/mention.rs` (new) |
| Channel Model updates | Low | `src/models/channel.rs` |
| Mention Service | Medium | `src/services/mention.rs` (new) |
| Channel Service updates | Medium | `src/services/channel.rs` |
| Mention Routes | Low | `src/routes/mentions.rs` (new) |
| Channel Route updates | Medium | `src/routes/channels.rs` |
| Frontend MentionList | Medium | Port Svelte file |
| Frontend Parser | Low | Port TypeScript file |

---

## Part 4: Estimation

| Phase | Task | Effort |
|-------|------|--------|
| **0** | PostgreSQL migration (db.rs, schema.sql, Cargo.toml) | 1 day |
| **1** | Enhanced Channel schema (is_private, archived, deleted) | 2 hours |
| **2** | Enhanced ChannelMember (role, status, mute, pin, timestamps) | 3 hours |
| **3** | MessageMention table and service | 4 hours |
| **4** | Channel DM logic (get_dm_channel_by_user_ids) | 3 hours |
| **5** | Mention parsing and API endpoints | 4 hours |
| **6** | Frontend MentionList + parser port | 6 hours |
| **7** | Testing and integration | 1 day |

**Total estimated**: ~3 days

---

## Part 5: Configuration

### Required env vars for open-coreui-15565.env

```bash
# Primary Database (PostgreSQL from your platform)
DATABASE_URL=postgresql://postgres_admin_user:Echovaeris1966!!@x100-gpu:18030/adapt_db

# Cache Layer (Redis)
ENABLE_REDIS=true
REDIS_URL=redis://:Echovaeris1966!!@x100-gpu:18010
SOCKETIO_REDIS_URL=redis://:Echovaeris1966!!@x100-gpu:18010

# Vector Database (Weaviate)
VECTOR_DB=weaviate
WEAVIATE_URL=http://x100-gpu:18050
WEAVIATE_API_KEY=Echovaeris1966!!
```

---

## Related Documentation

- `/data/adapt/projects/open-webui/backend/open_webui/models/channels.py` - Source implementation
- `/data/adapt/projects/open-webui/src/lib/utils/marked/mention-extension.ts` - Frontend parser
- `/data/adapt/platform/aiml/open-coreui/backend/src/schema.sql` - Current schema
- `/data/adapt/secrets/db_gpu_1.env` - Your infrastructure config

---

*Generated: 2026-01-06*
*Repository: open-coreui*
*CLAUDE.md context applied*
