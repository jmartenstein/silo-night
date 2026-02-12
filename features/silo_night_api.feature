Feature: silo-night API

  Scenario: Return a 200 response on the main page
    When any user sends a request to the main page
    Then the site responds with an OK code

  @failing
  Scenario: Return a user's show list through the API
    When "steph" sends an API request for a list of shows
    Then the site responds with JSON
    And the site responds with text containing "Equalizer"

  @failing
  Scenario: Return a different user's show list through the API
    When "justin" sends an API request for a list of shows
    Then the site responds with JSON
    And the site responds with text containing "His Dark Materials"
    And the site responds with text not containing "The Amazing Race"

  @failing
  Scenario: User deletes a show
    When "steph" sends an API request to delete "suits" from the list
    Then the site responds with an OK code
    And the site responds with text not containing "Suits"

  @failing
  Scenario: User adds a show
    When "test" sends an API request to add "Platonic" to the list
    Then the site responds with an OK code
    And the site responds with text containing "Platonic"

  @failing
  Scenario: Return a 404 when a show is not found for a user
    When "justin" sends an API request to delete "foo" from the list
    Then the site responds with a 404 error code

  @failing
  Scenario: Show user's schedule based on seeded data
    When "steph" sends an API request to view the schedule
    Then the show "The Afterparty" is scheduled for "Thursday"

  @failing
  Scenario: Remove and add a show and generate a new schedule
    Given "steph" sends an API request to delete "Suits" from the list
      And "steph" sends an API request to add "The Amazing Race" to the list
    When  "steph" generates a new schedule
    Then  the site responds with text not containing "Suits"
      And the site responds with text containing "The Amazing Race"
      And the show "The Amazing Race" is scheduled for "Wednesday"
