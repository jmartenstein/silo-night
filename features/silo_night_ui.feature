#  features/silo_night_ui.feature

Feature: silo-night user interface

  Scenario: Any user visits the main page
    When any user visits the main page
    Then the page displays "Create a new schedule"

  @failing
  Scenario: steph views her list of shows to watch
    When the user "steph" views her list of shows
    Then the page displays "The Equalizer"
    And the page displays "Grey&#39;s Anatomy"

  @failing
  Scenario: Stephanie edits her list of shows
    When the user "steph" visits the page to edit her shows
    Then the page displays a form with "Add" text
    And the page displays "Shows"
    And the page displays "Availability"

  Scenario: Create a new list of shows
    When any user visits the create new schedule page
    Then a blank list of shows is displayed
