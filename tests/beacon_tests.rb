require_relative "_test_strap"

context "Beacon" do
  setup { Beacon.new } 
  context "emails" do  
    asserts("should have emails") { !topic.emails.empty? }
    asserts("should contain delaney.burke@bskyb.com") { topic.emails.include? "delaney.burke@bskyb.com"}
  end                               
  context "deliver" do                                     
    asserts("will send !") { topic.deliver("subject","low","test")}
  end
end        

context "Message" do
  setup do
    email_message = Message.new(Logger.new("tmp/message.log"))
    email_message.subject = "subject"
    email_message.priority = "low"
    email_message.body = "body"
    email_message.from = "noreply@automationstack.bskyb.com"
    email_message.to = "delaney.burke@bskb.com"
    email_message
  end
  context "deliver" do                   
    asserts("priority is in the subject"){topic.subject=="low - subject"}
    asserts("sent ok!") { topic.deliver }  
  end
end