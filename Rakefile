task :verify do
  exec "spinach"
end

require 'rake/testtask'

Rake::TestTask.new(:tests) do |t|
    t.test_files = FileList['tests/*_tests.rb']
    t.verbose = true
end

task :default => :tests