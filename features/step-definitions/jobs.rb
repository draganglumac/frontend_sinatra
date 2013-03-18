# encoding: utf-8
Given(/^I am viewing the current list of jobs$/) do
  visit("/")
  click_button "New Job »"
end

Given(/^I want to create a job called "(.*?)"$/) do |name|
  @name_of_job = name
end


Given(/^I want it to run on the machine "(.*?)"$/) do |machine|
  @machine_name = machine
end

Given(/^I have a valid conf file$/) do
  @path_to_conf = "/Users/cococoder/Desktop/sky/automation_stack/ui/features/example.conf"
end

Given(/^I want the job to start (\d+) minutes from now$/) do |minutes|
  @trigger_time = Time.now + (minutes.to_i * 60)
end

Given(/^I do not want it reoccur$/) do
  click_button 'Single'
end

When(/^I submit a new Job$/) do
 attach_file("lfile", @path_to_conf)
 select @machine_name, :from => 'machine_id'
 fill_in 'lname', :with => @name_of_job
 fill_in 'ltrigger', :with => @trigger_time
 click_button 'Single'
 click_button 'submit'
end

Then(/^I should see "(.*?)" in the list of current jobs$/) do |name|
  page.has_text? name
end

