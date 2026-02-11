---
# silo-srm
title: Implement cache-aside logic in MetadataService
status: todo
type: task
priority: normal
created_at: 2026-02-11T22:20:04Z
updated_at: 2026-02-11T22:20:04Z
parent: silo-csy
---

Update the MetadataService to check the local cache before making external API requests.

## Checklist
- [ ] Modify MetadataService#fetch_show to check ShowMetadata
- [ ] Return cached data if present and not stale
- [ ] Fetch from external API on cache miss
- [ ] Store new results in cache after fetching