---
# silo-b21
title: Integrate RSpec into Rakefile
status: completed
type: task
priority: high
created_at: 2026-02-12T15:27:16Z
updated_at: 2026-02-12T19:46:36Z
parent: silo-ht5
blocking:
    - silo-d07
---

Add RSpec core rake task to the Rakefile to allow running unit tests via 'rake spec'.

## Checklist
- [x] Add 'rspec/core/rake_task' to Rakefile
- [x] Define :spec rake task
- [x] Ensure RACK_ENV=test is set