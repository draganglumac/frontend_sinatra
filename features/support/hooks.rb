Spinach.hooks.before_scenario do |scenario|
  `rm #{Beacon::LOG_FILE}` if File.exists? Beacon::LOG_FILE
  `cd ~/Desktop/sky/automation_stack/backend && rake test:db:setup`
end
