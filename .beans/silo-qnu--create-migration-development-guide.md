---
# silo-qnu
title: Create Migration Development Guide
status: todo
type: task
priority: normal
created_at: 2026-02-11T21:04:41Z
updated_at: 2026-02-11T21:19:31Z
parent: silo-iox
---

Write documentation for developers explaining how to create new migrations and run them in different environments.

## Suggestions
- Include examples of Sequel migration syntax.
- Explain the naming convention for migration files.
- Document how to use the Rake tasks.

## Checklist
- [ ] Create 'docs/migrations.md' (or add to README)
- [ ] Document migration file naming (e.g., timestamps vs serial numbers)
- [ ] Document 'db:migrate' and 'db:rollback' commands