# TODO for issue #32: Fix schedule cache staleness

- [x] Identify the routes needing `u.generate_schedule` in `silo_night.rb`
- [x] Add `u.generate_schedule` to `POST /user/:name/availability`
- [x] Add `u.generate_schedule` to `POST /api/v0.1/user/:name/show`
- [x] Add `u.generate_schedule` to `DELETE /api/v0.1/user/:name/show/:show`
- [x] Add `u.generate_schedule` to `POST /api/v0.1/user/:name/shows/reorder`
- [x] Verify fix by running the cucumber scenario `Investigation - Schedule is updated after adding a show via UI (Reason #1)`
- [x] Remove `@failing` tag from the scenario once verified
