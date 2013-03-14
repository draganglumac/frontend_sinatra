dbconf = YAML.load_file("conf/db.conf")
DB = Sequel.mysql2(dbconf["database"],:host  => dbconf["host"], :username => dbconf["username"], :password => dbconf["password"])
Sequel::Model.db = DB
