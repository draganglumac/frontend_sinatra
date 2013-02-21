Feature: Administer machines

 Scenario: add a new machine
  Given I am on the admin page
  When I add a new machine
  Then the machine should appear in the list of available machine
 
 Scenario: delete a new machine
  Given I am on the admin page
    And I have an existing machine
  When I delete the machine
  Then the machine should not appear in the list of available machine



  
