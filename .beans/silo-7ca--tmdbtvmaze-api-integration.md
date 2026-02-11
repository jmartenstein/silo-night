---
# silo-7ca
title: TMDB/TVMaze API Integration
status: draft
type: epic
priority: normal
created_at: 2026-02-11T20:20:46Z
updated_at: 2026-02-11T20:23:50Z
parent: silo-rdo
---

Build a robust API client to fetch show data (runtimes, genres, posters) from public databases. This replaces the manual seed.rb and static JSON data.

## Checklist
- [ ] Identify and sign up for TMDB and TVMaze API keys
- [ ] Implement a MetadataService class to interface with APIs
- [ ] Create client adapters for TMDB and TVMaze
- [ ] Implement error handling and rate limiting for API calls
- [ ] Replace static JSON data loading with API-driven data