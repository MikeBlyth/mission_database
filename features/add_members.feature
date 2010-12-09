Feature: Member generates unique "indexed" name

  
  Scenario Outline: Generate indexed name 
    When I enter names "<last_name>" , "<first_name>", "<middle_name>", and "<short_name>"
    Then the new indexed name should be "<name>"
   
  Scenarios: Put some description here, add more scenarios
    |last_name|first_name|middle_name|short_name|name|
    |Cooper   |Donald    |John       |Jack      | Cooper, Donald J.   | 
    |Cooper   |Jordan    |Franklin   |          | Cooper, Jordan F.          | 
    |Cooper   |Samuel    |           |Samuel    | Cooper, Samuel             | 
    |Cooper   |K.        |Quilton    |Jack      | Cooper, K. Q.       |

  Scenario: Model should reject duplicate name
    Given an existing member with a name "Baggins, Frodo"
    When I make a new member with name "Baggins, Frodo"
    Then the record will not be valid
    And it will show a duplication error
      
