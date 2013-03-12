require_relative "_test_strap"

context "AutomationStack" do
	context "jobs" do
	  context "list" do
	    setup { get "/job" }
	    asserts("is on jobs page") { topic.body.include? "Current jobs"}
	  end

	  context "add job" do
	  setup { post "/job",params={"file_source" => Rack::Test::UploadedFile.new("/Users/cococoder/Desktop/sky/example.conf", "application/octet-stream"),:lname => "test", :ltrigger => "12/03/2013 07:07:27.000000", :machine_id => "1","is_private" => "0"} }
	  asserts("can add job") { topic.redirect?}
	  end
	end


end