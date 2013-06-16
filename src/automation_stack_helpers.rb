module AutomationStackHelpers

  def check_availibility(id)
    if AutomationStack::Infrastructure::Job.count == 0
      puts "No jobs found in database"
      return 1
    end
    machine_id = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => id).first[:machine_id]
    puts "Checking availbility of machine #{machine_id}"

    machine_status = AutomationStack::Infrastructure::Job.select(:status).where(:machine_id =>machine_id).last

    if !machine_status
      puts "no status found for #{machine_id} assuming ready..."
      return 1
    end
    if machine_status[:status].include? "IN PROGRESS"
      puts "Machine #{machine_id} is currently in progress..."
      return 0
    else
      puts "Machine #{machine_id} is currently ready for action..."
      return 1 
    end
  end

  def partial(page, options={})
    erb page, options.merge!(:layout => false)
  end
  
  def link_folder_content(folder)
    puts "Link folder content #{folder}"
    file_list = []
    Dir.chdir("public/uploads/" + folder) do
      Dir.glob("*").reverse.each do |f|
        epoch,filename = f.split('.',2)
        display_name = Time.at(epoch.to_i).to_datetime.strftime("%Y-%m-%d %H:%M:%S ") + filename
        file_list << "<a href=\"/uploads/#{folder}/#{f}\">#{display_name}</a>"
      end
      return file_list
    end
  end
  
  def link_builder(name)
    target = "public/uploads"
    Dir.chdir(target) do
      if Dir.exist?(name)
        Dir.chdir(name) do 
          Dir.glob("*").reverse.each do|f|
            if Dir.exist?(f)
              yield  "<a href=\"/results/#{name}/#{f}\">#{f}</a>"
            end
          end
        end
      else
        halt 404, "Results unavailable - May not have been processed yet"
      end
    end
  end
  
  def current_user
    session[:current_user]
  end

  def job(jobs_id)
    AutomationStack::Infrastructure::Job[jobs_id]
  end

  def can_edit?
    current_user
  end

  def is_admin?
    can_edit?
  end

  def get_files(path)
    dir_array = Array.new
    Find.find(path) do |f|
      dir_array << File.basename(f, ".*")
    end
    return dir_array
  end 

  def suported_platorm(machine)
    case machine.supported_platforms
    when "ios"
      return "/images/ios.png"
    when "android"
      return "/images/android.png"
    end

    raise "oooops! #{machine.supported_platforms} is not supported !"
  end

  def connected(device_id)
    connected_ids = AutomationStack::Infrastructure::ConnectedDevice.dataset.map(:device_id)
    return connected_ids.include?(device_id)
  end

  def machine_id_hosting_device(device_id)
    connections = AutomationStack::Infrastructure::ConnectedDevice.dataset.to_hash(:device_id, :machine_id)
    return connections[device_id]
  end

  def should_autorefresh?
    session[:autorefresh] or not session[:toggled_already]
  end
end
