---
# silo-d07
title: Implement Unified 'rake test' Task
status: completed
type: task
priority: normal
created_at: 2026-02-12T15:27:41Z
updated_at: 2026-02-12T19:46:25Z
parent: silo-ht5
---

Create a top-level 'test' task that runs both RSpec and Cucumber tests.

## Checklist
- [x] Define :test task in Rakefile
- [x] Make :test depend on :spec and :cucumber
- [x] Set as default task (optional but recommended)