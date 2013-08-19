require 'rake/testtask'
require 'pry'

Rake::TestTask.new(:tests) do |t|
    t.test_files = FileList['tests/*_tests.rb']
    t.verbose = true
end

task :default => :tests



namespace :db do
    desc "reset"

    `if [ -d automation_stack_backend ]; then rm -rf automation_stack_backend; fi`
    `git clone git@github.com:draganglumac/automation_stack_backend.git`
    `cp features/supported/settings.yaml ./automation_stack_backend/`
    `pushd automation_stack_backend; ./build_and_install.sh; popd;`

    task :reset  do
        path_to_rake ="automation_stack_backend"
        `cd #{path_to_rake} && rake reset_frontend`
    end
end

desc "Task description"
task :task_name => [:dependent, :tasks] do

end


namespace :cukes do
 
desc "all"
task :all => ["db:reset"]do
    `mailcatcher`
    system "./sinatra_control"
    system "cucumber --tags ~@wip"
end

task :wip => ["db:reset"]do
    `mailcatcher`
    system "./sinatra_control"
    system "cucumber --tags @wip"
end

end

