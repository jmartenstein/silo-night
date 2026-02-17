---
# silo-zkx
title: Implement database lifecycle tasks
status: completed
type: task
priority: normal
created_at: 2026-02-12T23:04:45Z
updated_at: 2026-02-16T17:48:32Z
parent: silo-wal
---

Add Rake tasks for managing the SQLite database files and standardizing the setup process.

## Checklist
- [x] Add `db:create` to create database files in `data/`
- [x] Add `db:drop` to delete database files in `data/`
- [x] Add `db:setup` to run create, migrate, and seed
- [x] Add `db:reset` to run drop and setup

## Summary of Changes

Implemented `db:create`, `db:drop`, `db:setup`, and `db:reset` tasks in `Rakefile`.
