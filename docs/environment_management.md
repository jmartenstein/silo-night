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

The server's network binding and security middleware (Sinatra's protection) behave differently depending on the environment:

- **Development (`RACK_ENV=development`)**: The server binds only to **localhost** (`127.0.0.1`). It is **not accessible** from other systems on your local network. Sinatra's default protection middleware is **enabled**.
- **Test (`RACK_ENV=test`)**: The server binds to **all network interfaces** (`0.0.0.0`), allowing access from other machines on your local network. Sinatra's protection middleware is **completely disabled**, making it easy to test via any hostname (e.g., `justins-air.local`) without "host not permitted" errors.
- **Production (`RACK_ENV=production`)**: The server binds to **all network interfaces** (`0.0.0.0`) for public/network access. Sinatra's default protection middleware is **enabled**.

You can toggle between these behaviors by setting the `RACK_ENV` variable when starting the server:

```bash
# Restricted to localhost (default)
RACK_ENV=development bundle exec puma

# Accessible from network (unprotected)
RACK_ENV=test bundle exec puma
```
