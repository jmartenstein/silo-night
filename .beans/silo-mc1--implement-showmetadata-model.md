---
# silo-mc1
title: Implement ShowMetadata model
status: completed
type: task
priority: normal
created_at: 2026-02-11T22:18:11Z
updated_at: 2026-02-17T03:00:10Z
parent: silo-sem
---

Create a Sequel model for the show_metadata table to handle data persistence.

## Checklist
- [ ] Create lib/show_metadata.rb
- [ ] Configure JSON serialization for the payload column
- [ ] Add validations for provider_name and external_id
- [x] Write unit tests for the model

## Summary of Changes

- Created `lib/show_metadata.rb` with Sequel model.
- Enabled `serialization` plugin for JSON payload.
- Added validations for `provider_name` and `external_id`.
- Created `spec/show_metadata_spec.rb` and verified with RSpec.
