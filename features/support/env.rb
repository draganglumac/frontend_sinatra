require "capybara/cucumber"
require "pry"
require "wrong"

Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

Capybara.run_server = false
Capybara.app_host = 'http://localhost:9292'


include Wrong



