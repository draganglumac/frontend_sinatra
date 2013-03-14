Given(/^I am on logged in as admin$/) do
  
  click_on 'logoff'
  click_on 'login'
  fill_in 'username', :with => 'alex.jones'
  fill_in 'password', :with => 'sky'
  click_on 'Login'
end

When(/^I add a new machine$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the machine should appear in the list of available machine$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I am on the admin page$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^I have an existing machine$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I delete the machine$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the machine should not appear in the list of available machine$/) do
  pending # express the regexp above with the code you wish you had
end
