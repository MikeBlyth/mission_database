Feature: family list view

  This simple view shows families and all their members

  Scenario: Create family
    Given a family with a spouse
    Then the family includes the head and spouse

  Scenario Outline: View shows head, spouse and children
    Given a family with a "<spouse>" and "<first_child>" and "<second_child>"
    And that I am signed in
    When I view the list of families
    Then I see the head of family
    And I see the "<spouse>"
    And I see the "<first_child>"
    And I see the "<second_child>"
  
  Scenarios: no spouse or children  
    | spouse | first_child  |  second_child |
    |  --nil--   |  --nil--   | --nil-- |

  Scenarios: one spouse, no children
    | spouse | first_child  |  second_child |
    | Donna  |   --nil--   | --nil-- |

  Scenarios: spouse and child
    | spouse | first_child  |  second_child |
    | Donna  |   Maxwell    |   --nil--   | 

  Scenarios: spouse and two children
    | spouse | first_child  |  second_child |
    | Donna  |   Maxwell    | Gwendolyn |

  Scenarios: no spouse and two children
    |  spouse | first_child  |  second_child |
    | --nil-- |   Maxwell    | Gwendolyn |

  Scenario: View shows list of first names
    Given a family with a "Wife" and "Big Kid" and "Baby"
    And that I am signed in
    When I view the list of families
    Then I see the "Wife, Big Kid, Baby"
 

    
