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
