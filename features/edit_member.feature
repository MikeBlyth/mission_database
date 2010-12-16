Feature: edit member view

  This covers the basic editing form for members

  Scenario: Getting an editing form with expected values
    Given a family with a spouse
    When I edit the family head
    Then I should see the editing form for the family head

