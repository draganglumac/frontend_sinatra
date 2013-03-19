require 'rake/testtask'

Rake::TestTask.new(:tests) do |t|
    t.test_files = FileList['tests/*_tests.rb']
    t.verbose = true
end

task :default => :tests



namespace :DB do
	desc "reset"
	task :reset  do
		path_to_rake ="../backend"
		`cd #{path_to_rake} && rake reset`
	end
end
