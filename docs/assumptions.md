# Technical Assumptions & Known Constraints

This document records the technical assumptions, environmental constraints, and pragmatic realities of the Silo Night project. It is used to provide context for debugging and to justify specific implementation choices that may deviate from generic "best practices."

---

## I. Persistence & Data
- **Schema Stability:** We assume the underlying Sequel-based schema (especially the `User` and `Show` models) is structurally sound. Our focus is on refactoring how we *interact* with this data, rather than full migrations.
- **Data Integrity:** We assume that `data/seed.rb` and scenario files (e.g., `smoke.rb`) contain valid and up-to-date data for the current schema.
- **SQLite Concurrency:** We assume a single-user or low-concurrency environment consistent with SQLite's capabilities.
- **Technology Choice:** We assume the continued use of `Sequel` for migrations and database interaction.
- **Performance Bottlenecks:** We assume that N+1 queries and JSON parsing are the primary performance concerns, biasing our service layer toward optimized fetches where possible.

## II. External Dependencies (TMDB & TVMaze)
- **Provider Volatility:** We assume external providers are volatile. We utilize a strong "Adapter" pattern within the Service layer to ensure external API changes do not leak into our internal JSON contracts.
- **API Availability:** We assume these services are generally available. For testing, we assume the environment is configured with stable VCR mocks to prevent actual network calls.
- **Data Completeness:** We assume that the combination of TMDB and TVMaze provides all necessary fields (runtimes, genres, posters) for all shows in the database.
- **Unification Heuristics:** We assume that merging providers (prioritizing TMDB for posters/overviews and TVMaze for runtimes/schedules) produces a higher-quality record than any single provider can offer.
- **Search Noise Reduction:** We assume that applying hard popularity thresholds (e.g., TMDB popularity > 5.0) is a necessary trade-off to maintain search relevance and reduce API noise, even if it occasionally excludes niche content.
- **Heuristic Deduplication:** We assume that the combination of `Name` and `Premier Year` is a sufficient unique identifier for deduplicating results across different metadata providers and local data.

## III. Environment & Infrastructure
- **Twelve-Factor Configuration:** We assume that a `DATABASE_URL` or a standardized `.env` file is the primary method for handling environment-specific configuration.
- **Test Isolation:** We assume that switching to `data/test.db` and utilizing `DatabaseCleaner` resolves state pollution between tests.
- **Stale State Management:** We assume a high-frequency test environment (Cucumber) requires explicit state management (e.g., `reload`) to prevent stale data regressions during state-changing operations.
- **Statelessness:** While the legacy app uses server-side rendering, we assume future clients will favor a "Client-Side State" model. The API `v1` is designed as a stateless resource provider.

## IV. Schema Evolution & Refactoring
- **Expand-Contract Pattern**: We assume that any schema change involving column removal must follow an "Expand-Contract" pattern (Schema Expansion -> Dual-Writing/Delegation -> Read Cutover -> Write Lockdown -> Schema Cleanup).
- **Safety Bridges**: We assume the use of "Deprecated" column names (e.g., `deprecated_runtime`) as an application-level tripwire to detect residual dependencies before a final destructive schema change.
- **Service-Only Creation:** We assume that database models should not be directly instantiated with legacy attributes; all show creation must flow through service objects (`ShowFactory`) to guarantee integrity.
- **JSON Payload Flexibility:** We assume that storing a unified `payload` (JSON) within the `ShowMetadata` model is superior to flat database columns for frequently changing external data. This allows us to expand the UI without performing database migrations.

