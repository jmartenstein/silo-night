@vcr
Feature: Local-First Search
  As a user, I want to see my saved shows in the search results instantly,
  so that I can quickly add them to my schedule without waiting for external API calls.

  Scenario: Searching for a show already in the local database
    Given the user "TestUser" is on their shows and schedule page
    And a show named "The Expanse" exists in the local database with a poster
    When the user types "Expanse" in the "search" field
    Then the page displays a suggestion for "The Expanse"
    # Verify we don't necessarily need external API results for this show
