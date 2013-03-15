Feature: Administer machines

 Scenario: add a new machine
  Given I am on logged in as admin
  When I add a new machine called "iceman"
  Then the machine should appear in the list of available machine
 
 Scenario: delete a new machine
  Given I am on logged in as admin
    And I have an existing machine
  When I delete the machine
  Then the machine should not appear in the list of available machine



  
