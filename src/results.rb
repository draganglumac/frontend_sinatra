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

    get '/results/:name/:device' do
      @main_paths = link_main_results(params[:name] + '/' + params[:device], "cukes.html")
      @supporting_paths = link_supporting_results(params[:name] + '/' + params[:device], "cukes.html")
      erb :'results/resultjob', :layout => :results_layout
    end	
  end

end
