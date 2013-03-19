Feature: Connect devices

Background:
	Given I am on logged in as admin
	And I am viewing devices
	And the unconnected device "unconnected"
	And I have an existing machine called "hollywood"

Scenario: Connect a device to a machine
	Given I am looking at "hollywood" machine
	When I connect the "unconnected" device to the "hollywood" machine
	Then I should see "unconnected" device in my list of connected devices
  


  
