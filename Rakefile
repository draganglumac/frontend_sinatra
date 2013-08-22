task :default => [:setup, "cukes:all", :teardown]

task :setup do
  `if [ -d automation_stack_backend ]; then rm -rf automation_stack_backend; fi`
  `git clone git@github.com:draganglumac/automation_stack_backend.git`
  `pushd automation_stack_backend; ./build_and_install.sh 127.0.0.1 AUTOMATION dummy dummy test; popd;`
  system "./sinatra_control restart"
end

task :teardown do
  system "./sinatra_control stop"
  `if [ -d automation_stack_backend ]; then rm -rf automation_stack_backend; fi`
end

namespace :cukes do
  desc "all"
  
  task :all do
    `mailcatcher`
#    system "cucumber features/login.feature features/contact_us.feature features/connect_device.feature"
    system "cucumber features/login.feature"
  end
  
  task :wip => ["db:reset"]do
    `mailcatcher`
    system "cucumber --tags @wip"
  end
end

namespace :db do
   desc "reset"

   task :reset  do
        path_to_rake ="automation_stack_backend"
        `cd #{path_to_rake} && rake reset_frontend`
   end
end

