---
# silo-wd1
title: Develop cache write logic
status: todo
type: task
priority: normal
created_at: 2026-02-11T22:18:16Z
updated_at: 2026-02-11T22:18:16Z
parent: silo-sem
---

Implement the logic to persist API results into the local database.

## Checklist
- [ ] Create a method to upsert metadata records
- [ ] Ensure payload is correctly serialized before saving
- [ ] Handle database unique constraint violations gracefully
- [ ] Update created_at/updated_at timestamps correctly