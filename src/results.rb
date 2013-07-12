require_relative "./model"

module Results

  module Routes
    before '/results' do

    end

    get '/results' do
      #@results  = AutomationStack::Infrastructure::Result.all.uniq{|result| result.jobs_id}
      Dir.chdir("public/uploads") do
        @results = Dir.glob('*') 
      end

      erb :'results/index'
    end

    get '/results/:name' do

      @results = "#{params[:name]}"
      erb :'results/show'
    end

    get '/results/job/:job_id' do
      job = AutomationStack::Infrastructure::Job.find(:id => params[:job_id]);

      @project = project_name_from_job_name(job.name)
      @device = device_name_from_job_name(job.name)
      @main_paths = link_main_results(params[:job_id], "cukes.html")
      @supporting_paths = link_supporting_results(params[:job_id], "cukes.html")
      
      erb :'results/resultjob', :layout => :results_layout
    end	
  end

end
