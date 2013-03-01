class Sequel::Model
  # Open classes win every time!
  unrestrict_primary_key
end

module ConnectedDevices
  class Repository
    def self.link(device_id,machine_id)
      
      AutomationStack::Infrastructure::ConnectedDevice.create :device_id => device_id,:machine_id => machine_id 
    end
  end
end
module Devices
  
  class Device
    attr_accessor :model,:serial_number,:type,:platform_id
    def initialize(name,image)
      @name = name
      @image = image
    end
    attr_accessor :name,:image
  end
  
  class Tablet < Device
    
  end                  
  
  class Phone < Device
    
  end

  module Routes
    
    get '/devices' do 
      devices = AutomationStack::Infrastructure::Device.all
      erb :devices
    end

    post '/device' do
      
       device =  AutomationStack::Infrastructure::Device.create params[:device]
       ConnectedDevices::Repository.link(device.id,params[:machine_id])

      redirect back 
    end
    
    
  end
end