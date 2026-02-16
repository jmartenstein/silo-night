---
# silo-rtf
title: Define show_metadata schema
status: todo
type: task
priority: critical
created_at: 2026-02-11T22:18:06Z
updated_at: 2026-02-16T20:26:08Z
parent: silo-sem
blocking:
    - silo-mc1
    - silo-wd1
---

Create a new Sequel migration to establish the schema for caching show metadata.

## Checklist
- [ ] Create 002_create_show_metadata.rb migration
- [ ] Add columns: id, provider_name, external_id, payload (JSON), created_at, updated_at
- [ ] Add unique index on [provider_name, external_id]
- [ ] Run migration and verify schema
