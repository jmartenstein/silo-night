---
# silo-zp0
title: Migrate data loading to MetadataService
status: todo
type: task
priority: normal
created_at: 2026-02-16T20:25:51Z
updated_at: 2026-02-16T20:26:34Z
parent: silo-7ca
---

Replace existing static JSON loading with dynamic MetadataService calls.

## Checklist
- [ ] Update seed.rb to use MetadataService
- [ ] Update show expansion scripts to use MetadataService
- [ ] Remove legacy static JSON files if no longer needed
