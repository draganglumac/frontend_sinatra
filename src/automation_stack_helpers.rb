module AutomationStackHelpers

  def check_availibility(id)
    if AutomationStack::Infrastructure::Job.count == 0
      puts "No jobs found in database"
      return 1
    end
    machine_id = AutomationStack::Infrastructure::ConnectedDevice.select(:machine_id).where(:device_id => id)
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

  def link_main_results(job_id_folder, main_result_file)
    epoch_file_map = {}
    job_id_results_path = "public/uploads/results/#{job_id_folder}" 
    if Dir.exist?(job_id_results_path)
      Dir.chdir(job_id_results_path) do
        Dir.glob("*").reverse.each do |epoch|
          Dir.chdir(epoch) do
            Dir.glob("*").each do |filename|
              href = "/uploads/results/#{job_id_folder}/#{epoch}/#{filename}"
              if (filename == main_result_file) 
                display_name = Time.at(epoch.to_i).to_datetime.strftime("%Y-%m-%d %H:%M:%S")
                epoch_file_map[epoch] = "<a href=\"#\" onclick=\"reload_iframe('#{href}');\">"\
                                            "#{display_name}<span>&nbsp;</span><i class=\"icon-chevron-right\"></i>"\
                                        "</a>"
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

    images = [/\.jpg$/, /\.jpeg$/, /\.gif$/, /\.png$/]
    images.each do |img_regex|
      if relative_file_path =~ img_regex
        return "<a href=\"#img-modal\" data-toggle=\"modal\" class=\"thumbnail\""\
                    " data-dynamic=\"true\" data-backdrop=\"false\""\
                    " onclick=\"set_modal_image_src('#{href}', '#{display_name}');\">"\
                        "<img class=\"pull-left\""\
                            " src=\"#{href}\""\
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
                  epoch_file_map[epoch] << create_link_for_supporting_result(job_id_folder, f, display_name)
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
          display_name = Time.at(epoch.to_i).to_datetime.strftime("%Y-%m-%d %H:%M:%S ") + filename
          file_list << "<a href=\"/uploads/#{folder}/#{f}\" target=\"main-content\">#{display_name}</a>"
        end
        return file_list
      end
    else
      halt 404, "Results unavailable - May not have been processed yet"
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

  def project_name_from_job_name(job_name)
    job_name.split('-')[0...-1].join("-")
  end

  def device_name_from_job_name(job_name)
    job_name.split('-').last
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
end
