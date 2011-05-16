Feature: Administrative functions

  The administrator should have working links to the main functions

  Scenario: Administrator links are present
    Given that I am signed in as an administrator
    When I visit the home page
    Then I should see "Clean database"
    And I should see "amily summaries"
    And I should see "ravel reminders"
    And I should see "Users"
    
  Scenario: For non-administrator, admin links are not shown
    Given that I am signed in 
    When I visit the home page
    Then I should not see "Clean database"
    And I should not see "amily summaries"
    And I should not see "ravel reminders"
    And I should not see "Users"
    
  Scenario: The clean database link works
    Given that I am signed in as an administrator
    When I visit the home page
    And I click on "Clean database"
    Then the page title should be "Clean database"

  Scenario: The family summaries link works
    Given that I am signed in as an administrator
    When I visit the home page
    And I click on "amily summaries"
    Then the page title should be "Family data summaries"
    
  Scenario: The send family summaries works
    Given that I am signed in as an administrator
    And a one-person family
    And a contact record
    When I go to the family summaries page
    And I click on "Send"
    Then I should be on the families page
    And there should be 1 family summary email

  Scenario: The travel reminder link works
    Given that I am signed in as an administrator
    When I visit the home page
    And I click on "ravel reminders"
    Then the page title should be "Travel reminders"
    
  Scenario: The send family summaries works
    Given that I am signed in as an administrator
    And a one-person family
    And a contact record
    And a travel record
    When I go to the travel reminders page
    And I click on "Send"
    Then I should be on the travels page
    And there should be 1 travel reminder email

