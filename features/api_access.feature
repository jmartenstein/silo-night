# features/api_access.feature

Feature: API Access for Watch Guide
  As a developer like Programmatic Pete
  I want to access my show list and schedule via an API
  So that I can integrate my watch guide into other tools

  Scenario: Health check on the main page via API
    When any user sends a request to the main page
    Then the site responds with an OK code

  @failing
  Scenario: Fetching a user's watch list
    When "steph" sends an API request for a list of shows
    Then the site responds with JSON
    And the site responds with text containing "Equalizer"

  @failing
  Scenario: Fetching another user's watch list
    When "justin" sends an API request for a list of shows
    Then the site responds with JSON
    And the site responds with text containing "His Dark Materials"
    And the site responds with text not containing "The Amazing Race"

  @failing
  Scenario: Adding a show via the API
    When "test" sends an API request to add "Platonic" to the list
    Then the site responds with an OK code
    And the site responds with text containing "Platonic"

  @failing
  Scenario: Removing a show via the API
    When "steph" sends an API request to delete "suits" from the list
    Then the site responds with an OK code
    And the site responds with text not containing "Suits"

  @failing
  Scenario: Handling missing shows on deletion
    When "justin" sends an API request to delete "foo" from the list
    Then the site responds with a 404 error code

  @failing
  Scenario: Retrieving the user schedule
    When "steph" sends an API request to view the schedule
    Then the show "The Afterparty" is scheduled for "Thursday"

  @failing
  Scenario: Updating the schedule after changes
    Given "steph" sends an API request to delete "Suits" from the list
    And "steph" sends an API request to add "The Amazing Race" to the list
    When "steph" generates a new schedule
    Then the site responds with text not containing "Suits"
    And the site responds with text containing "The Amazing Race"
    And the show "The Amazing Race" is scheduled for "Wednesday"
