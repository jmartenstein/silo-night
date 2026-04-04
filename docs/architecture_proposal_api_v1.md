# Architectural Proposal: API v1 Refactor (TDD-Driven Service & Presenter Layers)

## Status: Proposed
**Author:** Software Architect (Consultant)  
**Date:** April 3, 2026  
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

## 3. The `ShowService` (Orchestration Layer)

### Purpose
The `ShowService` acts as the "Single Source of Truth" for operations involving shows, coordinating between the database and `MetadataService`.

### Responsibilities
- **Search & Create:** Searching for shows locally; fetching and persisting metadata if missing.
- **User Association:** Managing a user's collection and triggering side effects (like schedule regeneration).
- **Transaction Management:** Ensuring atomic updates for complex operations like list reordering.

---

## 4. The `ShowPresenter` (Representation Layer)

### Purpose
Presenters transform raw models into the versioned JSON contracts required by the front-end.

### Responsibilities
- **Schema Enforcement:** Whitelisting fields and ensuring consistent types (e.g., integers for runtimes).
- **Data Decoration:** Calculating dynamic fields like full poster URLs or formatted dates.

---

## 5. Roadmap: Planned Services & Presenters

To achieve full decoupling, the following objects are identified for implementation:

### Service Objects
- **`ShowService`:** Handles show lookup, metadata fetching, and creation.
- **`UserShowService`:** Manages the relationship between users and shows (adding, removing, reordering).
- **`ScheduleService`:** Encapsulates the logic for generating and formatting a user's weekly viewing schedule.
- **`UserConfigService`:** Manages user settings, credentials, and profile metadata.
- **`SearchService`:** Orchestrates multi-provider searches (Local DB + TMDB + TVMaze).

### Presenter Objects
- **`ShowPresenter`:** Standardized JSON for show details and list items.
- **`SchedulePresenter`:** Formats the complex schedule hash into a UI-friendly structure.
- **`UserPresenter`:** Represents user profiles and their associated configurations.
- **`SearchResultPresenter`:** Normalizes search results from different external APIs into a uniform UI format.
- **`ErrorPresenter`:** Standardizes error responses (e.g., `{ "error": "ShowNotFound", "message": "..." }`).

---

## 6. Assumptions & Biases

### Technical Assumptions
- **Persistence Layer Stability:** We assume the underlying Sequel-based schema (especially the `User` and `Show` models) is structurally sound enough to support new features without a full migration. Our refactor focuses on how we *interact* with this data, not how it is stored.
- **External API Volatility:** We assume that external providers (TMDB, TVMaze) are volatile. This architectural design biases toward a strong "Adapter" pattern within the Service layer to ensure that a change in the TMDB API doesn't leak into our UI JSON contracts.
- **Statelessness Preference:** While the current app uses some server-side rendering, we assume the future UI prototypes will favor a "Client-Side State" model. Our API v1 will be designed as a stateless resource provider, minimizing reliance on Sinatra-level session management.
- **Environment Parity:** We assume that the `test` environment is (or will be) configured with stable mocks for external services, allowing the TDD cycle to run without actual network calls to TMDB/TVMaze.

### Architectural Biases
- **Contract-First Design (TDD):** We bias heavily toward the API "Contract" as the primary deliverable. In this view, the backend is a service provider, and the JSON schema is the legal agreement between the backend and front-end teams.
- **Request-Level Verification over Unit Tests:** While unit tests have value, we bias toward RSpec **Request Specs** for the v1 refactor. This ensures that the *entire stack* (Route -> Service -> Model -> Presenter) is working together to deliver the correct contract, providing higher confidence during aggressive refactors.
- **"Thin Model, Thick Service" Philosophy:** We bias against adding business logic (like schedule generation or metadata fetching) directly to the `User` or `Show` models. We prefer keeping models as "Anemic" data containers and moving orchestration to Service Objects to prevent "God Objects" and circular dependencies.
- **Explicit Representation (Presenters):** We bias against using `to_json` overrides in models. We believe a model's data should be separate from its representation. Using explicit Presenters allows us to provide different "Views" of the same data (e.g., a `SummaryShowPresenter` for lists and a `FullShowPresenter` for details) without polluting the model.
- **Standardized Failure States:** We bias toward "Error Objects" over HTTP status codes alone. Every failure should return a predictable JSON payload, allowing the front-end to implement robust, user-friendly error handling for any UI prototype.
- **v0.1 Preservation:** We bias toward a "Side-by-Side" migration. We will not touch or "improve" the `v0.1` namespace; it will remain as a legacy reference point until the `v1` implementation is feature-complete and verified.

---

## 7. Next Steps

1.  **Initialize `api/v1` Spec Suite:** Create `spec/requests/api/v1/` to house the initial Red tests.
2.  **First Slice (Shows):** Implement the `ShowPresenter` and `ShowService` via a Red-Green-Refactor cycle for the `GET /api/v1/shows` endpoint.
3.  **Standardized Error Handling:** Implement the `ErrorPresenter` to replace plain-text error messages.
4.  **Integration Testing:** Ensure all `v1` endpoints are covered by request specs before any `v0.1` routes are deprecated.
