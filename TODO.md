# TODO for issue #32: Fix schedule cache staleness

- [ ] Identify the routes needing `u.generate_schedule` in `silo_night.rb`
- [ ] Add `u.generate_schedule` to `POST /user/:name/availability`
- [ ] Add `u.generate_schedule` to `POST /api/v0.1/user/:name/show`
- [ ] Add `u.generate_schedule` to `DELETE /api/v0.1/user/:name/show/:show`
- [ ] Add `u.generate_schedule` to `POST /api/v0.1/user/:name/shows/reorder`
- [ ] Verify fix by running the cucumber scenario `Investigation - Schedule is updated after adding a show via UI (Reason #1)`
- [ ] Remove `@failing` tag from the scenario once verified
