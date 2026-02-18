# Environment Management

This document describes how to manage the development and test environments for silo-night.

## Environment Configuration

The project uses `.env` files for environment-specific configuration.

- `.env`: Default environment variables (development).
- `.env.test`: Environment variables for tests.
- `.env.example`: A template for creating your own `.env` files.

Variables:
- `DATABASE_URL`: The SQLite connection URL (e.g., `sqlite://data/silo_night.db`).
- `TMDB_API_KEY`: API key for TMDB.
- `TVMAZE_API_KEY`: API key for TVMaze.

## Database Seeding and Scenarios

You can seed the database using Rake tasks:

- `rake db:seed`: Seeds with the default `smoke` scenario.
- `rake db:seed:scenario[name]`: Seeds with a specific scenario from `data/scenarios/`.

Available scenarios:
- `smoke`: A basic set of shows and a test user.
- `empty`: No data.

## Database Snapshotting

Snapshots allow you to quickly save and restore database states.

- `rake db:snapshot:save[name]`: Save the current database state to `db/snapshots/[name].sqlite3`.
- `rake db:snapshot:load[name]`: Restore the database from a snapshot.
- `rake db:snapshot:list`: List all available snapshots.

## Test Isolation

Tests (RSpec and Cucumber) are configured to use `DatabaseCleaner` with a `transaction` strategy. This ensures each test starts with a clean database state (after an initial truncation at the start of the suite).

If you need to re-run migrations for the test database:
```bash
RACK_ENV=test rake db:migrate
```
