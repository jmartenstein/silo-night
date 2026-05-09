# Phase 2: Restructuring for the Test Pyramid

Welcome to Phase 2 of our test suite overhaul! As a senior developer, my goal is to help you understand not just *what* we are changing, but *why* these patterns are industry standards.

## The Big Picture: The Test Pyramid
Our goal is a "Test Pyramid" with three tiers:
1.  **Unit Tests**: Hundreds of them. Fast, isolated, and testing logic.
2.  **Integration Tests**: Dozens of them. Testing how our code talks to the DB and APIs.
3.  **E2E (Cucumber)**: A few critical user journeys. Testing the whole system.

---

## Step 1: Infrastructure Cleanup (The Foundation)

### Why?
Good tests require a clean environment. Right now, our configuration is "leaky"—too much is crammed into `spec_helper.rb`. By modularizing, we make the suite easier to maintain.

### How?
1.  **Move VCR Config**: Create `spec/support/vcr.rb`.
    *   *Why?* VCR records real network calls so we don't hit APIs every time (which is slow and expensive). Keeping its config separate makes it clear where to manage API keys and recording settings.
2.  **Enable FactoryBot in Cucumber**: Update `features/support/env.rb`.
    *   *Why?* We want to use the same "factories" (blueprints) for data in both RSpec and Cucumber. This ensures a "Single Source of Truth" for what a `User` or `Show` looks like.

---

## Step 2: Fixing the "Identity Crisis" (Tagging)

### Why?
In `spec_helper.rb`, we have logic that automatically tags tests as `:unit` or `:integration`. Currently, it's marking `spec/services/` as unit tests. This is wrong. Services hit the database and external APIs—that's an **integration** test.

### How?
Update the regex in `spec_helper.rb`:
-   `spec/lib/` and `spec/presenters/` -> `:unit`
-   `spec/services/`, `spec/adapters/`, and `spec/requests/` -> `:integration`

---

## Step 3: Refactoring MetadataService (The Meat)

### Why?
The `MetadataService` is currently tested with "Manual Doubles" (mocks).
*   *The Problem:* If the TMDB API changes, our mocks won't know! The tests will pass, but the app will break in production.
*   *The Fix:* Use **Integration Testing with VCR**. We will use the *real* adapters and have VCR record the *real* response once. This gives us the speed of a mock with the accuracy of a real call.

### How?
1.  Remove `double('TmdbAdapter')`.
2.  Initialize the service with `TmdbAdapter.new` and `TvmazeAdapter.new`.
3.  Wrap the tests in `vcr: { cassette_name: '...' }` blocks.

---

## Step 4: Cucumber Step Cleanup

### Why?
Our Cucumber steps currently do things like `User.create(...)`.
*   *The Problem:* If we add a mandatory `email` field to the User model tomorrow, we have to find every single step definition and update it.
*   *The Fix:* Use `FactoryBot.create(:user)`. The factory handles the defaults, so we only specify the fields we care about for that specific test.

### How?
Go through `features/step_definitions/` and replace manual `Model.create` calls with FactoryBot syntax.

---

## Step 5: Verification

### Why?
A refactor isn't finished until the suite is green and the categories are separate.

### How?
Run the targeted rake tasks:
-   `rake test:unit` (Should be lightning fast)
-   `rake test:integration` (Should use VCR cassettes)
-   `rake test:cucumber` (Should pass with the new factory logic)

---

Happy coding! If you get stuck, remember: **Unit tests for logic, Integration for boundaries.**
