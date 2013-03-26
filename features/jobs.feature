Feature: Jobs
  
Background: 
 	Given I am on logged in as admin
 	 And I am viewing the current list of jobs
 	 
Scenario: Add a new job
  Given I want to create a job called "the italian"
   And I want it to run on the machine "goose"
   And I have a valid conf file in "example.conf"
   And I want the job to start 2 minutes from now
   And I do not want it reoccur
  When I submit a new Job
  Then I should see "the italian" in the list of current jobs

Scenario: delete a job
  Given the existing job "unwanted"
  When I delete the job "unwanted"
  Then I should not see the "unwanted" in the list of current jobs





  
 
 
