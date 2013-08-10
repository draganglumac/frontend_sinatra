require 'mysql2' 
require "sequel"
require 'sequel-json'
require 'yaml'
require_relative './mysql'
require_relative './model'
module Analytics
	class Project
		attr_accessor :jobs, :name,:id, :main_result_file, :email
		def initialize(name,id,main_result_file,email)
			@name = name
			@jobs = []
			@id = id
			@main_result_file = main_result_file
			@email = email
		end
		def get_nodes_used 
			nodes = []
			@jobs.each do | job |
				nodes << job.machine_id
			end
			return nodes
		end
		def get_last_job_run
			candidate_job = 0
			@jobs.each do | job |
				current_time = Time.now.to_i
			diff = job.trigger_time - current_time
			if candidate_job == 0 
				candidate_job = job
			else
				if candidate_job.trigger_time - current_time < diff
					candidate_job = job
				end
			end
			#Note that any negative diff will mean in the past, so regardless we always want the highest number
			end	
			return candidate_job
		end
	end
	class Parser
		attr_accessor :projects
		def create_objects
			@projects = []
			AutomationStack::Infrastructure::Project.all.each do | p |
				current_project = Project.new(p.name,p.id,p.main_result_file,p.email)
			AutomationStack::Infrastructure::Job.all.each do | j |
				if j.name.split('-')[0] == p.name
					current_project.jobs << j
				end
			end	
			@projects << current_project
			end
		end
		def initialize
			create_objects
		end
	end
end


p = Analytics::Parser.new
p.projects.each do | a |
	puts "Found project #{a.name}"
puts "Last job run was #{a.get_last_job_run.name}" 
end


graph "projects", :prefix => '/graphs', :type => 'pie' do

	p = Analytics::Parser.new
	proj = Hash.new(0)
	p.projects.each do | p |
	proj[p.name] = p.jobs.length
	end
	pie "projects", proj
end
graph "visitors", :prefix => '/graphs', :type => 'pie'  do

	visitor_ips = AutomationStack::Infrastructure::Analytics.all
	ip = []
	visitor_ips.each do | s |
		ip << s.IP
	end	
	b = Hash.new(0)
	ip.each do | v| 
	b[v] += 1
	end
	pie "Hits", b
end
graph "jobs", :prefix => '/graphs', :type => 'pie' do

	jobs = AutomationStack::Infrastructure::Job.all

	ajobs = []
	jobs.each do | s|
	ajobs << s.name.split("-")[0]
	end
	b = Hash.new(0)
	ajobs.each do | v| 
	b[v] += 1
	end
	pie "Runs",b
end
get '/analytics' do
	erb :analytics
end
