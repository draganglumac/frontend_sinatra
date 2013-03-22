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

desc "Task description"
task :task_name => [:dependent, :tasks] do

end
desc "cukes"
task :cukes => ["DB:reset"]do
    `mailcatcher`
    system "rackup &"
    system "cucumber"
end
