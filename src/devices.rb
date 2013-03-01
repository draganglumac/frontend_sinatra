module ConnectedDevices
  class Repository
    def self.link(device_id,machine_id)
      
      AutomationStack::Infrastructure::ConnectedDevice.create :device_id => device_id,:machine_id => machine_id 
    end
  end
end
module Devices

  module Routes
    
    before do
      protected!
    end

    get '/devices' do
      
      erb :'devices/index'
    end

    get '/devices/new' do
      
      erb :'devices/new'
    end

    get '/devices/:id' do
      erb :'devices/show'
    end

    post '/devices/:id/delete' do
      redirect "/devices"
    end


    post '/devices' do
      redirect "/devices" if params[:cancel]
      
      redirect "/devices"
    end
    
  end
  
end
