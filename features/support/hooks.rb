Spinach.hooks.before_scenario do |scenario|
  `rm #{Beacon::LOG_FILE}`
end
