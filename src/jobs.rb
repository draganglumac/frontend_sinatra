require 'jobs_helper'
require 'automation_stack_helpers'
require 'uri'

module Jobs
  module Routes

    helpers do
      def validate(params)
        errors = {}
        if not params.nil? and not params.empty?
          [:machine_id, :lname, :ltrigger].each do |key|
            (params[key] || "").strip!
          end

          errors[:lname] = "Project name is required." if params[:lname].empty?
          errors[:ltrigger] = "Trigger time is required." if params[:ltrigger].empty?

          templates = params[:template]
          if templates.nil?
            errors[:template] = "You must supply at least one template for a platform and optionally a device type."
          else
            templates.each do |k, t|
              next if k == '0'
              if t[:platform] == '0'
                errors['platform-' + k] = "You have to choose the platform for template #{k}"
              end

              if (t[:commands].nil? or t[:commands].empty?) and (t[:file_source].nil? or t[:file_source].empty?)
                errors['commands-' + k] = "You have to supply either commands or configuration file for template #{k}"
              end
            end
          end
        end 

        errors
      end

      def in_editing_mode?
        if can_edit?
          return @editing
        else
          return false
        end
      end

      def today_and_trigger_time
        trigger = Time.at(@job.trigger_time).strftime('%d/%m/%Y %H:%M:%S')
        now = (Time.now).strftime('%d/%m/%Y %H:%M:%S')
        now.split(' ').first + ' ' + trigger.split(' ').last
      end
      def url_escape(text)
        return nil if text.nil?
        URI.escape(text)
      end

      def url_unescape(text)
        return nil if text.nil?
        URI.unescape(text)
      end

      def recurrence_string(interval)
        if interval >= 900 and interval < 3600
          multiplier = interval / 60
          "#{multiplier} minutes"
        elsif interval < 86400
          multiplier = interval / 3600
          "#{multiplier} hours"
        elsif interval >= 86400
          multiplier = interval / 86400
          "#{multiplier} days"
        else
          "unknown"
        end
      end

      def multiplier_from_interval(interval)
        if interval == 0
          1
        elsif interval < 3600
          interval / 60
        elsif interval < 86400
          interval / 3600
        elsif interval >= 86400
          interval / 86400
        else
          1
        end
      end

      def time_unit_from_interval(interval)
        if interval == 0
          "days"
        elsif interval < 3600
          "minutes"
        elsif interval < 86400
          "hours"
        else
          "days"
        end
      end

      def project_page_helper(project)
        @machines  = AutomationStack::Infrastructure::Machine.all
        @devices = AutomationStack::Infrastructure::Device.all
        @platforms = AutomationStack::Infrastructure::Platform.all
        @device_types = AutomationStack::Infrastructure::DeviceType.all
        @jobs_done = Hound.get_jobs
        @project = project
        puts "@project = #{@project}"
      end

    end

    #new job page
    get '/project' do
      @errors = {}
      @notifications = {}
      project_page_helper({})
      erb :project_form
    end

    post '/project' do
      templates = params['template']
      templates.each do |k, t|
        if not t['file_source'].nil?
          tempfile = t['file_source'][:tempfile]	
          file_content = File.open(tempfile.path,'rb') { |file|file.read }
          t['commands'] = file_content
        end
      end

      @notifications = {}
      if not params[:lname].nil? and not params[:lname].empty?
        projects = AutomationStack::Infrastructure::Project.all
        projects.each do |p|
          if p.name == params[:lname].strip
            @notifications['existing_project'] = 'Project with the name ' + 
              params[:lname].strip + ' already exists. ' + 
              'If you would like to edit this project please go to ' + 
              'the dashboard and choose edit project from the action menu. ' + 
              'Otherwise please give the new project a different name.'
          end
        end
      end
 
      if @notifications.empty?
        @errors = validate(params)
      else
        @errors = {}
      end

      project_page_helper(params)

      erb :project_form
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
      if job.trigger_time < Time.new.to_i
        job.trigger_time += 60 * 60 * 24
      end

      # new recursion
      job.recursion = params[:recursion].to_i
      if job.recursion == 0
        job.interval = 0
      else
        interval = params[:seconds_multiplier].to_i * params[:seconds].to_i
        job.interval = interval < 900 ? 900 : interval
      end        

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

    post '/jobs/:project/delete' do
      AutomationStack::Infrastructure::Job.subset(:project, :name.like("#{params[:project]}%"))
      AutomationStack::Infrastructure::Job.project.delete

      proj = AutomationStack::Infrastructure::Project.find(:name => params[:project])
      proj.delete

      redirect back
    end

    post '/jobs/:project/edit' do
      preselected = params[:preselected].split(';')
      the_project = AutomationStack::Infrastructure::Project.find(:name => params[:project])

      params.keys.each do | pline |
        if pline.include? "SELECTED_DEVICE"
          current_device = pline.split("=").last

          if preselected.include?(current_device)
            preselected.delete(current_device)
            next
          end

          if not AutomationStack::Infrastructure::Device.select(:name).where(:id => current_device).first.nil?
            current_device_name = AutomationStack::Infrastructure::Device.select(:name).where(:id => current_device).first.name
          else
            next
          end

          machine = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => current_device)
          machine = machine.first[:machine_id]

          trigger = Time.new.to_i

          canonical_string = the_project.commands
          string = Jobhelper.replace_symbols(canonical_string,machine)	
          Hound.add_job(machine,the_project.name + "-#{current_device_name}",string,trigger,0,0,the_project.id,current_device)
        end
      end

      preselected.each do |device_id|
        job = AutomationStack::Infrastructure::Job.find(:device_id => device_id)
        job.delete
      end

      redirect back
    end

    post '/jobs' do
      params.keys.each do | pline |
        if pline.include? "SELECTED_DEVICE"
          current_device = pline.split("=").last
          if not AutomationStack::Infrastructure::Device.select(:name).where(:id => current_device).first.nil?
            current_device_name = AutomationStack::Infrastructure::Device.select(:name).where(:id => current_device).first.name
          else
            next
          end

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

          canonical_string = File.open(tempfile.path,'rb') { |file|file.read }

          email = params[:email]

          if params[:main_result_file].nil? or params[:main_result_file].strip == ''
            main_result_file = 'cukes.html'
          else
            main_result_file = params[:main_result_file]
          end

          trigger = params[:ltrigger] 
          trigger << ".000000"
          trigger = Time.parse(trigger).to_i
          if trigger < Time.new.to_i
            trigger += 60 * 60 * 24
          end
          recursion=0
          if params[:is_private] == "0"
            recursion=0
            interval=0
          else
            recursion=1
            interval=params[:seconds_multiplier].to_i * params[:seconds].to_i
            interval=interval < 900 ? 900 : interval
          end
          puts "interval = #{interval}"
          string = Jobhelper.replace_symbols(canonical_string,machine)	
          project_id = Hound.add_or_update_project(params[:lname],canonical_string,main_result_file,email)
          Hound.add_job(machine,params[:lname] + "-#{current_device_name}",string,trigger,recursion,interval,project_id,current_device)
        end
      end			
      redirect '/dashboard'
    end

  end
end
