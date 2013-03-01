require_relative "./model"

module Machines

  module Routes
  	
  	get '/machine' do
  		@machines  = AutomationStack::Infrastructure::Machine.all
  		erb :'machines/index'
  	end

  	get '/machine/new' do
  		@platforms = AutomationStack::Infrastructure::Platform.all
  		erb :'machines/new'
  	end

    get '/machine/:id' do
      @machine  = AutomationStack::Infrastructure::Machine[params[:id]]
      @platforms = AutomationStack::Infrastructure::Platform.all
      @manufacturers = AutomationStack::Infrastructure::Manufacturer.all
      @device_types = AutomationStack::Infrastructure::DeviceType.all
      erb :'machines/show'
    end

    post '/machine/:id/delete' do
    	Hound.remove_machine(params[:id])
		redirect "/machine"
    end


    post '/machine' do
      Hound.add_machine(params)
  	  @admin_pending_jobs = Hound.get_jobs
  	  @machine_available = Hound.get_machines
  	  redirect "/machine"
    end
    
  end
  
end
