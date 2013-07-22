require_relative 'server'
require 'pony'
require 'erb'

class Mailer
  include AutomationStackHelpers

  def initialize(ip, port, smtp_server)
    @base_url = "http://#{ip}:#{port}"
    @smtp_server = smtp_server
  end

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
        puts "\tEmailing results for #{proj_name}."
        jobs = proj_hash[:ready_jobs]
        renderer = ERB.new(File.read('views/email_template.erb'))
        email_body = renderer.result(binding)
        
        proj_hash[:ready_jobs].each do |job|
          update_processed_job(job)
        end
        
        if not @smtp_server.nil?
          Pony.mail(:to => proj_hash[:email],
                    :from => 'noreply@testlab',
                    :subject => "#{proj_name} Test Lab Run Results",
                    :html_body => email_body,
                    :via => :smtp,
                    :via_options => {
                      :address => @smtp_server
                    })
        else
          Pony.mail(:to => proj_hash[:email],
                    :from => 'noreply@testlab',
                    :subject => "#{proj_name} Test Lab Run Results",
                    :html_body => email_body,
                    :via => :sendmail
                   )
        end
      end 
    end
  end

  def format_job_for_email(job)
    Dir.chdir("public/uploads/results") do
      if Dir.glob('*').include?(job.id.to_s)
        Dir.chdir(job.id.to_s) do
          result_dirs = Dir.glob('*').sort { |x,y| y <=> x }
          if job.trigger_time <= result_dirs.first.to_i
            format_link_to_results(job)
          else
            format_link_to_dashboard(job)
          end
        end
      else
        format_link_to_dashboard(job)
      end
    end
  end

  def format_link_to_results(job)
    if job.status == 'FAILED'
      "<tr><td style=\"padding:5px\">#{job.name}</td><td style=\"padding:5px\"><a href=\"#{@base_url}/results/job/#{job.id}\" style=\"color: red\">#{job.status}</a></td></tr>\n"
    elsif job.status == 'COMPLETED'
      "<tr><td style=\"padding:5px\">#{job.name}</td><td style=\"padding:5px\"><a href=\"#{@base_url}/results/job/#{job.id}\" style=\"color: green\">#{job.status}</a></td></tr>\n"
    else
      "<tr><td style=\"padding:5px\">#{job.name}</td><td style=\"padding:5px\"><a href=\"#{@base_url}/results/job/#{job.id}\">#{job.status}</a></td></tr>\n"
    end
  end

  def format_link_to_dashboard(job)
    if job.status == 'FAILED'
      "<tr><td style=\"padding:5px\">#{job.name}</td><td style=\"padding:5px\"><a href=\"#{@base_url}/dashboard\" style=\"color: red\">#{job.status}</a></td></tr>\n"
    elsif job.status == 'COMPLETED'
      "<tr><td style=\"padding:5px\">#{job.name}</td><td style=\"padding:5px\"><a href=\"#{@base_url}/dashboard\" style=\"color: green\">#{job.status}</a></td></tr>\n"
    else
      "<tr><td style=\"padding:5px\">#{job.name}</td><td style=\"padding:5px\"><a href=\"#{@base_url}/dashboard\">#{job.status}</a></td></tr>\n"
    end
  end

  def update_processed_job(job)
    job.email_results = false
    job.save
  end

end
