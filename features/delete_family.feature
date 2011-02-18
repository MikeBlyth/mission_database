Feature: Deleting a family from the list

  Scenario: I am not signed in as an admin but try to delete a family
    Given a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in
    And I am viewing the family list
    When I select the delete link
    Then I should see an error message
    And the family should still be present

