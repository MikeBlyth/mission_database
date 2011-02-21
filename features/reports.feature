Feature: report generation

  The user should be able to access all the reports


  Scenario: Generate birthday report
    Given that I am signed in
    And I click on "Reports"
    When I click on "Birthday list" 
    Then I should get a "Birthday list" PDF report

  
