# Refactor Task: Implementing ScheduleService and SchedulePresenter

## Status: Ready for Implementation
**Target Audience:** Junior Engineering Team

---

## 1. Architectural Context
After successfully refactoring our **Show** and **UserShow** logic, we are moving on to the **Schedule** system. Currently, the logic for generating and viewing a user's schedule is still scattered between the `User` model and the routes in `silo_night.rb`.

Your goal is to apply the **Service/Presenter** pattern to clean this up, focusing on `GET /api/v1/user/:name/schedule`.

---

## 2. Part A: The `Presenters::Schedule` (The "What")

### Why?
The `User.schedule` field contains a raw JSON hash of the weekly viewing plan. The front-end needs this data in a clean, predictable format. The `SchedulePresenter` will handle making sure every day of the week is represented, even if it's empty.

### Your Instructions:
1.  **Create a new file:** `lib/presenters/schedule.rb`.
2.  **Define the class:** `module Presenters; class Schedule; end; end`.
3.  **Implement `initialize(schedule_hash)`:** Store the raw hash.
4.  **Implement `to_h`:** This method should return the schedule. (Bonus: Ensure it includes all 7 days of the week, with an empty array if a day is missing).
5.  **Bonus Method:** `tonight(day_name)` - Returns only the shows for a specific day.

---

## 3. Part B: The `Services::Schedule` (The "How")

### Why?
Calculating the schedule (matching show runtimes against user availability) is complex business logic. The `ScheduleService` will orchestrate this process.

### Your Instructions:
1.  **Create a new file:** `lib/services/schedule.rb`.
2.  **Define the class:** `module Services; class Schedule; end; end`.
3.  **Implement `self.get_for_user(user)`:** 
    - Should return the user's current schedule.
4.  **Implement `self.generate_for_user(user)`:**
    - Should trigger `user.generate_schedule` and return the new results.
    - Tip: This is where we will eventually move the generation logic out of the model!

---

## 4. Final Integration (The TDD Cycle)

Follow the **Red-Green-Refactor** pattern you've learned:

1.  **🔴 Red:** Write a test in `spec/services/schedule_spec.rb` or `spec/presenters/schedule_spec.rb`.
2.  **🟢 Green:** Implement the minimal code in the Service or Presenter.
3.  **🔵 Refactor:** Clean up the logic and update the route in `silo_night.rb`.

### Success Criteria:
- Run `bundle exec rspec`. All 46 tests must stay Green.
- Run `bundle exec cucumber`. All scenarios must pass.

---

## 5. Why This Matters
By moving the schedule logic here, we prepare the app for future features like "Skip this week" or "Swap these days," without ever having to touch the web server code again. You're building a professional, scalable back-end!
