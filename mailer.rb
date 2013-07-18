require_relative 'src/model'

class Mailer

  def process
    jobs = AutomationStack::Infrastructure::Job.all
    puts "job.id, job.name, job.email_results"
    
    jobs.each do |job|
      puts "#{job.id}, #{job.name}, #{job.email_results}"
    end
    puts ""
  end

end
