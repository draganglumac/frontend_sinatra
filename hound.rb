require 'dbconnect'
class Hound
	def self.get_machines
		return Dbconnect.query("SELECT * FROM machines")
	end
	def self.get_jobs
		return Dbconnect.query("SELECT * from `jobs`")
	end
	def self.get_complete_jobs
		return Dbconnect.query("select * from `AUTOMATION`.`jobs` where `status` = 'COMPLETE' limit 10")
	end
	def self.get_incomplete_jobs
		return Dbconnect.query("select * from `AUTOMATION`.`jobs` where `status` = 'INPROGRESS'")
	end
	def self.get_unstarted_jobs
		return Dbconnect.query("select * from `AUTOMATION`.`jobs` where `status` = 'INCOMPLETE'")
	end
	def self.get_results
		return Dbconnect.query("SELECT * FROM results")
	end
	def self.getmachineids
		return Dbconnect.query("SELECT `machine_id` from `machines`")
	end
	def self.remove_machine(inputraw)
		Dbconnect.query("DELETE FROM `AUTOMATION`.`machines` WHERE `machine_id`=#{inputraw}")
	end
	def self.remove_job(job_id)
		Dbconnect.query("DELETE FROM `AUTOMATION`.`jobs` WHERE `id`=#{job_id}")
	end
	def self.set_job_progress(job_id)
		puts "SETTING JOB PROGRESS BACK TO INPROG"
		Dbconnect.query("UPDATE `AUTOMATION`.`jobs` SET status='INPROGRESS' WHERE id=#{job_id}")
	end
	def self.set_job_restart(job_id)
	Dbconnect.query("UPDATE `AUTOMATION`.`jobs` SET status='INCOMPLETE' WHERE id=#{job_id}")
	end
	def self.directquery(query)
		return Dbconnect.query(query)
	end
	def self.truncate_results
		Dbconnect.query("TRUNCATE TABLE `AUTOMATION`.`results`")
	end
	def self.purgedb
		Dbconnect.query("DROP DATABASE AUTOMATION")
	end
	def self.add_job(machine_num,job_name,command)
		Dbconnect.query("INSERT INTO `AUTOMATION`.`jobs` (`id`,`name`,`TIMESTAMP`,`machines_machine_id`,`command`) VALUES (NULL,
		'#{job_name}',CURRENT_TIMESTAMP,'#{machine_num}','#{command}')")
	end
	def self.add_machine(inputraw)
		Dbconnect.query("INSERT INTO `AUTOMATION`.`machines` (`machine_id`, `machine_callsign`, `machine_ip`, `supported_platforms`, `iphone4`, `iphone4s`, `iphone5`, `ipadmini`, `ipad4`)  VALUES (NULL,'#{inputraw['callsign_form']}','#{inputraw['machine_ip_form']}','#{inputraw['supported_platforms_form']}', #{inputraw['iphone4_select']}, #{inputraw['iphone4s_select']},#{inputraw['iphone5_select']}, #{inputraw['ipadmini_select']}, #{inputraw['ipad4_select']})")
	end
	#analytics
	def self.add_visitor(ip)
		Dbconnect.query("INSERT INTO `AUTOMATION`.`analytics` (`id`,`DATETIME`,`IP`) VALUES (NULL,CURRENT_TIMESTAMP,'#{ip}')")
	end
	def self.get_visitors
		return Dbconnect.query("select * from `AUTOMATION`.`analytics`")
	end
end
