# Refactor Task: Implementing ShowService and ShowPresenter

## Status: Ready for Implementation
**Target Audience:** Junior Engineering Team

---

## 1. Architectural Context
We've just reached a "Green" state in our TDD cycle for `GET /api/v1/user/:name/shows`. However, the current code in `silo_night.rb` is problematic because it mixes **orchestration** (finding the user) and **presentation** (shaping the JSON) directly in the route.

Your goal is to perform the **Refactor** step: move this logic into dedicated objects that follow the **Single Responsibility Principle (SRP)**.

---

## 2. Part A: The `ShowPresenter` (The "What")

### Why?
Models like `Show` contain all kinds of data (database IDs, internal timestamps, raw strings). We shouldn't just dump all of that into our API. The `ShowPresenter` acts as a "filter" and a "decorator" that ensures the front-end gets exactly what it needs, in the correct format.

### Your Instructions:
1.  **Create a new file:** `lib/presenters/show_presenter.rb`.
2.  **Define the class:** It should take a `Show` object in its constructor.
3.  **Implement a `to_h` (or `as_json`) method:** This method should return a hash with the following keys:
    - `id`: The show's database ID.
    - `name`: The display name.
    - `runtime`: The runtime (as an integer).
    - `uri_safe_name`: The `uri_encoded` field from the model.
    - `poster_url`: A "decorated" version of `poster_path`. (Hint: If it starts with `/`, prepend the TMDB base URL `https://image.tmdb.org/t/p/w500`).
4.  **Requirement:** Do not touch the `Show` model itself. All formatting happens here.

---

## 3. Part B: The `ShowService` (The "How")

### Why?
Routes should be "thin shims." They should only handle the HTTP request and immediately hand off the real work to a "Service." This makes our business logic testable without needing to boot up a web server.

### Your Instructions:
1.  **Create a new file:** `lib/services/show_service.rb`.
2.  **Define a class method:** `self.list_for_user(user_name)`.
3.  **Implementation logic:**
    - Find the user by name using the `User` model.
    - If the user doesn't exist, return `nil` or raise a custom `UserNotFoundError`.
    - Fetch the shows associated with that user.
    - Return the collection of shows.
4.  **Goal:** This service should eventually handle adding, removing, and reordering shows, but for now, focus only on the `list_for_user` functionality.

---

## 4. Final Integration (The Refactor)

Once your Service and Presenter are ready, you'll update the route in `silo_night.rb` to look like this:

```ruby
get '/user/:name/shows' do
  content_type :json
  shows = Services::ShowService.list_for_user(params[:name])
  return status 404 unless shows
  
  shows.map { |s| Presenters::ShowPresenter.new(s).to_h }.to_json
end
```

### Success Criteria:
- Run `bundle exec rspec spec/requests/api/v1/shows_spec.rb`.
- **The test must stay Green.** If it turns Red, check if you renamed any JSON keys or if your `poster_url` logic changed the expected output.

---

## 5. Why This Matters
By doing this, you're making the system:
- **Testable:** We can now write a unit test for `ShowPresenter` without needing a database.
- **Maintainable:** If we decide to use a different image provider for posters, we only change one line in the `ShowPresenter`.
- **Flexible:** The front-end team can now trust that *every* endpoint returning a show will use this exact same structure.
