Feature: report generation

  The user should be able to access all the reports

  Scenario: Generate birthday report
    Given that I am signed in
    And I click on "Reports"
    When I click on "Birthday list" 
    Then I should get a "Birthday" PDF report

  @calendar
  Scenario: Generate birthday calendar
    Given that I am signed in
    And basic statuses
    And a one-person family
    And "John" has a birthday
    And "Mary" is traveling 
    When I click on "Reports"
    And I check "Birthdays" 
    And I uncheck "Travel"
    And I click on "Generate"
    Then I should get a "{next month}" PDF report
    And the report should include "John"
    And the report should not include "Mary"

  @calendar
  Scenario: Generate travel calendar
    Given that I am signed in
    And basic statuses
    And a one-person family
    And "John" has a birthday
    And "Mary" is traveling 
    When I click on "Reports"
    And I uncheck "Birthdays" 
    And I check "Travel"
    And I click on "Generate"
    Then I should get a "{next month}" PDF report
    And the report should not include "John"
    And the report should include "Mary"

  @calendar
  Scenario: Generate combined calendar
    Given that I am signed in
    And basic statuses
    And a one-person family
    And "John" has a birthday
    And "Mary" is traveling 
    When I click on "Reports"
    And I check "Birthdays" 
    And I check "Travel"
    And I click on "Generate"
    Then I should get a "{next month}" PDF report
    And the report should include "John"
    And the report should include "Mary"

  Scenario: Generate bloodtype reports
    Given that I am signed in
    And basic statuses
    And a one-person family
    And a blood type "AB+"
    And a blood type "unspecified"
    And a member "John" with bloodtype "AB+" and status "On field"
    And a member "Homebody" with bloodtype "AB+" and status "Home assignment"
    And a member "UnknownType" with bloodtype "unspecified" and status "On field"
    And I click on "Reports"
    When I click on "Blood types" 
    Then I should get a "Blood" PDF report
    And the report should include "John" 
    And the report should not include "Homebody" 
    And the report should not include "UnknownType" 

  Scenario: Generate phone list reports
    Given that I am signed in
    And a family with a "Wifey" and "ChildA" and "ChildB"
    And a contact record
    And I click on "Reports"
    When I click on "Phone and email" 
    Then I should get a "Phone" PDF report
    And the report should include the name, phone and email
    And the report should not include "ChildA"

  Scenario: Generate travel reports
    Given that I am signed in
    And a one-person family
    And a "travel" record
    And I click on "Reports"
    When I click on "Travel schedule" 
    Then I should get a "Travel" PDF report
    And the report should include the "travel" information

  @whereis
  Scenario: Generate where_is report
    Given that I am signed in
    And locations defined 
    And a one-person family
    And I click on "Reports"
    When I click on "Where is" 
    Then I should get a "Where Is" PDF report
    And the report should include the "Where Is" information
    

  
