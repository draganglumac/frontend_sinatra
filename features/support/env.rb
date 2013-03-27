require "pry"

$: << File.expand_path("../../../src",__FILE__) 


require "sequel"
require "capybara/cucumber"
require "model"

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end	

Capybara.run_server = false
Capybara.app_host = 'http://localhost:9292'






