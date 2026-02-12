# Testing Guide

This document provides instructions on how to execute and manage the test suites for the Silo Night project.

## Overview

The project uses two primary testing frameworks:
- **RSpec:** Used for unit and functional testing of Ruby classes and models.
- **Cucumber:** Used for behavior-driven development (BDD) and integration testing of the web interface and API.

## Prerequisites

Before running tests, ensure your environment is set up and dependencies are installed:

```bash
bundle install
```

## Running Tests via Rake (Recommended)

The project includes a unified testing task in the `Rakefile` that handles database preparation and executes both suites.

### Run all tests

This command will migrate the test database and run both RSpec and Cucumber:

```bash
RACK_ENV=test bundle exec rake test
```

*Note: `rake test` is the default task, so `RACK_ENV=test bundle exec rake` also works.*

### Run specific suites

You can run the suites individually while still ensuring the test environment is used:

```bash
# Run only RSpec
RACK_ENV=test bundle exec rake spec

# Run only Cucumber
RACK_ENV=test bundle exec rake cucumber
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

## Test Database Management

The testing suite is configured to use an isolated SQLite database located at `data/test.db`.

### Manual Migration
If you need to manually migrate the test database:

```bash
RACK_ENV=test bundle exec rake db:migrate
```

### Seeding
If a test requires the standard seed data, you can seed the test database:

```bash
RACK_ENV=test bundle exec rake db:seed
```

## Test Structure

- `spec/`: Contains RSpec tests and FactoryBot definitions.
- `features/`: Contains Cucumber `.feature` files and step definitions.
- `features/support/env.rb`: Configuration for the Cucumber test environment.
- `spec/spec_helper.rb`: Configuration for the RSpec test environment.
