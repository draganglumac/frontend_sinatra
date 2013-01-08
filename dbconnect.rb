require 'mysql2'
require 'yaml'

class Dbconnect
	
	def initialize
	  begin
      dbconfig = YAML.load_file("conf/db.conf")

      @host = dbconfig[:host]
      @user = dbconfig[:username]
      @password = dbconfig[:password]
      @database = dbconfig[:database]
    rescue
      print "\n"
      print "ERROR: It appears that you either don't have conf/db.conf file or that it couldn't be opened.\n"
      print "If you need to create the file then the easiest thing to do is to copy conf/db_conf.example,\n"
      print "rename the copy to db.conf, and change the values to match your MySQL database configuration.\n"
      print "\n"
      
      raise
    end
  end
  
	def query(inputquery)
		client = Mysql2::Client.new(:host => @host, :username => @user, :password =>  @password, :database => @database, :async => true)
		results = @client.query(inputquery)
		return results
	end
end
