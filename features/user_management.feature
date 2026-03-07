#  features/user_management.feature

Feature: User Management
  As a user like Structured Sam
  I want to create a new profile or select my existing one
  So that I can manage my curated TV schedule without friction

  Scenario: Root page lists existing users
    Given there are existing users "steph" and "justin"
    When any user visits the main page
    Then the page displays "steph"
    And the page displays "justin"
    And the page displays "Create a new schedule"

  Scenario: Creating a new user with a unique name
    Given any user visits the main page
    When the user enters "sam" in the "username" field
    And the user clicks the "Create" button
    Then the page displays "User 'sam' created successfully"

  Scenario: Creating a new user with an existing name
    Given there is an existing user "steph"
    And any user visits the main page
    When the user enters "steph" in the "username" field
    And the user clicks the "Create" button
    Then the page displays "Username 'steph' already exists. Please choose a different one."

  Scenario: Selecting an existing user
    Given there is an existing user "steph"
    When any user visits the main page
    And the user clicks on the name "steph"
    Then the page displays "Shows and Schedule for steph"
