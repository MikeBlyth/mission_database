Feature: Forms for creating and updating families

  This covers the tabbed editing form for families


  Scenario: Getting an update family form with expected values
    Given that detail tables (like Countries) exist
    And a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in as an administrator
    When I select "update family"
    Then I should see a valid tabbed form for updating a family

  Scenario: 
    Given that detail tables (like Countries) exist
    And a one-person family
    And that I am signed in as an administrator
    When I update family with errors
    Then I should see family update error messages
    
    

    
