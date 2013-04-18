module Overview

	module Routes
		get '/overview' do
			@machines = AutomationStack::Infrastructure::Machine.all
			erb :overview
		end
	end
end
