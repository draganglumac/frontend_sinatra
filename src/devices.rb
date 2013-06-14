module Devices

	module Routes

		before '/devices' do

		end

		get '/devices' do
			@devices = AutomationStack::Infrastructure::Device.all
			erb :'devices/index'
		end

		get '/devices/new' do
			@manufacturers  = AutomationStack::Infrastructure::Manufacturer.all 
			@platforms  = AutomationStack::Infrastructure::Platform.all 
			@device_types  = AutomationStack::Infrastructure::DeviceType.all 
			erb :'devices/new'
		end

		get '/devices/:id' do
			erb :'devices/show'
		end

		post '/devices/:id/delete' do
			AutomationStack::Infrastructure::Device[params[:id]].delete
			redirect "/devices"
		end


		post '/devices' do
			redirect "/devices" if params[:cancel]
			AutomationStack::Infrastructure::Device.create params[:device]
			redirect "/devices"
		end

	end

end
