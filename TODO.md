# Implementation Plan - Issue #40: Identity & Entry Flow

- [ ] Task 1.1: Automatic Redirect for New Users
  - [ ] Modify `POST /user` to redirect directly to `/user/:name/schedule/edit` upon successful creation.
  - [ ] Remove the success message on the index page in favor of immediate transition.
- [ ] Task 1.2: Simplified Existing User Selection
  - [ ] Update `index.slim` to make user names single-click links that go directly to `/user/:name/schedule`.
  - [ ] Remove redundant `/user/:name/shows` links from the index page.
- [ ] Task 1.3: Radical UI Simplification (Entry Focus)
  - [ ] Remove `h2` headers ("User Schedules" and "Create a new schedule").
  - [ ] Rename the "Create" button to "Enter".
  - [ ] Use a descriptive placeholder like "Who are you?" in the input field.
  - [ ] Ensure a single, cohesive vertical flow for both existing user links and the new entry input.
  - [ ] Eliminate any remaining non-functional text or structural clutter.
- [ ] Validation
  - [ ] Verify automatic redirect for new users.
  - [ ] Verify simplified user links.
  - [ ] Verify UI simplification.
  - [ ] Run existing tests and ensure no regressions.
