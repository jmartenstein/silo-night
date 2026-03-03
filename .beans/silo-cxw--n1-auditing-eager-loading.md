---
# silo-cxw
title: N+1 Auditing & Eager Loading
status: scrapped
type: epic
priority: high
created_at: 2026-02-11T20:45:12Z
updated_at: 2026-03-03T14:53:00Z
parent: silo-uuw
---

Audit the codebase for N+1 query patterns, particularly in many-to-many associations, and implement eager loading to optimize performance.

## Checklist
- [ ] Audit `lib/user.rb` for N+1 queries in schedule generation and runtime calculations
- [ ] Implement `eager` or `eager_graph` loading for `User#shows` and other associations
- [ ] Identify and resolve N+1 patterns in `silo_night.rb` API endpoints
- [ ] Benchmark performance improvements before and after eager loading
- [ ] Add regression tests to ensure N+1 patterns are not reintroduced
