Given(/^I am on logged in as admin$/) do
  


  visit "/" 
  
  click_on 'login'
  fill_in 'username', :with => 'alex.jones'
  fill_in 'password', :with => 'sky'
  click_on 'Login'
end


When(/^I add a new machine called "(.*?)"$/) do |call_sign|
  
  click_on "View machines"
  click_button 'Add new Machine'

  fill_in "call_sign",:with => call_sign
  fill_in "ip_address",:with => "ip_address"

  
  select('ios', :from => 'platform_id')
  


  click_button 'Add Machine'  
  
end


Then(/^the machine should appear in the list of available machine$/) do
  raise "cant find machine " unless page.has_content? "call_sign" 
end

Given(/^I have an existing machine$/) do
  @name_of_machine  = "call_sign"
end

When(/^I delete the machine$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the machine should not appear in the list of available machine$/) do
  pending # express the regexp above with the code you wish you had
end
