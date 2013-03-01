require_relative "./model"

module Machines

  module Routes
  	
    before do
      protected!
    end

  	get '/machines' do
  		@machines  = AutomationStack::Infrastructure::Machine.all
  		erb :'machines/index'
  	end

  	get '/machines/new' do
  		@platforms = AutomationStack::Infrastructure::Platform.all
      @manufacturers = AutomationStack::Infrastructure::Manufacturer.all
      @device_types = AutomationStack::Infrastructure::DeviceType.all
  		erb :'machines/new'
  	end

    get '/machines/:id' do
      @machine  = AutomationStack::Infrastructure::Machine[params[:id]]
      erb :'machines/show'
    end

    post '/machines/:id/delete' do
    	Hound.remove_machine(params[:id])
		redirect "/machines"
    end


    post '/machines' do
      redirect "/machines" if params[:cancel]
      Hound.add_machine(params)
  	  @admin_pending_jobs = Hound.get_jobs
  	  @machine_available = Hound.get_machines
  	  redirect "/machines"
    end
    
  end
  
end
