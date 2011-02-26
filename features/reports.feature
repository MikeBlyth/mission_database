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
    Then I should get a "{next month}" PDF report

  Scenario: Generate bloodtype reports
    Given that I am signed in
    And I click on "Reports"
    When I click on "Blood types" 
    Then I should get a "Blood" PDF report

  Scenario: Generate phone list reports
    Given that I am signed in
    And a one-person family
    And a contact record
    And I click on "Reports"
    When I click on "Phone and email" 
    Then I should get a "Phone" PDF report
    And the report should include the name, phone and email

  
