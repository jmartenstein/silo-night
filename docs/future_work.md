# Future Work: Shelved Milestones

This document captures detailed requirements and implementation plans for milestones and features that have been shelved or moved out of the active development roadmap.

---

## Milestone: v0.10: Show Metadata Infrastructure (silo-rdo)
**Status:** Scrapped / Moved to Documentation
**Description:** Focuses on establishing a robust metadata pipeline and database integrity for show data.

### Epic: Metadata Caching & Background Sync (silo-rl4)
Develop a local caching layer to store show metadata in the database, reducing latency and API rate-limit issues.

*   **Feature: Background Sync and Cache Management (silo-csy)**
    Manages the lifecycle of cached metadata, including background updates, TTL enforcement, and cache-aside integration.
    *   **Task: Add sync health monitoring (silo-pik)**
        Add logging and metrics to track the performance and health of the caching system.
    *   **Task: Create background refresh job (silo-wgo)**
        Develop a background mechanism to proactively refresh stale metadata records.
    *   **Task: Implement cache-aside logic in MetadataService (silo-srm)**
        Update the MetadataService to check the local cache before making external API requests.
    *   **Task: Implement TTL policy (silo-c3l)**
        Define and enforce a Time-To-Live strategy for cached metadata.

### Epic: Runtime Calculation Optimization (silo-kiz)
Refactor the `Show#average_runtime` logic to store runtimes as integers in the database, removing the need for fragile string parsing.
*   **Checklist:**
    *   [ ] Create a migration to add an integer runtime column to the shows table
    *   [ ] Write a script to migrate existing runtime data from strings to integers
    *   [ ] Refactor the Show model to use the new integer column
    *   [ ] Update any views or API responses that depend on runtime data
    *   [ ] Remove the old string-based runtime parsing logic

---

## Milestone: v0.11: User Schedule & Query Performance (silo-uuw)
**Status:** Scrapped / Moved to Documentation
**Description:** Focuses on normalizing user data and optimizing scheduling performance through efficient SQL queries.

### Epic: N+1 Auditing & Eager Loading (silo-cxw)
Audit the codebase for N+1 query patterns, particularly in many-to-many associations, and implement eager loading to optimize performance.
*   **Checklist:**
    *   [ ] Audit `lib/user.rb` for N+1 queries in schedule generation and runtime calculations
    *   [ ] Implement `eager` or `eager_graph` loading for `User#shows` and other associations
    *   [ ] Identify and resolve N+1 patterns in `silo_night.rb` API endpoints
    *   [ ] Benchmark performance improvements before and after eager loading
    *   [ ] Add regression tests to ensure N+1 patterns are not reintroduced

### Epic: Query Layer Refactoring (silo-cgn)
Rewrite the scheduling logic in the User model to use efficient SQL joins and aggregate functions instead of loading and parsing large JSON objects.
*   **Checklist:**
    *   [ ] Identify bottlenecks in the current JSON parsing logic
    *   [ ] Implement generate_schedule using SQL joins and aggregates
    *   [ ] Optimize the available_runtime method with SQL queries
    *   [ ] Add database indexes to support the new query patterns
    *   [ ] Benchmark the performance improvements

### Epic: User Preferences Normalization (silo-kgg)
Migrate the config and schedule JSON blobs in the users table into dedicated relational tables (`user_configs`, `schedules`, `schedule_items`).
*   **Checklist:**
    *   [ ] Design the schema for user_configs, schedules, and schedule_items
    *   [ ] Create migrations for the new relational tables
    *   [ ] Write a data migration script to extract and move data from JSON blobs
    *   [ ] Update the User model to use associations for preferences and schedules
    *   [ ] Update API endpoints in `silo_night.rb` to interact with new relational tables
    *   [ ] Refactor UI templates (`schedule.slim`, `schedule_edit.slim`) to consume normalized data
    *   [ ] Verify data integrity after the migration
