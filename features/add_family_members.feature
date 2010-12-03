Feature: add family members

  The person entering members to the database
  Wants an easy way to enter entire families
  
  When editing or viewing a family, we should be able to easily
  add a spouse and children without having to enter a lot of data
  that will automatically be constrained (last name, status, etc.)


  Scenario: Get a form for editing a spouse
    Given a family view
    When I ask to create a spouse
    Then I receive a valid form for a spouse
    
  Scenario: Get a form for editing a child
    Given a family view
    When I ask to create a child
    Then I receive a valid form for a child
    
