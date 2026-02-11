---
# silo-8b5
title: Remove redundant data/schema.rb
status: todo
type: task
priority: high
created_at: 2026-02-11T22:27:40Z
updated_at: 2026-02-11T22:35:34Z
blocking:
    - silo-rdo
---

'data/schema.rb' is legacy and has been replaced by migrations in 'db/migrations/'.

## Checklist
- [ ] Delete data/schema.rb
- [ ] Verify no remaining code references it