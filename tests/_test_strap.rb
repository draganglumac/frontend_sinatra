ENV['RACK_ENV'] == "test"

require "riot"  
require "logger"
require "pony"
require "configatron"

Pony.options = {
  :via => :smtp,
  :via_options => {
    :address => '127.0.0.1',
    :port => '1025'
  }
}
require_relative "../src/beacon"