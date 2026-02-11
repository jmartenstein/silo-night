---
# silo-8tm
title: Integrate Migrations into Build/CI Process
status: todo
type: task
priority: normal
created_at: 2026-02-11T21:04:48Z
updated_at: 2026-02-11T21:19:36Z
parent: silo-iox
---

Ensure that migrations are automatically run during the build process or as part of the test suite setup.

## Suggestions
- Update the 'features/support/env.rb' or 'spec_helper.rb' to run migrations before tests.
- Add a check to the application startup to warn if migrations are pending.

## Checklist
- [ ] Add 'Sequel::Migrator.check_current!' to test setup
- [ ] Ensure CI environment runs migrations before executing tests
- [ ] Add a health check or startup check for migration status