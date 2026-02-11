---
# silo-kiz
title: Runtime Calculation Optimization
status: draft
type: epic
priority: normal
created_at: 2026-02-11T20:21:07Z
updated_at: 2026-02-11T20:24:00Z
parent: silo-rdo
---

Refactor the Show#average_runtime logic to store runtimes as integers in the database, removing the need for fragile string parsing.

## Checklist
- [ ] Create a migration to add an integer runtime column to the shows table
- [ ] Write a script to migrate existing runtime data from strings to integers
- [ ] Refactor the Show model to use the new integer column
- [ ] Update any views or API responses that depend on runtime data
- [ ] Remove the old string-based runtime parsing logic