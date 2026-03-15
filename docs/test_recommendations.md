# Test Suite Recommendations: Silo Night

This document outlines an assessment of the current Cucumber test suite and provides a roadmap for improving its complexity, maintainability, and coverage. These recommendations are structured as individual projects that a Project Manager can prioritize and assign.

## Current State Assessment

### 1. Structural Complexity & Maintainability
*   **Mixed Responsibilities:** Step definitions currently handle both data setup (database calls) and interaction logic (HTTP calls). This "shadow implementation" makes tests brittle and difficult to debug.
*   **Brittle Assertions:** Many tests rely on raw HTML string matching (`expect(body).to include("text")`). This frequently breaks during UI refactors, even when functionality is unchanged.
*   **Logic Duplication:** Data creation logic (Users and Shows) is duplicated across four different step definition files.
*   **"Mock UI" Pattern:** The "UI" tests do not use a browser driver (like Capybara/Selenium). Instead, they simulate UI actions by manually constructing POST requests, which risks the tests drifting away from how the actual front-end behaves.

### 2. Coverage Gaps
*   **Negative Pathing:** There are very few tests for "failure" states (e.g., invalid time inputs, duplicate usernames, or missing API resources).
*   **Boundary Conditions:** The "Evening Time Budget" logic lacks testing for shows that exactly match, slightly exceed, or significantly exceed the available time.
*   **API Reliability:** The `api_access.feature` is currently heavily tagged with `@failing`, indicating the API implementation and its tests are out of sync.

---

## Proposed Improvement Projects

### Project 1: Centralized Data Management (Factories)
**Goal:** Eliminate duplicate database setup code and ensure consistent test data.
*   **Action:** Introduce a data factory pattern (e.g., using `FactoryBot` or a custom `TestHelper` module).
*   **Benefit:** Reduces the lines of code in step definitions by ~30% and prevents "flaky" tests caused by inconsistent initial states.
*   **PM Note:** This is a foundational project that should be completed before major refactoring.

### Project 2: UI Interaction Abstraction (Page Object Lite)
**Goal:** Decouple "What the user does" from "How the test performs the action."
*   **Action:** Create a helper class or module that maps logical actions (e.g., `add_show_to_list(name)`) to the specific HTTP requests required.
*   **Benefit:** If a URL or form field name changes, you only update one helper method instead of 10+ step definitions.
*   **PM Note:** High impact on long-term maintenance costs.

### Project 3: Robust Assertion Engine
**Goal:** Move away from raw string matching to semantic verification.
*   **Action:** Implement helper methods that parse the response body (HTML or JSON) and verify presence within specific elements (e.g., "Silo should be in the 'Watch List' section" rather than just "Silo should be on the page").
*   **Benefit:** Dramatically reduces "false positive" test failures during CSS or layout updates.
*   **PM Note:** Can be rolled out incrementally across features.

### Project 4: Boundary & Negative Path Expansion
**Goal:** Increase the "depth" of the test suite beyond the "Happy Path."
*   **Action:** Add new Gherkin scenarios for:
    *   **Time Budget:** Shows that are exactly the length of the budget.
    *   **Validation:** Entering non-numeric values in the availability fields.
    *   **Uniqueness:** Attempting to add a show that is already in the list.
*   **Benefit:** Catches edge-case bugs before they reach production.
*   **PM Note:** Best suited for a "Quality Sprint" once Project 1 is complete.

### Project 5: Tech Debt & Documentation Cleanup
**Goal:** Align the test suite with professional standards and remove internal "noise."
*   **Action:** 
    *   Fix the `@failing` API scenarios to match current implementation.
    *   Move "Investigation" scenarios from `final_guide.feature` into a separate internal debug file or standard RSpec unit tests.
*   **Benefit:** Ensures the test suite provides a clear, green "Source of Truth" for the project's health.
*   **PM Note:** This resolves existing "broken windows" in the codebase.
