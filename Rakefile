require 'rake/testtask'
require 'pry'

Rake::TestTask.new(:tests) do |t|
    t.test_files = FileList['tests/*_tests.rb']
    t.verbose = true
end

task :default => :tests



namespace :db do
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
task :cukes => ["db:reset"]do
    `mailcatcher`
    system "./sinatra_control"
    system "cucumber --tags ~@coco"
end
