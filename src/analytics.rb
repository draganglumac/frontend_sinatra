
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
