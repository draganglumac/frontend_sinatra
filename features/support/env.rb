require "pry"

$: << File.expand_path("../../../src",__FILE__) 


require "sequel"
#require "capybara/cucumber"
require 'selenium-webdriver'
require "model"
require 'rspec-expectations'

#Capybara.default_driver = :selenium
#Capybara.register_driver :selenium do |app|
#  Capybara::Selenium::Driver.new(app, :browser => :firefox)
#end	
#
#Capybara.run_server = false
#Capybara.app_host = 'http://localhost:9292'

def navigate_to_url(url)
  @driver = Selenium::WebDriver.for :firefox
  @driver.navigate.to "http://localhost:9292#{url}"
end

def end_session
  @driver.quit
end
