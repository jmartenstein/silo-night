---
# silo-wgr
title: Implement 'smoke_test' Seeding Scenario
status: completed
type: task
priority: high
created_at: 2026-02-17T23:19:46Z
updated_at: 2026-02-18T13:29:12Z
parent: silo-2tx
blocked_by:
    - silo-2tx
---

Implement a lightweight seeding scenario with 3 diverse shows and 1 test user with 2 shows in their schedule to facilitate rapid test execution.

## Summary of Changes\n\n- Updated `data/scenarios/smoke.rb` to seed 3 diverse shows and 1 test user with 2 shows in their schedule. - Used `DatabaseCleaner` to truncate tables for a clean slate.
