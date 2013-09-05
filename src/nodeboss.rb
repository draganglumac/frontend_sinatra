require 'socket'

class NodeBoss
	attr_accessor :transaction_api
	def initialize()
		@transaction_api="[{CMD`%s}{ID`%s}{DATA`%s}{OTHER`%s}{SENDER`%s}{PORT`%s}]"
	end
	def format_instruction(cmd,id,data,other,sender,port)
		new_string = transaction_api % [cmd,id,data,other,sender,port]
		return new_string
	end
	def send_instruction(hostip, hostport,command)
		puts "Boss: #{hostip} #{hostport} - #{command}"
		t = TCPSocket.new(hostip,hostport)
		t.write(command)
		t.close
	end	
	def machine_reboot(hostip,hostport)
	    send_instruction(hostip,hostport,format_instruction("SYSTEM","","sudo reboot","","",""))
	end

  def kill_job_on_machine(job, machine)
    send_instruction(machine.ip, machine.port, format_instruction("KILL", job.id, machine.ip, machine.port, "", ""))
  end
end

dash_c = false
dash_h = false
dash_p = false

command = nil
host = nil
port = nil

ARGV.each do |opt|
  puts "opt = #{opt}"

  if opt == '-c'
    dash_c = true
    next
  end

  if opt == '-h'
    dash_h = true
    next
  end

  if opt == '-p'
    dash_p = true
    next
  end

  if dash_c
    command = opt
    dash_c = false
    next
  end

  if dash_h
    host = opt
    dash_h = false
    next
  end

  if dash_p
    port = opt
    dash_p = false
    next
  end
end

not_all_params = host.nil? or port.nil? or command.nil?

if not_all_params
  puts "Usage\n\tnodeboss.rb -h host -p port -c \"command\""
else
  puts "Sending #{command} to the node..."
  nb = NodeBoss.new
  nb.send_instruction(host, port, command)
  puts "Command sent."
end
