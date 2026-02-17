---
# silo-7ca
title: TMDB/TVMaze API Integration
status: completed
type: epic
priority: critical
created_at: 2026-02-11T20:20:46Z
updated_at: 2026-02-17T22:29:20Z
parent: silo-rdo
blocking:
    - silo-srm
---

Build a robust API client to fetch show data (runtimes, genres, posters) from public databases. This replaces the manual seed.rb and static JSON data.

## Checklist
- [x] Identify and sign up for TMDB and TVMaze API keys
- [x] Implement a MetadataService class to interface with APIs
- [x] Create client adapters for TMDB and TVMaze
- [x] Implement error handling and rate limiting for API calls
- [x] Replace static JSON data loading with API-driven data

## Summary of Changes
Implemented client adapters for TMDB and TVMaze API. Added ApiClient with rate limiting and error handling. Created MetadataService to orchestrate fetching and unifying data from both providers. Updated seed.rb and expand_shows.rb to use the new service.
