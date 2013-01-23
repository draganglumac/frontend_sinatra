$:.unshift(File.dirname(__FILE__))
require "server"

Thread.new{
  Jobman.new.main_loop
}

run Sinatra::Application