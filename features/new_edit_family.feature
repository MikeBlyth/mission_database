Feature: Forms for creating and updating families

  This covers the basic editing form for families

  @wipx
  Scenario: Getting a new family form with expected values
    Given that detail tables (like Countries) exist
    When I select "new family"
    Then I should see a valid form for a new family

  @wipx    
  Scenario: Getting an update family form with expected values
    Given that detail tables (like Countries) exist
    And a family with a "Wife" and "Big Kid" and "Baby"
    When I select "update family"
    Then I should see a valid form for updating a family
    
  @wipx
  Scenario: After creating new family, I should see form to update family head
    Given a form filled in for a new family
    When I press "Create"
    Then the database should contain the new family
    And I should see a form for editing the family head
    
  @wip
  Scenario: Customized form
    Given that detail tables (like Countries) exist
    When I select "new family"
    Then I should see a customized form for a new family

