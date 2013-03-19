Given(/^the unconnected device "(.*?)"$/) do |tag|
  step "the tag \"#{tag}\""
  step 'the model "unconnected"'
  step 'the serial number "123456789"'
  step 'the manufacturer "Apple"'
  step 'the device type "phone"'
  step 'the os is "ios"'
  step 'I register the new device'
end

Given(/^I am looking at "(.*?)" machine$/) do |name|
  visit "/"
  click_on "View machines"

  
  
end

When(/^I connect the "(.*?)" device to the "(.*?)" machine$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then(/^I should see "(.*?)" device in my list of connected devices$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end