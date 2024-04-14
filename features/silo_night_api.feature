Feature: SiloNight API

  Scenario: Return a 200 response on the main page
    When any user sends a request to the main page
    Then the site responds with an OK code

  Scenario: Return a list of shows
    When "Stephanie" sends a request for a list of shows
    Then the site responds with JSON containing "Equalizer"
