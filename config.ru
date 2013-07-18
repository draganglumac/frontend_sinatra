$:.unshift(File.dirname(__FILE__))

require "server"
require 'mailer'
require "pry-remote"

m = Thread.new do
  mailer = Mailer.new
  sleep(15)

  while (true)
    wakeup = Time.new.to_i + 60
    mailer.process
    sleep(wakeup - Time.new.to_i)
  end
end
m.abort_on_exception = true

run Sinatra::Application
