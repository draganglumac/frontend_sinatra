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

	def partial(page, options={})
		erb page, options.merge!(:layout => false)
	end

	def link_builder(name)
		target = "public/uploads"

		Dir.chdir(target) do
			if Dir.exist?(name)
				Dir.chdir(name) do 
					Dir.glob("**").reverse.each do|f|
						epoch, filename = f.split('.', 2)
						display_name = Time.at(epoch.to_i).to_datetime.strftime("%Y-%m-%d %H:%M:%S ") + filename
						yield  "<a href=\"/uploads/#{name}/#{f}\">#{display_name}</a>"
					end
				end
			else
				halt 500, "Internal server error"
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
get '/analytics' do

	@num_visitors = Hound.get_visitors
	@num_completed_jobs = Hound.get_complete_jobs.size.to_i   
	#puts @num_completed_jobs
	@num_unstarted_jobs = Hound.get_unstarted_jobs.size.to_i   
	#puts @num_unstarted_jobs
	@num_pending_jobs = Hound.get_incomplete_jobs.size.to_i   
	erb :analytics
end

post '/upload/:id/:filename' do
	job = AutomationStack::Infrastructure::Job.find(:id => params[:id])
	fu = params[:filename]
	Dir.chdir("public/uploads") do
		Dir.mkdir job.name unless Dir.exists? job.name
		Dir.chdir("#{job.name}") do 
			puts "FILE NAME FOR SAVING IS #{fu}"
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

get '/overview' do
	
	erb :overview
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
