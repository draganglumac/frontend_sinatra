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
    puts "ENV['RACK_ENV'] = #{ENV['RACK_ENV']}"
    if ENV['RACK_ENV'] == 'test'
      puts 'Not processing emails for test runs.'
      return
    end

    puts "[#{Time.new}] Processing results for emailing..."

    templates = {}
    AutomationStack::Infrastructure::Template.all.each do |t|
      templates[t.id] = { :project => t.project.name, :email => t.email }
    end

    jobs_awaiting_email = AutomationStack::Infrastructure::Job.where(:email_results => true)
    queued_or_in_progress = AutomationStack::Infrastructure::Job.where(:status.like('%QUEUED%') | :status.like('%IN PROGRESS%'))

    jobs_awaiting_email.each do |job|
      template_id = job.template_id
      if templates.keys.include?(template_id)
        template = templates[template_id]
        if template[:ready_jobs].nil?
          template[:ready_jobs] = [job]
        else
          template[:ready_jobs] << job
        end
      end
    end

    templates_with_running_jobs = []
    queued_or_in_progress.each do |job|
      template_id = job.template_id
      if not templates_with_running_jobs.include?(template_id)
        templates_with_running_jobs << template_id
      end
    end

    send_emails(templates, templates_with_running_jobs)
    puts "Email processing done."
  end
  
  private

  def send_emails(templates, templates_with_running_jobs)
    templates.each do |template_id, template_hash|
      if template_hash[:ready_jobs].nil?
        next
      end
      
      if template_hash[:email].nil? or template_hash[:email].empty?
        template_hash[:ready_jobs].each do |job|
          update_processed_job(job)
        end
        next
      end

      if not templates_with_running_jobs.include?(template_id)
        puts "\tEmailing results for template #{template_id}."
        jobs = template_hash[:ready_jobs]
        renderer = ERB.new(File.read('views/email_template.erb'))
        email_body = renderer.result(binding)
        
        template_hash[:ready_jobs].each do |job|
          update_processed_job(job)
        end

        proj_name = template_hash[:project] 
        if not @smtp_server.nil?
          Pony.mail(:to => template_hash[:email],
                    :from => 'noreply@testlab',
                    :subject => "#{proj_name} Test Lab Run Results",
                    :html_body => email_body,
                    :via => :smtp,
                    :via_options => {
                      :address => @smtp_server
                    })
        else
          Pony.mail(:to => template_hash[:email],
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
    return if not File.directory?("public/uploads/results")

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
