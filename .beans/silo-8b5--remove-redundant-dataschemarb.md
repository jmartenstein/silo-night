---
# silo-8b5
title: Remove redundant data/schema.rb
status: completed
type: task
priority: high
created_at: 2026-02-11T22:27:40Z
updated_at: 2026-02-12T15:06:44Z
blocking:
    - silo-rdo
---

'data/schema.rb' is legacy and has been replaced by migrations in 'db/migrations/'.

## Checklist
- [x] Delete data/schema.rb
- [x] Verify no remaining code references it