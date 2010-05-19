# Load the rails application
require File.expand_path('../application', __FILE__)

F2N = {
  # Configure CA Certs used for signing Event Certs
  :ca_cert => Rails.root.join('lib', 'crypto', 'f2n_ca.crt'),
  :ca_key => Rails.root.join('lib', 'crypto', 'f2n_ca.key.unsecure'),

  # Configure openssl configuration template location
  :openssl_conf_tmpl => Rails.root.join('lib', 'crypto', 'openssl.cnf.tmpl'),

  # Configure keys used for encrypting Event bundles
  :encryption_key => Rails.root.join('lib', 'crypto', 'aes.key'),
  
  # Google Checkout merchant information
  :google_merchant_info => {
    :merchant_id => '505737408619416',
    :merchant_key => 'yyWPO3KjnNRI7JoL4pRZxw',
    :use_sandbox => true
  }
}

# Initialize the rails application
F2nstore::Application.initialize!
