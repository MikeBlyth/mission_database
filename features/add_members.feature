Feature: user adds member

  Personnel administrators need to add members over time.
  Adding them can be at different levels of completeness,
  from simple name and other essentials (birthdate?) all the
  way to entering every possible piece of data. Logic and
  error checking should include
  * A unique way to identify members; no duplicates.
  * Common-sense validation of dates
  * Checking for inconsistent attributes (e.g. a baby working)
  * Correctly cross-referencing spouses with each other and
    with children.
  
  Scenario Outline: create simplest member
    Given that the create member form is open
    When I enter "<last_name>" , "<first_name>", "<middle_name>", "<short_name>, and "<sex>"
    And I press the Create button
    Then the new member should be in the list
    And the name should be "<name>"
    
    |last_name|first_name|middle_name|short_name|sex|name|
    |Cooper   |Donald    |John       |Jack      | M | Cooper, Donald J. (Jack)   | 
    |Cooper   |Jordan    |Franklin   |          | M | Cooper, Jordan F.          | 
    |Cooper   |Samuel    |           |Samuel    | M | Cooper, Samuel             | 
    |Cooper   |K.        |Quilton    |Jack      | M | Cooper, K. Q. (Jack)       |
  
