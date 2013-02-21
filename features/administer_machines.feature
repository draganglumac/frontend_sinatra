Feature: Administer machines

Scenario: add a new machine
  Given I am on the admin page
  When I add a new machine
  Then the machine should appear in the list of available machine



  
