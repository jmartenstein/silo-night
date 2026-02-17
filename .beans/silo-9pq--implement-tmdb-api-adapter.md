---
# silo-9pq
title: Implement TMDB API Adapter
status: completed
type: task
priority: high
created_at: 2026-02-16T20:25:30Z
updated_at: 2026-02-17T22:06:35Z
parent: silo-7ca
blocking:
    - silo-2c5
---

Create a specialized adapter class to communicate with TMDB API.

## Checklist
- [ ] Create lib/tmdb_adapter.rb
- [ ] Implement show lookup by ID
- [ ] Implement show search by title
- [x] Add unit tests with WebMock/VCR

## Summary of Changes\n- Created lib/tmdb_adapter.rb using Faraday.\n- Implemented fetch_show_by_id and search_shows_by_title.\n- Added unit tests in spec/tmdb_adapter_spec.rb with WebMock.
