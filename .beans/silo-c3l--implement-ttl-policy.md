---
# silo-c3l
title: Implement TTL policy
status: scrapped
type: task
priority: low
created_at: 2026-02-11T22:20:15Z
updated_at: 2026-03-03T14:52:45Z
parent: silo-csy
---

Define and enforce a Time-To-Live strategy for cached metadata.

## Checklist
- [ ] Add TTL configuration (e.g., 24 hours for most data)
- [ ] Implement ShowMetadata#stale? helper method
- [ ] Allow force-refresh via API if needed
- [ ] Document the TTL strategy
