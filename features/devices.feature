Feature: Devices

 Background: 
 	Given I am on logged in as admin
 	 And I am viewing devices
 
 Scenario: register an iphone device
  Given the tag "a003"
   And the model "Iphone 5s"
   And the serial number "123456789"
   And the manufacturer "Apple"
   And the device type "phone"
   And the os is "ios"
  When I register the new device
  Then I should see the "a003" on the list of registered devices

 Scenario: register an ipad device
  Given the tag "a004"
   And the model "Ipad 5"
   And the serial number "123456789"
   And the manufacturer "Apple"
   And the device type "tablet"
   And the os is "ios"
  When I register the new device
  Then I should see the "a004" on the list of registered devices
 
 Scenario: register an adroid phone device
  Given the tag "SM001"
   And the model "Galaxy S4"
   And the serial number "hb99x1223"
   And the manufacturer "Samsung"
   And the device type "phone"
   And the os is "android"
  When I register the new device
  Then I should see the "SM001" on the list of registered devices
 
 Scenario: register an adroid tablet device
  Given the tag "SM002"
   And the model "Galaxy S4 tablet"
   And the serial number "hb99x1223s"
   And the manufacturer "Samsung"
   And the device type "tablet"
   And the os is "android"
  When I register the new device
  Then I should see the "SM002" on the list of registered devices

Scenario: delete an iphone device
  Given the unwanted device "SM00UNWANTED"
  When I delete the unwanted device "SM00UNWANTED"
  Then I should not see "SM00UNWANTED" on the list of registered devices
