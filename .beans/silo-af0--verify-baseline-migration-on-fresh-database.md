---
# silo-af0
title: Verify Baseline Migration on Fresh Database
status: draft
type: task
created_at: 2026-02-11T21:04:33Z
updated_at: 2026-02-11T21:04:33Z
parent: silo-3la
---

Ensure that the initial migration can successfully build a new database from scratch and matches the existing production schema.

## Suggestions
- Run the migration on a new SQLite database file.
- Compare the resulting schema with the existing 'data/silo_night.db'.
- Use 'db:rollback' to ensure the 'down' block works as expected.

## Checklist
- [ ] Run 'db:migrate' on a clean database
- [ ] Verify table structures match current schema
- [ ] Run 'db:rollback' and verify tables are removed
- [ ] Run 'db:migrate' again to confirm idempotency