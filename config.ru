$:.unshift(File.dirname(__FILE__))

require "server"
require "pry-remote"

run Sinatra::Application
