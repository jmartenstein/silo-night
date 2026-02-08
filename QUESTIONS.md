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
