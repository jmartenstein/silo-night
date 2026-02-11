---
# silo-kgg
title: User Preferences Normalization
status: draft
type: epic
priority: normal
created_at: 2026-02-11T20:21:16Z
updated_at: 2026-02-11T20:24:05Z
parent: silo-uuw
---

Migrate the config and schedule JSON blobs in the users table into dedicated relational tables (user_configs, schedules, schedule_items).

## Checklist
- [ ] Design the schema for user_configs, schedules, and schedule_items
- [ ] Create migrations for the new relational tables
- [ ] Write a data migration script to extract and move data from JSON blobs
- [ ] Update the User model to use associations for preferences and schedules
- [ ] Update API endpoints in `silo_night.rb` to interact with new relational tables
- [ ] Refactor UI templates (`schedule.slim`, `schedule_edit.slim`) to consume normalized data
- [ ] Verify data integrity after the migration