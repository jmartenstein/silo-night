# Performance Optimization: Show Addition & Metadata Fetching

This document analyzes the performance bottlenecks when adding new shows to the system, the architectural recommendations made to address them, and the current implementation status of each.

---

## Bottlenecks and Status

### 1. Redundant External API Calls (Metadata Re-fetch) — ✅ Resolved (issue #84)

When a user selected a show from the search dropdown, the client discarded all fetched metadata except the show name. The `POST /api/v1/user/:name/shows` body contained only `{ name }`, causing the server to re-fetch the same data from TMDB and TVMaze — up to **4 redundant external HTTP calls** per show addition.

**Resolution:** Search results now include `external_ids` (`tmdb_id`, `tvmaze_id`). The client caches full suggestion objects and forwards the complete metadata in the POST body. `ShowFactory` uses client-supplied metadata directly and skips `MetadataService` entirely when metadata is present. The existing `MetadataService` path is retained as a fallback for direct API callers (fully backwards compatible). See [Recommendation D](#recommendation-d-metadata-passthrough-from-search-to-post--implemented) below.

### 2. Synchronous External API Waterfall — ✅ Resolved for fallback path (issue #83)

When `MetadataService#get_show_metadata` is invoked (fallback path only — see above), it previously made four network calls in strict sequence:

1.  **TMDB Search**: Network request to TMDB.
2.  **TMDB Fetch**: If search results exist, a second request to TMDB for details.
3.  **TVMaze Search**: Network request to TVMaze.
4.  **TVMaze Fetch**: If search results exist, a second request to TVMaze for details.

Total latency was `T(tmdb_search) + T(tmdb_fetch) + T(tvmaze_search) + T(tvmaze_fetch)`. In high-latency scenarios this could exceed 2–3 seconds.

**Resolution:** The TMDB pair and TVMaze pair now run concurrently via `Thread.new`. Latency on the fallback path is now `max(T(tmdb_search) + T(tmdb_fetch), T(tvmaze_search) + T(tvmaze_fetch))`. See [Recommendation A](#recommendation-a-parallelize-external-requests--implemented) below.

> **Note:** Because issue #84 eliminates `MetadataService` calls entirely for the primary UI path, this parallelization only benefits direct API callers or programmatic consumers that omit metadata from the POST body.

### 3. Redundant Frontend Round-trips — ✅ Resolved (issue #83)

The JavaScript client previously followed a two-step refresh pattern after adding a show:

1.  `POST` to `/api/v1/user/:name/shows` (add the show).
2.  `GET` from `/api/v1/user/:name/shows` (re-fetch the full list to update the UI).

**Resolution:** `POST /api/v1/user/:name/shows` now returns the full updated show list as a JSON array (HTTP 201). `addShow()` in `default.js` calls `renderShows()` directly on the response body, eliminating the second round-trip entirely. See [Recommendation C](#recommendation-c-api-response-consolidation--implemented) below.

### 4. Eager Schedule Generation — 🔲 Open

In `Services::UserShow.add_show`, the system calls `user.generate_schedule` synchronously after adding a show. Schedule generation iterates through time slots and show runtimes and runs inside the HTTP request-response cycle, adding unnecessary latency to the add-show response.

---

## Architectural Recommendations

### Recommendation A: Parallelize External Requests — ✅ Implemented

Utilize Ruby threads to execute TMDB and TVMaze fetching in parallel.

*   **Pros:**
    *   **Reduced Latency**: Total time becomes `max(T(tmdb), T(tvm))` instead of `sum(T(tmdb), T(tvm))`.
    *   **Simple Implementation**: Does not require external infrastructure like Redis or background workers.
*   **Cons:**
    *   **Thread Overhead**: Spawning threads per request can be resource-heavy under high load.
    *   **Still Synchronous**: The caller still waits for the slowest API to respond.

**Implementation:** `MetadataService#get_show_metadata` wraps each provider pair in `Thread.new`. `Thread#value` is used to collect results and re-raise any exceptions, preserving existing error handling behaviour.

---

### Recommendation B: Background Metadata Enrichment — 🔲 Not Implemented

Transition to an asynchronous model where show creation is instant and metadata is fetched by a background worker.

*   **Pros:**
    *   **Instant Feedback**: The web request returns in milliseconds.
    *   **Resilience**: If an external API is down, the background job can retry without affecting the user experience.
    *   **Resource Management**: Background jobs can be rate-limited to stay within API tier limits.
*   **Cons:**
    *   **Complexity**: Requires a job queue (Sidekiq, Sucker Punch, or a database-backed queue) and a worker process.
    *   **UI State Management**: The frontend must handle "pending" states (e.g., showing a placeholder poster until the job completes).

---

### Recommendation C: API Response Consolidation — ✅ Implemented

Modify the `POST` endpoint to return the full updated list of shows rather than requiring a follow-up `GET`.

*   **Pros:**
    *   **Reduced Latency**: Eliminates one full round-trip.
    *   **Simplicity**: Purely a code change with no infrastructure impact.
*   **Cons:**
    *   **Payload Size**: Returning the full list may become inefficient for users with a very large number of shows.

**Implementation:** `POST /api/v1/user/:name/shows` returns a JSON array of all user shows (HTTP 201). `addShow()` in `default.js` passes the response body directly to `renderShows()`.

---

### Recommendation D: Metadata Passthrough from Search to POST — ✅ Implemented

Pass the already-fetched metadata from the search response through the add-show flow so the server can skip `MetadataService` calls entirely.

*   **Pros:**
    *   **Maximum Latency Reduction**: Eliminates all external API calls for the primary UI path (0 calls instead of 4).
    *   **Backwards Compatible**: Direct API callers that omit metadata fall back to the existing `MetadataService` path unchanged.
*   **Cons:**
    *   **Larger POST Payload**: The request body grows to include metadata fields, though the payload size is negligible in practice.

**Implementation:** `GET /api/v1/search` results include `external_ids` (`tmdb_id`, `tvmaze_id`). The client caches full suggestion objects in `currentSuggestions[]` and forwards `name`, `year`, `genres`, `poster_path`, `runtime`, and `external_ids` in the POST body. When these fields are present, `ShowFactory#create_with_metadata` uses them directly and skips `MetadataService`.

---

## Architectural Trade-offs: Background vs. Parallel

| Feature | Background Enrichment | Parallel Requests |
| :--- | :--- | :--- |
| **User Perceived Speed** | **Fastest** (Immediate response) | **Medium** (Wait for slowest API) |
| **System Complexity** | **High** (Needs worker/queue) | **Low** (In-process threads) |
| **Error Handling** | Better (Automatic retries) | Worse (Request fails on timeout) |
| **Scalability** | Better (Decouples web from IO) | Limited (Threads consume memory) |
| **Implementation Effort** | High | Low |

## Current State and Remaining Work

Recommendations A, C, and D have been implemented. For the primary UI path (add via search dropdown), external API calls during show addition have been eliminated entirely. For the fallback path (direct API callers), TMDB and TVMaze calls are now parallelized.

The two remaining open items are:

1.  **Recommendation B (Background Metadata Enrichment):** Still the best path to fully decouple show addition latency from external API availability. Relevant primarily for the fallback path and any future bulk-import workflows.
2.  **Bottleneck 4 (Eager Schedule Generation):** `user.generate_schedule` still runs synchronously on every show addition. Deferring or backgrounding this call would further reduce add-show response time.
