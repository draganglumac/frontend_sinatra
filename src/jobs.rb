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
  end
end
