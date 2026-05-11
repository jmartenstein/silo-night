Feature: Legacy API v0.1 Regression
  Scenario: Adding a show via v0.1 API
    Given the user "steph" exists
    When I send a POST request to "/api/v0.1/user/steph/show" with body "show=Foundation"
    Then the response status should be 200
