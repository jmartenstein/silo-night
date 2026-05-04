# Design Philosophy: Minimalist & Adaptive

This document outlines the core values and standards for Silo Night. It serves as a guide for both human developers and AI agents to ensure consistency across the user interface and the underlying system architecture.

---

## I. UI/UX Philosophy: Functional Minimalism
The fundamental goal of Silo Night's design is to **simplify the interface by removing unnecessary elements or content that does not directly support the user's task of managing their show schedule.** Every element must serve a clear, functional purpose.

### 1. Flat Patterns and Textures
*   **Principle:** Avoid skeuomorphic elements like heavy shadows, 3D gradients, or lifelike textures.
*   **Implementation:** Use "Flat 2.0"—clean, digital-first representations with subtle visual cues (like slight color shifts on hover) to indicate interactivity.

### 2. Limited & Strategic Color Palette
*   **Principle:** Use a primarily monochromatic or grayscale palette (white, black, gray) with a single, bold accent color.
*   **Implementation:** Use the accent color exclusively for primary actions (e.g., "Add Show," "Save Schedule") and critical information.

### 3. Maximized Negative Space
*   **Principle:** Use "white space" as a structural component to reduce cognitive load and direct the eye toward important information.

### 4. Adaptability & Responsiveness
*   **Mobile-First:** Interactive elements must be touch-friendly (min 44x44px). The schedule stacks vertically on small screens.
*   **Desktop Optimization:** Utilize extra width for side-by-side grid layouts. Use hover states to provide context without clutter.

---

## II. Architectural Philosophy: Contract-First & Decoupled
We believe that a robust backend architecture is the foundation for rapid front-end prototyping. Our architecture is guided by the following biases:

### 1. Contract-First Design (TDD)
We treat the API "Contract" as the primary deliverable. The backend is a service provider, and the JSON schema is the legal agreement between the backend and client teams. All new features must start with an RSpec request spec defining the contract.

### 2. Request-Level Verification
While unit tests have value, we prioritize **Request Specs** (Route -> Service -> Model -> Presenter). This ensures the entire stack works together to deliver the correct contract, providing higher confidence during aggressive refactors.

### 3. "Thin Model, Thick Service"
We avoid adding business logic (like schedule generation or metadata fetching) directly to models. We prefer keeping models as "Anemic" data containers and moving orchestration to **Service Objects** to prevent "God Objects" and circular dependencies.

### 4. Explicit Representation (Presenters)
We do not use `to_json` overrides in models. A model's data should be separate from its representation. Explicit **Presenters** allow us to provide different "Views" of the same data without polluting the model layer.

### 5. Standardized Failure States
Every failure should return a predictable JSON payload via the `Presenters::Error` object. This allows clients to implement robust, user-friendly error handling for any UI prototype.

### 6. Defensive Service Logic
Services are responsible for handling database-level constraints (e.g., `UniqueConstraintViolation`) and ensuring data freshness (e.g., calling `user.reload`) before state-changing operations.

### 7. Module Scoping & Naming
We favor concise, module-scoped naming (e.g., `Services::Show`) over redundant descriptors (e.g., `Services::ShowService`). The namespace provides sufficient context.

---

## III. Implementation Guidelines
1.  **Check Usability First:** Never sacrifice a functional feature for a "cleaner" look.
2.  **Performance Priority:** Minimalism extends to technical efficiency. Minimize large assets and complex CSS selectors.
3.  **Consistency:** Match existing typography and spacing in `default.css`.
4.  **Preservation:** Maintain side-by-side compatibility with the `v0.1` namespace; it remains as a legacy reference until `v1` is fully verified.

## IV. References
*   [NN/g: Characteristics of Minimalism in Web Design](https://www.nngroup.com/articles/characteristics-minimalism/)
*   [Silo Night User Journey](./user_journey.md)
*   [Technical Assumptions](./assumptions.md)
