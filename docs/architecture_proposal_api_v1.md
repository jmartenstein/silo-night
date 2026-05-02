# Architectural Proposal: API v1 Refactor (TDD-Driven Service & Presenter Layers)

## Status: In Progress
**Author:** Software Architect (Consultant)  
**Date:** April 12, 2026  
**Target Audience:** Engineering Team

---

## 1. Context & Objectives
The current `api/v0.1` implementation in `silo_night.rb` suffers from "Fat Route" syndrome, where business logic and HTTP concerns are intertwined. To support rapid UI prototyping and ensure long-term maintainability, we will transition to a **Test-Driven Development (TDD)** approach for all `v1` API development.

### Primary Goals:
1.  **Strict TDD Workflow:** Use the Red-Green-Refactor cycle to define API contracts before implementation.
2.  **Decouple Logic from HTTP:** Move business rules into testable Service objects.
3.  **Standardize Data Contracts:** Use Presenters to ensure consistent, rich JSON output for all UI prototypes.

---

## 2. Core Development Cycle: Red-Green-Refactor

All new `v1` features must follow this strict cycle:

1.  **🔴 Red (Test First):** Write an RSpec request spec that defines the expected JSON response and HTTP status for the new `v1` endpoint. Run the test and confirm it fails.
2.  **🟢 Green (Pass Fast):** Implement the minimal amount of code—likely directly in the Sinatra route initially—to satisfy the test. Confirm the test passes.
3.  **🔵 Refactor (Architect):** Extract the inline logic into its appropriate **Service** (for logic) or **Presenter** (for output formatting). Run the tests again to ensure no regressions occurred during the extraction.

---

## 3. Implemented Objects (v1 Milestone 1, 2, & 3)

The following objects have been successfully extracted and verified:
- **`Services::Show`**: Handles show lookup and user list retrieval.
- **`Presenters::Show`**: Standardized JSON representation of a single show.
- **`Services::UserShow`**: Manages the relationship between users and shows (adding, removing, reordering).
- **`Services::Schedule`**: Orchestrates retrieval and regeneration of the weekly viewing plan.
- **`Presenters::Schedule`**: Normalizes schedule data, ensuring a consistent 7-day JSON contract with rich show metadata.
- **`Services::UserConfig`**: Manages availability settings and user configuration persistence.
- **`Presenters::Tonight`**: Provides a contextually filtered view of today's schedule.

---

## 4. Current Target: API Completion (v1 Milestone 4 & 5)

### Milestone 4: Search & Error Handling
- **`SearchService`**: Orchestrates multi-provider show searches.
- **`SearchResultPresenter`**: Standardizes search result formats.
- **`ErrorPresenter`**: Centralizes error messaging for all `v1` API responses.

### Milestone 5: Full RESTful User Resource
- **`UserManagement`**: Migrating `v0.1` user lifecycle routes (create, delete, update) to RESTful `v1` standards.
- **`ShowManagement`**: Migrating `v0.1` show manipulation routes (reordering, adding, removing) to RESTful `v1` standards.

---

## 5. Roadmap: Future Services & Presenters

- **`SearchService` / `SearchResultPresenter`**: Orchestrates multi-provider searches.
- **`ErrorPresenter`**: Standardizes error responses across all v1 endpoints.
- **`UserManagementService`**: RESTful interface for user lifecycle.
- **`ShowManagementService`**: RESTful interface for curated show lists.

---

## 6. Assumptions & Biases

### Technical Assumptions
- **Persistence Layer Stability:** We assume the underlying Sequel-based schema (especially the `User` and `Show` models) is structurally sound enough to support new features without a full migration. Our refactor focuses on how we *interact* with this data, not how it is stored.
- **External API Volatility:** We assume that external providers (TMDB, TVMaze) are volatile. This architectural design biases toward a strong "Adapter" pattern within the Service layer to ensure that a change in the TMDB API doesn't leak into our UI JSON contracts.
- **Statelessness Preference:** While the current app uses some server-side rendering, we assume the future UI prototypes will favor a "Client-Side State" model. Our API v1 will be designed as a stateless resource provider, minimizing reliance on Sinatra-level session management.
- **Environment Parity:** We assume that the `test` environment is (or will be) configured with stable mocks for external services, allowing the TDD cycle to run without actual network calls to TMDB/TVMaze.
- **Stale State Management (New):** We assume that the Service layer is responsible for ensuring model data is fresh (e.g., using `user.reload`) before performing state-changing operations, especially when triggered by high-frequency testing environments like Cucumber.

### Architectural Biases
- **Contract-First Design (TDD):** We bias heavily toward the API "Contract" as the primary deliverable. In this view, the backend is a service provider, and the JSON schema is the legal agreement between the backend and front-end teams.
- **Request-Level Verification over Unit Tests:** While unit tests have value, we bias toward RSpec **Request Specs** for the v1 refactor. This ensures that the *entire stack* (Route -> Service -> Model -> Presenter) is working together to deliver the correct contract, providing higher confidence during aggressive refactors.
- **"Thin Model, Thick Service" Philosophy:** We bias against adding business logic (like schedule generation or metadata fetching) directly to the `User` or `Show` models. We prefer keeping models as "Anemic" data containers and moving orchestration to Service Objects to prevent "God Objects" and circular dependencies.
- **Explicit Representation (Presenters):** We bias against using `to_json` overrides in models. We believe a model's data should be separate from its representation. Using explicit Presenters allows us to provide different "Views" of the same data (e.g., a `SummaryShowPresenter` for lists and a `FullShowPresenter` for details) without polluting the model.
- **Standardized Failure States:** We bias toward "Error Objects" over HTTP status codes alone. Every failure should return a predictable JSON payload, allowing the front-end to implement robust, user-friendly error handling for any UI prototype.
- **v0.1 Preservation:** We bias toward a "Side-by-Side" migration. We will not touch or "improve" the `v0.1` namespace; it will remain as a legacy reference point until the `v1` implementation is feature-complete and verified.
- **Idiomatic Module Scoping (New):** We bias toward concise, module-scoped naming (e.g., `Services::Show`) over redundant descriptors (e.g., `Services::ShowService`). We believe the namespace already provides sufficient context.
- **Defensive Service Logic (New):** We bias toward Services handling database-level constraints (e.g., `UniqueConstraintViolation`) gracefully. Services should ensure the application remains stable even when the underlying data layer hits expected constraints.

---

## 7. Next Steps

1.  [x] **Schedule Refactor:** Implement `Services::Schedule` and `Presenters::Schedule` for `GET /api/v1/user/:name/schedule`.
2.  [x] **Tonight View:** Create a specialized presenter or method for `GET /api/v1/user/:name/tonight`.
3.  [x] **User Config:** Move availability settings to `UserConfigService`.
4.  [ ] **Search Service:** Implement `SearchService` and `SearchResultPresenter`.
5.  [ ] **Error Handling:** Implement `ErrorPresenter` for API-wide error standardization.
6.  [ ] **RESTful User Management:** Migrate user lifecycle routes to `v1`.
7.  [ ] **RESTful Show Management:** Migrate show manipulation routes to `v1`.
