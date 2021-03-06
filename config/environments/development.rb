F2nstore::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
#  config.action_mailer.delivery_method = :smtp
#  config.action_mailer.smtp_settings = {
#      :address => "smtp.carbonfive.com",
#      :port => 25,
#      :enable_starttls_auto => false
#  }

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

end

%w"/usr/bin /opt/local/bin /usr/local/bin".each do |dir|
  Paperclip.options[:command_path] = dir if File.exist?(File.join(dir, 'identify'))
end

F2N.deep_merge!({
  :cleanup_configs => false
})
