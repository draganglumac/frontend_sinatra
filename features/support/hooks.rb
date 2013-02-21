Spinach.hooks.before_scenario do |scenario|
  `rm #{Beacon::LOG_FILE}`
  system "cd ~/Desktop/sky/automation_stack/backend && rake test:db:setup"
end
