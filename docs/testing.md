# Testing Guide

This document provides instructions on how to execute and manage the test suites for the Silo Night project.

## Overview

The project uses two primary testing frameworks:
- **RSpec:** Used for unit and functional testing of Ruby classes and models.
- **Cucumber:** Used for behavior-driven development (BDD) and integration testing of the web interface and API.

## Prerequisites

Before running tests, ensure your environment is set up and dependencies are installed.

```bash
bundle install
bundle exec rake db:setup
```

The `db:setup` task will create, migrate, and seed the database for the environment specified by `RACK_ENV` (defaults to `development`).

## Running Tests via Rake (Recommended)

The project includes a unified testing task in the `Rakefile` that handles database preparation and executes both suites. It is crucial to set `RACK_ENV=test` to ensure tests run against the isolated test database.

### Run all tests

This command will migrate the test database and run both RSpec and Cucumber:

```bash
RACK_ENV=test bundle exec rake test
```

*Note: `rake test` is the default task, so `RACK_ENV=test bundle exec rake` also works.*

### Run specific suites

You can run the suites individually:

```bash
# Run only RSpec
RACK_ENV=test bundle exec rake test:spec

# Run only Cucumber
RACK_ENV=test bundle exec rake test:cucumber
```

## Handling Failing Tests

Currently, several tests in both RSpec and Cucumber are failing due to missing seed data or pending implementation. To maintain a passing CI baseline, these tests have been tagged and are skipped by default.

### RSpec Skipped Tests
Failing specs are tagged with `failing: true`.
- To run only the passing tests: `bundle exec rspec --tag ~failing`
- To include the failing tests: `bundle exec rspec`

### Cucumber Skipped Scenarios
Failing scenarios are tagged with `@failing`.
- To run only the passing scenarios: `bundle exec cucumber --tags "not @failing"`
- To include the failing scenarios: `bundle exec cucumber`

## Test Database and Isolation

The testing suite is configured to use an isolated SQLite database to prevent interference with development data.

Tests (RSpec and Cucumber) are configured to use `DatabaseCleaner` with a `transaction` strategy. This ensures each test starts with a clean database state (after an initial truncation at the start of the test suite).

For details on managing database state, including migrations, seeding, and snapshots, please see the [Environment Management](./environment_management.md) documentation.

## Test Structure

- `spec/`: Contains RSpec tests and FactoryBot definitions.
- `features/`: Contains Cucumber `.feature` files and step definitions.
- `features/support/env.rb`: Configuration for the Cucumber test environment.
- `spec/spec_helper.rb`: Configuration for the RSpec test environment.
