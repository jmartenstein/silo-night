---
# silo-zkx
title: Implement database lifecycle tasks
status: todo
type: task
priority: normal
created_at: 2026-02-12T23:04:45Z
updated_at: 2026-02-12T23:04:45Z
parent: silo-wal
---

Add Rake tasks for managing the SQLite database files and standardizing the setup process.

## Checklist
- [ ] Add `db:create` to create database files in `data/`
- [ ] Add `db:drop` to delete database files in `data/`
- [ ] Add `db:setup` to run create, migrate, and seed
- [ ] Add `db:reset` to run drop and setup