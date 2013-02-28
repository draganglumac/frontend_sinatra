require_relative "./model"

module Machines
  
 

  module Routes
  
    get '/machine/:id' do
      @machine  = AutomationStack::Infrastructure::Machine[params[:id]]
      @platforms = AutomationStack::Infrastructure::Platform.all
      erb :machine_show
    end
    
  end
  
end