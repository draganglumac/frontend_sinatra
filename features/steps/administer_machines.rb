class Spinach::Features::AdministerMachines < Spinach::FeatureSteps
  step 'I am on the admin page' do
    page.driver.browser.authorize("dummy","dummy")
    visit "/admin"
    
  end
 
  step 'I add a new machine' do
    @maverick = add_machine "maverick"              
  end
  step 'I have an existing machine' do
    @unwnted_machine =  add_machine "unwanted_machine"
  end
 
  step 'the machine should appear in the list of available machine' do
   has_content? @maverick 
   #clean up
   
  end                
  
  step 'I delete the machine' do        
    remove_machine(@unwanted_machine)
  end
  
  
  step 'the machine should not appear in the list of available machine' do
    !has_content? @unwnted_machine
  end
  
  def remove_machine(name)
    find("#" + @unwnted_machine).click 
  end
  def add_machine(name)               
    name = "#{name}#{(1000..10000).to_a.sample}"
    fill_in 'call_sign', :with => name
    fill_in 'ip_address', :with => '127.0.0.1'
    select 'ios', :from => 'platform_id'
    click_button 'Add Machine'    
    name
  end
end             
