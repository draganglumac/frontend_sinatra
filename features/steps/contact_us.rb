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
    
    log=File.read(Beacon::LOG_FILE)
    
    Beacon.new().emails.each do |email|
      raise "could not find #{email}" unless log.include? email
    end
    
  end
  
  step 'I should see confirmation that the message has been sent' do
    page.has_text? "thank you! your request has been sent"
  end

  step 'I am on the automation stack frontend' do
    visit '/'
  end

  step 'I am on the contact page' do
    visit '/contact'
  end                                       
end