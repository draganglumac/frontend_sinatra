require_relative 'hound'
require 'tempfile'
require 'yaml'

class Jobman

	def initialize
		begin
			config = YAML.load_file("conf/general.conf")

			@timewait = config['timewait'] && 10
			@satellite_port = config['satellite_port'] && 9099
		rescue
			@timewait = 10
			@satellite_port = 9099
		end

		print "@timewait = #{@timewait}, @satellite_port = #{@satellite_port}"
	end

	def main_loop
		while true
			sleep @timewait
			#puts "Checking jobs..."
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
				puts request = "satellite -m SEND -h #{m.first['machine_ip']} -p #{@satellite_port} -i #{tmp.path} -j #{entry['id']}"
				system request
				#Lets now update the job progress 
				Hound.set_job_progress(entry['id'])
				end
			end

		end
	end

end
