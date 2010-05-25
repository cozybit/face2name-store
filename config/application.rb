require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module F2nstore
  class Application < Rails::Application

    Paperclip::Railtie.insert
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
  end
end

require "google4r/checkout"

F2N = {
  # Configure CA Certs used for signing Event Certs
  :ca_cert => Rails.root.join('lib', 'crypto', 'f2n_ca.crt'),
  :ca_key => Rails.root.join('lib', 'crypto', 'f2n_ca.key.unsecure'),

  # Configure openssl configuration template location
  :openssl_conf_tmpl => Rails.root.join('lib', 'crypto', 'openssl.cnf.tmpl'),

  # Configure keys used for encrypting Event bundles
  :encryption_key => Rails.root.join('lib', 'crypto', 'aes.key'),

  # Should we delete temporary files after creating a configuration bundle?
  :cleanup_configs => true,

  # Google Checkout merchant information
  :google_merchant_info => {
    :merchant_id => '505737408619416',
    :merchant_key => 'yyWPO3KjnNRI7JoL4pRZxw',
    :use_sandbox => true
  },

  :paperclip_info => {
    :storage => :s3,
    :s3_credentials => { :access_key_id => "1414VZ2X13XZGN9BPP02", :secret_access_key => "c1zKHGB+PLp1YUcdWg4OvpIo7sdjxZV7AkwATp7t" },
    :path => "/:attachment/:id/:style.:extension",
    :bucket => "face2name-store",
    :convert_options => { :quality => 80 }
  }
}
