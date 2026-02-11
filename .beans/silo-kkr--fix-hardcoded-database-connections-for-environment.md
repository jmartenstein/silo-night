---
# silo-kkr
title: Fix hardcoded database connections for environment isolation
status: todo
type: bug
priority: critical
created_at: 2026-02-11T22:27:30Z
updated_at: 2026-02-11T22:35:29Z
blocking:
    - silo-rdo
    - silo-hi3
    - silo-8b5
---

All database connections are currently hardcoded to 'sqlite://data/silo_night.db'. This causes tests to run against development data and prevents environment isolation.

## Checklist
- [ ] Use DATABASE_URL environment variable for connections
- [ ] Update lib/user.rb and lib/show.rb
- [ ] Update silo_night.rb
- [ ] Update Rakefile
- [ ] Update features/support/env.rb and spec/spec_helper.rb
- [ ] Ensure tests use data/test.db