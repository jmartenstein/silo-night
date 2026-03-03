---
# silo-wgo
title: Create background refresh job
status: scrapped
type: task
priority: low
created_at: 2026-02-11T22:20:10Z
updated_at: 2026-03-03T14:52:35Z
parent: silo-csy
---

Develop a background mechanism to proactively refresh stale metadata records.

## Checklist
- [ ] Create a Rake task for metadata synchronization
- [ ] Identify records that have exceeded their TTL
- [ ] Batch process updates to avoid API rate limits
- [ ] Schedule the job for periodic execution (e.g., daily)
