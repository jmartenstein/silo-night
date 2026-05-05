# TODO: Implement Local-First Search & Database Seeding

Hello! As your senior developer, I've outlined the following roadmap to implement Issue #69. This task is about making our search "smarter" by checking our own database before asking external APIs (TMDB/TVMaze). This improves speed and reduces API dependency.

## Phase 1: Knowledge Enrichment (Adapters)
**Goal:** Teach our system how to find "Popular" shows automatically.

- [ ] **Task 1.1: Update `TmdbAdapter`**
  - **Action:** Add a `fetch_popular_shows(page = 1)` method to `lib/tmdb_adapter.rb`. It should hit the `/tv/popular` endpoint.
  - **Why:** We need a way to bulk-fetch data to seed our database.
  - **Learning:** You'll learn how to extend a third-party API wrapper and handle paginated results.

## Phase 2: The "Local First" Logic (Service Layer)
**Goal:** Modify the search engine to prioritize local data.

- [ ] **Task 2.1: Implement Local Search in `MetadataService`**
  - **Action:** In `lib/metadata_service.rb`, update `search_shows(title)`. 
  - **Step A:** Query the `Show` table using `Sequel.ilike` for the title.
  - **Step B:** Map these `Show` objects into our standard "Suggestion" hash format.
  - **Step C:** When performing the external API search afterwards, filter out any shows that have the same name (case-insensitive) as the local ones you already found.
  - **Why:** This provides "instant" results and prevents duplicate suggestions.
  - **Learning:** You'll practice data normalization (mapping different objects to a shared format) and array deduplication in Ruby.

## Phase 3: Seeding the Ecosystem (Data)
**Goal:** Fill the database with high-quality initial data.

- [ ] **Task 3.1: Create the `top_shows` Seeding Scenario**
  - **Action:** Create a new file `data/scenarios/top_shows.rb`. 
  - **Logic:** It should fetch the top 20-40 shows from TMDB, get their full metadata via `MetadataService`, and `Show.create` them in the DB.
  - **Why:** A "Local First" search is only useful if the local database isn't empty!
  - **Learning:** You'll learn how to write automated data-migration scripts that bridge external APIs and local persistence.

## Phase 4: Frontend Alignment (UI)
**Goal:** Ensure the website actually uses the new logic.

- [ ] **Task 4.1: Migrate `public/javascript/default.js` to v1 API**
  - **Action:** Find all `fetch` calls pointing to `/api/v0.1/` and update them to `/api/v1/`.
  - **Why:** We've upgraded the backend to `v1`, but the frontend is still talking to the deprecated `v0.1` endpoints.
  - **Learning:** You'll see the real-world impact of API versioning and why keeping the frontend/backend in sync is vital.

---
**Senior Tip:** Always run your tests (`bundle exec rake test`) after each phase. If the search logic changes, some Cucumber scenarios might need tiny updates to match the new (faster) behavior!
