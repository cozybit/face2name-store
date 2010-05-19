F2nstore::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
end

F2N.merge!({
  # Configure CA Certs used for signing Event Certs
  :ca_cert => Rails.root.join('test', 'resources', 'crypto', 'ca.cert'),
  :ca_key => Rails.root.join('test', 'resources', 'crypto', 'ca.key'),

  # Configure keys used for encrypting Event bundles
  :encryption_key => Rails.root.join('test', 'resources', 'crypto', 'aes.key'),

  # Configure path to f2n_cipher and it's associated resources
  :f2n_cipher_root => Rails.root.join('test', 'resources', 'f2n-cipher-1.0.0'),

  # Configure path to keys for rudimentary PK encryption testing
  :test_public_key => Rails.root.join('test', 'resources', 'crypto', 'public.pem'),
  :test_private_key => Rails.root.join('test', 'resources', 'crypto', 'private.pem'),
})