---
# silo-d07
title: Implement Unified 'rake test' Task
status: todo
type: task
priority: normal
created_at: 2026-02-12T15:27:41Z
updated_at: 2026-02-12T15:28:31Z
parent: silo-ht5
---

Create a top-level 'test' task that runs both RSpec and Cucumber tests.

## Checklist
- [ ] Define :test task in Rakefile
- [ ] Make :test depend on :spec and :cucumber
- [ ] Set as default task (optional but recommended)