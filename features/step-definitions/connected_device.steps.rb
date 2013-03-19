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

  within("#machine_table") do
    all("a").find{|a|a["text"]==name}.click
  end

end

When(/^I connect the "(.*?)" device to the "(.*?)" machine$/) do |device,call_sign|
  select device, :from => 'device_id'
  click_button "Register Device"
end

Then(/^I should see "(.*?)" device in my list of connected devices$/) do |name|
  raise "Ooooops #{name} is not be connected" unless page.has_text? name 
end