require_relative "./model"

module Results

  module Routes
    before '/results' do
     
    end

  	get '/results' do
  		@results  = AutomationStack::Infrastructure::Result.all.uniq{|result| result.jobs_id}

  		erb :'results/index'
  	end

    get '/results/:id' do
      @result  = AutomationStack::Infrastructure::Result[params[:id]]
      erb :'results/show'
    end    
  end
  
end
