module ConnectedDevices
  class Repository
    def self.link(device_id,machine_id)
      Hound.connect_device(device_id,machine_id)
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
  
  class Repository
    def all
      devices = []                              
      devices << Phone.new("iphone4","iphone4.jpg")
      devices << Phone.new("iphone4s","iphone4s.jpg")
      devices << Phone.new("iphone5","iphone5.jpg")
      devices << Tablet.new("ipadmini","ipadmini.jpg")
      devices << Tablet.new("ipad4","ipad4.jpg")
    end 

    def add device
      return Hound.add_device device
    end
    
    def find_by_name(name)
      all.find{ |device| device.name == name  }
    end
  end
  
  module Routes
    
    get '/devices' do 
      devices = Devices::Repository.new
      erb :devices
    end

    post '/device' do

      devices = Repository.new

       device =  Device.new("","")
       device.model = params["model"]
       device.serial_number = params["serial_number"]
       device.type = params["type"]
       device.platform_id = params["platform_id"]

       device_id = devices.add device



       ConnectedDevices::Repository.link(device_id,params["machine_id"])

      redirect back 
    end
    
    
  end
end