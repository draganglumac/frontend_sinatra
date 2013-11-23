require 'jobs_helper'
require 'automation_stack_helpers'
require 'uri'

module Jobs
  module Routes

    include JobsHelpers

    #new project page
    get '/project' do
      @errors = {}
      @notifications = {}
      set_data_for_project_add_page({})
      erb :'projects/project_add'
    end

    post '/project' do
      templates = params['template']
      set_commands_from_supplied_files(templates)

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
        set_data_for_project_add_page(params)
        erb :'projects/project_add'
      else
        add_project(params)
        redirect '/dashboard'
      end
    end

    get '/project/:id' do
      proj = AutomationStack::Infrastructure::Project.find(:id => params[:id])
      @notifications = {}
      @errors = {}
      set_data_for_project_edit_page(proj)

      erb :'projects/project_edit'
    end

    post '/project/:id' do
      templates = params['template']
      set_commands_from_supplied_files(templates)

      proj = AutomationStack::Infrastructure::Project.find(:id => params[:id])
      @notifications = {}
      @errors = edit_project(params, proj)
      @notifications['success'] = 'Changes saved succesfully.' if @errors.empty?
      set_data_for_project_edit_page(proj)

      erb :'projects/project_edit'
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
        job.command = strip_carriage_returns(file_content)
      else
        job.command = strip_carriage_retruns(url_unescape(params[:command]))
      end

      job.save
      redirect "/job/#{params[:id]}"
    end

    get '/job/:id/delete' do
      job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
      if job.status != 'IN PROGRESS' and job.status != 'QUEUED'
        job.delete
      end
      redirect '/dashboard' 
    end

    post '/job/:id/delete' do
      job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
      if job.status != 'IN PROGRESS' and job.status != 'QUEUED'
        job.delete
      end
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

      if selected_devices?(params)
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
            string = Jobhelper.replace_symbols(canonical_string,machine_id.first.machine_id,current_device.serial_number,current_device.ip)

            job = AutomationStack::Infrastructure::Job.new
            job.name = the_project.name + '-' + current_device.name
            job.project = the_project
            job.template = the_template.first
            job.trigger_time = trigger
            job.status = 'NOT STARTED'
            job.email_results = false
            job.machine_id = machine_id.first.machine_id
            job.command = strip_carriage_retruns(string)
            job.device = current_device

            job.save
          end
        end

        preselected.each do |device_id|
          job = AutomationStack::Infrastructure::Job.where(:project_id => params[:project_id], :device_id => device_id).first
          if job.status != 'IN PROGRESS' and job.status != 'QUEUED'
            job.delete
          end
        end
      end

      redirect back
    end

    get '/project/:id/startall' do
      settings.banner_message = 'Your jobs will start within the next minute.'
      
      jobs = AutomationStack::Infrastructure::Job.where(:project_id => params[:id])
      jobs.each do |job|
        status = job.status
        if status != 'QUEUED' and status != 'IN PROGRESS'
          Hound.set_job_restart(job.id)
        end
      end

      redirect back 
    end

  end
end
