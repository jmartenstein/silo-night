---
# silo-g5j
title: Implement environment inspection tasks
status: completed
type: task
priority: normal
created_at: 2026-02-12T23:04:50Z
updated_at: 2026-02-16T17:49:35Z
parent: silo-wal
---

Add Rake tasks to help developers inspect the application state and routes.

## Checklist
- [x] Add `console` task to open IRB with app environment pre-loaded
- [x] Add `routes` task by integrating `scripts/list_routes.rb`

## Summary of Changes

Added `console` and `routes` Rake tasks for environment inspection.
