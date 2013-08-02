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
          seen_templates = []
          if templates.nil?
            errors[:template] = "You must supply at least one template for a platform and optionally a device type."
          else
            templates.each do |k, t|
              next if k == '0'
              if t[:platform] == '0'
                errors['platform-' + k] = "You have to choose the platform for template #{k}"
              else
                tid = t[:platform] + '-' + t[:device_type]
                if seen_templates.include?(tid)
                  errors['duplicate-'+ tid] = "You have already created a template for the platform and device type from template #{k}"
                else
                  seen_templates << tid
                end
              end

              if (t[:commands].nil? or t[:commands].empty?) and (t[:file_source].nil? or t[:file_source].empty?)
                errors['commands-' + k] = "You have to supply either commands or configuration file for template #{k}"
              end
            end
            puts "seen_templates = #{seen_templates}"
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

      def add_project_helper(params)
        # Create Project - guaranteed unique name
        # as otherwise it would have been caught by validation
        p = AutomationStack::Infrastructure::Project.new
        p.name = params[:lname]
        p.main_result_file = 'cukes.html'
        p.save

        # Create Templates - no duplicates here
        # as otherwise they would have been caught by validation
        templates_in = params['template']
        templates = []
        templates_in.each do |k, template|
          next if k == '0'
          t = AutomationStack::Infrastructure::Template.new
          t.project = p
          platform_id = template['platform'].to_i
          t.platform = AutomationStack::Infrastructure::Platform.find(:id => platform_id)
          if template['device_type'] != '0'
            dt_id = template['device_type']
            t.device_type = AutomationStack::Infrastructure::DeviceType.find(:id => dt_id)
          end
          t.commands = template['commands']
          t.main_result_file = template['main_result_file']
          if t.main_result_file.nil? or t.main_result_file.empty?
            t.main_result_file = 'cukes.html'
          end
          t.email = template['email']
          t.save

          templates << t
        end

        puts "templates = #{templates}"

        # Finally, create a job for each device
        params.keys.each do | pline |
          if pline.include? "SELECTED_DEVICE"
            job = AutomationStack::Infrastructure::Job.new
            job.project = p

            current_device = pline.split("=").last
            job.device = AutomationStack::Infrastructure::Device.find(:id => current_device)

            job.name = p.name + '-' + job.device.name

            machine = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => current_device)
            machine_id = machine.first[:machine_id]
            job.machine_id = machine_id

            template = nil
            templates.each do |t|
              if t.platform == job.device.platform
                if t.device_type == job.device.device_type
                  template = t
                  break
                elsif t.device_type.nil?
                  template = t
                end
              end
            end

            raise RuntimeError, "Device doesn't match any templates which should not be possible. Aborting!" if template.nil? 
            job.template = template
            job.email_results = false

            trigger = params[:ltrigger] 
            trigger << ".000000"
            trigger = Time.parse(trigger).to_i
            if trigger < Time.new.to_i
              trigger += 60 * 60 * 24
            end
            job.trigger_time = trigger

            recursion=0
            if params[:is_recurrent] == "0"
              recursion=0
              interval=0
            else
              recursion=1
              interval=params[:seconds_multiplier].to_i * params[:seconds].to_i
              interval=interval < 900 ? 900 : interval
            end
            job.recursion = recursion
            job.interval = interval

            canonical_string =  template.commands
            string = Jobhelper.replace_symbols(canonical_string,job.machine_id)	
            job.command = string
            job.status = 'NOT STARTED'

            job.save
          end			
        end
      end

      def platform_name_for_id(id)
        p = AutomationStack::Infrastructure::Platform.find(:id => id)
        p.name
      end

      def device_type_for_id(id)
        dt = AutomationStack::Infrastructure::Platform.find(:id => id)
        dt.name
      end

      def template_moniker(template)
        if template.device_type.nil?
          return platform_name_for_id(template.platform_id)
        else
          return platform_name_for_id(template.platform_id) + '-' +
            device_type_for_id(template.device_type_id)
        end
      end
    end

    #new job page
    get '/project' do
      @errors = {}
      @notifications = {}
      project_page_helper({})
      erb :'projects/project_add'
    end

    get '/project/:id' do
      @errors = {}
      @notifications = {}

      @project = AutomationStack::Infrastructure::Project.find(:id => params[:id])
      @templates = AutomationStack::Infrastructure::Template.where(:project_id => params[:id])
      jobs = AutomationStack::Infrastructure::Job.where(:project_id => params[:id])
      @devices = AutomationStack::Infrastructure::Device.all
      @selected_device_ids = []
      jobs.each do |job|
        @selected_device_ids << job.device_id
      end
      @platforms = AutomationStack::Infrastructure::Platform.all
      @device_types = AutomationStack::Infrastructure::DeviceType.all

      erb :'projects/project_edit'
    end

    post '/project/:id' do
      puts 'To Do'
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

      if not @notifications.empty? or not @errors.empty?
        project_page_helper(params)
        erb :'projects/project_add'
      else
        add_project_helper(params)
        redirect '/dashboard'
      end
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

    post '/jobs/:project_id/delete' do
      AutomationStack::Infrastructure::Job.subset(:project, :project_id => params[:project_id])
      AutomationStack::Infrastructure::Job.project.delete

      AutomationStack::Infrastructure::Template.subset(:project, :project_id => params[:project_id])
      AutomationStack::Infrastructure::Template.project.delete

      proj = AutomationStack::Infrastructure::Project.find(:id => params[:project_id])
      proj.delete

      redirect back
    end

    post '/jobs/:project_id/edit' do
      preselected = params[:preselected].split(';')
      the_project = AutomationStack::Infrastructure::Project.find(:id => params[:project_id])

      params.keys.each do | pline |
        if pline.include? "SELECTED_DEVICE"
          current_device_id = pline.split("=").last

          if preselected.include?(current_device_id)
            preselected.delete(current_device_id)
            next
          end

          if not AutomationStack::Infrastructure::Device.select(:name).where(:id => current_device_id).first.nil?
            current_device = AutomationStack::Infrastructure::Device.find(:id => current_device_id)
          else
            next
          end

          machine_id = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => current_device_id)

          trigger = Time.new.to_i

          the_template = AutomationStack::Infrastructure::Template.where(:project_id => params[:project_id],
                                                                         :platform_id => current_device.platform_id,
                                                                         :device_type_id => current_device.device_type_id)
          if the_template.first.nil?
            the_template = AutomationStack::Infrastructure::Template.where(:project_id => params[:project_id],
                                                                           :platform_id => current_device.platform_id,
                                                                           :device_type_id => nil)
          end

          if the_template.first.nil?
            puts "No matching template found for device #{current_device.name}. Skipping the device"
            next
          end

          canonical_string = the_template.first.commands
          string = Jobhelper.replace_symbols(canonical_string,machine_id.first.machine_id)

          job = AutomationStack::Infrastructure::Job.new
          job.name = the_project.name + '-' + current_device.name
          job.project = the_project
          job.template = the_template.first
          job.trigger_time = trigger
          job.status = 'NOT STARTED'
          job.email_results = false
          job.machine_id = machine_id.first.machine_id
          job.command = string
          job.device = current_device

          job.save
        end
      end

      preselected.each do |device_id|
        job = AutomationStack::Infrastructure::Job.where(:project_id => params[:project_id], :device_id => device_id)
        job.delete
      end

      redirect back
    end

  end
end
