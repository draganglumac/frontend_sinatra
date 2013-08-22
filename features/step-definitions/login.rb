# encoding: utf-8

Given(/^I am on the "Home" screen$/) do
    navigate_to_url('/')  
end

When(/^I press login$/)do
  sleep(2)
  login = @driver.find_element(:id, 'login')
  login.click

  sleep(2)
  username = @driver.find_element(:name, 'username')
  password = @driver.find_element(:name, 'password')
  submit = @driver.find_element(:id, 'sign_in_submit')

  username.send_keys "alex.jones"
  password.send_keys "sky"
  submit.click
end

Then(/^I am authenticated$/)do
  sleep(2)
  login = @driver.find_element(:id, 'login')
  text = login.text
  text.should include('Logout alex.jones')
  end_session
end
