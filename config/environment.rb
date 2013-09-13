# Load the rails application
require File.expand_path('../application', __FILE__)
require File.expand_path('../../config/ssl_config', __FILE__)

# Initialize the rails application
QueryComposer::Application.initialize!

# Allow the application to send notification e-mails
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {
  :address  => "mail.mitre.org",
  :port  => 25,
  :domain => "mitre.org",
  :openssl_verify_mode => 'none'
}
ActionMailer::Base.default_url_options = {
  :host => "localhost", # TODO: This should be localhost in test.rb but a real host for production env
  :port => 3000
}
