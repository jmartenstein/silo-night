---
# silo-wal
title: Add Missing Rake Tasks
status: completed
type: feature
priority: normal
created_at: 2026-02-12T23:04:33Z
updated_at: 2026-02-16T17:50:07Z
---

Improve the project's maintenance and development workflow by adding missing Rake tasks for database management, environment inspection, and script integration.

## Checklist
- [x] Implement database lifecycle tasks (create, drop, setup, reset)
- [x] Implement environment inspection tasks (console, routes)
- [x] Implement script wrapper tasks (schedule:generate, shows:expand)
- [x] Implement code quality tasks (lint, stats)

## Summary of Changes

Successfully added all missing Rake tasks to improve maintenance and development workflow:

1.  **Database Lifecycle**: `db:create`, `db:drop`, `db:setup`, `db:reset`.
2.  **Environment Inspection**: `console`, `routes`.
3.  **Script Wrappers**: `schedule:generate`, `shows:expand`.
4.  **Code Quality**: `lint` (RuboCop), `stats` (LOC).
