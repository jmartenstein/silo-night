# Implementation Plan - Backend Infrastructure for Show Art (#46)

- [ ] Create database migration `db/migrations/003_add_poster_path_to_shows.rb`
- [ ] Update `Show` model in `lib/show.rb`
- [ ] Modify `MetadataService#search_shows` in `lib/metadata_service.rb`
- [ ] Update `MetadataService#unify_metadata` in `lib/metadata_service.rb`
- [ ] Add unit tests in `spec/metadata_service_spec.rb`
- [ ] Verify all tests pass
- [ ] Remove `TODO.md` and mark PR as ready
