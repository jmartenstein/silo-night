---
# silo-kcb
title: Automate Test Database Preparation in Rakefile
status: completed
type: task
priority: high
created_at: 2026-02-12T15:27:36Z
updated_at: 2026-02-12T19:46:31Z
parent: silo-ht5
blocking:
    - silo-b21
    - silo-nkw
---

Ensure the test database is migrated before running tests to avoid 'migrations not up to date' errors.

## Checklist
- [x] Add a task to migrate the test database
- [x] Make :spec and :cucumber depend on test database migration
