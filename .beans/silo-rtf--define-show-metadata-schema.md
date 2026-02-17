---
# silo-rtf
title: Define show_metadata schema
status: completed
type: task
priority: critical
created_at: 2026-02-11T22:18:06Z
updated_at: 2026-02-17T02:59:02Z
parent: silo-sem
blocking:
    - silo-mc1
    - silo-wd1
---

Create a new Sequel migration to establish the schema for caching show metadata.

## Checklist
- [x] Create 002_create_show_metadata.rb migration
- [x] Add columns: id, provider_name, external_id, payload (JSON), created_at, updated_at
- [x] Add unique index on [provider_name, external_id]
- [x] Run migration and verify schema

## Summary of Changes

- Created `db/migrations/002_create_show_metadata.rb`
- Ran `rake db:migrate`
- Verified schema using `sqlite3`
