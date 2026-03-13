# TODO: Issue #41 - Minimalist Planning Interface (State 2)

- [x] **Task 2.1: CSS Variable & Layout Foundation**
    - [x] Identify and centralize "Minimalist" styles (spacing, font weights) into CSS variables in `public/stylesheets/default.css`.
    - [x] Implement the 2:1 negative space ratio (empty space to content) for the planning view (`template/schedule_edit.slim`).
    - [x] Ensure the layout holds across screen sizes.

- [x] **Task 2.2: "View Schedule" Exit Action**
    - [x] Add a prominent "View Schedule" button to `template/schedule_edit.slim`.
    - [x] Implement the route/action to trigger `generate_schedule` call before redirecting to the schedule view.

- [x] **Task 2.3: Refine Show List Minimalism**
    - [x] Update show list styling to be a clean vertical list of titles and runtimes only in `template/schedule_edit.slim` or associated partials.
    - [x] Ensure "Remove" interaction is present but visually non-distracting.
    - [x] Remove all "Confirm" or "Are you sure?" modals from the "Remove" action.

- [x] **Task 2.4: Grid-based Availability UI**
    - [x] Refactor the availability table into a minimalist grid or simplify table styling to remove "spreadsheet" aesthetics.

- [x] **Task 2.5: Continuous State Preservation**
    - [x] Verify AJAX implementation for adding, removing, and reordering shows.
    - [x] Implement AJAX if missing to ensure no page reloads during planning.
