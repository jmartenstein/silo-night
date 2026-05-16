@vcr
Feature: Search Relevance
  As a user
  I want search results to be relevant
  So that I can easily find the show I'm looking for without noise

  Scenario: Filter out obscure shows based on popularity
    Given I search for "The Bear"
    Then I should see "The Bear" in the results
    And I should not see "Obscure Bear Show" in the results
