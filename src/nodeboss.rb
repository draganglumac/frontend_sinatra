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
