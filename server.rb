
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


require "pry-remote"

include FileUtils::Verbose   
include Devices::Routes
include Machines::Routes
include ConnectedDevices::Routes

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

    def protected!
        unless authorized?
            response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
            throw(:halt, [401, "<link rel='stylesheet' href='css/bootstrap.css' type='text/css' /> <form method=get' action='/home'>
    <input type='submit' value='Home admin' name='home_button' id='home_button' title='Homer' class='buttoncss' />
    </form><h2>Not authorized</h2>\n"])
        end
        session["is_admin"] = true;
    end

    def can_edit?
        session["is_admin"] == true;
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
#admin panel
get '/admin' do
    protected!
    @admin_pending_jobs = Hound.get_jobs
    @machines  = AutomationStack::Infrastructure::Machine.all
    erb :admin
end

get '/admin/getapp/:file' do |file|
    puts "you requested #{params[:file]}"
    file = File.join('public/', file)
    send_file(file, :disposition => 'attachment', :filename => File.basename(file))
end


delete '/admin/delete/jobs/:id' do
    id = params[:id]
    Hound.remove_job(id);
    @machine_available = Hound.get_machines
    @admin_pending_jobs = Hound.get_jobs
    redirect '/admin'
end
post '/admin' do
  Hound.add_machine(params)
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
    @machines  = AutomationStack::Infrastructure::Machine.all
    @jobs_done = Hound.get_jobs
    erb :jobs
end
#Posting new job
post '/job' do
    if params[:file].nil?
        @error = "<p style='color:red;'>Need input file</p>"    
        puts "NO FILE"
        redirect '/job'
    end
    tempfile = params[:file][:tempfile] 
    filename = params[:file][:filename] 
    cp(tempfile.path, "public/uploads/#{filename}")
    string = File.open(tempfile.path, 'rb') { |file| file.read }
    #puts string
    #machine_num = params[:machine_id].split("machine_id")

    #There is a difference here between ruby versions, be aware
      machine_num = params[:machine_id]
    #'dd/MM/yyyy hh:mm:ss'
    trigger = params[:ltrigger] 
    trigger << ".000000"
    trigger = Time.parse(trigger).to_i
    puts "JOB NAME #{params[:lname]}"
    puts "MACHINE NUMBER #{machine_num}"
    puts "OUTPUT STRING IS #{string}"
    puts "TRIGGER TIME IS #{trigger}"
    
    Hound.add_job(machine_num,params[:lname],string,trigger)
    redirect '/job'
end
post '/job/restart/:jobnum' do
    Hound.set_job_restart(params[:jobnum])
    redirect '/'
end
#view machine page
get '/machines' do                              
  devices = Devices::Repository.new
  @machines = Machines::Repository.new(devices)
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