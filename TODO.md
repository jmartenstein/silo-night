# Watch List Management (Issue #24)

- [ ] Implement display of show runtimes in the watch list
    - [ ] Update `template/schedule_edit.slim` to include runtime
    - [ ] Update `public/javascript/default.js` `renderShows` to include runtime
    - [ ] Update `silo_night.rb` `post '/user/:name/show'` to return show details (including runtime)
- [ ] Fix search suggestion functionality
    - [ ] Ensure "Silo" search results match expected format (genres, year)
- [ ] Verify persistence and UI behavior
    - [ ] Add more robust tests for reordering
    - [ ] Ensure list order is maintained on page refresh
- [ ] Improve Cucumber tests to be more rigorous
    - [ ] Fix `Then('the runtime {string} is displayed for {string}')` to actually check for runtime
