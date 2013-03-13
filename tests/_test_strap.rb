$: << "src"

require 'simplecov'
SimpleCov.start

ENV['RACK_ENV'] == :test

require "rubygems"
require "riot"  
require "riot-rack"


require "logger"
require "pony"
require "pry"
require "configatron"
require "sinatra"
require "sequel"

require "mysql"
require_relative "./seed"



Pony.options = {
  :via => :smtp,
  :via_options => {
    :address => '127.0.0.1',
    :port => '1025'
  }
}

require_relative "../src/beacon"
require_relative "../src/sessions"