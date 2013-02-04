ENV['RACK_ENV'] = 'test'  
require 'sinatra'      
require 'capybara'
require 'spinach/capybara' 

require_relative '../../server'

Spinach::FeatureSteps.send(:include, Spinach::FeatureSteps::Capybara)
Capybara.app = Sinatra::Application



