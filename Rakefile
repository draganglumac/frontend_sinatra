require 'rake/testtask'

Rake::TestTask.new(:tests) do |t|
    t.test_files = FileList['tests/*_tests.rb']
    t.verbose = true
end

task :default => :tests



namespace :DB do
	desc "reset"
	task :reset  do
		path_to_rake ="../automation_stack_backend"
		`cd #{path_to_rake} && rake reset`
	end
end

desc "cukes"
task :cukes do
  system "rackup &"
  system "cucumber"
end
