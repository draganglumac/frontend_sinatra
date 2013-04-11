module Dashboard
    
    module Routes
        
        post '/dashboard/job/restart/:jobnum' do
            puts ">>>hi from /dashboard/job/restart/#{params[:jobnum]}<<<"
            Hound.set_job_restart(params[:jobnum])
            redirect '/dashboard'
        end

    end

end
