---
# silo-jgv
title: Generate Initial Migration from Current Schema
status: completed
type: task
priority: normal
created_at: 2026-02-11T21:04:26Z
updated_at: 2026-02-11T21:22:50Z
parent: silo-3la
---

Create a migration file that recreates the current 'shows' and 'users' tables along with their associations.

## Suggestions
- Refer to 'data/schema.rb' for the current table definitions.
- Ensure 'show_order' in 'shows_users' table is correctly defined.
- Name the file '001_create_initial_schema.rb'.

## Checklist
- [x] Create 'db/migrations/001_create_initial_schema.rb'
- [x] Define 'users' table schema
- [x] Define 'shows' table schema
- [x] Define 'shows_users' join table schema
- [x] Add necessary indexes