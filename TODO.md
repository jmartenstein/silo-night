# TODO: Issue #41 - Minimalist Planning Interface (State 2)

- [ ] **Task 2.1: CSS Variable & Layout Foundation**
    - [ ] Identify and centralize "Minimalist" styles (spacing, font weights) into CSS variables in `public/stylesheets/default.css`.
    - [ ] Implement the 2:1 negative space ratio (empty space to content) for the planning view (`template/schedule_edit.slim`).
    - [ ] Ensure the layout holds across screen sizes.

- [ ] **Task 2.2: "View Schedule" Exit Action**
    - [ ] Add a prominent "View Schedule" button to `template/schedule_edit.slim`.
    - [ ] Implement the route/action to trigger `generate_schedule` call before redirecting to the schedule view.

- [ ] **Task 2.3: Refine Show List Minimalism**
    - [ ] Update show list styling to be a clean vertical list of titles and runtimes only in `template/schedule_edit.slim` or associated partials.
    - [ ] Ensure "Remove" interaction is present but visually non-distracting.
    - [ ] Remove all "Confirm" or "Are you sure?" modals from the "Remove" action.

- [ ] **Task 2.4: Grid-based Availability UI**
    - [ ] Refactor the availability table into a minimalist grid or simplify table styling to remove "spreadsheet" aesthetics.

- [ ] **Task 2.5: Continuous State Preservation**
    - [ ] Verify AJAX implementation for adding, removing, and reordering shows.
    - [ ] Implement AJAX if missing to ensure no page reloads during planning.
