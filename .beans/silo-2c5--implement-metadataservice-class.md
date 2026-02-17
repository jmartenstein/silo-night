---
# silo-2c5
title: Implement MetadataService class
status: completed
type: task
priority: high
created_at: 2026-02-16T20:25:40Z
updated_at: 2026-02-17T22:29:31Z
parent: silo-7ca
blocking:
    - silo-zp0
---

Implement a central service to orchestrate calls between different API adapters.

## Checklist
- [x] Create lib/metadata_service.rb
- [x] Implement unified interface for show data
- [x] Handle provider fallback logic
- [x] Add unit tests

## Summary of Changes\nImplemented  to orchestrate calls between TMDB and TVMaze adapters. It provides unified show metadata with provider fallback logic. Added unit tests.
