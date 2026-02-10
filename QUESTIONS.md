# Project Planning Questions

## 1. What is the data source for show metadata?

**Context:** The Architecture section mentions populating data with attributes like average runtime, number of seasons, and episodes.

**Suggested Answer:**
Currently, the application appears to rely on local data seeding (`data/seed.rb`) and static JSON files (`public/static/justephanie/shows.json`).

**Recommendation:**
To scale this effectively, we should integrate with a public TV metadata API such as **The Movie Database (TMDB)** or **TVMaze**.
- **Short-term:** Continue using `data/seed.rb` for core testing data.
- **Long-term:** Implement a service object (e.g., `ShowFetcher`) that queries an external API to populate the database. This ensures data is accurate and automatically updated. We would likely need to add an API key to the environment variables.

## 2. How is user authentication and data isolation handled?

**Context:** The README describes this as a "multi-user website," but `lib/user.rb` exists without clear authentication documentation.

**Suggested Answer:**
The application needs a mechanism to distinguish between users to render their specific weekly schedules.

**Recommendation:**
Implement a lightweight authentication system:
- **Database:** Ensure the `users` table exists (checked via `data/schema.rb`) with columns for `username` and `password_digest`.
- **Security:** Use `BCrypt` for secure password hashing.
- **Session Management:** Utilize Rack's native session middleware (`use Rack::Session::Cookie`) to store the `user_id` upon login.
- **Isolation:** All schedule queries should be scoped to the current user (e.g., `user.schedules` instead of `Schedule.all`).

## 3. What is the intended deployment environment?

**Context:** The "Running the App" section currently only covers local `rackup` usage.

**Suggested Answer:**
The choice of database (SQLite3) influences the deployment strategy significantly because SQLite requires persistent local disk storage, which ephemeral file systems (like standard Heroku dynos) wipe on restart.

**Recommendation:**
- **Option A (VPS):** Deploy to a Virtual Private Server (e.g., DigitalOcean Droplet, Linode, AWS Lightsail) where the SQLite file can persist on the disk.
- **Option B (Docker):** Containerize the application. Use a Docker volume to map the `data/` directory to the host machine, ensuring the database survives container restarts.
- **Option C (PaaS with modification):** If using Heroku or Render, switch the database from SQLite to PostgreSQL to handle data persistence statelessly.

## 4. What architectural assumptions and biases exist in the current implementation?

**Context:** Analysis of the codebase (`silo_night.rb`, `lib/show.rb`, `lib/user.rb`, etc.) reveals several ingrained technical and logic-based assumptions.

**Assumptions identified:**
- **Database Coupling:** The database connection (`sqlite://data/silo_night.db`) is hardcoded in multiple core files, assuming a local SQLite file system.
- **Identity via URL:** The application assumes a trusted environment by identifying users solely through URL parameters (e.g., `/user/:name`), with no session-based authentication.
- **Serialized State:** User schedules and configurations are stored as JSON strings within database columns. This assumes that relational queries on schedule data won't be necessary and complicates data validation.
- **Brittle Parsing:** The `Show#average_runtime` method assumes a specific string format (e.g., "60 minutes") and uses a basic regex/split strategy that may fail on more complex runtime descriptions.
- **Local File Dependency:** There is a heavy reliance on local JSON files (`data/*.json`) for seeding and data loading, assuming these files are always present and correctly formatted.
- **Greedy Scheduling:** The `generate_schedule` logic assumes a "first-fit" priority where shows are added to the first available day that fits their runtime, which may not align with complex user preferences.

**Recommendation:**
To improve the project's flexibility and robustness:
- **Environment Configuration:** Extract database URLs and file paths into environment variables or a `config.yml`.
- **Relational Refactoring:** Move schedule data from a JSON blob into a join table (e.g., `schedules` or `user_shows`) to allow for better data integrity and querying.
- **Standardized Data Types:** Store runtimes as integers (minutes) in the database instead of strings to avoid brittle parsing.
- **API-First Data:** Shift away from local JSON files towards the API-based approach mentioned in Question 1.
