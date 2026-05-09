# Junior Developer Tutorial: Building the Test Pyramid

Welcome! This guide is designed to take you through the process of refactoring a legacy test suite into a modern, reliable "Test Pyramid." You will learn about infrastructure isolation, deterministic API testing, and standardized data setup.

---

## Module 1: Infrastructure & Isolation

### Lesson: Modular Configuration
**Why?** A monolithic `spec_helper.rb` becomes a "junk drawer." We want to move specific tool configurations (like VCR) into their own files in `spec/support/`.

### Step 1.1: Extract VCR Configuration
1.  **Create** a new file at `spec/support/vcr.rb`.
2.  **Move** the `VCR.configure` block from `spec/spec_helper.rb` into this new file.
3.  **Update** `spec/spec_helper.rb` to require the new support file: `require_relative 'support/vcr'`.

### Step 1.2: Unify FactoryBot
1.  **Open** `features/support/env.rb`.
2.  **Add** `World(FactoryBot::Syntax::Methods)` to the bottom of the file.
    *   *Junior Tip:* `World` makes the FactoryBot methods (like `create` and `build`) available directly inside your Cucumber steps.

**[Homework Assignment #1]**
- Run `bundle exec rspec spec/adapters/tmdb_adapter_spec.rb`. 
- **Verification:** Did it pass? If not, check if `vcr.rb` is being loaded correctly. Why is it important that `tmdb_adapter_spec.rb` still works even after we moved the config?

---

## Module 2: The "Identity Crisis" (Tagging)

### Lesson: Defining Boundaries
**Why?** We want to run our "Unit" tests (logic only) in seconds. If a unit test hits a database, it's not a unit test—it's an "Integration" test.

### Step 2.1: Correct the Auto-Tagging
1.  **Open** `spec/spec_helper.rb`.
2.  **Locate** the `config.define_derived_metadata` blocks.
3.  **Change the Regex:**
    *   Currently: `spec/(services|lib)/` is tagged `:unit`.
    *   **Change to:** Only `spec/lib/` and `spec/presenters/` should be `:unit`.
    *   **Add:** `spec/services/` should now be tagged `:integration`.

**[Homework Assignment #2]**
- Run `rake test:unit`. 
- **Observation:** Notice that `MetadataService` no longer runs. 
- **Question:** Explain in one sentence why a "Service" that talks to a database is an integration test, not a unit test.

---

## Module 3: Realism over Mocks (MetadataService)

### Lesson: VCR vs. Manual Doubles
**Why?** Manual `double('Adapter')` calls are "brittle." They assume we know exactly how the adapter works. VCR records *real* interactions, so if the API changes, our tests will actually fail (which is good!).

### Step 3.1: Refactor the Spec
1.  **Open** `spec/services/metadata_service_spec.rb`.
2.  **Remove** the `double` calls for `tmdb_adapter` and `tvmaze_adapter`.
3.  **Replace** them with real instances: `TmdbAdapter.new(ENV['TMDB_API_KEY'])`.
4.  **Add the VCR tag** to the top-level `describe` or individual `it` blocks: `, vcr: { cassette_name: 'metadata_service/unified_lookup' }`.

**[Homework Assignment #3]**
- Delete the file `spec/fixtures/vcr_cassettes/metadata_service/unified_lookup.yml` (if it exists).
- Run the spec. Watch it record a *new* cassette.
- **Challenge:** Look inside the `.yml` file. Can you see the real JSON response from the TV API?

---

## Module 4: Standardizing Data (Cucumber)

### Lesson: Factories > Manual Creation
**Why?** Calling `User.create` in every step makes your tests hard to maintain. If the database schema changes, you have to fix it in 50 places. Factories centralize this.

### Step 4.1: Update User Steps
1.  **Open** `features/step_definitions/user_steps.rb`.
2.  **Find** the line: `User.find(name: username) || User.create(name: username, ...)`
3.  **Replace with:** `User.find(name: username) || create(:user, name: username)`

**[Homework Assignment #4]**
- Open `spec/factories/users.rb`.
- Add a "trait" to the user factory called `:admin`.
- **Task:** Create a new Cucumber step in a new file that uses `create(:user, :admin)`.

---

## Final Exam: Verification
When you think you're done, run the full suite:
`rake test`

**Success Criteria:**
1. `rake test:unit` runs only pure logic tests.
2. `rake test:integration` uses VCR for all service/adapter tests.
3. `rake test:cucumber` passes using FactoryBot helpers.
