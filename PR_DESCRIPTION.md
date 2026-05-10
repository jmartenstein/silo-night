# Issue: #69

## Changes
- Updated `MetadataService#search_shows` to query the local database first.
- Implemented deduplication logic in `MetadataService` to prevent duplicates when local and API results match.
- Made Show model attribute access robust in `MetadataService` to handle missing methods.
- Added a new integration test in `spec/services/local_first_search_spec.rb` to verify the local-first search and deduplication.

## Verification
- Ran the new integration test `spec/services/local_first_search_spec.rb` which passed.
- Ran existing tests `spec/services/metadata_service_spec.rb` and `spec/services/search_spec.rb` which all passed.
- Command used: `bundle _4.0.11_ exec rspec spec/services/metadata_service_spec.rb spec/services/search_spec.rb spec/services/local_first_search_spec.rb`
- Output: 
  ........

  Finished in 0.02845 seconds (files took 0.22907 seconds to load)
  8 examples, 0 failures
