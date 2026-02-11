# Silo Night - Project Epics & Milestones

This document outlines the proposed epics for the Silo Night project, categorized by their respective milestones.

## Milestone: Show Metadata Integration (silo-0cx)
*Current Status: todo*

### Epic: TMDB/TVMaze API Integration
Build a robust API client to fetch show data (runtimes, genres, posters) from public databases. This replaces the manual `seed.rb` and static JSON data.
- **Key Deliverable:** A `MetadataService` class capable of querying multiple providers.

### Epic: Show Search & Discovery Interface
Implement a user-facing search bar that allows users to find shows in the external database and add them to their personal "Interested" list.
- **Key Deliverable:** New UI components for search results and show preview cards.

### Epic: Metadata Caching & Background Sync
Develop a local caching layer to store show metadata in the database, reducing latency and API rate-limit issues.
- **Key Deliverable:** A caching strategy that updates show details periodically in the background.

### Epic: Rich Metadata UI Expansion
Update the existing schedule and show views to display rich information like posters, episode counts, and average runtime visual indicators.
- **Key Deliverable:** Redesigned show detail pages and hover-states in the schedule view.

--

## Milestone: Refactor & Relational Integrity (silo-856)
*Current Status: todo*

### Epic: User Preferences Normalization
Migrate the `config` and `schedule` JSON blobs in the `users` table into dedicated relational tables (`user_configs`, `schedules`, `schedule_items`).
- **Key Deliverable:** A fully normalized database schema for user-specific data.

### Epic: Database Migration Framework
Introduce a formal migration system (e.g., Sequel migrations) to handle schema changes predictably across development and production environments.
- **Key Deliverable:** A `db/migrations` directory with versioned migration files.

### Epic: Runtime Calculation Optimization
Refactor the `Show#average_runtime` logic to store runtimes as integers in the database, removing the need for fragile string parsing.
- **Key Deliverable:** Integer-based runtime columns and updated model logic.

### Epic: Query Layer Refactoring
Rewrite the scheduling logic in the `User` model to use efficient SQL joins and aggregate functions instead of loading and parsing large JSON objects.
- **Key Deliverable:** Optimized `generate_schedule` and `available_runtime` methods.

---

## Milestone: User Identity & Authentication (silo-qtj)
*Current Status: todo*

### Epic: Secure Authentication System
Implement a robust login/logout system using BCrypt for password hashing and Sinatra sessions for state management.
- **Key Deliverable:** Login forms, session handling logic, and secure password storage.

### Epic: User Signup & Profile Management
Create a registration flow that allows new users to create accounts and manage their personal details and watching preferences.
- **Key Deliverable:** Signup views and a "My Profile" settings page.

### Epic: Role-Based Access Control (RBAC)
Establish an authorization layer to differentiate between regular users (who can only see their own schedules) and admins.
- **Key Deliverable:** Middleware to protect routes based on user role.

### Epic: Security Audit & Hardening
Perform a security sweep to implement CSRF protection, secure HTTP headers, and input validation across all forms and API endpoints.
- **Key Deliverable:** Security-hardened application middleware and validated inputs.

---

## Milestone: Production Hardening & Deployment (silo-riz)
*Current Status: todo*

### Epic: Dockerization & Orchestration
Containerize the Sinatra application and its dependencies (PostgreSQL, Redis) using Docker and provide Compose/Kubernetes manifests.
- **Key Deliverable:** `Dockerfile` and `docker-compose.yml` optimized for production.

### Epic: PostgreSQL Migration
Transition the backend from SQLite to PostgreSQL to support concurrent users and production-grade reliability.
- **Key Deliverable:** Updated `Gemfile`, database connection logic, and environment-specific configs.

### Epic: Environment Configuration Management
Implement a centralized system for managing secrets, API keys, and environment variables using `dotenv` or similar.
- **Key Deliverable:** A `.env.example` file and integrated configuration loader.

### Epic: CI/CD Pipeline Implementation
Set up automated testing and deployment pipelines (e.g., via GitHub Actions) to ensure code quality and seamless releases.
- **Key Deliverable:** `.github/workflows` configurations for testing and deployment.

---

## Feedback & Proposed Milestones

### Gap Analysis
1.  **UI/UX Modernization**: The project goal is "a lifestyle for those tired of binging shows," but the current UI is extremely minimal. A premium feel is essential for user retention.
2.  **Advanced Scheduling Engine**: The current logic is basic. It needs to handle show priority, specific day preferences, and complex scheduling rules.
3.  **Data Analytics**: Users who are "tired of binging" likely want to see how they are spending their time.

### Suggested New Milestones

#### 1. UI/UX Modernization & Mobile Experience (silo-ui)
*Focus: Turning the prototype into a polished, responsive web application.*
- **Epic: Responsive Design Refresh**: Implement a mobile-first design using a modern CSS framework.
- **Epic: Interactive Schedule Builder**: Add drag-and-drop support for reordering shows.
- **Epic: Theming & Visual Identity**: Create a cohesive "Silo" brand aesthetic.
- **Epic: Real-time UI Updates**: Use WebSockets or modern frontend patterns for instant schedule feedback.

#### 2. Advanced Scheduling & Insights (silo-adv)
*Focus: Adding intelligence and feedback to the scheduling process.*
- **Epic: Priority-Based Scheduling**: Let the system auto-fill slots based on user-defined show priorities.
- **Epic: Time Tracking & Analytics Dashboard**: Show users their viewing patterns and time-saving stats.
- **Epic: Custom Scheduling Rules**: Support rules like "daily show" vs "weekly show" or "no horror on school nights".
- **Epic: External Calendar Integration**: Allow users to export their Silo Night schedule to iCal/Google Calendar.
