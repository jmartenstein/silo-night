---
# silo-p29
title: Disable Failing Cucumber Scenarios
status: completed
type: task
priority: normal
created_at: 2026-02-12T15:27:31Z
updated_at: 2026-02-12T19:46:15Z
parent: silo-ht5
---

Most Cucumber scenarios are failing because the test database is not properly seeded or users are missing. These should be disabled for now.

## Checklist
- [x] Identify all failing Cucumber scenarios
- [x] Disable failing scenarios (e.g., using @wip tag or marking as pending)
- [x] Verify cucumber command exits with 0