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
      @folder_path = link_folder_content(params[:name] + '/' + params[:device])
      puts "@folder_path = #{@folder_path}"
      erb :'results/resultjob'
    end	
  end

end
