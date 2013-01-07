require 'hound'
require 'tempfile'
class Jobman
@@timewait = 10

	def main_loop
		while true
			sleep @@timewait
			puts "Checking jobs..."
			incomplete = Hound.get_unstarted_jobs
			if incomplete.size > 0
				puts "Awaiting completion"
				
				incomplete.each do | entry |
				m =  Hound.directquery("select machine_ip from `AUTOMATION`.`machines` where machine_id=#{entry['machines_machine_id']}")

					puts "JOB------------"
					puts "Job id #{entry['id']}"
					puts "Machine IP #{entry['machines_machine_id']}"
					
					#This is because the result is returned to us as an array of hashes..
					puts m.first["machine_ip"]

					puts "Command #{entry['command']}"
					puts "---------------"
					tmp = Tempfile.new("#{entry['id']}")
					tmp << "#{entry['command']}"
					tmp.close
				#lets feed this information to our satellite

					puts request = "satellite -m SEND -h #{m.first['machine_ip']} -p 9099 -i #{tmp.path} -j #{entry['id']}"
					system request
					
					#Lets now update the job progress 
					Hound.set_job_progress(entry['id'])
				end
			end
			
		end
	end
	def initialize
		self.main_loop
	end
end

