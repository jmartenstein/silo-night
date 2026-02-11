# Key Changes to Project Tasks

### Critical & Blocking
- **silo-kkr** (Fix hardcoded database connections): Now marked as **critical**. It blocks the milestone **silo-rdo** and other cleanup tasks, as environment isolation is essential for safe development and testing.

### High Priority
- **silo-8b5** (Remove `data/schema.rb`) and **silo-hi3** (Integrate seed data): Now **high** priority to ensure the project structure is clean and automated.
- **silo-sem** (Persistent Metadata Storage) and its sub-task **silo-rtf** (Define schema): Now **high** priority as they form the foundation for the metadata epic.
- **silo-7ca** (API Integration): Now **high** priority and blocks **silo-srm** (Cache-aside logic).

### Blocking Relationships
- Established dependencies where infrastructure or schema changes must precede logic implementation (e.g., schema definition before model creation, and API client development before cache-aside logic).
