$:.unshift(File.dirname(__FILE__))

require "server"
require "mailer"
require "pry-remote"
require "socket"
require "yaml"

config = YAML.load(File.read('conf/general.conf'))
if not config['email_results'].nil? and config['email_results']

  if config['front_end_port'].nil?
    raise 'You need to specify a front_end_port in conf/general.conf before emails can be processed.'
  end

  this_ip = nil
  Socket.ip_address_list.each do |addrinfo|
    ip = addrinfo.ip_address
    if ip.match('\.') and not ip.match('127\.0\.0\.1')
      this_ip = ip
      break
    end
  end

  m = Thread.new do
    puts 'Creating the thread'
    mailer = Mailer.new(this_ip, config['front_end_port'], config['smtp_server'])
    sleep(15)

    while (true)
      wakeup = Time.new.to_i + 60
      mailer.process
      sleep(wakeup - Time.new.to_i)
    end
  end
  m.abort_on_exception = true

end

run Sinatra::Application 
