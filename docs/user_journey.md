# User Persona: Structured Sam

"I love great TV, but I hate the feeling of wasting my evening scrolling through menus or accidentally binging until 2 AM."

*   **Demographics:** 28, Remote Software Engineer, lives in a medium-sized city.
*   **Behavioral Patterns:** Sam is highly organized in her professional life but finds herself suffering from "decision paralysis" when it comes to entertainment. She values high-quality storytelling (like the show *Silo*) but often ends up returning her same favorite content because it's "just there", or it "feels comfortable." She hesitates to start new shows due to concerns about becoming over-invested, or trying new things. She wants to mix comfort food shows with the newer binge-worthy shows that folks are talking about.
*   **Goals and Needs:**
    *   To establish a predictable evening routine with a clear "stop" time.
    *   To make steady progress through a curated list of shows without feeling overwhelmed.
    *   To remove the friction of choosing what to watch each night.
*   **Pain Points:**
    *   **Binge Burnout:** Feeling regret and exhaustion after staying up too late watching "just one more episode."
    *   **Content Overload:** A massive "watch list" across five different streaming services that feels like a chore to manage.
*   **Mental Model:** Sam views her time as a budget. She wants to allocate her "entertainment budget" (e.g., 45 minutes on a Tuesday) as efficiently as possible to maximize her enjoyment without sacrificing sleep or other hobbies.

---

# User Onboarding

The entry point for all users to access their personalized viewing schedules.

*   **Landing Page:** The root page serves as the primary gateway.
*   **Primary Route:** `GET /`
*   **Authentication:** No password required; the prototype prioritizes immediate access.
*   **Core Actions:**
    *   **Select Profile:** Click an existing username to load a saved configuration via `/user/:name/schedule`.
    *   **New Profile:** Use the provided text box to start a fresh setup.

# Creating a New User

A frictionless process to establish a new identity and viewing plan.

*   **Profile Setup:** Users provide a unique **username** and click **Create**.
*   **Primary Route:** `PUT /api/v0.1/user/:name`
*   **Validation Flow:**
    *   **Success:** The system confirms creation and moves the user to their personal dashboard (`GET /user/:name/schedule/edit`).
    *   **Error Handling:** If a username is **already taken**, the user is prompted to try a different name on the landing page.

# Existing User Experience

Seamlessly resuming a curated entertainment journey.

*   **Persistent State:** Unlike new users, existing profiles load with all **shows and schedules** pre-populated.
*   **Primary Route:** `GET /user/:name/schedule`
*   **Efficiency:** One-click access from the landing page bypasses the initial setup phase.

# Shows and Schedule Management

The central hub for balancing content desires with real-world time constraints.

*   **Dashboard View:** Access the configuration interface for shows and schedule.
*   **Primary Route:** `GET /user/:name/schedule/edit`
*   **Content Curation:**
    *   **Add Shows:** Use `POST /api/v0.1/user/:name/show` to add new content to the watch list.
    *   **Remove Shows:** Use `DELETE /api/v0.1/user/:name/show/:show_name` to refine the list.
    *   **Smart Search:** Find shows using a search bar with **thumbnails, genre, and year** metadata.
    *   **Watch List:** Build a **draggable, reorderable** list that calculates total **runtime** automatically.
*   **Time Budgeting:**
    *   **Availability:** Toggle specific **days of the week** for television viewing.
    *   **Time Limits:** Define precise available windows in **minutes** for each active day.
*   **System Logic:** Trigger `PUT /api/v0.1/user/:name/schedule` to fit show durations into defined nightly time slots.

# Final Guide

The actionable output that eliminates decision fatigue each night.

*   **Weekly Roadmap:** Displays a clear, structured view of what to watch and when.
*   **Primary Route:** `GET /user/:name/schedule`
*   **Daily Focus:** Automatically **highlights shows** assigned to the current date, powered by `GET /api/v0.1/user/:name/tonight`.
*   **User Interface:** Functions as a dedicated "view mode" to keep the user focused on the plan rather than the configuration.
