$: << "src"
require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
require 'automation_stack_helpers'
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

helpers AutomationStackHelpers 

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
  if request.cookies['uncle'].nil?
    response.set_cookie "uncle", "Bob"
    @uncle = "Bob"
  else
    @uncle = request.cookies['uncle']
  end

  @current_jobs = Hound.get_jobs
  @projects = {}
  @current_jobs.each do |job|
    project = job['name'].split('-').first
    if @projects[project].nil?
      @projects[project] = [job]
    else
      @projects[project] << job
    end 
  end 
  
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

post '/refresh' do
  # Need this ugly flag for should_autorefresh? helper, which is called 
  # from ERB files. I couldn't find a way of nicely initialising 
  # session[:autorefresh] flag to true. Tried the before method, 
  # but Sinatra seems to create session[:autorefresh] flag even before
  # I first refer to it in code (I imagine while it's processing routes)
  # so I couldn't test for flag being nil? and set it to global setting
  # or anything similarly elegant. Might have to investigate it further.
  session[:toggled_already] = true

  if params[:auto_refresh] == 'true'
    session[:autorefresh] = true
  else
    session[:autorefresh] = false
  end

  redirect params[:redirect_url]
end
