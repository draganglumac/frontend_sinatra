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


Given(/^I have a valid conf file in "(.*?)"$/) do |file_name|
  @path_to_conf ="#{Dir.pwd}/features/support/#{file_name}"
end


Given(/^I want the job to start (\d+) minutes from now$/) do |minutes|
  #'dd/MM/yyyy hh:mm:ss'
  @trigger_time = (Time.now + (minutes.to_i * 60)).strftime("%d/%m/%Y %H:%M:%S")  
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
  
  find("#job_table")

  within("#job_table") do 
    job_name = all("tr")[2].all("td")[1].text
    raise "Oooops! could not find #{name} in the list of current jobs" unless job_name == name
  end
end

Then(/^the job should be on the correct machine$/) do
  within("#job_table") do 
    machine_id = all("tr")[2].all("td")[6].text
    raise "ooops ! not on correct machine" unless machine_id==1
  end
end


Given(/^the existing job "(.*?)"$/) do |name|
   step "I want to create a job called \"#{name}\""
   step "I want it to run on the machine \"goose\""
   step "I have a valid conf file in \"example.conf\""
   step "I want the job to start 2 minutes from now"
   step "I do not want it reoccur"
   step "I submit a new Job"
end

When(/^I delete the job$/) do

  find("#job_table")
  
  within("#job_table") do 
     all("tr")[2].all("td")[10].all("button").first.click
  end


end

Then(/^I should not see the "(.*?)" in the list of current jobs$/) do |name|
  raise "Ooooops #{name} job was not deleted" if page.has_text? name
end

