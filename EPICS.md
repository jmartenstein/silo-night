# Silo Night - Project Epics & Milestones

This document outlines the proposed epics for the Silo Night project, categorized by their respective milestones.

## Epic: Database Migration Framework
Introduce a formal migration system (e.g., Sequel migrations) to handle schema changes predictably across development and production environments.
- **Key Deliverable:** A `db/migrations` directory with versioned migration files.

## Epic: TMDB/TVMaze API Integration
Build a robust API client to fetch show data (runtimes, genres, posters) from public databases. This replaces the manual `seed.rb` and static JSON data.
- **Key Deliverable:** A `MetadataService` class capable of querying multiple providers.

## Epic: Metadata Caching & Background Sync
Develop a local caching layer to store show metadata in the database, reducing latency and API rate-limit issues.
- **Key Deliverable:** A caching strategy that updates show details periodically in the background.

## Epic: Runtime Calculation Optimization
Refactor the `Show#average_runtime` logic to store runtimes as integers in the database, removing the need for fragile string parsing.
- **Key Deliverable:** Integer-based runtime columns and updated model logic.

## Epic: User Preferences Normalization
Migrate the `config` and `schedule` JSON blobs in the `users` table into dedicated relational tables (`user_configs`, `schedules`, `schedule_items`).
- **Key Deliverable:** A fully normalized database schema for user-specific data.

## Epic: Query Layer Refactoring
Rewrite the scheduling logic in the `User` model to use efficient SQL joins and aggregate functions instead of loading and parsing large JSON objects.
- **Key Deliverable:** Optimized `generate_schedule` and `available_runtime` methods.


