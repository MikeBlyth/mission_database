SIM::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Enable livereload (https://github.com/johnbintz/rack-livereload) 
#  config.middleware.insert_before(Rack::Lock, Rack::LiveReload)

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  #
  config.colorize_logging = true

  # autoload everything in the /lib path  
  config.autoload_paths += %W(#{Rails.root}/lib)

  #**********************
  # ACTION MAILER
  #***********************
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
# config.action_mailer.delivery_method = :smtp | :sendmail | :test  
  config.action_mailer.delivery_method = :test

end

