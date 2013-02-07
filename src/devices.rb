module Devices
  
  class Device
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
    
    def find_by_name(name)
      all.find{ |device| device.name == name  }
    end
  end
  
  module Routes
    
    get '/devices' do 
      devices = Devices::Repository.new
      erb :devices
    end
    
    
  end
end