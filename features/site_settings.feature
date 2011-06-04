Feature: configurable site settings

  The administrator should be able to configure the site settings such as organization name,
  formats, credentials for outside services such as email and sms, etc.

  Scenario: View the site settings
    Given that I am signed in as an administrator
    When I click on "Settings"
    Then I should see "Site Settings"

  Scenario: View the site settings
    Given that I am signed in as an administrator
    When I click on "Settings"
    And I fill in "Sendgrid password" with "secret"
    And I fill in "Sendgrid user name" with "Some User"
    And I click on "Save"
    Then I should see "Settings saved"
    And the "Sendgrid user name" field should contain "Some User"
   
