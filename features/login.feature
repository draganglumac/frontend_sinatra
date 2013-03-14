Feature: Login
    As an administrator
    I want to login to the website to gain control
    So that I can remove a machine

    Scenario: Administrator attempts to login
        Given I am on the "Home" screen
        When I press login
        Then I am authenticated

