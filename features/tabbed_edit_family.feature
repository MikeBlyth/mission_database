Feature: Forms for creating and updating families

  This covers the tabbed editing form for families


  @pending
  Scenario: Getting a new family form with expected values
    Given that detail tables (like Countries) exist
    And that I am signed in as an administrator
    When I select "new family"
    Then I should see a valid form for a new family

  
  Scenario: Getting an update family form with expected values
    Given that detail tables (like Countries) exist
    And a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in as an administrator
    When I select "update family"
    Then I should see a valid tabbed form for updating a family

  @go
  Scenario: 
    Given that detail tables (like Countries) exist
    And a one-person family
    And that I am signed in as an administrator
    When I update family with errors
    Then I should see family update error messages
    
  @pending
  Scenario: I should not see a link to add a spouse when a spouse already exists
    Given that detail tables (like Countries) exist
    And a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in as an administrator
    When I select "update family"
    Then I should not see a button for adding a spouse
    

  @pending
  Scenario: I should get a form to add spouse from family edit form
    Given that I am signed in as an administrator
    And that I am updating a family
    When I click on "Add spouse"
    Then I should see a form titled "Add Spouse for"
    And the form should be pre-set to add a spouse

  @pending
  Scenario: I should be able to add child from family edit form
    Given that I am signed in as an administrator
    And that I am updating a family
    When I click on "Add child"
    Then I should see a form titled "Add Child for"
    And the form should be pre-set to add a child
    
  @pending
  Scenario: I should be able to add spouse 
    Given that I am signed in as an administrator
    And that I have a form to add a spouse
    When I input values for spouse
    And I click on "Create"
    Then the new member message should be shown

    
