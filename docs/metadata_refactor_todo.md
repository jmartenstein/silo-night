# Metadata Refactor: Moving to a Flexible Payload

Hey there! As we discussed, we're refactoring how `silo-night` handles TV show information. 

## The "Why"
Currently, we store things like `runtime` and `poster_path` as hardcoded columns on the `shows` table. This is "brittle"—every time a new API provider gives us a cool new piece of data (like "average episode length" vs "total runtime"), we have to run a database migration to add a column.

We are moving this data into a `payload` JSON column in the `show_metadata` table. This allows us to:
1. Store whatever the API gives us without changing the schema.
2. Associate a single show with metadata from multiple sources (TMDB, TVMaze, etc.) in the future.
3. Keep the core `shows` table lean.

---

## The Workflow: "Verify at Every Step"
We are currently on the `refactor/metadata` branch. If a step breaks the tests and you can't figure out why within 15 minutes, **stop, revert the file, and ask for a review.** It's better to stay "green" than to plow ahead into a broken state.

### Step 0: Establish Database Baselines (Safety First)
Before we touch the schema, we need a "Save Point" in case we need to abandon this branch entirely.

- [x] **Create a V3 Snapshot (Checkpoint)**: Create a fresh snapshot of the database *before* running migrations. This is our "Point of Abandonment"—if the refactor fails, we can restore this.
  ```bash
  # Create a schedule_v4 snapshot to save current state
  bundle exec rake db:snapshot:save[schedule_v3]
  ```
- [x] **Sync Environments**: Use this snapshot to ensure your development and test databases are synced.
  ```bash
  bundle exec rake db:snapshot:load[schedule_v3]
  ```

### Step 1: Data Migration
The schema changes are already in `db/migrations`. Now we need to move the actual data.

- [x] **Run Migrations**: Ensure your local DB is up to date.
  ```bash
  bundle exec rake db:migrate
  ```
- [x] **Run the Migration Script**: Move data from `shows` columns into `show_metadata` records.
  ```bash
  bundle exec ruby scripts/migrate_metadata_to_payload.rb
  ```
- [x] **Validation**: Open the console and verify a show has metadata.
  ```ruby
  # In bundle exec irb -r ./silo_night
  Show.first.metadata.payload # Should return a hash with runtime and poster_path
  ```
- [x] **Create a V4 Snapshot (Checkpoint)**: Create a fresh snapshot of the database *before* running migrations. This is our "Point of Abandonment"—if the refactor fails, we can restore this.
  ```bash
  # Create a schedule_v4 snapshot to save current state
  bundle exec rake db:snapshot:save[schedule_v4]
  ```

### Step 2: Update the `Show` Model (Delegation)
We want the `Show` model to be smart. If someone asks for `show.runtime`, it should check its associated metadata record first.

- [x] **Edit `lib/show.rb`**: 
    - Update the `runtime` getter (or create one) to return `metadata.payload['runtime']` if it exists, falling back to the column.
    - Do the same for `poster_path`.
- [x] **Validation**: Run the model specs.
  ```bash
  bundle exec rspec spec/lib/show_spec.rb
  ```

### Step 3: Update Show Creation Logic
When we add a new show (e.g., via the Search UI), we need to make sure we create the `Show` **and** the `ShowMetadata` at the same time.

- [x] **Edit `silo_night.rb`**: Find the `post '/user/:name/show'` route (and any other creation points). Ensure that when a show is created from `MetadataService` results, the metadata is saved to the `show_metadata` table and linked via `show_id`.
- [x] **Edit `lib/services/user_show.rb`**: If there is logic here for adding shows, ensure it handles the metadata link.
- [x] **Validation**: Run the integration tests for adding shows.
  ```bash
  bundle exec rspec spec/requests/api/v1/shows/create_spec.rb
  ```

### Step 4: Refactor Data Seeding Scenarios
Our seed scripts (`smoke.rb`, `n1_audit.rb`) currently create shows without metadata, which will break the new delegation logic. We need a unified helper to create shows consistently.

- [x] **Create Seeder Helper**: Move show creation logic to a shared helper (e.g., in a `DatabaseSeeder` module or shared service) that creates both `Show` and `ShowMetadata` records.
- [x] **Update Seeding Scripts**: Refactor `data/scenarios/smoke.rb` and `data/scenarios/n1_audit.rb` to use this new helper.
- [x] **Validation**: Run the scenarios to verify they don't break.
  ```bash
  bundle exec rake db:seed:scenario[smoke]
  bundle exec rake db:seed:scenario[n1_audit]
  ```

### Step 5: Modernize Data Creation (Factories & Services)
This is our "Contract (Writes)" phase. We must stop all parts of the app—both test and production—from writing to the legacy columns.

- [x] **5.1: Factory Modernization**: Update `spec/factories/users.rb` to use transient attributes. (Done)
- [x] **5.2: Service Layer Audit (Production Fix)**: Refactor `Services::ShowFactory` and `Shows#load_from_json` to remove legacy keys from `create` and `new` calls.
    - *Verification*: `bundle exec rspec spec/services/show_factory_spec.rb`
- [x] **5.3: Unit Spec Data Setup Audit**: Audit `spec/lib/` and `spec/services/` for raw `Show.create` calls and fix the "primary key" association error in `show_spec.rb`.
    - *Verification*: `bundle exec rake test:unit`
- [x] **5.4: Request Spec Data Setup Audit**: Systematically update `spec/requests/` to use factories instead of raw `Show.create`.
    - *Verification*: `bundle exec rake test:integration`

### Step 6: Refactor Feature Step Definitions
Cucumber steps currently create `Show` objects directly, bypassing the metadata service. This will cause failures once columns are removed.

- [x] **Refactor Step Definitions**: Update `features/step_definitions/schedule_steps.rb` and `features/step_definitions/ui_steps.rb` to use your unified show creation helper.
- [x] **Validation**: Run the feature suite.
  ```bash
  bundle exec cucumber
  ```

### Step 7: Refactor the Presenter
The Presenter shouldn't care *where* the data comes from, but we should make sure it's using the new "source of truth."

- [x] **Edit `lib/presenters/show.rb`**: Update it to use the delegated methods from the `Show` model.
- [x] **Validation**: Run the presenter specs.
  ```bash
  bundle exec rspec spec/lib/presenters/show_spec.rb
  ```

### Step 8: Hardening & Model Lockdown (The "Ruby Tripwire")
Before we touch the database, we add application-level guards to prove the system is "Write-Safe."

- [ ] **8.1: The Model Tripwire**: Add explicit `runtime=` and `poster_path=` methods to the `Show` model that `raise` a custom "Deprecated Write Detected" error.
    - *Why*: This provides a much clearer error message than a database crash and proves the code is "Write-Safe" at the application level.
- [ ] **8.2: Mass-Assignment Restriction**: Replace the tripwire methods with Sequel's `set_restricted_columns :runtime, :poster_path`.
- [ ] **8.3: Final Build Verification**: Run the **entire** test suite (`bundle exec rake test`). If it stays green, the application is officially decoupled from the legacy columns.

### Step 9: Final Schema Cleanup (The "Point of No Return")
Once we are 100% sure the app is reading from the `payload` and no code is trying to write to legacy columns, we safely remove them.

- [x] **Rename Columns**: Create a migration to rename `runtime` and `poster_path` to `deprecated_runtime` and `deprecated_poster_path`. This will trigger an immediate crash if any code still tries to access them.
- [x] **Run Migration**: `bundle exec rake db:migrate`.
- [ ] **Verification**: Run the **entire** test suite (`bundle exec rake test`). If it stays green, you are safe.
- [ ] **Drop Columns**: Create a final migration to remove the `deprecated_` columns.
- [ ] **Run Migration**: `bundle exec rake db:migrate`.

---

## Troubleshooting & Recovery
If `Show.first.metadata` returns `nil` after Step 1, the migration script didn't work. Check `scripts/migrate_metadata_to_payload.rb` and ensure `DATABASE_URL` is pointing to the right place.

### "Abandon Ship" (How to reset)
If you decide to abandon the `refactor/metadata` branch due to unresolvable issues:
1. **Restore Baseline**: Revert to the known-good schedule_v3 state.
   ```bash
   bundle exec rake db:snapshot:load[schedule_v3]
   ```
2. **Discard Branch Changes**:
   ```bash
   git reset --hard origin/refactor/metadata
   ```
3. **Notify Lead**: If you had to perform a restore, please notify the senior developer before attempting to restart the refactor process.

Good luck! You've got this.
