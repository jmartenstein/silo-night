Feature: Tonight's Viewing Guide
  As a user who is easily overwhelmed by a full weekly schedule
  I want a simple list of what to watch "Tonight"
  So that I can focus only on my current evening's entertainment

  Scenario: Viewing shows for tonight
    Given a user "steph" has shows scheduled for "Monday"
    And today is "Monday"
    When "steph" sends an API request for shows "tonight"
    Then the site responds with JSON
    And the site responds with text containing "The Expanse"
