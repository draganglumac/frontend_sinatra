class Spinach::Features::AdministerMachines < Spinach::FeatureSteps
  step 'I am on the admin page' do
    page.driver.browser.authorize("dummy","dummy")
    visit "/admin"
    
  end
 
  step 'I add a new machine' do              
   
   fill_in 'call_sign', :with => 'maverick'
   fill_in 'ip_address', :with => '127.0.0.1'
   select 'ios', :from => 'platform_id'
   
   click_button 'Add Machine'
   
  end
 
  step 'the machine should appear in the list of available machine' do
   has_content? "mavreick"
  end
end