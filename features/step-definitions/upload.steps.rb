Given(/^the front end is visible$/) do
  visit "/"
  find ".modal"
end

Given(/^there is no "(.*?)" folder$/) do |name|
  `rm -rf public/uploads/#{name}`
end

Given(/^the "(.*?)" job$/) do |job|
  @job = AutomationStack::Infrastructure::Job.find(:name => job)
end


Given(/^the results file "(.*?)"$/) do |file_name|
  @path_to_results_file ="#{Dir.pwd}/features/support/#{file_name}"
  @file_name = file_name
end

When(/^I upload the file$/) do
  `curl -X PUT -F result=#{@file_name}  http://localhost:9292/result/upload/#{@job.id}`
end


Then(/^I should see the "(.*?)" file "(.*?)" job directory$/) do |file_name, job_name|
  Dir.chdir("public/uploads") do
    raise "oooops ! #{job_name} do noes exist" unless Dir.exists? job_name

    Dir.chdir(job_name) do
      raise "oooops ! no time stamped files in the uploads directory"  unless Dir.entries(".").any? { |f| /\d*..*$/.match(f) }
    end
    
  end
end
