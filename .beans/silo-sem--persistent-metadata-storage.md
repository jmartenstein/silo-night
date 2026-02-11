---
# silo-sem
title: Persistent Metadata Storage
status: todo
type: feature
priority: high
created_at: 2026-02-11T22:17:13Z
updated_at: 2026-02-11T22:35:50Z
parent: silo-rl4
blocking:
    - silo-csy
---

Implements the database-level storage for show metadata, including schema migrations and data models.

## Checklist
- [ ] Create database migration for show_metadata table
- [ ] Implement ShowMetadata model with Sequel
- [ ] Add serialization for complex API response objects
- [ ] Implement basic CRUD operations for metadata records