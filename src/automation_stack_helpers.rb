require 'fileutils'
require 'jenkins_api_client'

module AutomationStackHelpers

  def has_templates?(project_id, device)
    templates = AutomationStack::Infrastructure::Template.where(:project_id => project_id, :platform_id => device.platform_id)
    return false if templates.nil?

    templates.each do |t|
      return true if t.device_type_id == device.device_type_id
      return true if t.device_type_id.nil?
    end

    return false
  end

  def update_job_names_for_project(project_id, new_project_name)
    jobs = AutomationStack::Infrastructure::Job.where(:project_id => project_id)
    jobs.each do |job|
      job.name = new_project_name + '-' + device_name_from_job_name(job.name)
      job.save
    end
  end

  def check_availibility(id)
    if AutomationStack::Infrastructure::Job.count == 0
      return 1
    end

    m = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => id).first
    if m.nil?
      return 0
    end

    device_statuses = AutomationStack::Infrastructure::Job.select(:status).where(:device_id => id)
    if device_statuses.count == 0
      return 1
    end

    device_statuses.each do |dstatus|
      device_status = dstatus.status
      if device_status == 'IN PROGRESS' or device_status == 'QUEUED'
        return 0
      end
    end

    return 1
  end

  def partial(page, options={})
    erb page, options.merge!(:layout => false)
  end

  def get_datetime_string_for_epoch(epoch)
    datetime_parts = Time.at(epoch).to_s.split(' ')
    "#{datetime_parts[0]} #{datetime_parts[1]}"
  end

  def link_main_results(job_id_folder, main_result_file)
    epoch_file_map = {}
    job_id_results_path = "public/uploads/results/#{job_id_folder}" 
    if Dir.exist?(job_id_results_path)
      Dir.chdir(job_id_results_path) do
        Dir.glob("*").reverse.each do |epoch|
          Dir.chdir(epoch) do
            if not Dir.glob('*').include?(main_result_file)
              File.open(main_result_file, 'w') do |f|
                f.puts "#{main_result_file} not found!"
              end
            end
            Dir.glob("*").each do |filename|
              href = "/uploads/results/#{job_id_folder}/#{epoch}/#{filename}"
              if filename == main_result_file 
                display_name = get_datetime_string_for_epoch(epoch.to_i)
                epoch_file_map[epoch] = "<a href=\"#\" onclick=\"reload_iframe('#{href}'); "\
                  "reload_other_files('#{job_id_folder}','#{epoch}','#{filename}');\">"\
                  "#{display_name}<span>&nbsp;</span><i class=\"icon-chevron-right\"></i></a>"
              end
            end
          end
        end

        return epoch_file_map 
      end
    else
      halt 404, "Results unavailable - May not have been processed yet"
    end
  end

  def create_link_for_supporting_result(job_id_folder, relative_file_path, display_name)
    href = "/uploads/results/#{job_id_folder}#{relative_file_path}"
    puts relative_file_path

    if relative_file_path =~ /console_log\.txt$/
      return "<a class=\"btn\" href=\"#{href}\" target=\"_blank\" style=\"width: 100%\"><img src=\"/img/icon-console.png\" style=\"width: 32px;\"></img>&nbsp;Console Log</a>"
    end

    images = [/\.jpg$/, /\.jpeg$/, /\.gif$/, /\.png$/]
    images.each do |img_regex|
      if relative_file_path =~ img_regex
        return "<a href=\"#img-modal\" data-toggle=\"modal\" class=\"thumbnail\""\
          " data-dynamic=\"true\" data-backdrop=\"false\""\
          " onclick=\"set_modal_image_src('#{href}', '#{display_name}');\">"\
          "<img src=\"#{href}\""\
          " style=\"width: 90px; height: 120px;\""\
          " alt=\"#{display_name}\">"\
          "#{display_name}"\
          "</a>"
      end
    end

    return "<a href=\"#{href}\">#{display_name}</a>"
  end

  def link_supporting_results(job_id_folder, main_result_file)
    epoch_file_map = {} 
    job_id_results_path = "public/uploads/results/#{job_id_folder}" 
    if Dir.exist?(job_id_results_path)
      Dir.chdir(job_id_results_path) do
        Dir.glob("*").reverse.each do |epoch|
          Dir.chdir(epoch) do
            Dir.glob("*").each do |filename|
              f = "/#{epoch}/#{filename}"
              if (filename != main_result_file) 
                display_name = filename

                if epoch_file_map[epoch].nil?
                  epoch_file_map[epoch] = [create_link_for_supporting_result(job_id_folder, f, display_name)]
                else
                  if filename == 'console_log.txt'
                    epoch_file_map[epoch] = [create_link_for_supporting_result(job_id_folder, f, display_name)] + epoch_file_map[epoch]
                  else
                    epoch_file_map[epoch] << create_link_for_supporting_result(job_id_folder, f, display_name)
                  end
                end
              end
            end
          end
        end

        return epoch_file_map
      end
    else
      halt 404, "Results unavailable - May not have been processed yet"
    end
  end


  def link_folder_content(folder)
    puts "Link folder content #{folder}"
    file_list = []
    if Dir.exist?("public/uploads/#{folder}")
      Dir.chdir("public/uploads/" + folder) do
        Dir.glob("*").reverse.each do |f|
          epoch,filename = f.split('.',2)
          display_name = get_datetime_string_for_epoch(epoch.to_i) + filename
          file_list << "<a href=\"/uploads/#{folder}/#{f}\" target=\"main-content\">#{display_name}</a>"
        end
        return file_list
      end
    else
      halt 404, "Results unavailable - May not have been processed yet"
    end
  end

  def link_builder(filtered_results_folders)
    if not filtered_results_folders.empty?
      filtered_results_folders.each do |job_id_device|
        job_id = job_id_device[0]
        device = job_id_device[1]        
        yield  "<a href=\"/results/job/#{job_id}#\">#{device}</a>"
      end
    else
      halt 404, "Results unavailable - May not have been processed yet"
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

  def project_name_from_job_name(job_name)
    job_name.split('-')[0...-1].join("-")
  end

  def device_name_from_job_name(job_name)
    job_name.split('-').last
  end

  def machine_name_for_job(job)
    m = AutomationStack::Infrastructure::Machine.find(:id => job['machine_id'])
    m.call_sign
  end

  def device_report_folder_name(job_name)
    device_name = device_name_from_job_name(job_name)
    device_name.split('/').join('-')
  end

  def increment_status_count(status, status_hash)
    if status == 'COMPLETED'
      status_hash[:completed] += 1
    elsif status == 'FAILED'
      status_hash[:failed] += 1
    elsif status == 'IN PROGRESS'
      status_hash[:running] += 1
    elsif status == 'NOT STARTED' or status == 'SCHEDULED' or status == 'QUEUED' or status =='PENDING'
      status_hash[:pending] += 1
    end
  end

  def get_percentages_for_statuses(statuses)
    min_percentage = 3
    max_percentage = 100
    percentages = {}

    total = statuses.values.inject(:+)
    sorted_statuses = statuses.sort_by { |k, v| v }
    sorted_statuses.each do |pair|
      status = pair[0]
      value = pair[1]

      if value == 0
        percentages[status] = 0
      else
        percentage = (max_percentage * value / total).floor
        percentages[status] = percentage >= min_percentage ? percentage : min_percentage
      end

      total -= statuses[status]
      max_percentage -= percentages[status]
    end

    return percentages
  end 

  def site_alert
    settings.site_alert
  end

  def site_alert_type
    settings.site_alert_type
  end

  def get_ci_jobs_info
    begin    
      jobs_info = {}
      client = JenkinsApi::Client.new(:server_url => settings.ci_url, :timeout => 10) 
      jobs = client.job.list_all
      job_url = "#{settings.ci_url}/job"
      jobs.each do |j|
        status = client.job.get_current_build_status(j) 
        jobs_info[j] = [status, "#{job_url}/#{j}"]
      end

      return jobs_info
    rescue
      return {}
    end
  end

  def devices_already_used_by_project_with_id(pid)
    device_ids = []
    jobs = AutomationStack::Infrastructure::Job.select(:device_id).where(:project_id => pid)
    jobs.each do |j|
      device_ids << j.device_id
    end

    device_ids
  end

  def pick_connected_device_with_name(name)
    devs_with_name = AutomationStack::Infrastructure::Device.where(:name => name)
    devices = []
    devs_with_name.each do |d|
      if not d.ip.nil?
        running_job = AutomationStack::Infrastructure::Job.where(:device_id => d.id, :status => 'IN PROGRESS').first
        queued_job = AutomationStack::Infrastructure::Job.where(:device_id => d.id, :status => 'QUEUED').first
        if running_job.nil? and queued_job.nil?
            devices << d
        end
      end
    end

    count = devices.count
    if count > 0
      r = Random.rand(0...count)
      return devices[r]
    else
      return nil
    end
  end

  def create_device_suggestion_for_project(pid)
    devices = AutomationStack::Infrastructure::Device.all
    project_device_ids = devices_already_used_by_project_with_id(pid)
    unique_names = {}

    project_device_ids.each do |did|
      d = AutomationStack::Infrastructure::Device.find(:id => did)
      name = d.name
      unique_names[name] = d
    end

    devices.each do |d|
      name = d.name
      if unique_names[name].nil?
        unique_names[name] = pick_connected_device_with_name(name)
      elsif not d.ip.nil?
        if unique_names[name].ip.nil?
          unique_names[name] = d
        end
      end
    end

    return unique_names.values.reject { |x| x.nil? }
  end

  def create_device_suggestions_for_all_projects
    devices = {}
    projects = AutomationStack::Infrastructure::Project.all
    projects.each do |p|
      devices[p.id] = create_device_suggestion_for_project(p.id)
    end

    return devices
  end

  def extract_selected_ids_from_params(params)
    device_ids = []
    params.each do |key, value|
      if key.match(/SELECTED_DEVICE=/)
        device_ids << key.sub(/SELECTED_DEVICE=/, '')
      end
    end

    return device_ids
  end

  def create_device_suggestion_for_new_project(params)
    devices = AutomationStack::Infrastructure::Device.all
    project_device_ids = extract_selected_ids_from_params(params)
    unique_names = {}

    project_device_ids.each do |did|
      d = AutomationStack::Infrastructure::Device.find(:id => did)
      name = d.name
      unique_names[name] = d
    end

    devices.each do |d|
      name = d.name
      if unique_names[name].nil?
        unique_names[name] = pick_connected_device_with_name(name)
      elsif not d.ip.nil?
        if unique_names[name].ip.nil?
          unique_names[name] = d
        end
      end
    end

    return unique_names.values.reject { |x| x.nil? }
  end

end
