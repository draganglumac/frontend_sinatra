class Spinach::Features::AdministerMachines < Spinach::FeatureSteps
  step 'I am on the admin page' do
    visit "/admin"
  end
 
  step 'I add a new machine' do 
   fill_in 'Machine callsign', :with => 'maverick'
   fill_in 'Machine IP', :with => '127.0.0.1'

   
   pending 'step not implemented'
  end
 
  step 'the machine should appear in the list of available machine' do
   pending 'step not implemented'
  end
end