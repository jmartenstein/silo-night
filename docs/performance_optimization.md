# Performance Optimization: Show Addition & Metadata Fetching

This document analyzes the current performance bottlenecks when adding new shows to the system and provides architectural recommendations for improvement.

## Current Bottlenecks

### 1. Synchronous External API Waterfall
The `MetadataService#get_show_metadata` method currently operates in a strictly sequential manner. When a user adds a show not already in the database, the backend performs the following steps in order:
1.  **TMDB Search**: Network request to TMDB.
2.  **TMDB Fetch**: If search results exist, a second request to TMDB for details.
3.  **TVMaze Search**: Network request to TVMaze.
4.  **TVMaze Fetch**: If search results exist, a second request to TVMaze for details.

The total latency is `T(tmdb_search) + T(tmdb_fetch) + T(tvmaze_search) + T(tvmaze_fetch)`. In high-latency scenarios, this can exceed 2-3 seconds.

### 2. Eager Schedule Generation
In `Services::UserShow.add_show`, the system calls `user.generate_schedule` immediately after adding a show. Schedule generation is a compute-intensive task that iterates through time slots and show runtimes. Performing this during the HTTP request-response cycle delays the final response to the user.

### 3. Redundant Frontend Round-trips
The current JavaScript implementation in `public/javascript/default.js` follows a two-step refresh pattern:
1.  `POST` to `/api/v1/user/:name/shows`.
2.  Wait for success, then `GET` from `/api/v1/user/:name/shows`.

This doubles the impact of network latency and server-side processing time.

---

## Architectural Recommendations

### Recommendation A: Parallelize External Requests
Utilize Ruby threads or concurrent-ruby to execute TMDB and TVMaze fetching in parallel.

*   **Pros:**
    *   **Reduced Latency**: Total time becomes `max(T(tmdb), T(tvm))` instead of `sum(T(tmdb), T(tvm))`.
    *   **Simple Implementation**: Does not require external infrastructure like Redis or background workers.
*   **Cons:**
    *   **Thread Overhead**: Spawning threads per request can be resource-heavy under high load.
    *   **Still Synchronous**: The user still waits for the slowest API to respond before the UI updates.

### Recommendation B: Background Metadata Enrichment
Transition to an asynchronous model where show creation is instant, and metadata is fetched by a background worker.

*   **Pros:**
    *   **Instant Feedback**: The web request returns in milliseconds.
    *   **Resilience**: If an external API is down, the background job can retry without affecting the user experience.
    *   **Resource Management**: Background jobs can be rate-limited to stay within API tier limits.
*   **Cons:**
    *   **Complexity**: Requires a job queue (Sidekiq, Sucker Punch, or a database-backed queue) and a worker process.
    *   **UI State Management**: The frontend must handle "pending" states (e.g., showing a placeholder poster until the job completes).

### Recommendation C: API Response Consolidation
Modify the `POST` endpoint to return the full list of shows or the newly created show with its metadata included.

*   **Pros:**
    *   **Reduced Latency**: Eliminates one full round-trip.
    *   **Simplicity**: Purely a code change with no infrastructure impact.
*   **Cons:**
    *   **Payload Size**: Returning the full list might become inefficient for users with hundreds of shows.

---

## Architectural Trade-offs: Background vs. Parallel

| Feature | Background Enrichment | Parallel Requests |
| :--- | :--- | :--- |
| **User Perceived Speed** | **Fastest** (Immediate response) | **Medium** (Wait for slowest API) |
| **System Complexity** | **High** (Needs worker/queue) | **Low** (In-process threads) |
| **Error Handling** | Better (Automatic retries) | Worse (Request fails on timeout) |
| **Scalability** | Better (Decouples web from IO) | Limited (Threads consume memory) |
| **Implementation Effort** | High | Low |

### Selection Strategy
*   If the goal is **minimal effort for immediate gain**, parallelizing requests and consolidating the API response (Recommendations A & C) is the best path.
*   If the goal is **enterprise-grade resilience and UX**, background enrichment (Recommendation B) combined with Optimistic UI updates is the superior architectural choice.
