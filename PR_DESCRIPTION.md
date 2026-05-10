# Issue: #69

## Changes
- Implemented "Local First" search strategy in `MetadataService#search_shows`.
- Added database lookup using `Show.where(Sequel.ilike(:name, "%#{title}%")).limit(5)`.
- Implemented deduplication logic to merge local and API results.
- Added RSpec unit tests for the local search logic.

## Verification
- Ran `rspec spec/services/metadata_service_spec.rb` and all tests passed, including the new local-first search test.
- Output:
```
......

Finished in 0.00953 seconds (files took 0.28628 seconds to load)
6 examples, 0 failures
```
