---
# silo-gox
title: Implement script wrapper tasks
status: todo
type: task
priority: normal
created_at: 2026-02-12T23:04:55Z
updated_at: 2026-02-12T23:04:55Z
parent: silo-wal
---

Wrap existing standalone scripts into Rake tasks for better discoverability and standard interface.

## Checklist
- [ ] Add `schedule:generate` to wrap `scripts/generate_schedule.rb`
- [ ] Add `shows:expand` to wrap `scripts/expand_shows.rb`