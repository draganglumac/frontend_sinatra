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
          project = project_name_from_job_name(job.name)
          if not @results.include? project
            @results << project 
          end
        end
      end

      erb :'results/index'
    end

    get '/results/:name' do
      project = params[:name]
      @results = []
      
      Dir.chdir('public/uploads/results') do
        Dir.glob('*').each do |job_id_folder|
          job = AutomationStack::Infrastructure::Job.find(:id => job_id_folder)
          if project_name_from_job_name(job.name) == project
            @results << [job.id, device_name_from_job_name(job.name)]
          end
        end
      end

      @results.sort!
      erb :'results/show'
    end

    get '/results/job/:job_id' do
      job = AutomationStack::Infrastructure::Job.find(:id => params[:job_id]);

      @project = project_name_from_job_name(job.name)
      @device = device_name_from_job_name(job.name)
      @main_paths = link_main_results(params[:job_id], "cukes.html")
      
      erb :'results/resultjob', :layout => :results_layout
    end

    get '/results/other/:job_id/:epoch' do
      supporting_paths = link_supporting_results(params[:job_id], params[:main_file])
      @supporting_paths = supporting_paths[params[:epoch]]

      erb :'results/other_results', :layout => false
    end
  end

end
