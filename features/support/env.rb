ENV['RACK_ENV'] = 'test'

require_relative "../../server.rb"

require 'capybara'
require 'capybara/cucumber'
require 'wrong'

Capybara.app = Sinatra::Application

World do
  include Capybara::DSL
end