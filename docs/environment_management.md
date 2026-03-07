# Environment Management

This document describes how to manage the development and test environments for silo-night.

The development environment is used for local development. Data in the database should be considered unreliable and ephemeral - it could be deleted or reset at any moment.

The test environment is a more stable environment used for running the test suite. For more details on the testing setup, see the [Testing Guide](./testing.md).

## Environment Configuration

The project uses `.env` files for environment-specific configuration.

- `.env.development`: Default environment variables for local work
- `.env.test`: Environment variables for tests.
- `.env.example`: A template for creating your own `.env` files.

Variables:
- `DATABASE_URL`: The SQLite connection URL (e.g., `sqlite://data/silo_night.db`).
- `RACK_ENV`:     Environment variable for Rack to load (`development`, `test`, etc.).
- `TMDB_API_KEY`: API key for TMDB.

## Database Management

The application's database state can be managed via Rake tasks.

### Migrations

If you need to run or re-run migrations for a specific environment:
```bash
RACK_ENV=development rake db:migrate
```
*Replace `development` with the desired environment (e.g., `test`).*

### Seeding and Scenarios

You can seed the database with predefined data scenarios using Rake tasks. This is useful for populating your development environment or preparing a specific state for testing.

- `rake db:seed`: Seeds with the default `smoke` scenario.
- `rake db:seed:scenario[name]`: Seeds with a specific scenario from `data/scenarios/`.

Available scenarios:
- `smoke`: A basic set of shows and a test user.
- `n1_audit`: A complex set of users and shows.
- `empty`: No data.

## Network Access and Security

The server is configured to bind to all network interfaces (`0.0.0.0`) in both development and test environments, allowing access from other machines on your local network. However, the security middleware (Sinatra's protection) behaves differently between environments:

- **Development (`RACK_ENV=development`)**: Sinatra's default protection middleware is **enabled**. This includes host authorization, which may block requests from unrecognized hostnames (like `.local` addresses) to prevent DNS rebinding attacks. Use this environment for standard local development where security parity with production is desired.
- **Test (`RACK_ENV=test`)**: Sinatra's protection middleware is **completely disabled**. This allows for easier remote testing and access via any hostname (e.g., `justins-air.local`) without being blocked by "host not permitted" errors. This is the recommended environment for remote debugging and cross-device testing.

You can toggle between these behaviors by setting the `RACK_ENV` variable when starting the server:

```bash
# Protected (default)
RACK_ENV=development bundle exec puma

# Unprotected (recommended for remote access)
RACK_ENV=test bundle exec puma
```
