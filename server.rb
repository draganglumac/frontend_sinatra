$: << "src"
require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
require 'sinatra/graph'
require 'automation_stack_helpers'
require 'analytics'
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
require "json_api"
require 'cgi'
require 'api'
include FileUtils::Verbose   
include Devices::Routes
include Machines::Routes
include ConnectedDevices::Routes
include Admin::Routes
include Jobs::Routes
include Sessions::Routes
include Results::Routes
include Api::Routes

set :port, 8091
set :bind, '0.0.0.0'
if ENV['RACK_ENV'].nil?
  set :environment, :development
end
set :public_folder, 'public'
set :views ,'views'
set :ci_url, 'http://10.65.82.93:8080'
set :action_timeout, 10

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

configure do
  set :site_alert, ''
  set :site_alert_type, 'message'
  set :maintenance_mode, 'off'
end

@@connections = []
#instantiate our database connection
#Entry page

helpers AutomationStackHelpers 

class AllButPattern
  Match = Struct.new(:captures)

  def initialize(exceptions)
    @exceptions = exceptions
    @captures = Match.new([])
  end

  def match(str)
    @exceptions.each do |except|
      if except === str
        return nil
      end
    end
    @captures
  end
end

def all_but(patterns)
  AllButPattern.new(patterns)
end

before all_but(['/maintenance', '/session', '/session/destroy']) do
  if settings.maintenance_mode == 'on' and (not can_edit? or current_user.username != 'alex.jones')
    redirect '/maintenance'
  else
    @cookies = request.cookies
    if settings.site_alert.nil? or settings.site_alert.empty?
      response.set_cookie('hide_alerts', :value => 'false')
    end
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

get '/maintenance' do
  if settings.maintenance_mode == 'on'
    #erb :maintenance, :layout => :maintenance_layout
    erb :maintenance
  else
    redirect '/'
  end
end

post '/maintenance' do
  if settings.maintenance_mode == 'off'
    settings.maintenance_mode = 'on'
  else
    settings.maintenance_mode = 'off'
  end
  redirect back
end

#resource page
get '/resources' do
  erb :installer
end
post '/upload/:id/:filename/?:bin?' do
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

      if !params[:bin].nil?
        File.open("#{Time.now.to_i}.#{fu}",'wb') do |file|
          file.write(Base64.decode64(request.body.read))
        end
      else
        File.open("#{Time.now.to_i}.#{fu}", 'w+') do |file|
          file.write(request.body.read)
        end
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
  @current_jobs = Hound.get_jobs

  @projects = {}
  @project_devices = {}
  @statuses = {}
  @last_run_times = {}
  @project_names = {}

  @current_jobs.each do |job|
    project = job['project_id']
    project_name = project_name_from_job_name(job['name'])

    @project_names[project] = project_name

    if @projects[project].nil?
      @projects[project] = [job]
    else
      @projects[project] << job
    end

    if @project_devices[project].nil?
      @project_devices[project] = [job['device_id']]
    else
      @project_devices[project] << job['device_id']
    end

    if @statuses[project].nil?
      @statuses[project] = { :completed => 0, :failed => 0, :running => 0, :pending => 0 }
    end
    increment_status_count(job['status'], @statuses[project])

    if @last_run_times[project].nil?
      @last_run_times[project] = ''
    end
    current_timestr = job['TIMESTAMP'].strftime('%A, %d-%m-%Y at %H:%M:%S') unless job['status'] == 'NOT STARTED' 
    if not current_timestr.nil? and @last_run_times[project] < current_timestr 
      @last_run_times[project] = current_timestr
    end  
  end

  @device_suggestions = create_device_suggestions_for_all_projects 

  erb :'dashboard/system'
end

#project dashboard
get '/dashboard/:id' do
  @current_jobs = Hound.get_jobs_for_project(params[:id]) 

  @projects = {}
  @project_devices = {}
  @statuses = {}
  @last_run_times = {}
  @project_names = {}

  @current_jobs.each do |job|
    project = job['project_id']
    project_name = project_name_from_job_name(job['name'])

    @project_names[project] = project_name

    if @projects[project].nil?
      @projects[project] = [job]
    else
      @projects[project] << job
    end

    if @project_devices[project].nil?
      @project_devices[project] = [job['device_id']]
    else
      @project_devices[project] << job['device_id']
    end

    if @statuses[project].nil?
      @statuses[project] = { :completed => 0, :failed => 0, :running => 0, :pending => 0 }
    end
    increment_status_count(job['status'], @statuses[project])

    if @last_run_times[project].nil?
      @last_run_times[project] = ''
    end
    current_timestr = job['TIMESTAMP'].strftime('%A, %d-%m-%Y at %H:%M:%S') unless job['status'] == 'NOT STARTED' 
    if not current_timestr.nil? and @last_run_times[project] < current_timestr 
      @last_run_times[project] = current_timestr
    end  
  end

  @devices = create_device_suggestion_for_project(params[:id]) 

  erb :'dashboard/single_project'
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

post '/alert' do
  alert = params[:site_alert].strip
  alert_style = params[:alert_type]
  puts "Setting the site-wide #{alert_style}: #{alert}"
  settings.site_alert_type = alert_style
  settings.site_alert = alert

  redirect back
end

get '/ci' do
  @status_classes = {
    'success' => 'progress-success',
    'failure' => 'progress-danger',
    'unstable' => 'progress-warning',
    'running' => 'progress-info progress-striped',
    'not_run' => '',
    'aborted' => 'progress-danger',
    'invalid' => 'progress-danger'
  }

  # @lab_projects is a hash of the following project info:
  #   proj_name => [ proj_status, proj_url_on_ci_server ]
  #
  @lab_projects = get_ci_jobs_info
  
  erb :ci
end
