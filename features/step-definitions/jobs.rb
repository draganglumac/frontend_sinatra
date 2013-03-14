# encoding: utf-8

Given(/^I am on the "New Job" screen$/) do
  visit '/'
  click_button 'New Job »'
end

When(/^I attempt to add a new job without a job name$/) do
  select('maverick', :from => 'machine_id')
  click_on 'submit'
end

Then(/^the job is not added to the queue$/) do
  # This is not a proper assertion. I just using as an example What I would expect is a pop up with an error
   #NOT COMPLETE
    pending
end
