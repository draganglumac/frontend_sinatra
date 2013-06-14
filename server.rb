$: << "src"
require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
require 'jobman'
require 'hound'
require 'find'  
require "logger"
require "pony"
require 'configatron' 
require 'beacon'  
require 'devices'
require 'machines'
require 'connected_devices'
require 'admin'
require 'jobs'
require 'sessions'
require 'results'
require 'dashboard'
require 'overview'
require "pry-remote"

include FileUtils::Verbose   
include Devices::Routes
include Machines::Routes
include ConnectedDevices::Routes
include Admin::Routes
include Jobs::Routes
include Sessions::Routes
include Results::Routes

set :port, 8091
set :bind, '0.0.0.0'
set :environment, :development
set :public_folder, 'public'
set :views ,'views'

enable :sessions  
configure :test,:development do
	Pony.options = {
		:via => :smtp,
		:via_options => {
		:address => '127.0.0.1',
		:port => '1025'
	}
	}
end

@@connections = []
#instantiate our database connection
#Entry page
helpers do
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
end

get '/home' do  
	redirect '/'
end

#landing page
get '/' do
	#@info = "Welcome #{request.ip}"
	Hound.add_visitor(request.ip)
	erb :home
end
#resource page
get '/resources' do
	erb :installer
end
post '/upload/:id/:filename' do
	job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
	fu = params[:filename]
	Dir.chdir("public/uploads") do
		#Take the job name and cut at the - mark 
		job_split = job.name.split('-',2)
		job_name = job_split[0]
		job_device = job_split[1]
		#subbing out the whitespace
		job_device.gsub!('/','-')
		job_path = job_name + "/" + job_device
		puts "job path #{job_path}"
		FileUtils.mkdir_p job_name
		FileUtils.mkdir_p job_path
		puts "Created job directory"
		Dir.chdir(job_path) do
			puts "Changing dir"
			File.open("#{Time.now.to_i}.#{fu}", 'w+') do |file|
				file.write(request.body.read)
			end
		end
	end
	status 200
end
#/uploads/hudsoniPhoneExample/cuke.html
post '/results/:id' do
	job_name = ""
	Hound.directquery("select name from `jobs` where id=#{params[:id]}").each do |row|
		job_name = row
	end
	puts "Job name is #{job_name['name']}"
	send_file("public/uploads/#{job_name['name']}/cuke.html")
end
#system dashboard
get '/dashboard' do
	@current_jobs=Hound.get_jobs 
	erb :dashboard
end
get '/contact' do
	erb :contact
end
post '/contact' do    

	if params[:send]
		beacon = Beacon.new
		beacon.deliver(params[:subject],params[:priority],params[:description]) 
		flash[:info] = "thank you! your request has been sent"
	else
		flash[:info] = "canceled !!"
	end

	redirect '/contact'

end
