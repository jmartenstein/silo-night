---
# silo-856
title: Refactor & Relational Integrity
status: todo
type: milestone
created_at: 2026-02-11T00:38:39Z
updated_at: 2026-02-11T00:38:39Z
---

Transition from JSON-serialized data to a fully relational schema. This will improve data stability and simplify querying for user schedules.

- Create relational tables for schedules and configurations.
- Migrate existing JSON blobs to the new schema.
- Refactor show runtime parsing to use database integers.