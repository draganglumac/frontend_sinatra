class Message
  attr_accessor :subject,:priority,:body,:from,:to
  def initialize(log)
    @log = log
  end                  
  
  def subject=(value)
    @subject = value
  end               
  
  def subject
    "#{self.priority} - #{@subject}"
  end
  
  def deliver
    Pony.mail(:to => @to, :from => @from, :subject => subject, :body => @body)
    @log.info "message sent to #{@to} ok !"
  end
end

class Beacon 
  LOG_FILE = "tmp/beacon.log"
  CONF= "conf/beacon.conf"
  def initialize()
    @log = Logger.new(LOG_FILE)
  end
  
  def emails()
    File.read(CONF).split("\n")
  end         
  
  def deliver(subject,priority,description)                                      
    begin
      emails.each do |email|
        email_message = Message.new(@log)
        email_message.priority = priority
        email_message.subject = subject  
        email_message.body = description
        email_message.from = "noreply@automationstack.bskyb.com"
        email_message.to = email
        email_message.deliver
      end
      return true
    rescue Exception => e
      @log.info "failed to send emails because #{e.to_s}"   
      return false
    end
  end
  
end