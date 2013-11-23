get '/api/job/:id' do
	AutomationStack::Infrastructure::Job.find(:id => params[:id]).to_json	
end
get '/api/project/:name' do
	AutomationStack::Infrastructure::Project.find( :name => params[:name]).to_json
end
get '/api/project/lastrun/:name' do
	projects = AutomationStack::Infrastructure::Project.all
	
	projects.each do | s | 
	
		if s.name == params[:name]
			puts "Found project id of #{s.id}"
	
			project_jobs = 	AutomationStack::Infrastructure::Job.where(:project_id => s.id)

			res = project_jobs.sort { | x,y | (x.TIMESTAMP || nil) <=> (y.TIMESTAMP || nil) }
			return res.last.to_json
		end
	end
	
	return "UNKNOWN"
end

get '/api/project/jobs/:project_name' do
  project = AutomationStack::Infrastructure::Project.find(:name => params[:project_name])
  return "Unknown project name. If you have spaces in project name \
  make sure you replace them with + in the api URL." if project.nil?
  
  proj_id = project.id
  proj_name = project.name
  puts "proj_id = #{proj_id}"
  jobs_for_project = AutomationStack::Infrastructure::Job.where(:project_id => proj_id)
  jobs = []
  jobs_for_project.each do |job|
    job_details = {}
    job_details['id'] = job.id
    job_details['device'] = job.name.gsub("#{proj_name}-", '')
    job_details['status'] = job.status
    job_details['last_run'] = job.TIMESTAMP
    jobs << job_details
  end

  return jobs.to_json
end 
