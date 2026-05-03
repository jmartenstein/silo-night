# Technical Assumptions & Known Constraints

This document records the technical assumptions, environmental constraints, and pragmatic realities of the Silo Night project. It is used to provide context for debugging and to justify specific implementation choices that may deviate from generic "best practices."

---

## I. Persistence & Data
- **Schema Stability:** We assume the underlying Sequel-based schema (especially the `User` and `Show` models) is structurally sound. Our focus is on refactoring how we *interact* with this data, rather than full migrations.
- **Data Integrity:** We assume that `data/seed.rb` and scenario files (e.g., `smoke.rb`) contain valid and up-to-date data for the current schema.
- **SQLite Concurrency:** We assume a single-user or low-concurrency environment consistent with SQLite's capabilities.
- **Technology Choice:** We assume the continued use of `Sequel` for migrations and database interaction.

## II. External Dependencies (TMDB & TVMaze)
- **Provider Volatility:** We assume external providers are volatile. We utilize a strong "Adapter" pattern within the Service layer to ensure external API changes do not leak into our internal JSON contracts.
- **API Availability:** We assume these services are generally available. For testing, we assume the environment is configured with stable VCR mocks to prevent actual network calls.
- **Data Completeness:** We assume that the combination of TMDB and TVMaze provides all necessary fields (runtimes, genres, posters) for all shows in the database.

## III. Environment & Infrastructure
- **Twelve-Factor Configuration:** We assume that a `DATABASE_URL` or a standardized `.env` file is the primary method for handling environment-specific configuration.
- **Test Isolation:** We assume that switching to `data/test.db` and utilizing `DatabaseCleaner` resolves state pollution between tests.
- **Statelessness:** While the legacy app uses server-side rendering, we assume future clients will favor a "Client-Side State" model. The API `v1` is designed as a stateless resource provider.

## IV. Application Logic
- **Stale State Management:** We assume that the Service layer is responsible for ensuring model data is fresh (e.g., calling `reload`) before performing state-changing operations, especially in high-frequency test environments like Cucumber.
- **Performance Bottlenecks:** We assume that N+1 queries and JSON parsing are the primary performance concerns, biasing our service layer toward optimized fetches where possible.
- **Orchestration:** We assume that a single `MetadataService` is sufficient to orchestrate multiple providers and handle fallbacks effectively.
