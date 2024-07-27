#  features/silo_night_ui.feature

Feature: SiloNight user interface

  Scenario: Any user visits the main page
    When a new user visits the main page
    Then the welcome page displays "Create a new schedule"

  Scenario: steph views her list of shows to watch
    When the user "steph" views her list of shows
    Then the list page displays "Equalizer" and "Grey's Anatomy"

  Scenario: Stephanie edits her list of shows
    When the user "steph" visits the page to edit her shows
    Then the edit page displays an "Add" button
    And the edit page displays a "Shows" header
    And the edit page displays an "Availability" header

  Scenario: Create a new list of shows
    When any user clicks the "Create" link on the welcome page
    Then a blank list of shows is displayed
