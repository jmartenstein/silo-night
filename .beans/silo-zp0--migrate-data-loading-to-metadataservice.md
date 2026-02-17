---
# silo-zp0
title: Migrate data loading to MetadataService
status: completed
type: task
priority: normal
created_at: 2026-02-16T20:25:51Z
updated_at: 2026-02-17T22:29:25Z
parent: silo-7ca
---

Replace existing static JSON loading with dynamic MetadataService calls.

## Checklist
- [x] Update seed.rb to use MetadataService
- [x] Update show expansion scripts to use MetadataService
- [x] Remove legacy static JSON files if no longer needed

## Summary of Changes\nUpdated  and  to use  for dynamic metadata fetching. Kept existing JSON files as they are still useful as source lists and intermediate caches.
