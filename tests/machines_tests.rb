require_relative "_test_strap"

context "Automation Stack" do
	context "ui" do
	  context "machines" do

	  	context "list" do
	  	  setup { get "/" }
	  	  asserts("has list"){topic.ok?}
	  	end
	    context "Add" do
	      setup { post '/machines',params={:call_sign => "iceman", :ip_address => "127.0.0.1", :platform_id => "1"}}
	      asserts("new job should exist") do
	      	page = follow_redirect!
			page.body.include? "Machine Callsign"
	      	
	      end
	    end
	     
	  end
	end
end