require 'sequel-json'
require 'yaml'

require_relative "./mysql"
Sequel::Model.plugin :json_serializer
module AutomationStack

  module Application

  end

  module Domain

  end


  module Infrastructure

    class Machine < Sequel::Model
      one_to_many :jobs
      many_to_one :platform
      one_to_many :connected_devices
    end

    class Analytics < Sequel::Model

    end

    class Platform < Sequel::Model
      one_to_many :devices
      one_to_many :machines
    end

    class ConnectedDevice < Sequel::Model
      many_to_one :machine
      many_to_one :device
    end


    class Manufacturer < Sequel::Model
      one_to_many :devices

    end

    class DeviceType < Sequel::Model
      one_to_many :devices
    end

    class Device < Sequel::Model
      many_to_one :platform
      many_to_one :device_type
      many_to_one :manufacturer
      one_to_many :jobs
    end

    class Project < Sequel::Model
		plugin :serialization, :json
	 	one_to_many :jobs
    end

    class Job < Sequel::Model
      plugin :serialization, :json
      many_to_one :project
      one_to_many :results
      many_to_one :template
      many_to_one :device
    end

    class Result < Sequel::Model
      many_to_one :job
    end

    class Template < Sequel::Model
      many_to_one :project
      one_to_many :jobs
      many_to_one :platform
      many_to_one :device_type
    end
  end

end
