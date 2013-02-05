require 'pry'               

class Spinach::Features::ContactUs < Spinach::FeatureSteps
  step 'a subject' do
    @subject = "subject"
  end

  step 'a description' do
    @description = "description"
  end

  step 'a low priority' do
    @priority = "low"
  end

  step 'I send the contact request' do   
   
    fill_in 'subject', :with => @subject
    fill_in 'description', :with => @description
    select('low', :from => 'priority')
    
    click_on 'Send'
    
  end

  step 'the messages should be sent to the list of Administrators' do
    
    log=File.read("features/ui.log")
    
    ["delaney.burke@bsky.com","alex.jones@bskyb.com"].each do |email|
      raise "could not find #{email}" unless log.include? email
    end
    
  end

  step 'the priority should be in the subject of the mail' do
    pending 'step not implemented'
  end

  step 'I should see confirmation that the message has been sent' do
    pending 'step not implemented'
  end

  step 'I am on the automation stack frontend' do
    visit '/'
  end

  step 'I am on the contact page' do
    visit '/contact'
  end                                       
end