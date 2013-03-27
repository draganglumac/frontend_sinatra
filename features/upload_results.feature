@wip
Feature: Upload Results
  In order to communicate test sucess or failure
  As a the saterlite agent
  I want to be able to upload the test results
  
  Scenario: upload file
  	Given the "upload_test" job
     And the results file "cukes.html"
    When I upload the file 
    Then I should see the "cukes.html" file "upload_test" job directory

  
  
  
  
