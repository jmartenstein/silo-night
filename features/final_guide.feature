# features/final_guide.feature

Feature: Final Watch Guide
  As a user like Structured Sam
  I want a clear, generated guide of what to watch and when
  So that I can stop thinking and just enjoy my evening

  Scenario: Generating a weekly schedule
    Given the user "sam" has "Foundation" (53 min) and "The Bear" (30 min) in their list
    And "sam" has "60 min" availability on "Monday"
    And "sam" has "60 min" availability on "Tuesday"
    When the user generates their final guide
    Then "Foundation" should be scheduled for "Monday"
    And "The Bear" should be scheduled for "Tuesday"

  Scenario: Highlighting today's show
    Given the user "sam" has "Foundation" scheduled for today
    When the user views their final guide
    Then "Foundation" is highlighted as "Watch Tonight"
    And the current day is marked as active in the weekly schedule

  @failing
  Scenario: Investigation - Schedule is updated after adding a show via UI (Reason #1)
    Given the user "investigator" exists
    And "investigator" has "60 min" availability on "Monday"
    And "investigator" has an empty schedule
    When the user adds "Foundation" ("53 min") to their list via the UI
    And the user views their final guide
    Then "Monday" schedule should show "Foundation"

  @failing
  Scenario: Investigation - Enabled days with zero time are visible in the UI (Reason #3)
    Given the user "investigator" exists
    When the user enables "Wednesday" but sets time to "0" minutes
    And the user views their final guide
    Then "Wednesday" schedule should show "No TV tonight"
