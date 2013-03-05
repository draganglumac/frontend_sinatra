module ConnectedDevices
	module Routes
		post '/connected_devices' do
			AutomationStack::Infrastructure::ConnectedDevice.create params[:connected_device]
			redirect back
		end
	end
end