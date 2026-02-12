---
# silo-kcb
title: Automate Test Database Preparation in Rakefile
status: todo
type: task
priority: high
created_at: 2026-02-12T15:27:36Z
updated_at: 2026-02-12T15:28:26Z
parent: silo-ht5
blocking:
    - silo-b21
    - silo-nkw
---

Ensure the test database is migrated before running tests to avoid 'migrations not up to date' errors.

## Checklist
- [ ] Add a task to migrate the test database
- [ ] Make :spec and :cucumber depend on test database migration