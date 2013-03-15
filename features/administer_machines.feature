Feature: Administer machines
	
 Background: 
 	Given I am on logged in as admin	
 
 Scenario: add a new machine 
  When I add a new machine called "iceman"
  Then the machine "iceman" should appear in the list of available machine
 
 Scenario: delete a new machine
    And I have an existing machine called "hollywood"
  When I delete the machine "hollywood"
  Then the machine "hollywood" should not appear in the list of available machine



  
