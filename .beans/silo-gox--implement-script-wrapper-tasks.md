---
# silo-gox
title: Implement script wrapper tasks
status: completed
type: task
priority: normal
created_at: 2026-02-12T23:04:55Z
updated_at: 2026-02-16T17:49:20Z
parent: silo-wal
---

Wrap existing standalone scripts into Rake tasks for better discoverability and standard interface.

## Checklist
- [x] Add `schedule:generate` to wrap `scripts/generate_schedule.rb`
- [x] Add `shows:expand` to wrap `scripts/expand_shows.rb`

## Summary of Changes

Wrapped existing scripts in `schedule:generate` and `shows:expand` Rake tasks.
