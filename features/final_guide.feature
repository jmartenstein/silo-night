# features/final_guide.feature

Feature: Final Watch Guide
  As a user like Structured Sam
  I want a clear, generated guide of what to watch and when
  So that I can stop thinking and just enjoy my evening

  Scenario: Generating a weekly schedule
    Given the user "sam" has "Silo" (45 min) and "The Bear" (30 min) in their list
    And "sam" has "60 min" availability on "Monday"
    And "sam" has "60 min" availability on "Tuesday"
    When the user generates their final guide
    Then "Silo" should be scheduled for "Monday"
    And "The Bear" should be scheduled for "Tuesday"

  Scenario: Highlighting today's show
    Given the user "sam" has "Silo" scheduled for today
    When the user views their final guide
    Then "Silo" is highlighted as "Watch Tonight"
    And the current day is marked as active in the weekly schedule
