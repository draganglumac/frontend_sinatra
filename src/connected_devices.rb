module ConnectedDevices
	module Routes
		post '/connected_devices' do
			AutomationStack::Infrastructure::ConnectedDevice.create params[:connected_device]
			redirect back
		end

		get '/connected_devices/:id/delete' do
			AutomationStack::Infrastructure::ConnectedDevice[params[:id]].delete
			redirect back
		end
	end
end