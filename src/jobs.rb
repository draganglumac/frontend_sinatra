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

		post '/job/:id/delete' do
			job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
			job.delete
			redirect '/job'
		end

		post '/job' do
			puts params if development?

			@errors = validate(params);

			if not @errors.empty?
				@machines  = AutomationStack::Infrastructure::Machine.all
				@jobs_done = Hound.get_jobs
				erb :jobs
			else
				puts params[:file_source][:filename] if development?

				tempfile = params[:file_source][:tempfile] 
				filename = params[:file_source][:filename] 
				string = File.open(tempfile.path, 'rb') { |file| file.read }
				#######Parse the string and replace 

				if string.include?("$IPAD_ENDPOINT")
					ip_addr = "not done"
					ip_addr = Hound.get_device_ip_from_type_and_machine(2,params[:machine_id]).first
					puts ip_addr['ip']
					string.gsub!("$IPAD_ENDPOINT",ip_addr['ip'])
				end
				if string.include?("$IPHONE_ENDPOINT")
					ip_addr = "UNKNOWN"
					ip_addr = Hound.get_device_ip_from_type_and_machine(1,params[:machine_id]).first
					puts ip_addr['ip']
					string.gsub!("$IPHONE_ENDPOINT","#{ip_addr['ip']}")
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
				redirect '/job'
			end
		end
	end
end
