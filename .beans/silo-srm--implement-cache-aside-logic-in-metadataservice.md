---
# silo-srm
title: Implement cache-aside logic in MetadataService
status: scrapped
type: task
priority: low
created_at: 2026-02-11T22:20:04Z
updated_at: 2026-03-03T14:52:40Z
parent: silo-csy
---

Update the MetadataService to check the local cache before making external API requests.

## Checklist
- [ ] Modify MetadataService#fetch_show to check ShowMetadata
- [ ] Return cached data if present and not stale
- [ ] Fetch from external API on cache miss
- [ ] Store new results in cache after fetching
