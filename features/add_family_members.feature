Feature: add family members

  The person entering members to the database
  Wants an easy way to enter entire families
  
  When editing or viewing a family, we should be able to easily
  add a spouse and children without having to enter a lot of data
  that will automatically be constrained (last name, status, etc.)

  Scenario: Set up and list family
    Given a one-person family
    When I view the family list
    Then I should see the family members

#  Scenario: Set up and list family
#    Given a family
#    When I view the family list
#    Then I should see the family members
#@wip
#  Scenario: Get a form for editing a spouse
#    Given a family view
#    When I ask to create a spouse
#    Then I receive a valid form for a spouse
#@wip
#  Scenario: Get a form for editing a child
#    Given a family view
#    When I ask to create a child
#    Then I receive a valid form for a child
#  @wip
#  Scenario Outline: New members should be linked to families
#    Given a single family record existing with ID=100
#    When I add a member ID=101 with "<family_id>" and "<head>"
#    Then the member's family_id will be "<new_fam_id>"
#    And the "<new_fam_id>" family record will exist
#  @wip    
#  Scenarios: no pre-existing family record
#    | family_id |  head  |  new_fam_id |
#   |           |  false |   101       |
#    |           |  true  |   101       |
#    | 101       |  false |   101       |
#    | 101       |  true  |   101       |
#  @wip      
#  Scenarios: family record does exist for the new member
#    | family_id |  head  |  new_fam_id |
#    | 100       |  false |   100       |
#    | 100       |  true  |   101  |

   
