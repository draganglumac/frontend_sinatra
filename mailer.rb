require_relative 'server'

class Mailer
  include AutomationStackHelpers

  def process
    puts "[#{Time.new}] Processing results for emailing..."

    projects = {}
    AutomationStack::Infrastructure::Project.all.each { |p| projects[p.name] = {:email => p.email} }

    jobs_awaiting_email = AutomationStack::Infrastructure::Job.where(:email_results => true)
    queued_or_in_progress = AutomationStack::Infrastructure::Job.where(:status.like('%QUEUED%') | :status.like('%IN PROGRESS%'))

    jobs_awaiting_email.each do |job|
      project_name = project_name_from_job_name(job.name)
      if projects.keys.include?(project_name)
        project = projects[project_name]
        if project[:ready_jobs].nil?
          project[:ready_jobs] = [job]
        else
          project[:ready_jobs] << job
        end
      end
    end

    projects_with_running_jobs = []
    queued_or_in_progress.each do |job|
      project_name = project_name_from_job_name(job.name)
      if not projects_with_running_jobs.include?(project_name)
        projects_with_running_jobs << project_name
      end
    end

    send_emails(projects, projects_with_running_jobs)
    puts "Email processing done."
  end
  
  private

  def send_emails(projects, projects_with_running_jobs)
    projects.each do |proj_name, proj_hash|
      if proj_hash[:ready_jobs].nil?
        next
      end
      
      if proj_hash[:email].nil? or proj_hash[:email].empty?
        proj_hash[:ready_jobs].each do |job|
          update_processed_job(job)
        end
        next
      end

      if not projects_with_running_jobs.include?(proj_name)
        puts "Emailing #{proj_hash[:email]} with:"
        proj_hash[:ready_jobs].each do |job|
          email_snippet = format_job_for_email(job)
          puts email_snippet
          update_processed_job(job)
        end
      end 
    end
  end

  def format_job_for_email(job)
    "\t#{job.name} -> #{job.status}"
  end

  def update_processed_job(job)
    job.email_results = false
    job.save
  end

end
