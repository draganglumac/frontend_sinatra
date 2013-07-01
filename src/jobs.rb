require 'jobs_helper'
require 'automation_stack_helpers'
require 'uri'

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

      def in_editing_mode?
        if can_edit?
          return @editing
        else
          return false
        end
      end

      def url_escape(text)
        URI.escape(text)
      end

      def url_unescape(text)
        URI.unescape(text)
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

    get '/job/:id' do
      if params[:edit] == 'on'
        @editing = true
      else
        @editing = false
      end

      @errors ||= {}      
      @job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
      puts "params[:id] = #{params[:id]}"
      puts "job.id = #{@job.id}, machine.id = #{@job.machine_id}"
      @machine = AutomationStack::Infrastructure::Machine.find(:id => @job.machine_id)

      erb :'job_detail/job_detail'
    end

    post '/job/:id/update' do
      @errors = {}
      job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
      
      # new trigger time
      trigger = params[:ltrigger]
      trigger << '.000000'
      job.trigger_time = Time.parse(trigger).to_i

      # new recursion
      job.recursion = params[:recursion].to_i

      # new commands - use file content if supplied
      if not params[:file_source].nil?
        tempfile = params[:file_source][:tempfile]	
        #filename = params[:file_source][:filename]
        file_content = File.open(tempfile.path,'rb') { |file|file.read}
        job.command = file_content
      else
        job.command = url_unescape(params[:command])
      end

      job.save
      redirect "/job/#{params[:id]}"
    end

    get '/job/:id/delete' do
      job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
      job.delete
      redirect '/dashboard' 
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
          current_device_name = AutomationStack::Infrastructure::Device.select(:name).where(:id => current_device).first[:name]

          puts "Device name #{current_device_name}"
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
          trigger = paramy[:ltrigger] 
          trigger << ".000000"
          trigger = Time.parse(trigger).to_i
          recursion=0
          if params[:is_private] == "0"
            recursion=0
          else
            recursion=1
          end
          string = Jobhelper.replace_symbols(string,machine)	
          Hound.add_job(machine,params[:lname] + "-#{current_device_name}",string,trigger,recursion)
        end
      end			
      redirect '/dashboard'
    end

  end
end
