require 'yaml'

dbconf = YAML.load_file("conf/db.conf")

DB = Sequel.mysql2(dbconf["database"],:host  => dbconf["host"], :username => dbconf["username"], :password => dbconf["password"])
Sequel::Model.db = DB

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
			many_to_one  :machine
			many_to_one :device
		end


		class Manufacturer < Sequel::Model
			one_to_many :devices

		end

		class DeviceType<Sequel::Model
			one_to_many :devices
		end
		


		class Device < Sequel::Model
			many_to_one :platform
			many_to_one :device_type
			many_to_one :manufacturer
		end

		class Jobs < Sequel::Model
			many_to_one :job
			many_to_one :results

		end

		class Result < Sequel::Model
			many_to_one :job
		end
	
	end
	
end
