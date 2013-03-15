Given(/^I am on the automation stack frontend$/) do
  visit "/"
end

Given(/^I am on the contact page$/) do
  click_on 'Contact'
end

Given(/^a subject$/) do
  @subject = "subject"
end

Given(/^a description$/) do
  @description = "description"
end

Given(/^a low priority$/) do
  @priority = "low"
end

When(/^I send the contact request$/) do
  fill_in "subject" ,:with => @subject 
  fill_in "description" ,:with => @description 
  select('low', :from => 'priority')
  click_on 'Send'
end

Then(/^I should see confirmation that the message has been sent$/) do
	 raise "ooops! did not find the confirmation message" unless page.has_content?("thank you! your request has been sent") 
end
