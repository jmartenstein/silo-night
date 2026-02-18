---
# silo-plv
title: Implement 'n1_audit' Seeding Scenario
status: completed
type: task
priority: normal
created_at: 2026-02-17T23:19:57Z
updated_at: 2026-02-18T13:30:44Z
parent: silo-2tx
blocked_by:
    - silo-2tx
---

Implement a seeding scenario with a large dataset (100+ shows, 10+ users with complex schedules) to identify N+1 query and performance issues.

## Summary of Changes

- Created `data/scenarios/n1_audit.rb` with 100+ shows and 10 users with complex schedules. - Used `DatabaseCleaner` with `PRAGMA foreign_keys = OFF` for reliable cleaning.
