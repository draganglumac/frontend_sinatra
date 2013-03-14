# encoding: utf-8

Given(/^I am on the "Home" screen$/) do
    visit '/'
end

When(/^I press login$/)do
    click_on 'login'
    fill_in 'username', :with => 'alex.jones'
    fill_in 'password', :with => 'sky'
    click_on 'Login'
end

Then(/^I am authenticated$/)do

end
