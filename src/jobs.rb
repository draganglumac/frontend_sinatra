module Jobs
	module Routes
		helpers do
			def validate(params)
				errors = {}
				[:machine_id, :lname, :ltrigger].each do |key|
					(params[key] || "").strip
				end

				if params[:file_source].nil?
					errors[:file_source] = "Configuration file is required."
				end 
				errors[:machine_id] = "Selected machine is required." if params[:machine_id].empty?
				errors[:lname] = "Job name is required." if params[:lname].empty?
				errors[:ltrigger] = "Trigger time is required." if params[:ltrigger].empty?

				errors
			end
		end

		#new job page
		get '/job' do
			@errors    = {}
			@machines  = AutomationStack::Infrastructure::Machine.all
			@devices = AutomationStack::Infrastructure::Device.all
			@jobs_done = Hound.get_jobs
			erb :jobs
		end

		#Posting new jobs

		post '/job/restart/:jobnum' do
			Hound.set_job_restart(params[:jobnum])
			redirect back
		end

		post '/job/recursion/disable/:id' do
			Hound.disable_recursion(params[:id])
			redirect back
		end
		post '/job/recursion/enable/:id' do
			Hound.enable_recursion(params[:id])
			redirect back
		end
		get '/job/:id/delete' do
			job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
			job.delete
			redirect back
		end
		post '/job/:id/delete' do
			job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
			job.delete
			redirect '/job'
		end

		post '/job' do

			params.keys.each do | pline |
				if pline.include? "SELECTED_DEVICE"
					current_device = pline.split("=").last
					puts "Current device #{current_device}"
					machine = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => current_device)
					machine = machine.first[:machine_id]
					puts "Device machine is #{machine}"
					#We have our current device, so lets build a job for each device
					####
					####
					#
					tempfile = params[:file_source][:tempfile]	
					filename = params[:file_source][:filename]
					string = File.open(tempfile.path,'rb') { |file|file.read}
					trigger = params[:ltrigger] 
					trigger << ".000000"
					trigger = Time.parse(trigger).to_i
					recursion=0
					if params[:is_private] == "0"
						recursion=0
					else
						recursion=1
					end
					Hound.add_job(machine,params[:lname],string,trigger,recursion)
				end
			end			
=begin
				tempfile = params[:file_source][:tempfile] 
				filename = params[:file_source][:filename] 
				string = File.open(tempfile.path, 'rb') { |file| file.read }
				#######Parse the string and replace 

				if string.include?("$PAD_ENDPOINT")
					ip_addr = "UNKNOWN"
					ip_addr = Hound.get_device_ip_from_type_and_machine(2,params[:machine_id]).first
					puts "PAD ENDPOINT #{ip_addr['ip']}"
					string.gsub!("$PAD_ENDPOINT",ip_addr['ip'])
				end
				if string.include?("$PHONE_ENDPOINT")
					ip_addr = "UNKNOWN"
					ip_addr = Hound.get_device_ip_from_type_and_machine(1,params[:machine_id]).first
					puts "PHONE ENDPOINT #{ip_addr['ip']}"
					string.gsub!("$PHONE_ENDPOINT","#{ip_addr['ip']}")
				end

				if string.include?("$PHONE_SERIAL")
					serial = "NULL"
					serial = Hound.get_device_serial_from_type_and_machine(1,params[:machine_id])
					puts "PHONE SERIAL #{serial.first['serial_number']}"
					string.gsub!("$PHONE_SERIAL", "#{serial.first['serial_number']}")
				end

				if string.include?("$PAD_SERIAL")
					serial = "NULL"
					serial = Hound.get_device_serial_from_type_and_machine(2,params[:machine_id])
					puts "PAD SERIAL #{serial.first['serial_number']}"
					string.gsub!("$PAD_SERIAL", "#{serial.first['serial_number']}")
				end
				#######
				recursion=0
				if params[:is_private] == "0"
					puts "NO RECURSION SET, SINGLE RUN MODE" if development?
					recursion=0
				else
					puts "RECURSION HAS BEEN SET, RECURSIVE MODE" if development?
					recursion=1
				end
				machine_num = params[:machine_id]
				trigger = params[:ltrigger] 
				trigger << ".000000"
				trigger = Time.parse(trigger).to_i

				Hound.add_job(machine_num,params[:lname],string,trigger,recursion)

				#redirect '/job'
=end	
redirect '/dashboard'
		end
	end
end
