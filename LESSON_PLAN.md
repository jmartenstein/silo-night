# Lesson Plan: Implementing the Test Pyramid in silo-night

## Objective
Learn how to restructure a Ruby test suite into a "Test Pyramid" to improve speed, reliability, and maintainability. We will focus on the first two changes proposed in Issue #72: **Categorization & Structure** and **Standardizing API Testing**.

---

## 1. Categorization & Structure

### The Concept
The **Test Pyramid** (pioneered by Mike Cohn and popularized by Martin Fowler) is a framework for balancing your test suite. It suggests that you should have many more low-level unit tests than high-level end-to-end tests.

- **Unit Tests (The Base):** Fast, isolated, zero external dependencies. They test logic and algorithms.
- **Integration Tests (The Middle):** Verify how components work together, including database and external API interactions (using tools like VCR).
- **End-to-End (E2E) Tests (The Top):** Test the entire system from a user's perspective (using Cucumber in this project).

### Practical Steps for silo-night

#### A. Moving Files to Enforce Boundaries
Currently, many specs are in the root `spec/` directory. We will move them to subdirectories that reflect their role.

*Action:*
- Move `spec/show_spec.rb` -> `spec/lib/show_spec.rb` (Unit)
- Move `spec/user_spec.rb` -> `spec/lib/user_spec.rb` (Unit)
- Move `spec/tmdb_adapter_spec.rb` -> `spec/adapters/tmdb_adapter_spec.rb` (Integration)

#### B. Tagging Tests
RSpec allows us to tag tests with metadata. This enables us to run specific tiers of the pyramid (e.g., run only unit tests for maximum speed).

*Example:*
```ruby
RSpec.describe Show, :unit do
  # This test will only run if we include :unit or don't exclude it.
end
```

#### C. Configuring RSpec to Use Tags
We update `spec/spec_helper.rb` to allow filtering based on these tags.

```ruby
RSpec.configure do |config|
  # Allow running only unit tests: RSpec.configure { |c| c.filter_run_including :unit }
  config.define_derived_metadata(file_path: %r{spec/lib/}) do |metadata|
    metadata[:type] = :unit
  end
end
```

---

## 2. Standardizing API Testing with VCR

### The Concept
Manual mocking with `stub_request` (WebMock) or `allow_any_instance_of` is brittle. If the external API changes, your tests might still pass because the mock is static and detached from reality.

**VCR (Video Cassette Recorder)** records real API responses and replays them during future test runs.
- **Realistic:** The first run captures a real response from the actual API.
- **Fast:** Subsequent runs are nearly instantaneous as they read from a local YAML "cassette".
- **Deterministic:** The response doesn't change unless you delete the cassette.

### Practical Steps for silo-night

#### A. Removing Manual Stubs
Identify tests using `stub_request` and replace them with VCR metadata.

*Before (`spec/tmdb_adapter_spec.rb`):*
```ruby
it 'returns show data' do
  stub_request(:get, "https://api.themoviedb.org/3/tv/1399?api_key=test")
    .to_return(status: 200, body: { name: 'Game of Thrones' }.to_json)

  result = adapter.fetch_show_by_id(1399)
  expect(result['name']).to eq('Game of Thrones')
end
```

*After:*
```ruby
it 'returns show data', :vcr do
  # No stub needed! VCR records the network call the first time.
  result = adapter.fetch_show_by_id(1399)
  expect(result['name']).to eq('Game of Thrones')
end
```

#### B. Handling Sensitive Data
Never commit API keys in cassettes. Ensure `spec/spec_helper.rb` is configured to scrub them.

```ruby
VCR.configure do |config|
  config.filter_sensitive_data('<TMDB_API_KEY>') { ENV['TMDB_API_KEY'] }
end
```

---

## Resources for Further Learning
- [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) - Martin Fowler
- [VCR Documentation](https://github.com/vcr/vcr) - Official GitHub Repository
- [Better Specs](https://www.betterspecs.org/) - RSpec Best Practices
- [RSpec Metadata](https://relishapp.com/rspec/rspec-core/docs/metadata/user-defined-metadata) - RelishApp

---

## Homework / Exercise
1. **Refactor Location:** Move `spec/show_metadata_spec.rb` to `spec/lib/` and add the `:unit` tag.
2. **VCR Conversion:** Locate a test in `spec/api_client_spec.rb` that uses `stub_request` and convert it to use `:vcr`.
3. **Verify:** Run only unit tests using `rspec --tag unit`.
