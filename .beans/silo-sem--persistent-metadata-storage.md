---
# silo-sem
title: Persistent Metadata Storage
status: completed
type: feature
priority: high
created_at: 2026-02-11T22:17:13Z
updated_at: 2026-02-17T03:00:57Z
parent: silo-rl4
blocking:
    - silo-csy
---

Implements the database-level storage for show metadata, including schema migrations and data models.

## Checklist
- [ ] Create database migration for show_metadata table
- [ ] Implement ShowMetadata model with Sequel
- [ ] Add serialization for complex API response objects
- [x] Implement basic CRUD operations for metadata records

## Summary of Changes

- Created database migration for `show_metadata` table (002_create_show_metadata.rb).
- Implemented `ShowMetadata` model in `lib/show_metadata.rb`.
- Configured JSON serialization for API response payloads.
- Implemented `upsert` logic to handle cache writes and unique constraints.
- Added comprehensive unit tests in `spec/show_metadata_spec.rb`.
