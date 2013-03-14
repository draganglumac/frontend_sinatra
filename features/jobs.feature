Feature: Jobs
  As a Test Manager
  I want to add a job into the system
  So that I can automate my testing

Scenario: User attempts to create a new job without a job name
  Given I am on the "New Job" screen
  When I attempt to add a new job without a job name
  Then the job is not added to the queue
  
 
 
