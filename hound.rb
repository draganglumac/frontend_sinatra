require_relative 'dbconnect'
class Hound
	@@dbconnect = Dbconnect.new

	def self.get_machines
		return @@dbconnect.query("SELECT * FROM machines")
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
		return @@dbconnect.query("SELECT `machine_id` from `machines`")
	end
	def self.remove_machine(inputraw)
		@@dbconnect.query("DELETE FROM `AUTOMATION`.`machines` WHERE `machine_id`=#{inputraw}")
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
	def self.add_job(machine_num,job_name,command)
		@@dbconnect.query("INSERT INTO `AUTOMATION`.`jobs` (`id`,`name`,`TIMESTAMP`,`machines_machine_id`,`command`) VALUES (NULL,
    '#{job_name}',CURRENT_TIMESTAMP,'#{machine_num}','#{command}')")
	end
	def self.add_machines_long(callsign,ip,platforms,iphone4,iphone4s,iphone5,ipadmini,ipad4)
		@@dbconnect.query("INSERT INTO `AUTOMATION`.`machines` (`machine_id`, `machine_callsign`, `machine_ip`, `supported_platforms`, `iphone4`, `iphone4s`, `iphone5`, `ipadmini`, `ipad4`)  VALUES (NULL,'#{callsign}','#{ip}','#{platforms}', #{iphone4}, #{iphone4s},#{iphone5}, #{ipadmini}, #{ipad4})")

	end
	def self.add_machine(inputraw)
		
		@@dbconnect.query("INSERT INTO `AUTOMATION`.`machines` (`machine_id`, `machine_callsign`, `machine_ip`, `supported_platforms`, `iphone4`, `iphone4s`, `iphone5`, `ipadmini`, `ipad4`)  VALUES (NULL,'#{inputraw['callsign_form']}','#{inputraw['machine_ip_form']}','#{inputraw['supported_platforms_form']}', #{inputraw['iphone4_select']}, #{inputraw['iphone4s_select']},#{inputraw['iphone5_select']}, #{inputraw['ipadmini_select']}, #{inputraw['ipad4_select']})")
	end
	#analytics
	def self.add_visitor(ip)
		@@dbconnect.query("INSERT INTO `AUTOMATION`.`analytics` (`id`,`DATETIME`,`IP`) VALUES (NULL,CURRENT_TIMESTAMP,'#{ip}')")
	end
	def self.get_visitors
		return @@dbconnect.query("select * from `AUTOMATION`.`analytics`")
	end
end
