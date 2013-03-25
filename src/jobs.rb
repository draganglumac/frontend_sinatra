module Jobs
	module Routes
    		#new job page
        get '/job' do
            @machines  = AutomationStack::Infrastructure::Machine.all
            @jobs_done = Hound.get_jobs
            erb :jobs
        end
        #Posting new jobs
        
        
        post '/job/restart/:jobnum' do
            Hound.set_job_restart(params[:jobnum])
            redirect '/'
    	end

        post '/job/recursion/disable/:id' do
            Hound.disable_recursion(params[:id])
            redirect back
        end
        post '/job/recursion/enable/:id' do
            Hound.enable_recursion(params[:id])
            redirect back
        end
        post '/job/restart/:jobnum' do
            Hound.set_job_restart(params[:jobnum])
            redirect '/'
        end

        post '/job' do
            puts params if development?
                
            if params[:file_source].nil?
                @error = "<p style='color:red;'>Need input file</p>"    
                raise  "NO FILE"
                redirect '/job'
            end
            
            puts params[:file_source][:filename] if development?
            
            tempfile = params[:file_source][:tempfile] 
            filename = params[:file_source][:filename] 
            cp(tempfile.path, "public/uploads/#{filename}")
            string = File.open(tempfile.path, 'rb') { |file| file.read }
            #puts string
            #machine_num = params[:machine_id].split("machine_id")

            recursion=0

            if params[:is_private] == "0"
                puts "NO RECURSION SET, SINGLE RUN MODE" if development?
                recursion=0
            else
                puts "RECURSION HAS BEEN SET, RECURSIVE MODE" if development?
                recursion=1
            end
            #There is a difference here between ruby versions, be aware
              machine_num = params[:machine_id]
            #'dd/MM/yyyy hh:mm:ss'
            trigger = params[:ltrigger] 
            trigger << ".000000"
            trigger = Time.parse(trigger).to_i
            
            if development?
                puts "JOB NAME #{params[:lname]}"
                puts "MACHINE NUMBER #{machine_num}"
                puts "OUTPUT STRING IS #{string}"
                puts "TRIGGER TIME IS #{trigger}"    
            end
            
            
            Hound.add_job(machine_num,params[:lname],string,trigger,recursion)
            redirect '/job'
        end
    end
end
