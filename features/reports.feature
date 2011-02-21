Feature: report generation

  The user should be able to access all the reports


  Scenario: Generate birthday report
    Given that I am signed in
    And I click on "Reports"
    When I click on "Birthday list" 
    Then I should get a "Birthday" PDF report

  Scenario: Generate birthday calendar
    Given that I am signed in
    And I click on "Reports"
    When I click on "Birthday calendar" 
    Then I should get a "March" PDF report

  Scenario: Generate bloodtype reports
    Given that I am signed in
    And I click on "Reports"
    When I click on "Blood types" 
    Then I should get a "Blood" PDF report

  
