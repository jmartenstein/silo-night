---
# silo-73f
title: Implement 'empty' Seeding Scenario
status: completed
type: task
priority: normal
created_at: 2026-02-17T23:19:36Z
updated_at: 2026-02-18T13:28:27Z
parent: silo-2tx
blocked_by:
    - silo-2tx
---

Implement a seeding scenario that applies migrations but leaves database tables empty to test first-run UI states and empty dashboards.

## Summary of Changes\n\n- Updated `data/scenarios/empty.rb` to use `DatabaseCleaner` and truncate all database tables.
