require_relative "./model"

module Machines
  
  class Machine                                          
    def initialize()
      @devices = []
    end
    
    attr_accessor :id,:call_sign,:ip_address,:platform_id,:devices

    def platform_name
      name = Hound.get_platform_name_from_id self.platform_id
    end
    
  end                  

  
  
  class Repository
    
    def initialize()
      
    end
    
    def all
      
      machines = []             
      Hound.get_machines.each do |machine|
        m = Machine.new
        
        m.id = machine["id"]
        m.call_sign = machine["call_sign"]
        m.ip_address = machine["ip_address"]
        m.platform_id = machine["platform_id"]
        
        machines << m

      end
      
      machines
      
    end
    def get id
      all.find { |machine| machine.id == id.to_i }
    end
  end


  module Routes
  
    get '/machine/:id' do
      machines  = Repository.new
      @machine = machines.get(params["id"])

      @platforms = Hound.get_platforms
      
      @machine.devices = []


      erb :machine_show
    end
    
  end
  
end