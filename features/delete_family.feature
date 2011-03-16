Feature: Deleting a family from the list

  Scenario: I am not signed in as an admin but try to delete a family
    Given a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in
    And I am viewing the family list
    Then I should not see "Delete" 
    
  Scenario: I am signed in as an admin and try to delete a family
    Given a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in as an administrator
    And I am viewing the family list
    When I click on "Delete"
    Then the list should not show the family     
