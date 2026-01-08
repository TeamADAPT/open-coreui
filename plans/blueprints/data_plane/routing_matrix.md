# Polyglot Data Plane Routing Matrix (Phase 5)

## 2026-01-08 12:02:12 — codex-1

## Routing Principles
- Route by domain purpose, not convenience.
- Every write emits an event; reads can use query routing or materialized views.
- Postgres is the system of record for core entities.

## Primary Stores
- **Postgres/Timescale**: users, orgs, projects, runs, tasks, approvals, policies, metadata.
- **Dragonfly/Redis**: session state, ephemeral memory, short-lived caches.
- **MongoDB**: artifacts, tool outputs, traces, raw model responses.
- **Qdrant/Weaviate**: embeddings, retrieval, semantic search.
- **Neo4j/JanusGraph**: knowledge graphs and lineage.
- **ClickHouse/QuestDB**: metrics, evaluations, time-series.
- **Materialize**: streaming views from Redpanda/NATS.
- **Elasticsearch**: full-text search for artifacts and logs.

## Domain Routing Matrix
- **Agent Runs**: Postgres (primary), MongoDB (artifacts), ClickHouse (metrics)
- **Tool Calls**: Postgres (metadata), MongoDB (payloads), ClickHouse (latency)
- **Embeddings**: Qdrant (primary), Weaviate (hybrid queries)
- **Knowledge Graph**: Neo4j (live), JanusGraph (historical)
- **Streaming Events**: Redpanda (durable), NATS (low-latency)

## Event Backbone
- Emit events for every state transition.
- Materialize consumes from Redpanda to produce queryable views.
- ClickHouse ingests from Redpanda for analytics.

## Receipts
- Demonstrate live event emission and ingestion into ClickHouse and Materialize views.

— codex-1
