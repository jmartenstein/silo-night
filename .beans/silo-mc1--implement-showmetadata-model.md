---
# silo-mc1
title: Implement ShowMetadata model
status: todo
type: task
priority: normal
created_at: 2026-02-11T22:18:11Z
updated_at: 2026-02-11T22:18:11Z
parent: silo-sem
---

Create a Sequel model for the show_metadata table to handle data persistence.

## Checklist
- [ ] Create lib/show_metadata.rb
- [ ] Configure JSON serialization for the payload column
- [ ] Add validations for provider_name and external_id
- [ ] Write unit tests for the model