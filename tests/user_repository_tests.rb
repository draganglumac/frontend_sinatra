require_relative "_test_strap"

context "UserRepository" do
  context "get_by_username_and_password" do
  	context "with valid username and password" do
      context "username: delaney .burke and password: sky" do
        setup {Sessions::UserRepository.get_by_username_and_password "delaney.burke","sky"}
        asserts("is a User") { topic.is_a? Sessions::User}
        asserts("username is correctly set"){topic.username =="delaney.burke"}    
      end
  		
      context "username: alex.jones password: sky" do
        setup {Sessions::UserRepository.get_by_username_and_password "alex.jones","sky"}
        asserts("is a User") { topic.is_a? Sessions::User}
        asserts("username is correctly set"){topic.username =="alex.jones"}    
      end
      
  	end

  	context "with invalid username and password" do
  		setup {Sessions::UserRepository.get_by_username_and_password "delaney.burke","invalid"}
  		asserts_topic.nil
  	end
  	
  end
end