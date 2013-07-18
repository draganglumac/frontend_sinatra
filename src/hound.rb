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
    @@dbconnect.query("DELETE FROM `jobs` WHERE `id`=#{job_id}")
  end
  def self.set_job_progress(job_id)
    puts "SETTING JOB PROGRESS BACK TO INPROG"
    @@dbconnect.query("UPDATE `jobs` SET status='INPROGRESS' WHERE id=#{job_id}")
  end
  def self.set_job_restart(job_id)
    @@dbconnect.query("UPDATE `jobs` SET status='NOT STARTED' WHERE id=#{job_id}")
    #get current unix timestamp
    #update the trigger to the current time stamp
    #we add two minutes to be sure the local satellite differential doesn't miss the job
    current_time = Time.now.to_i + 60
    DB[:jobs].where(:id => job_id).update(:trigger_time =>current_time)
  end
  def self.directquery(query)
    return @@dbconnect.query(query)
  end
  def self.set_result(job_id,result,time)
    @@dbconnect.query("INSERT INTO `results` (`id`,`DATETIME`,`testresult`,`jobs_id`,`jobs_machines_machine_id`)VALUES(NULL,CURRENT_TIMESTAMP,'#{result}',#{job_id});")
  end
  def self.truncate_results
    @@dbconnect.query("TRUNCATE TABLE `results`")
  end



  def truncate_table name
    turn_off_foreign_key_checks
    @@dbconnect.query("TRUNCATE TABLE `#{name}`")
    turn_on_foreign_key_checks
  end

  def self.turn_off_foreign_key_checks
    @@dbconnect.query("SET FOREIGN_KEY_CHECKS=0;")
  end
  def self.turn_on_foreign_key_checks
    @@dbconnect.query("SET FOREIGN_KEY_CHECKS=1;")
  end
  
  def self.add_or_update_project(proj_name,commands,main_result_file,email)
    project = AutomationStack::Infrastructure::Project.find(:name => proj_name)
    if project.nil?
      DB[:projects].insert :name => proj_name, :commands => commands, :main_result_file => main_result_file, :email => email
    else
      project.commands = commands
      project.main_result_file = main_result_file
      project.email = email
      project.save
    end

    project = AutomationStack::Infrastructure::Project.find(:name => proj_name)
    return project.id
  end

  def self.add_job(machine_id,job_name,command,trigger_time,recursionflag,interval,project_id,device_id)
    DB[:jobs].insert :name => job_name, :machine_id => machine_id, :command => command, :trigger_time => trigger_time, :status => 'NOT STARTED', :recursion => recursionflag, :interval => interval, :project_id => project_id, :device_id => device_id
  end
  def self.add_machine(machine)
    DB[:machines].insert :call_sign => machine[:call_sign],:platform_id => machine[:platform_id],:ip_address => machine[:ip_address],:port => machine[:port]
  end
  #analytics
  def self.add_visitor(ip)
    #@@dbconnect.query("INSERT INTO `analytics` (`id`,`DATETIME`,`IP`) VALUES (NULL,CURRENT_TIMESTAMP,'#{ip}')")
  end
  def self.get_visitors
    return @@dbconnect.query("select * from `analytics`")
  end
  def self.enable_recursion(id)
    @@dbconnect.query("update jobs set recursion=1 where id=#{id}")
  end
  def self.disable_recursion(id)
    @@dbconnect.query("update jobs set recursion=0 where id=#{id}")
  end

  def self.get_device_ip_from_type_and_machine(type,machine_id)
    @@dbconnect.query("select devices.ip from connected_devices inner join devices on connected_devices.device_id=devices.id where devices.device_type_id=#{type} and connected_devices.machine_id=#{machine_id};")

  end
  def self.get_device_serial_from_type_and_machine(type,machine_id)
    @@dbconnect.query("select devices.serial_number from connected_devices inner join devices on connected_devices.device_id=devices.id where devices.device_type_id=#{type} and connected_devices.machine_id=#{machine_id};")

  end
end
