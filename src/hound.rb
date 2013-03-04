require_relative 'dbconnect'

                      



class Hound
	@@dbconnect = Dbconnect.new

	def self.get_machines
		return @@dbconnect.query("SELECT * FROM machines")
	end    
	
	def self.get_platforms()
	  return @@dbconnect.query("SELECT * FROM platforms")
	end

	def self.get_platform_name_from_id platform_id
		DB[:platforms].where(:id => platform_id).first[:name]
	end

	def self.add_device device
		id = DB[:devices].insert :model => device.model, :serial_number => device.serial_number, :type => device.type, :platform_id => device.platform_id 
		id
	end
	def self.connect_device(device_id,machine_id)
		DB[:connected_devices].insert :machines_id => machine_id, :devices_id => device_id 
	end
	def self.get_jobs
		return @@dbconnect.query("SELECT * from `jobs`")
	end
	def self.get_complete_jobs
		return @@dbconnect.query("select * from `AUTOMATION`.`jobs` where `status` = 'COMPLETE' limit 10")
	end
	def self.get_incomplete_jobs
		return @@dbconnect.query("select * from `AUTOMATION`.`jobs` where `status` = 'INPROGRESS'")
	end
	def self.get_unstarted_jobs
		return @@dbconnect.query("select * from `AUTOMATION`.`jobs` where `status` = 'INCOMPLETE'")
	end
	def self.get_results
		return @@dbconnect.query("SELECT * FROM results")
	end
	def self.getmachineids
		return @@dbconnect.query("SELECT `id` from `machines`")
	end
	def self.remove_machine(id)                                   
	  obj = DB[:machines].where(:id => id)
		obj.delete
	end
	def self.remove_job(job_id)
		@@dbconnect.query("DELETE FROM `AUTOMATION`.`jobs` WHERE `id`=#{job_id}")
	end
	def self.set_job_progress(job_id)
		puts "SETTING JOB PROGRESS BACK TO INPROG"
		@@dbconnect.query("UPDATE `AUTOMATION`.`jobs` SET status='INPROGRESS' WHERE id=#{job_id}")
	end
	def self.set_job_restart(job_id)
		@@dbconnect.query("UPDATE `AUTOMATION`.`jobs` SET status='INCOMPLETE' WHERE id=#{job_id}")
	end
	def self.directquery(query)
		return @@dbconnect.query(query)
	end
	def self.set_result(job_id,result,time)
		@@dbconnect.query("INSERT INTO `AUTOMATION`.`results` (`id`,`DATETIME`,`testresult`,`jobs_id`,`jobs_machines_machine_id`)VALUES(NULL,CURRENT_TIMESTAMP,'#{result}',#{job_id});")
	end
	def self.truncate_results
		@@dbconnect.query("TRUNCATE TABLE `AUTOMATION`.`results`")
	end
	def self.purgedb
		@@dbconnect.query("DROP DATABASE AUTOMATION")
	end
	def self.add_job(job_name,machine_id,command,trigger_time)
    #DB[:jobs].insert :name => job_name, :machine_id => machine_id, :command => command, :trigger_time => trigger_time, :status => 'INCOMPLETE' 
   
    @@dbconnect.query("INSERT INTO `AUTOMATION`.`jobs` (`id`,`name`,`TIMESTAMP`,`command`,`status`,`machine_id`,`trigger_time`) VALUES (NULL,
        '#{job_name}',CURRENT_TIMESTAMP,'#{command}','INCOMPLETE','#{machine_id}','#{trigger_time}')")
   
    end
	def self.add_machine(machine)
	  DB[:machines].insert :call_sign => machine[:call_sign],:platform_id => machine[:platform_id],:ip_address => machine[:ip_address]
	end
	#analytics
	def self.add_visitor(ip)
		#@@dbconnect.query("INSERT INTO `AUTOMATION`.`analytics` (`id`,`DATETIME`,`IP`) VALUES (NULL,CURRENT_TIMESTAMP,'#{ip}')")
	end
	def self.get_visitors
		return @@dbconnect.query("select * from `AUTOMATION`.`analytics`")
	end
end
