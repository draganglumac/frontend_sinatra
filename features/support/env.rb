ENV['RACK_ENV'] = 'test'  
require 'sinatra'      
require 'wrong'
require 'capybara'
require 'spinach/capybara'      
require 'pry'

require_relative '../../server'

Spinach::FeatureSteps.send(:include, Spinach::FeatureSteps::Capybara)  
Spinach::FeatureSteps.send(:include, Capybara::DSL)
Spinach::FeatureSteps.send(:include, Wrong)

Capybara.app = Sinatra::Application



