@vcr
Feature: Search Edge Cases
  As a user
  I want search results to be handled gracefully
  So that I have a consistent experience

  Scenario: Empty results handled gracefully
    Given I search for "nonexistent-show-12345"
    Then I should see a "No shows found" message
