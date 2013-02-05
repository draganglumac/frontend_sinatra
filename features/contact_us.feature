Feature: Contact us
  In order to to contact the automation stack team
  As a user
  I want to be able to contact the automation stack developers by email
  
  
  Background:
    Given I am on the automation stack frontend
     And I am on the contact page
     
  Scenario:A low priority contact request
    Given a subject
      And a description
      And a low priority
    When I send the contact request
    Then the messages should be sent to the list of Administrators
     And I should see confirmation that the message has been sent
          
     
     
  
  
  
  
