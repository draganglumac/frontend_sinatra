DB = Sequel.mysql2("AUTOMATION",:host  => "10.65.80.46", :username => "dummy", :password => "dummy")
Sequel::Model.db = DB

module AutomationStack

	module Application

	end

	module Domain
		
	end


	module Infrastructure

	class Machine < Sequel::Model
			one_to_many :jobs
			many_to_one :Platform
			one_to_many :connected_devices
		end

		class Analytics < Sequel::Model

		end

		class Platform < Sequel::Model
			one_to_many :devices
			one_to_many :machines
		end

		class ConnectedDevices < Sequel::Model
			many_to_one :machine
			many_to_one :device
		end


		class Devices < Sequel::Model
			
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
