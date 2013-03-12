require_relative "_test_strap"

context "AutomationStack" do
  context "session" do
  	context "valid username and password" do
  	  setup  { post '/session',params={:username => "delaney.burke", :password => "sky"}}
  	  asserts("valid username and password redirects") do  	  	
  	  	topic.status == 302 and !topic.location.include? "login=failed"
  	  end
  	end

  	context "invalid username and password" do
  		context "password" do
  			setup { post '/session',params={:username => "delaney.burke", :password => "invalid"}}
  			asserts("invalid password") { topic.status == 302 and topic.location.include? "login=failed" }
  		end
  		
  		context "username" do
  		  setup { post '/session',params={:username => "invalid", :password => "sky"}}
  		  asserts("invalid password") { topic.status == 302 and topic.location.include? "login=failed" }
  		end
  		

  	end
  	
  end
  
end