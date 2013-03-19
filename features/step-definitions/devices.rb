
Given(/^I am viewing devices$/) do
  visit("/")
  click_button "View Devices"
end

Given(/^the tag "(.*?)"$/) do |tag|
  @tag = tag
end

Given(/^the model "(.*?)"$/) do |model|
  @model = model
end

Given(/^the serial number "(.*?)"$/) do |serial_number|
  @serial_number = serial_number
end

Given(/^the manufacturer "(.*?)"$/) do |manufacturer|
  @manufacturer = manufacturer.downcase
end

Given(/^the device type "(.*?)"$/) do |device_type|
  @device_type = device_type
end

Given(/^the os is "(.*?)"$/) do |os|
  @os = os
end

When(/^I register the new device$/) do
  click_on "add-new-device"
  
  fill_in "device[tag]",:with => @tag 
  fill_in "device[name]",:with => @model 
  fill_in "device[serial_number]",:with => @serial_number
  
  select @manufacturer, :from => "device[manufacturer_id]"
  select @device_type, :from => "device[device_type_id]"
  select @os, :from => "device[platform_id]"

  click_button "Register Device"
end

Then(/^I should see the "(.*?)" on the list of registered devices$/) do |tag|
  raise "Ooops could not find the #{tag}" unless page.has_text? tag
end

Given(/^the unwanted device "(.*?)"$/) do |tag|
  step "the tag \"#{tag}\""
  step 'the model "Iphone 5s"'
  step 'the serial number "123456789"'
  step 'the manufacturer "Apple"'
  step 'the device type "phone"'
  step 'the os is "ios"'
  step 'I register the new device'
end

When(/^I delete the unwanted device "(.*?)"$/) do |tag|
  all(".delete").find{|btn|btn["data-id"] == tag}.click
end

Then(/^I should not see "(.*?)" on the list of registered devices$/) do |tag|
  raise "Oooops ! failed to delete #{tag}" if page.has_text? tag
end
