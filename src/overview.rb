module Overview

	module Routes

    before do
      @cookies = request.cookies
    end

    get '/overview' do
      @y_pos = @cookies['overview_y_pos']
			@machines = AutomationStack::Infrastructure::Machine.all
      @active_jobs = {}
      jobs = AutomationStack::Infrastructure::Job.all
      jobs.each do |job|
        if job.status == 'IN PROGRESS' or job.status == 'QUEUED'
          machine_id = job.machine_id
      text = "#{job.name} - #{job.status}"
          entry = "<a href=\"/job/#{job.id}\" class=\""
          if job.status == 'IN PROGRESS'
            entry += 'text-info'
          else
            entry += 'text-warning'
          end            
          entry += "\" style=\"white-space: nowrap; overflow: hidden; text-overflow: ellipsis; -o-text-overflow: ellipsis;\" data-toggle=\"tooltip\" title=\"#{text}\" onclick=\"$('#link#{job.id}').click();\">#{text}</a>"

          if @active_jobs[machine_id].nil?
            @active_jobs[machine_id] = [entry]
          else
            if job.status == 'IN PROGRESS'
              @active_jobs[machine_id].unshift entry
            else
              @active_jobs[machine_id] << entry
            end
          end
        end
      end

			erb :overview
		end
	end
end
