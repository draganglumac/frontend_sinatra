# encoding: utf-8

Given(/^I am on the "Home" screen$/) do
    navigate_to_url('/')  
end

When(/^I press login$/)do
  @wait.until { @driver.find_element(:id, 'login') }
  login = @driver.find_element(:id, 'login')
  login.click

  @wait.until { @driver.find_element(:id, 'sign_in_submit') }

  username = @driver.find_element(:name, 'username')
  password = @driver.find_element(:name, 'password')

  username.send_keys "alex.jones"
  password.send_keys "sky"

  submit = @driver.find_element(:id, 'sign_in_submit')
  submit.click
end

Then(/^I am authenticated$/)do
  @wait.until { @driver.find_element(:id, 'login') }

  text = @driver.find_element(:id, 'login').text
  text.should include('Logout alex.jones')
  end_session
end
