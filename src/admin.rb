module Admin
    module Routes
        #admin panel
get '/admin' do
    
end

get '/admin/getapp/:file' do |file|
    puts "you requested #{params[:file]}"
    file = File.join('public/', file)
    send_file(file, :disposition => 'attachment', :filename => File.basename(file))
end

get '/signout' do
  session["is_admin"] = nil
  redirect "/"
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
post '/admin/results/delete' do
    Hound.truncate_results
    redirect '/admin'
end
post '/admin/jobs/delete' do
    Hound.truncate_jobs
    redirect '/admin'
end
    end
end