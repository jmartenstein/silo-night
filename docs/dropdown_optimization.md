# Drop-down Optimization: Performance & Relevance

The "Show Add" drop-down currently suffers from high latency (due to synchronous external API calls) and low relevance (due to unfiltered search results). This document outlines three features to resolve these issues.

---

## 1. Persistent Search Cache
**Objective:** Reduce latency by caching external API responses for common search queries.

### Developer Tasks:
1. **Database Migration:** Create a new table `search_caches` with the following columns:
    - `query` (String, indexed): The search term normalized to lowercase.
    - `results_json` (Text): The stringified JSON array of unified results.
    - `created_at` (DateTime): To track cache age.
2. **MetadataService Integration:**
    - Modify `MetadataService#search_shows(query)` to first check `DB[:search_caches].where(query: query.downcase)`.
    - If a valid entry exists (e.g., less than 24 hours old), return the parsed `results_json`.
3. **Cache Population:**
    - If no cache exists or it's expired, perform the external API calls as usual.
    - Before returning the results, save/update the `search_caches` table with the new data.
4. **Cleanup Strategy:** 
    - Add a simple method to `MetadataService` or a Rake task to delete rows where `created_at < (Now - 24 hours)`.

---

## 2. Popularity-based Relevance Filtering
**Objective:** Remove obscure, low-interest shows from the search suggestions.

### Developer Tasks:
1. **Adapter Updates:**
    - Verify `TmdbAdapter` and `TvmazeAdapter` are returning the `popularity` (TMDB) and `weight` (TVMaze) fields.
2. **Filtering Logic:**
    - In `MetadataService#search_shows`, add a filtering step for each API's results:
        - **TMDB:** Keep only if `popularity > 5.0` (adjust based on testing).
        - **TVMaze:** Keep only if `weight > 30` (adjust based on testing).
3. **Result Sorting:**
    - After merging results, sort the final `suggestions` array by a combined popularity score or simply ensure the highest-popularity matches are at the top of the list.
4. **Validation:**
    - Search for a common name (e.g., "The Bear") and verify that major network shows appear before obscure international titles with the same name.

---

## 3. "Local First" Search Strategy
**Objective:** Provide instant results for shows already known to the system.

### Developer Tasks:
1. **Local Query Implementation:**
    - In `MetadataService#search_shows`, perform a local database lookup: `Show.where(Sequel.ilike(:name, "%#{title}%")).limit(5)`.
2. **Data Normalization:**
    - Map the `Show` model objects to the unified search result format (matching the keys: `name`, `year`, `genres`, `poster_path`).
3. **Deduplication:**
    - Ensure that if a show is found locally, it is not duplicated by the subsequent API search. Use the show name or a normalized URI as the unique key.
4. **UI Refinement (Optional):**
    - Update `default.js` to render local results immediately if the API returns them in a separate "local" block, or simply ensure they are at the top of the combined list for maximum speed.

---

## Implementation Priority
1. **Local First Strategy:** Easiest to implement and provides immediate wins for common shows.
2. **Popularity Filtering:** Essential for cleaning up the user experience.
3. **Persistent Cache:** Best for overall system performance and reducing API usage costs/limits.
