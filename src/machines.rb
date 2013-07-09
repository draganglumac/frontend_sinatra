require_relative "./model"

module Machines

  module Routes
    helpers do
      def validate_new_machine(params) 
        errors = {}

        if params[:call_sign].nil? or params[:call_sign] == "" 
          errors[:call_sign] = 'You must supply the call sign.'
        end

        if params[:ip_address].nil? or params[:ip_address] == ""
          errors[:ip_address] = 'You must supply the IP address.'
        end

        if params[:port].nil? or params[:port] == ""
          errors[:port] = 'You must supply the port.'
        end

        if params[:platform_id].nil? or params[:platform_id] == "-1"
          errors[:platform_id] = 'You must pick a supported platform.'
        end

        errors
      end
    end

    before '/machines' do
    end

    get '/machines' do
      @machines  = AutomationStack::Infrastructure::Machine.all
      erb :'machines/index'
    end

    get '/machines/new' do
      @errors ||= session[:new_machine_errors]
      @platforms = AutomationStack::Infrastructure::Platform.all
      @manufacturers = AutomationStack::Infrastructure::Manufacturer.all
      @device_types = AutomationStack::Infrastructure::DeviceType.all
      erb :'machines/new'
    end

    get '/machines/:id' do
      @machine  = AutomationStack::Infrastructure::Machine[params[:id]]
      @devices =AutomationStack::Infrastructure::Device.all
      erb :'machines/show'
    end

    post '/machines/:id/delete' do
      Hound.remove_machine(params[:id])
      redirect "/machines"
    end
    post '/machines/status/:status' do
      puts "received status update from machine #{request.ip}"
      Hound.directquery("call update_machine_status('#{request.ip}','#{params[:status]}');")	
    end

    post '/machines' do
      redirect "/machines" if params[:cancel]
      session[:new_machine_errors] = validate_new_machine(params)
      if not session[:new_machine_errors].empty?
        redirect back
      else
        Hound.add_machine(params)
        @admin_pending_jobs = Hound.get_jobs
        @machine_available = Hound.get_machines
        redirect "/machines"
      end
    end

  end
end
