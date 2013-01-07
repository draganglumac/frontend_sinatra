require 'mysql2'

class Dbconnect
	@@client = 0
	
	def self.query(inputquery)
		@client = Mysql2::Client.new(:host => "172.20.141.82", :username => "dummy",:password =>  "dummy", :database => "AUTOMATION", :async => true)
		results = @client.query(inputquery)
		return results
	end
end
