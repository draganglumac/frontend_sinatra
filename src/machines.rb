module Machines
  
  class Machine                                          
    def initialize()
      @devices = []
    end
    
    attr_accessor :id,:call_sign,:ip,:supported_platforms,:devices
    
  end                                                    
  
  
  class Repository
    
    def initialize(devices)
      @devices = devices
    end
    
    def all
      
      machines = []             
      Hound.get_machines.each do |machine|
        m = Machine.new
        
        m.id = machine["machine_id"]
        m.call_sign = machine["machine_callsign"]
        m.ip = machine["machine_ip"]
        m.supported_platforms = machine["supported_platforms"]
                                           
        
        m.devices << @devices.find_by_name("iphone4") if machine["iphone4"] == 1
        m.devices << @devices.find_by_name("iphone4s") if machine["iphone4s"] == 1
        m.devices << @devices.find_by_name("iphone5") if machine["iphone5"] == 1
        m.devices << @devices.find_by_name("ipadmini") if machine["ipadmini"] == 1
        m.devices << @devices.find_by_name("ipad4") if machine["ipad4"] == 1
        
        
        
        machines << m

      end
      
      machines
      
    end
  end


  module Routes
  
    get '/machine/:id' do
      erb :machine_show
    end
    
  end
  
end