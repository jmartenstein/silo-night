Feature: SiloNight api

  Scenario: Return a 200 response on the main page
    When any user sends a request to the main page
    Then the site responds with an OK code

  Scenario: Return a list of shows
    When the user "Stephanie" sends a request her list of shows
    Then the site responds with a JSON object containtaining "Equalizer"
