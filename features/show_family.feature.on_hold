Feature: family members view

  This simple view shows family members

  Scenario: View shows link to add spouse
    Given a family without a spouse
    When I view the family
    Then I see a link to add a spouse   
    
  Scenario: View shows link to add spouse
    Given a family with a spouse
    When I view the family
    Then I do not see a link to add a spouse   
    
  Scenario Outline: View shows head, spouse and children
    Given a family with a "<spouse>" and "<first_child>" and "<second_child>"
    When I view the family
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
 

    
