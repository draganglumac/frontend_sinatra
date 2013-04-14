module Dashboard
    
    module Routes
        
        post '/dashboard/job/restart/:jobnum' do
            Hound.set_job_restart(params[:jobnum])
            redirect back
        end

    end

end
