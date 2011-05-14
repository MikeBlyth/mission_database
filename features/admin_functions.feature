Feature: Administrative functions

  The administrator should have working links to the main functions

  Scenario: Administrator links are present
    Given that I am signed in as an administrator
    When I visit the home page
    Then I should see "Clean database"
    And I should see "Send family summaries"
    And I should see "Users"
    
  Scenario: For non-administrator, admin links are not shown
    Given that I am signed in 
    When I visit the home page
    Then I should not see "Clean database"
    And I should not see "Send family summaries"
    And I should not see "Users"
    
  Scenario: The clean database link works
    Given that I am signed in as an administrator
    When I visit the home page
    And I click on "Clean database"
    Then the page title should be "Clean database"

  Scenario: The family summaries link works
    Given that I am signed in as an administrator
    When I visit the home page
    And I click on "Send family summaries"
    Then the page title should be "Family data summaries"

