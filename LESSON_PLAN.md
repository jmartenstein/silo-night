# Junior Developer Tutorial: Building the Test Pyramid

Welcome! This guide is designed to take you through the process of refactoring a legacy test suite into a modern, reliable "Test Pyramid." You will learn about infrastructure isolation, deterministic API testing, and the crucial distinction between **Unit** and **Integration** tests.

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

## Module 2: The "Identity Crisis" (Tagging & Boundaries)

### Lesson: Logic vs. Orchestration
**Why?** Services are often "hybrids." They do two things:
1.  **Orchestration (Wiring)**: "Call API A, then call API B."
2.  **Transformation (Logic)**: "Take data from A and B, merge it, and format it."

We want to test **Logic** with lightning-fast **Unit Tests** (using mocks). We want to test **Wiring** with **Integration Tests** (using VCR).

### Step 2.1: Set the Default Tags
1.  **Open** `spec/spec_helper.rb`.
2.  **Update** the auto-tagging logic:
    *   Keep `spec/lib/` and `spec/presenters/` as `:unit`.
    *   Tag `spec/adapters/` and `spec/requests/` as `:integration`.
    *   *Note:* We will manually tag services because they are hybrids!

### Step 2.2: Identify the Split
Look at `lib/metadata_service.rb`. The method `unify_metadata` is pure logic—it doesn't need a real API. But `get_show_metadata` is wiring—it needs to know the adapters were called.

**[Homework Assignment #2]**
- Find the `calculate_runtime` method in `MetadataService`. 
- **Question:** If we want to test that it correctly handles 10 different weird edge cases for runtimes, should we use a Unit test with mocks or an Integration test with VCR? Why?

---

## Module 3: Implementing the Hybrid Split

### Lesson: mocks for Logic, VCR for Wiring
**Why?** If we use VCR for every edge case, we'll have 50 slow cassettes. If we use mocks for everything, we might not notice if the real API changes. We need both.

### Step 3.1: Refactor the Unit Spec
1.  **Open** `spec/services/metadata_service_spec.rb`.
2.  **Add** the tag `:unit` to the top-level `RSpec.describe`.
3.  **Upgrade Mocks**: Replace `double('TmdbAdapter')` with `instance_double(TmdbAdapter)`.
    *   *Junior Tip:* `instance_double` is safer. It will fail if you try to mock a method that doesn't actually exist on the real class!

### Step 3.2: Create the Integration Spec
1.  **Create** `spec/services/metadata_service_integration_spec.rb`.
2.  **Add** the tag `:integration` and use **real** adapters:
    ```ruby
    RSpec.describe MetadataService, :integration do
      let(:service) { MetadataService.new(TmdbAdapter.new, TvmazeAdapter.new) }
      
      it 'successfully fetches and merges data', vcr: { cassette_name: 'metadata_service/happy_path' } do
        result = service.get_show_metadata('Breaking Bad')
        expect(result[:name]).to eq('Breaking Bad')
      end
    end
    ```

**[Homework Assignment #3]**
- Run `rake test:unit`. How many milliseconds did the `MetadataService` unit tests take?
- Run `rake test:integration`. Notice how much slower it is because it's "talking" (via VCR) to the external world.

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
1. `rake test:unit` contains the logic edge-cases for `MetadataService` and runs in < 1 second.
2. `rake test:integration` contains one or two "Happy Path" tests for `MetadataService` using real adapters and VCR.
3. `rake test:cucumber` passes using FactoryBot helpers.
