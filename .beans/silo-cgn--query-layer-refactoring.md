---
# silo-cgn
title: Query Layer Refactoring
status: scrapped
type: epic
priority: normal
created_at: 2026-02-11T20:21:26Z
updated_at: 2026-03-03T14:53:05Z
parent: silo-uuw
---

Rewrite the scheduling logic in the User model to use efficient SQL joins and aggregate functions instead of loading and parsing large JSON objects.

## Checklist
- [ ] Identify bottlenecks in the current JSON parsing logic
- [ ] Implement generate_schedule using SQL joins and aggregates
- [ ] Optimize the available_runtime method with SQL queries
- [ ] Add database indexes to support the new query patterns
- [ ] Benchmark the performance improvements
