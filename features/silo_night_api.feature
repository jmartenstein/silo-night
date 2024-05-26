Feature: silo-night API

  Scenario: Return a 200 response on the main page
    When any user sends a request to the main page
    Then the site responds with an OK code

  Scenario: Return a user's show list through the API
    When "steph" sends an API request for a list of shows
    Then the site responds with JSON
    And the site responds with text containing "Equalizer"

  Scenario: Return a different user's show list through the API
    When "justin" sends an API request for a list of shows
    Then the site responds with JSON
    And the site responds with text containing "Slow Horses"
    And the site responds with text not containing "Suits"

  Scenario: Return 200 on a delete request
    When "steph" sends an API request to delete "Suits" from the list
    Then the site responds with an OK code

  Scenario: Return 200 on a post request to an add URL
    When "justin" sends an API request to add "Suits" to the list
    Then the site responds with an OK code
    And the site responds with text containing "Equalizer"

  Scenario: Show user's schedule based on seeded data
    When "justin" sends an API request to view the schedule
    Then the show "Reacher" is scheduled for "Monday"

  Scenario: Remove and add a show and generate a new schedule
    Given "steph" sends an API request to delete "Suits" from the list
      And "steph" sends an API request to add "Suits" to the list
    When  "steph" generates a new schedule
    Then  the site responds with text not containing "Suits"
      And the site responds with text containing "The Amazing Race"
      And the show "The Amazing Race" is scheduled for "Wednesday"
