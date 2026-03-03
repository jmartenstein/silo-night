# Parallel Development Roadmap: Trunk-Based Execution

This document outlines the workstreams for Silo Night, optimized for parallel execution by three independent AI agents using **Trunk-Based Development**. Agents should focus on merging small, frequent, and tested increments to the `main` branch to minimize integration complexity and avoid long-lived branch collisions.

---

### **Agent Identities**
- `agent-altair`
- `agent-vega`
- `agent-deneb`

*Note: Branch names must be descriptive of the feature or task (e.g., `feat/user-validation` or `fix/api-404-error`), not the agent identity.*

---

## **Workstream: Identity & UI Core (agent-altair)**
*Focus: Establishing the user session context and global UI feedback systems.*

- **Scope:**
  - **Epic:** Core User Management Implementation (`silo-vjq`)
  - **Feature:** UI Flash Messages and Feedback (`silo-ne1`)
- **Key Deliverables:** 
  - Root page listing existing users (`silo-qd0`).
  - User creation logic with validation and flash feedback (`silo-ayb`, `silo-6uq`).
  - Gherkin step definitions for user state (`silo-wyq`).
- **Strategy:** Provide the foundational user context and UI patterns that other workstreams will consume.

---

## **Workstream: Search & Metadata Integration (agent-vega)**
*Focus: The "Curate" loop of finding, adding, and persisting show data.*

- **Scope:**
  - **Feature:** Show Search and Metadata Integration (`silo-qy7`)
  - **Feature:** User Show Persistence (`silo-43v`)
  - **Feature:** Search Result Selection & Persistence (`silo-kfy`)
  - **Feature:** Persistent Show Reordering (`silo-pqt`)
- **Key Deliverables:**
  - `MetadataService` result formatting and suggestion UI (`silo-p21`, `silo-ik7`).
  - Show selection logic and database persistence (`silo-9tu`, `silo-sxv`).
- **Strategy:** Develop the show management loop in parallel by utilizing a default or mock user context while Identity features are being merged.

---

## **Workstream: Scheduling Logic & API (agent-deneb)**
*Focus: The "Schedule" engine, its configuration UI, and the REST API layer.*

- **Scope:**
  - **Epic:** Show & Schedule Configuration (`silo-w9n`)
  - **Feature:** Weekly Availability Configuration (`silo-yjw`)
  - **Epic:** Intelligent Schedule Generation Engine (`silo-f6n`)
  - **Epic:** REST API for Show & Schedule Management (`silo-e0b`)
- **Key Deliverables:**
  - Availability configuration UI and persistence (`silo-2lf`, `silo-i8h`).
  - Core scheduling algorithm and "Watch Tonight" UI highlights (`silo-i9t`, `silo-ktp`, `silo-3jt`).
  - REST API suite with authentication and error handling (`silo-tea`, `silo-qg1`, `silo-gf9`, `silo-6wr`).
- **Strategy:** Implement the scheduling algorithm as an independent engine that can be verified with mock data, incrementally exposing it via the UI and API.

---

## **Coordination & Integration**
- **Small Commits:** Merge individual task beans or small feature sets to `main` as soon as they are "Green".
- **Claim-on-Main:** Rigorously follow the claiming protocol in `docs/coordination_workflow.md` to avoid duplicate effort.
- **Continuous Validation:** Agents must run all Cucumber features before merging to ensure their changes do not break other workstreams.
