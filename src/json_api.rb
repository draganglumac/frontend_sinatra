#get information about a particular job
get '/api/job/:id' do
	job_id = params[:id]
	AutomationStack::Infrastructure::Job.find(:id => params[:id]).to_json	
end

#TODO
#Start job
#Stop job
#Delete job

#get results
