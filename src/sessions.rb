module Sessions

	class User
		def initialize(username,password)
	    	@username =username
	    	@password = password
		end
    	attr_accessor :username,:password
	end

	class UserRepository
		CONF= "conf/admin.conf"
		def self.get_by_username_and_password username,password
			users = File.read(CONF).split("\n").map { |line| line.split(":")  }.map { |data| User.new(data[0],data[1])}
			return users.find { |user| user.username == username and user.password == password}
		end
	end


	module Routes
		post '/session' do

			user = UserRepository.get_by_username_and_password params[:username ],params[:password]


			if user

				session[:current_user] = user
			else
				redirect "/?login=failed"
			end

			redirect back
		end

		get '/session/destroy' do
			session[:current_user] = nil
			redirect back
		end
	end
end