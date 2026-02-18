---
# silo-2tx
title: Refactor Seeding for Scenario Support
status: completed
type: feature
priority: normal
created_at: 2026-02-17T23:13:24Z
updated_at: 2026-02-18T00:58:36Z
parent: silo-qwm
---

Refactor `data/seed.rb` to support loading different data 'scenarios', allowing users to seed the database with specific datasets (e.g., empty, full, or specific user data) via a Rake task.

## Summary of Changes\n- Refactored `data/seed.rb` to support pluggable scenarios.\n- Added `data/scenarios/` directory with `smoke.rb` and `empty.rb`.\n- Added Rake task `db:seed:scenario[name]` to load specific seeding scenarios.
