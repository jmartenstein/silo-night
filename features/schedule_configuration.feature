# features/schedule_configuration.feature

Feature: Shows and Schedule Configuration
  As a user like Structured Sam
  I want to curate my watch list and define my evening time budget
  So that I can eliminate decision paralysis
Scenario: Searching for a show to add
  Given there is an existing user "sam"
  And the user "sam" is on their shows and schedule page
  When the user types "Silo" in the "show-search" field
  Then the page displays a suggestion for "Silo" with "Science-Fiction" and "2023"

Scenario: Viewing the watch list
  Given the user "steph" has "The Equalizer" and "Grey's Anatomy" in their list
  When the user "steph" views her list of shows
  Then the page displays "The Equalizer"
  And the page displays "Grey's Anatomy"

Scenario: Editing the watch list
  When the user "steph" visits the page to edit her shows
  Then the page displays a form with "Add" text
  And the page displays "Shows"
  And the page displays "Availability"

Scenario: Creating a new list of shows
  When any user visits the create new schedule page
  Then a blank list of shows is displayed

  Scenario: Adding a show to the watch list
    Given there is an existing user "sam"
    And the user "sam" is on their shows and schedule page
    When the user searches for and adds "Silo"
    And the user "sam" visits the page to edit her shows
    Then the show "Silo" appears in the "Watch List"
    And the runtime "50 min" is displayed for "Silo"
    And the show "Silo" displays its poster art

  Scenario: Reordering the watch list
    Given the user "sam" has "Silo" and "Foundation" in their list
    And the user "sam" is on their shows and schedule page
    When the user drags "Foundation" above "Silo"
    Then "Foundation" is the first show in the list
    When the user "sam" visits the page to edit her shows
    Then "Foundation" is the first show in the list

  Scenario: Configuring daily availability
    Given the user "sam" is on their shows and schedule page
    When the user sets the available time for "Monday" to "60" minutes
    And the user sets "Tuesday" as "Unavailable"
    Then the Monday schedule should show "60 min"
    And the Tuesday schedule should show "0 min" or "No TV tonight"
