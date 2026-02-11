---
# silo-qtj
title: User Identity & Authentication
status: todo
type: milestone
created_at: 2026-02-11T00:38:44Z
updated_at: 2026-02-11T00:38:44Z
---

Implement secure user management to support multiple external testers. This replaces the current insecure URL-based identification with session-based authentication.

- Integrate BCrypt for secure password storage and hashing.
- Implement login/logout flows and session management.
- Restrict schedule access to the authenticated owner.