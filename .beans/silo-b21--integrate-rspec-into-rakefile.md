---
# silo-b21
title: Integrate RSpec into Rakefile
status: todo
type: task
priority: high
created_at: 2026-02-12T15:27:16Z
updated_at: 2026-02-12T15:28:05Z
parent: silo-ht5
blocking:
    - silo-d07
---

Add RSpec core rake task to the Rakefile to allow running unit tests via 'rake spec'.

## Checklist
- [ ] Add 'rspec/core/rake_task' to Rakefile
- [ ] Define :spec rake task
- [ ] Ensure RACK_ENV=test is set