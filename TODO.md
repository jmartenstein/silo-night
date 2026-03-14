# Implementation Plan - Issue #47

- [ ] Update `POST /api/v0.1/user/:name/show` in `silo_night.rb` to capture `poster_path`.
- [ ] Update `User#load_from_json_string` and other loading methods in `lib/user.rb` if necessary.
- [ ] Create a backfill script or Rake task for existing shows.
- [ ] Verify with an integration test in `features/step_definitions/api_steps.rb` or a new spec.
