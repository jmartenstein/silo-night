# User Persona: Structured Sam

"I love great TV, but I hate the feeling of wasting my evening scrolling through menus or accidentally binging until 2 AM."

*   **Mindset:** Sam views her time as a budget. She is prone to "decision paralysis" and values an interface that makes choices *for* her based on her predefined constraints.
*   **Goal:** To arrive at the "Watch" state with zero friction and a clear stopping point.

---

# The Minimalist Journey: State & Route Mapping

Silo Night is designed with a "Subtract until it breaks" philosophy. This document serves as the **Navigation Source of Truth** for both developers and automated agents.

## State 1: Enter (The Gateway)
The user establishes identity. Access must be instantaneous.

*   **Route:** `GET /`
*   **Minimalist Choice:** No password. Single text input for new users; single-click list for existing users. While the UI is simplified, it must remain navigable for both new and returning users through brief, clear descriptive instructions.
*   **Known User Mechanism:** Identity is managed via a manual selection list of existing usernames on the index page. No browser sessions or cookies are used to maintain identity.
*   **Developer/Agent Note:** 
    *   **New Users:** Upon name entry, transition to State 2 (Plan) via `GET /user/:name/schedule/edit`.
    *   **Existing Users:** Upon name selection, transition to State 3 (Watch) via `GET /user/:name/schedule`.
    *   **Clarity:** UI simplification must NOT be at the expense of making the site harder to navigate. Always provide enough context for the user to understand the current state and the path forward.

## State 2: Plan (The Budgeting)
The user defines their "Entertainment Budget" and "Content Queue."

*   **Route:** `GET /user/:name/schedule/edit`
*   **Minimalist Choice:** 
    *   **Curation:** A vertical list of show names. No thumbnails, no ratings, no distracting metadata. Just titles and runtimes.
    *   **Availability:** A simple grid of days with time inputs (minutes).
*   **Transitions:**
    *   `POST /api/v0.1/user/:name/show` -> Adds a show, remains on page.
    *   `POST /user/:name/availability` -> Updates time constraints, remains on page.
    *   `POST /api/v0.1/user/:name/shows/reorder` -> Changes priority, remains on page.
    *   **Exit Action:** Clicking "View Schedule" (State 3) MUST trigger a fresh generation of the schedule data to ensure consistency.

## State 3: Watch (The Execution)
The final, immutable plan for the week. This is the application's primary consumption state.

*   **Route:** `GET /user/:name/schedule`
*   **Minimalist Choice:** 
    *   The UI must recede. Only the schedule is visible.
    *   **Tonight's Show:** High-contrast visual focus on the current day's content.
*   **Transitions:**
    *   **Action:** "Return to Plan" -> Links to `GET /user/:name/schedule/edit` (State 2).
*   **Developer/Agent Note:** This page should be the default "Home" for Sam once her schedule is configured. It should require zero interaction to identify "What do I watch right now?"

---

# Navigation Logic for Coding Agents

When automating or refactoring navigation, adhere to these explicit constraints:

1.  **Direct Pathing:** Never introduce "Confirm" or "Are you sure?" modals unless data loss is catastrophic. Minimalism favors speed over safety nets.
2.  **Route Hierarchy:**
    *   `/` -> Identity Selection.
    *   `/:name/schedule` -> Primary Consumption (State 3).
    *   `/:name/schedule/edit` -> Primary Configuration (State 2).
3.  **One Action per State:**
    *   In `Enter`, the action is **Identify**.
    *   In `Plan`, the action is **Configure** (an aggregate action comprising Availability, Curation, and Ordering sub-tasks).
    *   In `Watch`, the action is **Observe**.
4.  **No Dead Ends:** Every page must provide a clear, single-link path to the next logical state.

# Visual & Interaction Heuristics

*   **Negative Space:** Maintain a 2:1 ratio of empty space to content on the `Watch` page.
*   **Typography over Graphics:** Use font-weight (bold/light) to indicate "Today" vs "Rest of Week" instead of icons or colors.
*   **Interaction:** Use `GET /api/v0.1/user/:name/tonight` to drive the "Today" highlight logic programmatically.
