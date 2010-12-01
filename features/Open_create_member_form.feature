Feature: user opens create member form

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
  
  Scenario: open create member form
    Given that the main menu is present
    When I select "Create member"
    Then I should see the create member form
    