$: << "src"

require 'bundler/setup'
require 'sinatra'

require 'jobman'
require 'hound'
require 'find'
include FileUtils::Verbose

#set :port, 8091
#set :bind, '0.0.0.0'
#set :environment, :development
set :public_folder, 'public'
set :views ,'views'   
                           
                      

before do
  env['rack.logger'] = Logger.new("features/ui.log") if ENV['RACK_ENV']=="test"
end


@@connections = []
#instantiate our database connection
#Entry page

helpers do
	def protected!
		unless authorized?
			response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
			throw(:halt, [401, "<link rel='stylesheet' href='css/bootstrap.css' type='text/css' /> <form method=get' action='/home'>
	<input type='submit' value='Home admin' name='home_button' id='home_button' title='Homer' class='buttoncss' />
	</form><h2>Not authorized</h2>\n"])
		end
	end
	def authorized?
		@auth ||=  Rack::Auth::Basic::Request.new(request.env)
		@auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['dummy', 'dummy']
	end
	def get_files(path)
		dir_array = Array.new
		Find.find(path) do |f|
			dir_array << File.basename(f, ".*")
		end
		return dir_array
	end  
end
#admin panel
get '/admin' do
	protected!
	@admin_pending_jobs = Hound.get_jobs
	@machine_available = Hound.get_machines
	erb :admin
end

get '/admin/getapp/:file' do |file|
	puts "you requested #{params[:file]}"
	file = File.join('public/', file)
	send_file(file, :disposition => 'attachment', :filename => File.basename(file))
end

delete '/admin/delete/:id' do
	Hound.remove_machine(params[:id])
	@machine_available = Hound.get_machines
	redirect '/admin'
end

delete '/admin/delete/jobs/:id' do
	id = params[:id]
	Hound.remove_job(id);
	@machine_available = Hound.get_machines
	@admin_pending_jobs = Hound.get_jobs
	redirect '/admin'
end
post '/admin' do

	#I would like to make a note that I am not happy with this current method of capturing and sending to SQL. It is very difficult to expand upon and will be extremely brittle"
	puts params[:post]

	@iphone4 = 0
	@iphone4s = 0
	@iphone5 = 0
	@ipadmini = 0
	@ipad4 = 0

	if(params[:post][:iphone4_check])
		@iphone4 = 1
	end
	if(params[:post][:iphone4s_check])
		@iphone4s = 1
	end
	if(params[:post][:iphone5_check])
		@iphone5 = 1
	end
	if(params[:post][:ipadmini_check])
		@ipadmini = 1
	end
	if(params[:post][:ipad4_check])
		@ipad4 = 1
	end

	puts "OUTPUT -> #{params[:post][:callsign_form]}"
	puts "OUTPUT -> #{params[:post][:machine_ip_form]}"
	puts "OUTPUT -> #{params[:post][:supported_platforms]}"

	Hound.add_machines_long(params[:post][:callsign_form],params[:post][:machine_ip_form],params[:post][:supported_platforms],@iphone4,@iphone4s,@iphone5,@ipadmini,@ipad4)



	#Hound.add_machine(params[:post])
	@admin_pending_jobs = Hound.get_jobs
	@machine_available = Hound.get_machines
	erb :admin
end
#admin delete sqldb_butto
post '/admin/sql/delete' do
	Hound.purgedb
end
get '/home' do  
	redirect '/'
end
post '/admin/results/delete' do
	Hound.truncate_results
	redirect '/admin'
end
post '/admin/jobs/delete' do
	Hound.truncate_jobs
	redirect '/admin'
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
#new job page
get '/job' do
	@machine_available = Hound.getmachineids
	@jobs_done = Hound.get_jobs
	erb :jobs
end
#Posting new job
post '/job' do
	if params[:file].nil?
		@error = "<p style='color:red;'>Need input file</p>"
		@machine_available = Hound.getmachineids
		return erb :jobs
	end
	tempfile = params[:file][:tempfile] 
	filename = params[:file][:filename] 
	cp(tempfile.path, "public/uploads/#{filename}")
	string = File.open(tempfile.path, 'rb') { |file| file.read }
	puts string
	#machine_num = params[:machine_id].split("machine_id")

	#There is a difference here between ruby versions, be aware
	machine_num = params[:machine_id]

	puts "MACHINE NUMBER #{machine_num}"
	Hound.add_job(machine_num,params[:lname],string)
	redirect '/job'
end
post '/job/restart/:jobnum' do
	Hound.set_job_restart(params[:jobnum])
	redirect '/'
end
#view machine page
get '/machines' do
	@machine_available = Hound.get_machines
	erb :machines
end
#results page
get '/results' do
	@time = Time.new.inspect
	@results = Hound.get_results
	erb :results
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
put '/upload/:dir/:id' do
	puts "UPLOADING"
	cwd = Dir.pwd
	puts "Current working directory #{cwd}"
	Dir.chdir("public/uploads")
	nwd = Dir.pwd
	puts "Switched directory to #{nwd}"
	directory_name = params[:dir]
	Dir.mkdir(directory_name) unless File.exists?(directory_name)
	Dir.chdir(directory_name)
	nwd = Dir.pwd
	#we are using cuke.html as our default naming convention for files...
	#This isn't something that is sustainable but is used currently
	#so that results has something it can look for when it builds the path
	puts "Switched into project directory #{nwd}"
	File.open(params[:id], 'w+') do |file|
		file.write(request.body.read)
	end
	Dir.chdir(cwd)
	puts "Lets now update the results table to set it to completed..."
	Hound.set_result(params[:dir  ],"PASS","timeplaceholder")
end
#/uploads/hudsoniPhoneExample/cuke.html
post '/results/:id' do
	job_name = ""
	Hound.directquery("select name from `AUTOMATION`.`jobs` where id=#{params[:id]}").each do |row|
		#Just FYI, this select should only ever return 1 entry but its a hash so has to be enumerated as direct key purchase doesn't seem to do anything... though my ruby is pretty awful'
		job_name = row
	end
	puts "Job name is #{job_name['name']}"
	send_file("public/uploads/#{job_name['name']}/cuke.html")
end 


get '/contact' do
	erb :contact
end

post '/contact' do
  ["delaney.burke@bsky.com","alex.jones@bskyb.com"].each do |email|
    
    logger.info "email sent to #{email} ok !"
  end
end
