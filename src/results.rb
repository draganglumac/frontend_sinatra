require_relative "./model"

module Results

  module Routes
    before '/results' do

    end

    get '/results' do
      @results = []
      
      Dir.chdir("public/uploads/results") do
        Dir.glob('*').each do |job_id_folder|
          job = AutomationStack::Infrastructure::Job.find(:id => job_id_folder)
          if job.nil?
            next
          end
          project = project_name_from_job_name(job.name)
          if not @results.include? project
            @results << project 
          end
        end
      end

      if @results.empty?
        halt 404, "Results unavailable - May not have been processed yet"
      else
        erb :'results/index'
      end
    end

    get '/results/:name' do
      project = params[:name]
      @results = []
      
      Dir.chdir('public/uploads/results') do
        Dir.glob('*').each do |job_id_folder|
          job = AutomationStack::Infrastructure::Job.find(:id => job_id_folder)
          if job.nil?
            next
          end

          if project_name_from_job_name(job.name) == project
            @results << [job.id, device_name_from_job_name(job.name)]
          end
        end
      end

      if @results.empty?
        halt 404, "Results unavailable - May not have been processed yet"
      else
        @results.sort!
        erb :'results/show'
      end
    end

    get '/results/job/:job_id' do
      job = AutomationStack::Infrastructure::Job.find(:id => params[:job_id]);

      if job.project_id.nil?
        @project = project_name_from_job_name(job.name)
        main_file = "cukes.html"
      else
        project = AutomationStack::Infrastructure::Project.find(:id => job.project_id)
        @project = project.name
        main_file = project.main_result_file
        puts "project.name = #{project.name}, main_file = #{main_file}"
      end
      @device = device_name_from_job_name(job.name)
      @main_paths = link_main_results(params[:job_id], main_file)
      
      erb :'results/resultjob', :layout => :results_layout
    end

    get '/results/other/:job_id/:epoch' do
      supporting_paths = link_supporting_results(params[:job_id], params[:main_file])
      @supporting_paths = supporting_paths[params[:epoch]]

      erb :'results/other_results', :layout => false
    end
  end

end
