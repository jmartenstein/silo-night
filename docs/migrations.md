# Migration Development Guide

This document explains how to manage database migrations for the Silo Night project.

## Overview

We use [Sequel](https://sequel.jeremyevans.net/) for database interactions and migrations. Migrations allow us to evolve the database schema over time in a consistent and reproducible way.

## Migration File Naming

Migration files are stored in the `db/migrations` directory.

We use **serial numbers** (three-digit prefix) for migration files to ensure a strict order of execution:

- `001_create_initial_schema.rb`
- `002_add_user_preferences.rb`
- `003_normalize_runtime.rb`

## Creating a New Migration

To create a new migration, add a new Ruby file in `db/migrations` with the next available serial number.

### Example Migration Syntax

```ruby
Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, null: false, unique: true
      String :schedule, text: true
    end
  end

  down do
    drop_table(:users)
  end
end
```

For more details on Sequel migration DSL, see the [Sequel Documentation](https://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html).

## Running Migrations

We use Rake tasks to manage migrations.

### Apply all pending migrations

```bash
rake db:migrate
```

### Rollback the last migration

```bash
rake db:rollback
```

### Check current migration version

```bash
rake db:version
```

### Check if migrations are up to date

```bash
rake db:status
```

## Environment Considerations

- **Development:** Migrations are run against the local `data/silo_night.db` file.
- **Testing:** Migrations are automatically checked/run during test suite initialization.
- **CI/CD:** The CI process runs `rake db:migrate` before executing tests to ensure the schema is current.
