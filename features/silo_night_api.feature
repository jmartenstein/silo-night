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

  Scenario: Remove and add a show and generate a new schedule
    When "steph" deletes "Suits" and adds "Amazing Race" and generates a new schedule
    Then the show "Suits" is not in the list
    And the show "The Amazing Race" is in in the list
    And "The Amazing Race" is scheduled for Wednesday 
