---
# silo-wd1
title: Develop cache write logic
status: completed
type: task
priority: normal
created_at: 2026-02-11T22:18:16Z
updated_at: 2026-02-17T03:00:37Z
parent: silo-sem
---

Implement the logic to persist API results into the local database.

## Checklist
- [ ] Create a method to upsert metadata records
- [ ] Ensure payload is correctly serialized before saving
- [ ] Handle database unique constraint violations gracefully
- [x] Update created_at/updated_at timestamps correctly

## Summary of Changes

- Implemented `ShowMetadata.upsert` method.
- Added logic to handle `Sequel::UniqueConstraintViolation` with retries.
- Verified that `timestamps` plugin correctly updates `created_at` and `updated_at`.
