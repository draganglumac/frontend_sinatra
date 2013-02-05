Spinach.hooks.before_scenario do |scenario|
  `rm features/ui.log`
end
